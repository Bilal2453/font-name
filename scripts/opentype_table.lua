-- a script that generates a Lua table of the OpenType languages
-- for the Windows platform. This is based off of the official
-- specification (and it sucks).
-- see https://learn.microsoft.com/en-us/typography/opentype/spec/name#windows-language-ids

local html_table = io.open('./opentype_table.html', 'r'):read('*a')

local function clean(str)
  return str:lower()
    :gsub('[%(/]', ' ')
    :gsub('%)', '')
    :gsub('[%s%p’]+', '_')
    :gsub('[%p%s]+$', '')
end
string.clean = clean

-- because the OpenType list is so good (/sarcasm) we have
-- to account for the inconsistences in the region naming
-- for example, sometimes China is referred to as "People's Republic of China"
-- and othertimes it's simply "prc" in the same table. It is great.

local finalized_regions = {
  prc = "people's republic of china", -- the name used in lcid table
  ['macedonia'] = 'north macedonia', -- name used in lcid table
  basque = 'spain', -- region name in lcid that matches the ID is spain
  catalan = 'spain', -- same as above
  galician = 'spain', -- s-same, gosh Spain, slow down on the colonization!
  mohawk = 'canada', -- region name in lcid that matches the id 0x047C
  venezuela = 'bolivarian republic of venezuela', -- name in lcid table
}

local finalized_lang = {
  isixhosa = 'xhosa', -- that "isi" prefix feels wrong.. the name in LCID is xhosa
  isizulu = 'zulu', -- name in LCID is zulu
  mongolian_traditional = 'mongolian_traditional_mongolian',
  uighur = 'uyghur',
  inuktitut = 'inuktitut_syllabics',
}

local state = 'lang'
local tbl = {}
for tr in html_table:gmatch '<tr>(.-)</tr>' do
  local lang, region
  local lang_key, region_key
  for td in tr:gmatch '<td>(.-)</td>' do
    if state == 'lang' then
      lang_key = td:clean():gsub('.+', finalized_lang)
      lang = td

      if not tbl[lang_key] then tbl[lang_key] = {} end
      state = 'region'
    elseif state == 'region' then
      region_key = td:lower():gsub('.+', finalized_regions)
      region = td
      state = 'code'
    elseif state == 'code' then
      tbl[lang_key][region_key] = {
        id = tonumber(td, 16),
        name = lang,
        region = region,
      }
      state = 'lang'
      lang, region_key = nil, nil
      lang_key, region_key = nil, nil
    end
  end
end

-- require'fs'.writeFileSync('./generated_ot.json', require'json'.encode(tbl, {indent = 2}))
return tbl
