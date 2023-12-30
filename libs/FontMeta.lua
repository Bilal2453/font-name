-- A class that contains the metainfo of a loaded font,
-- such as the font's name, styles and description,
-- possibly in multiple languages.
---@class fontmeta.FontMeta
-- The cached return of `getPlatforms`.
---@field private _platforms table?
-- The cached return of `getLanguages`.
---@field private _languages table?
-- A table that hold a copy of the raw data of the metainfo.
---@field platforms {[integer]: table?}
-- The font's family name. Such as `Arial`.
--
-- The method used to determin the name follows what the
-- OpenType specification recommends, and that is checking
-- if the `typographic_family_name` record is provided by
-- the font, if it's provided its value is used otherwise
-- (e.x. in legacy fonts) the value of `family_name` is used.
-- The two records are often identical but that
-- isn't necessarily true. There are restrictions on
-- `family_name` that don't apply on `typographic_family_name`.
---@field name string
-- The Font's version parsed into `major.minor`.
-- See also `FontMeta.version_string`.
---@field version {major: integer, minor: integer}
-- The font's subfamily name, also referred to as the style.
-- Such as `bold`, `italic`, etc.
--
-- The method used to determin the style follows what the
-- OpenType specification recommends, and that is checking
-- if the `typographic_subfamily_name` record is provided by
-- the font, if it's provided its value is used otherwise
-- `subfamily_name` is used. There are restrictions that applies on
-- `subfamily_name` but not `typographic_subfamily_name`.
--
-- Note: This isn't necessarily limited to `bold`/`italic`/etc
-- when `typographic_subfamily_name` is used.
---@field style string
---@field copyright string
---@field family_name string
---@field subfamily_name string
---@field uid string
---@field full_name string
---@field version_string string
---@field postscript_name string
---@field trademark string
---@field manufacturer string
---@field designer string
---@field description string?
---@field vendor_url string?
---@field designer_url string?
---@field license_description string?
---@field license_url string?
---@field typographic_family_name string?
---@field typographic_subfamily_name string?
---@field compatible_full_name string?
---@field sample_text string?
---@field postscript_cid_findfont_name string?
---@field wws_family_name string?
---@field wws_subfamily_name string?
---@field light_background_palette string?
---@field dark_background_palette string?
---@field variations_postScript_name_prefix string?
local FontMeta = {}

local enums = require('libs.constants')
local resolve = require('libs.resolver')

---Returns an array of platform IDs used in this font.
---
---The return is cached after first call.
---@return integer[]
---@nodiscard
function FontMeta:getPlatforms()
  if self._platforms then return self._platforms end
  local platforms = {}
  for platform_id in pairs(self.platforms) do
    platforms[#platforms+1] = platform_id
  end
  self._platforms = platforms
  return platforms
end

---Whether or not the font defines name records for this platform.
---@param platform platform_id | integer
---@return boolean
---@nodiscard
function FontMeta:hasPlatform(platform)
  platform = resolve.platform(platform)
  return not not self.platforms[platform]
end

---Returns a table where keys are the available encodings, and value
---is an array of available languages for that encoding.
---
---The return is cached after first call.
---@param platform platform_id | integer
---@return {[integer]: integer[]}
---@nodiscard
function FontMeta:getLanguages(platform)
  if self._languages then return self._languages end
  platform = resolve.platform(platform)
  assert(self.platforms[platform], 'name table does not contain specified platform')

  local languages = {}
  for encoding, langs in pairs(self.platforms[platform]) do
    local encoding_langs = {}
    for language in pairs(langs) do
      encoding_langs[#encoding_langs+1] = language
    end
    languages[encoding] = encoding_langs
  end

  self._languages = languages
  return languages
end

---@overload fun(self: self, platform: "unicode", encoding: unicode_encoding, language: integer): boolean
---@overload fun(self: self, platform: "macintosh", encoding: macintosh_encoding, language: macintosh_language): boolean
---@overload fun(self: self, platform: "windows", encoding: windows_encoding, language: windows_language): boolean
---@param platform integer
---@param encoding integer
---@param language integer
---@return boolean
---@nodiscard
function FontMeta:hasLanguage(platform, encoding, language)
  platform = resolve.platform(platform)
  assert(self.platforms[platform], 'name table does not contain specified platform')

  encoding = resolve.encoding(platform, encoding)
  if not language or not self.platforms[platform][encoding] then
    return not not self.platforms[platform][encoding]
  end
  assert(
    platform ~= enums.platform_name_id.unicode or type(language) == 'number',
    'Automatically resolving language ID for Unicode platforms is unsupported,\
    please use numeric values for the language argument instead!'
  )

  language = resolve.language(platform, encoding, language)
  assert(self.platforms[platform][encoding][language], 'name table does not contain specified language')
  return not not self.platforms[platform][encoding][language]
end

---@overload fun(self: self, platform: "unicode", encoding: unicode_encoding, language: integer): boolean
---@overload fun(self: self, platform: "macintosh", encoding: macintosh_encoding, language: macintosh_language): boolean
---@overload fun(self: self, platform: "windows", encoding: windows_encoding, language: windows_language): boolean
---@param platform integer
---@param encoding integer
---@param language integer
function FontMeta:changeLanguage(platform, encoding, language)
  platform = resolve.platform(platform)
  encoding = resolve.encoding(platform, encoding)
  language = resolve.language(platform, encoding, language)
  assert(self.platforms[platform], 'name table does not contain specified platform')
  assert(self.platforms[platform][encoding], 'name table does not contain specified encoding')
  assert(self.platforms[platform][encoding][language], 'name table does not contain specified language')

  local record = self.platforms[platform][encoding][language]
  setmetatable(self, {
    __index = record,
  })

  self.name = self.typographic_family_name or self.family_name
  if self.version_string then
    -- apparently, not all records will have the version
    -- Times New Roman defines all the records in us_en locale
    -- and for the rest of locales it only sets subfamily_name and full_name 
    self.version.major = tonumber(self.version_string:match('^%D*(%d+)')) --[[@as integer]]
    self.version.minor = tonumber(self.version_string:match('^%D*%d+%.(%d+)')) --[[@as integer]]
  else
    self.version = nil
  end
	self.style = self.typographic_subfamily_name or self.subfamily_name
end


---@return fontmeta.FontMeta
local function createFont(data)
  for k, v in pairs(FontMeta) do
    data[k] = v
  end
  -- return setmetatable(data, {
  --   __index = FontMeta,
  -- })
  return data
end

return createFont
