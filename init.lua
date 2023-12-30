local FontMeta = require('libs.FontMeta')

local decoders = {
  sfnt = require('decoders.sfnt'),
}


local EXT_DECODER_MAP = {
  ttf = decoders.sfnt.decode,
  otf = decoders.sfnt.decode,
}


---Given a binary string of a font file, attempt to guess the
---right decoder for the font format using the magic number.
---@param binary string
local function getFontDecoder(binary)
  for decoder_name, decoder in pairs(decoders) do
    if decoder.getMagicNumber(binary) then
      return decoder, decoder_name
    end
  end
end

---Given a binary string of a font file, attempt to guess the the font format
---using the magic number.
---@param binary string
---@return "truetype"|"opentype"|nil format_name
local function getFontFormat(binary)
  for decoder_name, decoder in pairs(decoders) do
    local _, name = decoder.getMagicNumber(binary)
    if name then
      return name
    end
  end
end

local function loadFontString(binary)
  local decoder = getFontDecoder(binary)
  if not decoder then
    return error("unsupported or corrupted font")
  end

  local decoded_font = assert(decoder.decode(binary))
  local fontData = decoder.fontMetaStruct(decoded_font)
  return FontMeta(fontData)
end

return {
  loadFontString = loadFontString,

  decoders = decoders,
  EXT_DECODER_MAP = EXT_DECODER_MAP,
}
