-- a script that generates a Lua table of most known
-- Windows Language IDs. This is based off of the
-- official LCID ms-docs HTML page.
-- see https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-lcid

local html_table = io.open('./lcid_table.html', 'r'):read('*a')

local function clean(str)
  return str:lower()
    :gsub('[%(/]', ' ')
    :gsub('%)', '')
    :gsub('[%s%p]+', '_')
    :gsub('[%p%s]+$', '')
end
string.clean = clean

local tbl = {}

local state = 'lang'
for tr in html_table:gmatch('<tr>(.-)</tr>') do
  local lang, region, lcid, tag
  for td in tr:gmatch('<td>(.-)</td>') do
    local p = td:match('<p>(.-)</p>') or td
    if state == 'lang' then
      lang = p:clean()
      state = 'region'
    elseif state == 'region' then
      region = p
      state = 'lcid'
    elseif state == 'lcid' then
      lcid = tonumber(p, 16)
      -- there are way too many entries with the same ID of 0x1000 (4096),
      -- no way this can work with the OpenType fonts as they are not using .NET
      -- this has to be a Windows meme:
      --[[
        In versions of Windows prior to Windows 10,
        the locale identifier LOCALE_CUSTOM_UNSPECIFIED (0x1000, or 4096)
        is assigned to custom cultures created by the user.
        Starting with Windows 10, it is assigned to any culture that
        does not have a unique locale identifier and does not have complete
        system-provided data. As a result, code that iterates cultures and retrieves
        those with an LCID value of LOCALE_CUSTOM_UNSPECIFIED returns a larger
        subset of CultureInfo objects if run under Windows 10.
      ]]
      if lcid == 0x1000 then
        lang, region, lcid = nil, nil, nil
      end
      state = 'tag'
    elseif state == 'tag' then
      tag = p
      if lcid then
        if not tbl[lang] then tbl[lang] = {} end
        tbl[lang][tag] = {id = lcid, tag = tag, region = region}
      end
      state = 'release'
    else
      state = 'lang'
    end
  end
end

-- require'fs'.writeFileSync('./generated_lcid.json', require'json'.encode(tbl, {indent = 2}))
return tbl
