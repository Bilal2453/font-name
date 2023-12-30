local constants = require('libs.constants')
local platform_name = constants.platform_name_id

---@return integer
local function resolve(value, enum, message, ...)
  if message then
    -- if message is passed it must accept at least one format argument
    message = message:format(...)
  end
  return assert(value ~= nil and enum[value], message) --[[@as integer]]
end

---@param platform platform_id | integer
---@return integer
local function resolvePlatform(platform)
  if type(platform) == 'number' then
    return platform
  end
  return resolve(platform, platform_name, '%q is not a valid platform', platform)
end

local PLATFORM_TO_ENCODING_MAP = {
  [platform_name.unicode] = constants.unicode_encoding_id,
  [platform_name.macintosh] = constants.macintosh_encoding_id,
  [platform_name.windows] = constants.windows_encoding_id,
}

---@overload fun(platform: "unicode" | 0 , encoding: unicode_encoding): integer
---@overload fun(platform: "macintosh" | 1 , encoding: macintosh_encoding): integer
---@overload fun(platform: "windows" | 3 , encoding: windows_encoding): integer
---@param platform string | integer
---@param encoding string | integer
---@return integer
local function resolveEncoding(platform, encoding)
  local rplat = resolvePlatform(platform)
  if type(encoding) == 'number' then
    return encoding
  end

  encoding = resolve(
    encoding,
    PLATFORM_TO_ENCODING_MAP[rplat],
    '%q is not a valid encoding under %q platform',
    encoding,
    platform
  )
  return encoding
end


local PLATFORM_TO_LANGUAGE_ENUM = {
  [platform_name.macintosh] = constants.macintosh_language_id,
  [platform_name.windows] = constants.windows_language_id,
}

---@overload fun(platform: "macintosh" | 1 , encoding: macintosh_encoding, language: macintosh_language): integer
---@overload fun(platform: "windows" | 3 , encoding: windows_encoding, language: windows_language): integer
---@param encoding integer
---@param language integer
---@return integer
local function resolveLanguage(platform, encoding, language)
  platform = resolvePlatform(platform)
  encoding = resolveEncoding(platform, encoding)
  do
    local t = type(language)
    if t == 'number' then
      return language
    elseif t == 'string' then
      language = language:lower()
    end
  end
  assert(platform ~= platform_name.unicode, 'non-numeric languages for Unicode platform are not supported')

  language = resolve(
    language,
    PLATFORM_TO_LANGUAGE_ENUM[platform],
    '%q is not a valid language under %q platform',
    language,
    platform
  )
  return language
end

return {
  resolve = resolve,
  platform = resolvePlatform,
  encoding = resolveEncoding,
  language = resolveLanguage,
}
