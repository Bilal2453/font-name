-- A decoder and parser for the Name record of
-- SFNT-housed fonts such as TrueType and OpenType

local unpack = assert(string.unpack, 'string.unpack is unavailable')
local constants = require('libs.constants')

local magic_number = constants.magic_numbers.sfnt
local name_record_names = constants.record_code_name
local platform_id = constants.platform_name_id

---@alias fontmeta.alias.OffsetSubtle {scaler_type: integer, num_tables: integer, search_range: integer, entry_selector: integer, range_shift: integer}
---@alias fontmeta.alias.TableDirectoryTag {checksum: integer, offset: integer, length: integer, order: integer}
---@alias fontmeta.alias.TableDirectory {[string]: fontmeta.alias.TableDirectoryTag}
---@alias fontmeta.alias.NameTableFormat
---| 0 # Always 0 for TrueType, OpenType accept it as well. See [OpenType Name Table Version 0](https://learn.microsoft.com/en-us/typography/opentype/spec/name#naming-table-version-0).
---| 1 # Can only be 1 for OpenType. See [OpenType Name Table Version 1](https://learn.microsoft.com/en-us/typography/opentype/spec/name#naming-table-version-1).
---| integer
---@alias fontmeta.alias.Name {platform_id: integer, encoding_id: integer, language_id: integer, name_id: integer, length: integer, offset: integer, string: string}
---@alias fontmeta.alias.NameRecord fontmeta.alias.Name[]
---@alias fontmeta.alias.LangTag {length: integer, lang_tag_offset: integer}
---@alias fontmeta.alias.LangTagRecord fontmeta.alias.LangTag[]
---@alias fontmeta.alias.NameTable {format: fontmeta.alias.NameTableFormat, count: integer, string_offset: integer, name_record: fontmeta.alias.NameRecord, lang_tag_count: integer?, lang_tag_record: fontmeta.alias.LangTagRecord?}

---Parse and decode the offset subtable, part of the first table in a TrueType file.
---@param data string										# The binary data to decode the table from.
---@return fontmeta.alias.OffsetSubtle	# The parsed offset subtle structure as a table.
---@return integer offset								# The new position after the parsing.
local function decodeOffsetSubtable(data)
	local scaler_type, num_tables, search_range, entry_selector, range_shift, offset = unpack(">I4I2I2I2I2", data)
	return {
		scaler_type = scaler_type,
		num_tables = num_tables,
		search_range = search_range,
		entry_selector = entry_selector,
		range_shift = range_shift,
	}, offset --[[@as integer]]
end

---Parse and decode a [Table Directory](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6.html).
---@param data string         						# The binary data to decode the table from.
---@param offset? integer     						# The offest to seek by and start decoding the table at.
---@param num_tables integer  						# The number of entries in the table to expect.
---@return fontmeta.alias.TableDirectory	# A table where the key is the tag name and the value is the entry.
---@return integer offset									# The new position after the parsing.
local function decodeTableDirectory(data, offset, num_tables)
	local entries = {}
	for i = 1, num_tables do
		local tag, checksum, tbl_offset, length, new_offset = unpack(">c4I4I4I4", data, offset)
		entries[tag] = {
			checksum = checksum,
			offset = tbl_offset,
			length = length,
			order = i,
		}
		offset = new_offset
	end
	return entries, offset --[[@as integer]]
end

---Parse and decode a [Font Directory](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6.html)
---(the first table in a SFNT structure).
---@param data string																			# The binary data to parse.
---@return fontmeta.alias.OffsetSubtle offset_subtable		# The Offset Subtable.
---@return fontmeta.alias.TableDirectory table_directory	# The Table Directory.
---@return integer offset																	# The new position after the parsing.
local function decodeFontDirectory(data)
	local subtable, table_dir, offset
	subtable, offset = decodeOffsetSubtable(data)
	table_dir, offset = decodeTableDirectory(data, offset, subtable.num_tables)
	return subtable, table_dir, offset
end

---Parse and decode the [Name Table](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6name.html).
---@param data string								# The binary data to decode the table from.
---@param offset integer						# The offest to seek by and start decoding the table at.
---@return fontmeta.alias.NameTable # The parsed Name Table as a table.
local function decodeNameTable(data, offset)
	-- decode the header
	local format, count, string_offset, x_offset = unpack(">I2I2I2", data, offset + 1)
	local base_offset = offset + string_offset

	assert(format == 0 or format == 1, 'Name Table format is unrecognized')

	-- decode the name record
	local name_record = {}
	for i = 1, count do
		local platform_id,
			encoding_id,
			language_id,
			name_id,
			length,
			name_offset,
			new_offset = unpack(">I2I2I2I2I2I2", data, x_offset)

		x_offset = new_offset
		name_record[i] = {
			encoding_id = encoding_id,
			platform_id = platform_id,
			language_id = language_id,
			name_id = name_id,
			offset = name_offset,
			length = length,
			string = data:sub(base_offset + name_offset + 1, base_offset + name_offset + length),
		}
	end

	-- decode language record if format is 1 (OpenType only)
	-- TODO: test otf fonts with format 1; not tested at all
	local lang_tag_count, lang_tag_record
	if format == 1 then
		lang_tag_count, x_offset = unpack('>I2', data, x_offset)
		lang_tag_record = {}
		for i = 1, lang_tag_count do
			local length, lang_tag_offset, new_offset = unpack('>I2I2', data, x_offset)
			x_offset = new_offset
			lang_tag_record[i] = {
				length = length,
				lang_tag_offset = lang_tag_count,
				string = data:sub(base_offset + lang_tag_offset + 1, base_offset + lang_tag_offset + length),
			}
		end
	end

	return {
		format = format,
		count = count,
		string_offset = string_offset,
		name_record = name_record,
		lang_tag_count = lang_tag_count,
		lang_tag_record = lang_tag_record,
		name = data:sub(
			base_offset + 1,
			base_offset + (name_record[#name_record].offset + name_record[#name_record].length)
		),
	}
end


---Given a TrueType/OpenType file (as a string), parse the Name Table and return it.
---
--- - If the data given is not a valid TrueType/OpenType this function *may* raise an error.
--- - If the font does not contain a `name` table, it is not a valid TrueType/OpenType font and an error *will* be raised.
---@param data string
---@return fontmeta.alias.NameTable
local function decodeMeta(data)
	local _, table_dir = decodeFontDirectory(data)
	assert(table_dir.name, 'data does not contain a name table')
	return decodeNameTable(data, table_dir.name.offset)
end


---Returns whether the magic number matches TrueType/OpenType or not.
---If it is true, return a second value representing which format of the two it is.
---
---Note: A `true` return does not imply
---that this is necessarily a *valid* TrueType/OpenType font.
---@param data string
---@return boolean, "truetype"|"opentype"|nil
---@nodiscard
local function getFormat(data)
	local number = decodeOffsetSubtable(data).scaler_type
	return magic_number[number] and true, magic_number[number]
end

-- TODO: abstract lang_tag_record

local function defaultRecords(platforms)
	local platform, languages, records
	if platforms[platform_id.unicode] then
		platform = platforms[platform_id.unicode]
		languages = platform[constants.unicode_encoding_id.unicode_2_0_full] or select(2, next(platform))
		records = select(2, next(languages))
	elseif platforms[platform_id.macintosh] then
		platform = platforms[platform_id.macintosh]
		languages = platform[constants.macintosh_encoding_id.roman] or select(2, next(platform))
		records = languages[constants.macintosh_language_id.english] or select(2, next(languages))
	else -- this is worst scenario, user has to deal with utf16
		-- windows was a mistake windows was a mistake windows was a mistake
		platform = platforms[platform_id.windows]
		languages = platform[constants.windows_encoding_id.symbol] or select(2, next(platform))
		records = languages[constants.windows_language_id['en-us']] or select(2, next(languages))
	end
	return records
end

local function resolveRecordsMap(name_record)
	local platforms = {}
	for _, record in ipairs(name_record) do
		local key = name_record_names[record.name_id]
		if key then
			local plat_id = record.platform_id
			local enc_id  = record.encoding_id
			local lang_id = record.language_id
			-- add the record to platforms[PLATFORM_ID][ENCODING_ID][LANGUAGE_ID]
			-- whether the platform id is unicode or not
			if not platforms[plat_id] then
				platforms[plat_id] = {}
			end
			if not platforms[plat_id][enc_id] then
				platforms[plat_id][enc_id] = {}
			end
			if not platforms[plat_id][enc_id][lang_id] then
				platforms[plat_id][enc_id][lang_id] = {}
			end
			platforms[plat_id][enc_id][lang_id][key] = record.string
		end
	end
	return platforms
end

---Given a decoded SFNT structure (returned by `decodeMeta`),
---return a FontMeta structure.
---
---This is intended to be used by the library internals
---to initialize a FontMeta class instance.
---@private
---@param decoded_font fontmeta.alias.NameTable
local function fontMetaStruct(decoded_font)
	-- resolve name records into tables under structure
	-- platforms[PLATFORM_ID][ENCODING_ID][LANGUAGE_ID]
	local platforms = resolveRecordsMap(decoded_font.name_record)
	-- expose the records as a metatable to make it easier
	-- to swap out a platform for another. by default pick
	-- something sane (ie not Windows UTF16 shenanigans)
	local meta = {platforms = platforms}
	local records = defaultRecords(platforms)
	setmetatable(meta, {
		__index = records
	})

	-- additional properties for user-friendliness
	meta.name = meta.typographic_family_name or meta.family_name
	if meta.version_string then
		meta.version = {
			major = tonumber(meta.version_string:match('^%D*(%d+)')),
			minor = tonumber(meta.version_string:match('^%D*%d+%.(%d+)')),
		}
	end
	meta.style = meta.typographic_subfamily_name or meta.subfamily_name

	return meta
end

return {
	decodeOffsetSubtable = decodeOffsetSubtable,
	decodeTableDirectory = decodeTableDirectory,
	decodeFontDirectory = decodeFontDirectory,
	decodeNameTable = decodeNameTable,
	decodeMeta = decodeMeta,

	-- public standard interface
	fontMetaStruct = fontMetaStruct,
	decode = decodeMeta, 		   	-- main decoder
	getMagicNumber = getFormat, -- does magic number match?

	magic_number = magic_number
}
