-- TODO: currently we only have the TrueType/OpenType decoder
-- so the decodeMeta return works just fine.
-- But in the future we may support more fonts.
-- and as such we need a shared interface for all of the decoders.

local decoders = {
  sfnt = require('decoders.sfnt'),
}

local EXT_MAP = {
  ttf = decoders.sfnt.decodeMeta,
  otf = decoders.sfnt.decodeMeta,
}

local function getDecoderFor(ext)
  return EXT_MAP[ext]
end

return {
  getDecoderFor = getDecoderFor,

  decoders = decoders,
  EXT_MAP = EXT_MAP,
}
