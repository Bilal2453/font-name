-- a script that uses the parsed tables of languages
-- to compare between the official opentype and the lcid tables
-- this gives us a general overview of what could be missing
-- or under a different name and then generate a complete list.
-- In other words, this is what we use to generate constants.lua
-- Windows language table.
-- Note: We depend on goto and luajit's bit.tohex here!

local ot = require('opentype_table')
local lcid = require('lcid_table')
local tbl = {}

local function trim(str)
  return str:gsub('^%s+', ''):gsub('%s+$', '')
end
string.trim = trim

-- special cases in which we have to map the language name
-- to something specific for the matching process

-- in opentype table, chinese is always referred to as "chinese"
-- while in the lcid table, it is either "chinese simplified" or traditional
-- we solve that by merging the simplified and traditional into one.
-- surprisingly they never overlap!
local chinese = {}
for k, v in pairs(lcid.chinese_simplified) do
  chinese[k] = v
end
for k, v in pairs(lcid.chinese_traditional) do
  assert(not chinese[k]) -- any overlap?
  chinese[k] = v
end
lcid.chinese = chinese

-- here we find ourselves at the exact opposite of the above situation
local finalize_language = {
  spanish_modern_sort = 'spanish',
  spanish_traditional_sort = 'spanish',
}


-- matching

for lang_name, regions in pairs(ot) do
  lang_name = lang_name:gsub('.+', finalize_language)
  if not lcid[lang_name] then
    print('NOT FOUND\t not found in LCID: ' .. lang_name .. ' ' .. next(regions))
    goto continue
  end

  for region_name, info_ot in pairs(regions) do
    local region_found = false
    for tag, info_lcid in pairs(lcid[lang_name]) do
      -- if region_name:lower():trim() == info.region:lower():trim() then
      if info_ot.id == info_lcid.id then
        region_found = tag
        break
      end
    end

    if not region_found then
      print('FOUND\t\t but not region: ' .. region_name .. ' ' .. info_ot.id)
      goto continue
    end

    tbl[region_found] = {
      id = info_ot.id,
      region = info_ot.region,
      name = info_ot.name
    }
  end

  ::continue::
end

-- serialization

local buf = {'return {'}

-- figure out indention
local max_len = 0
for k in pairs(tbl) do
  max_len = math.max(max_len, #k)
end

for k, v in pairs(tbl) do
  local indent = (' '):rep(max_len - #k)
  local comment = ('-- %s - %s'):format(v.name, v.region)
  k = k:lower() -- hmm?
  buf[#buf+1] = ("\t['%s']%s= 0x%s, %s"):format(k, indent, bit.tohex(v.id, -4), comment)
end

buf[#buf+1] = '}'

io.open('final.lua', 'w+'):write(table.concat(buf, '\n'))
