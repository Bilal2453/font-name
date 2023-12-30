local function swapkeyvalue(tbl)
  local new = {}
  for k, v in pairs(tbl) do
    new[v] = k
  end
  return new
end


local magic_numbers = {
	sfnt = {
		[0x00010000] = "truetype", -- "1"
		[0x74727565] = "truetype", -- "true"
		[0x4F54544F] = "opentype", -- "OTTO"
	}
}

--[[ OpenType constants ]]

---@enum (key) record_name
local record_name_code = {
  copyright                         = 0,
	family_name                       = 1,
	subfamily_name                    = 2,
	uid                               = 3,
	full_name                         = 4,
	version_string                    = 5, -- "version" is used in Font class
	postscript_name                   = 6,
	trademark                         = 7,
	manufacturer                      = 8,
	designer                          = 9,
	description                       = 10,
	vendor_url                        = 11,
	designer_url                      = 12,
	license_description               = 13,
	license_url                       = 14,
	-- reserved                       = 15,
	typographic_family_name           = 16,
	typographic_subfamily_name        = 17,
	compatible_full_name              = 18,
	sample_text                       = 19,
	postscript_cid_findfont_name      = 20,
	wws_family_name                   = 21,
	wws_subfamily_name                = 22,
	light_background_palette          = 23,
	dark_background_palette           = 24,
	variations_postScript_name_prefix = 25,
}
local record_code_name = swapkeyvalue(record_name_code)


---@enum (key) platform_id
local platform_name_id = {
  unicode   = 0,
  macintosh = 1,
  -- res    = 2,
  windows   = 3,
}
local platform_id_name = swapkeyvalue(platform_name_id)


---@enum (key) unicode_encoding
local unicode_encoding_id = {
  unicode_1_0      = 0,
  unicode_1_1      = 1,
  iso_10646        = 2,
  unicode_2_0_bmp  = 3,
  unicode_2_0_full = 4,
}
local unicode_id_encoding = swapkeyvalue(unicode_encoding_id)

-- there are no unicode language ids defined in spec
-- otherthan the suggested optional use of 0


---@enum (key) macintosh_encoding
local macintosh_encoding_id = {
  roman = 0,
  japanese = 1,
  chinese_traditional = 2,
  korean = 3,
  arabic = 4,
  hebrew = 5,
  greek = 6,
  russian = 7,
  rsymbol = 8,
  devanagari = 9,
  gurmukhi = 10 ,
  gujarati = 11 ,
  odia = 12,
  bangla = 13,
  tamil = 14,
  telugu = 15,
  kannada = 16,
  malayalam = 17,
 	sinhalese = 18,
  burmese = 19,
  khmer = 20,
  thai = 21,
  laotian = 22,
  georgian = 23,
 	armenian = 24,
 	chinese_simplified = 25,
  tibetan = 26,
	mongolian = 27,
	geez = 28,
  slavic = 29,
 	vietnamese = 30,
  sindhi = 31,
 	uninterpreted = 32,
}
local macintosh_id_encoding = swapkeyvalue(macintosh_encoding_id)

---@enum (key) macintosh_language
local macintosh_language_id = {
  english                     = 0,
  french                      = 1,
  german                      = 2,
  italian                     = 3,
  dutch                       = 4,
  swedish                     = 5,
  spanish                     = 6,
  danish                      = 7,
  portuguese                  = 8,
  norwegian                   = 9,
  hebrew                      = 10,
  japanese                    = 11,
  arabic                      = 12,
  finnish                     = 13,
  greek                       = 14,
  icelandic                   = 15,
  maltese                     = 16,
  turkish                     = 17,
  croatian                    = 18,
  chinese_traditional         = 19,
  urdu                        = 20,
  hindi                       = 21,
  thai                        = 22,
  korean                      = 23,
  lithuanian                  = 24,
  polish                      = 25,
  hungarian                   = 26,
  estonian                    = 27,
  latvian                     = 28,
  sami                        = 29,
  faroese                     = 30,
  farsi_persian               = 31,
  russian                     = 32,
  chinese_simplified          = 33,
  flemish                     = 34,
  irish                       = 35,
  albanian                    = 36,
  romanian                    = 37,
  czech                       = 38,
  slovak                      = 39,
  slovenian                   = 40,
  yiddish                     = 41,
  serbian                     = 42,
  macedonian                  = 43,
  bulgarian                   = 44,
  ukrainian                   = 45,
  byelorussian                = 46,
  uzbek                       = 47,
  kazakh                      = 48,
  azerbaijani_cyrillic_script = 49,
  azerbaijani_arabic_script   = 50,
  armenian                    = 51,
  georgian                    = 52,
  romanian_moldova            = 53,
  kirghiz                     = 54,
  tajiki                      = 55,
  turkmen                     = 56,
  mongolian_mongolian_script  = 57,
  mongolian_cyrillic_script   = 58,
  pashto                      = 59,
  kurdish                     = 60,
  kashmiri                    = 61,
  sindhi                      = 62,
  tibetan                     = 63,
  nepali                      = 64,
  sanskrit                    = 65,
  marathi                     = 66,
  bangla                      = 67,
  assamese                    = 68,
  gujarati                    = 69,
  punjabi                     = 70,
  odia                        = 71,
  malayalam                   = 72,
  kannada                     = 73,
  tamil                       = 74,
  telugu                      = 75,
  sinhalese                   = 76,
  burmese                     = 77,
  khmer                       = 78,
  lao                         = 79,
  vietnamese                  = 80,
  indonesian                  = 81,
  tagalog                     = 82,
  malay_roman_script          = 83,
  malay_arabic_script         = 84,
  amharic                     = 85,
  tigrinya                    = 86,
  galla                       = 87,
  somali                      = 88,
  swahili                     = 89,
  kinyarwanda_ruanda          = 90,
  rundi                       = 91,
  nyanja_chewa                = 92,
  malagasy                    = 93,
  esperanto                   = 94,
  welsh                       = 128,
  basque                      = 129,
  catalan                     = 130,
  latin                       = 131,
  quechua                     = 132,
  guarani                     = 133,
  aymara                      = 134,
  tatar                       = 135,
  uighur                      = 136,
  dzongkha                    = 137,
  javanese_roman_script       = 138,
  sundanese_roman_script      = 139,
  galician                    = 140,
  afrikaans                   = 141,
  breton                      = 142,
  inuktitut                   = 143,
  scottish_gaelic             = 144,
  manx                        = 145,
  irish_with_dot_above        = 146,
  tongan                      = 147,
  greek_polytonic             = 148,
  greenlandic                 = 149,
  azerbaijani_roman_script    = 150,
}
local macintosh_id_language = swapkeyvalue(macintosh_language_id)


---@enum (key) windows_encoding
local windows_encoding_id = {
  symbol                  = 0,
  unicode_bmp             = 1,
  shiftjis                = 2,
  prc                     = 3,
  big5                    = 4,
  wansung                 = 5,
  johab                   = 6,
  -- reserved             = 7,
  -- reserved             = 8,
  -- reserved             = 9,
  unicode_full_repertoire = 10,
}
local windows_id_encoding = swapkeyvalue(windows_encoding_id)

---@enum (key) windows_language
local windows_language_id = {
	['is-is']       = 0x040F, -- Icelandic - Iceland
	['sr-latn-cs']  = 0x081A, -- Serbian (Latin) - Serbia
	['es-bo']       = 0x400A, -- Spanish - Bolivia
	['bn-in']       = 0x0445, -- Bangla - India
	['se-fi']       = 0x0C3B, -- Sami (Northern) - Finland
	['zh-tw']       = 0x0404, -- Chinese - Taiwan
	['mr-in']       = 0x044E, -- Marathi - India
	['en-my']       = 0x4409, -- English - Malaysia
	['se-no']       = 0x043B, -- Sami (Northern) - Norway
	['es-cl']       = 0x340A, -- Spanish - Chile
	['ig-ng']       = 0x0470, -- Igbo - Nigeria
	['ar-dz']       = 0x1401, -- Arabic - Algeria
	['se-se']       = 0x083B, -- Sami (Northern) - Sweden
	['tzm-latn-dz'] = 0x085F, -- Tamazight (Latin) - Algeria
	['es-co']       = 0x240A, -- Spanish - Colombia
	['tr-tr']       = 0x041F, -- Turkish - Türkiye
	['tk-tm']       = 0x0442, -- Turkmen - Turkmenistan
	['ar-bh']       = 0x3C01, -- Arabic - Bahrain
	['nn-no']       = 0x0814, -- Norwegian (Nynorsk) - Norway
	['es-cr']       = 0x140A, -- Spanish - Costa Rica
	['fr-ca']       = 0x0C0C, -- French - Canada
	['ba-ru']       = 0x046D, -- Bashkir - Russia
	['sms-fi']      = 0x203B, -- Sami (Skolt) - Finland
	['tn-za']       = 0x0432, -- Setswana - South Africa
	['fi-fi']       = 0x040B, -- Finnish - Finland
	['es-do']       = 0x1C0A, -- Spanish - Dominican Republic
	['eu-es']       = 0x042D, -- Basque - Basque
	['ar-eg']       = 0x0C01, -- Arabic - Egypt
	['hsb-de']      = 0x042E, -- Upper Sorbian - Germany
	['sma-no']      = 0x183B, -- Sami (Southern) - Norway
	['es-sv']       = 0x440A, -- Spanish - El Salvador
	['sma-se']      = 0x1C3B, -- Sami (Southern) - Sweden
	['be-by']       = 0x0423, -- Belarusian - Belarus
	['en-nz']       = 0x1409, -- English - New Zealand
	['iu-latn-ca']  = 0x085D, -- Inuktitut (Latin) - Canada
	['cy-gb']       = 0x0452, -- Welsh - United Kingdom
	['af-za']       = 0x0436, -- Afrikaans - South Africa
	['lo-la']       = 0x0454, -- Lao - Lao P.D.R.
	['moh-ca']      = 0x047C, -- Mohawk - Mohawk
	['en-bz']       = 0x2809, -- English - Belize
	['ar-jo']       = 0x2C01, -- Arabic - Jordan
	['oc-fr']       = 0x0482, -- Occitan - France
	['ar-kw']       = 0x3401, -- Arabic - Kuwait
	['iu-cans-ca']  = 0x045D, -- Inuktitut - Canada
	['ug-cn']       = 0x0480, -- Uighur - People’s Republic of China
	['or-in']       = 0x0448, -- Odia - India
	['ar-lb']       = 0x3001, -- Arabic - Lebanon
	['lv-lv']       = 0x0426, -- Latvian - Latvia
	['de-li']       = 0x1407, -- German - Liechtenstein
	['es-ni']       = 0x4C0A, -- Spanish - Nicaragua
	['de-lu']       = 0x1007, -- German - Luxembourg
	['lt-lt']       = 0x0427, -- Lithuanian - Lithuania
	['xh-za']       = 0x0434, -- isiXhosa - South Africa
	['en-sg']       = 0x4809, -- English - Singapore
	['it-it']       = 0x0410, -- Italian - Italy
	['ar-ma']       = 0x1801, -- Arabic - Morocco
	['sk-sk']       = 0x041B, -- Slovak - Slovakia
	['en-ca']       = 0x1009, -- English - Canada
	['es-pe']       = 0x280A, -- Spanish - Peru
	['ar-om']       = 0x2001, -- Arabic - Oman
	['ps-af']       = 0x0463, -- Pashto - Afghanistan
	['it-ch']       = 0x0810, -- Italian - Switzerland
	['en-029']      = 0x2409, -- English - Caribbean
	['el-gr']       = 0x0408, -- Greek - Greece
	['sl-si']       = 0x0424, -- Slovenian - Slovenia
	['es-pr']       = 0x500A, -- Spanish - Puerto Rico
	['en-za']       = 0x1C09, -- English - South Africa
	['ar-qa']       = 0x4001, -- Arabic - Qatar
	['es-es_tradnl']= 0x040A, -- Spanish (Traditional Sort) - Spain
	['kl-gl']       = 0x046F, -- Greenlandic - Greenland
	['es-es']       = 0x0C0A, -- Spanish (Modern Sort) - Spain
	['uz-latn-uz']  = 0x0443, -- Uzbek (Latin) - Uzbekistan
	['gsw-fr']      = 0x0484, -- Alsatian - France
	['ja-jp']       = 0x0411, -- Japanese - Japan
	['kn-in']       = 0x044B, -- Kannada - India
	['es-uy']       = 0x380A, -- Spanish - Uruguay
	['ms-bn']       = 0x083E, -- Malay - Brunei Darussalam
	['yo-ng']       = 0x046A, -- Yoruba - Nigeria
	['si-lk']       = 0x045B, -- Sinhala - Sri Lanka
	['ms-my']       = 0x043E, -- Malay - Malaysia
	['fy-nl']       = 0x0462, -- Frisian - Netherlands
	['ar-ye']       = 0x2401, -- Arabic - Yemen
	['sr-cyrl-cs']  = 0x0C1A, -- Serbian (Cyrillic) - Serbia
	['ar-sy']       = 0x2801, -- Arabic - Syria
	['es-ve']       = 0x200A, -- Spanish - Venezuela
	['br-fr']       = 0x047E, -- Breton - France
	['gu-in']       = 0x0447, -- Gujarati - India
	['am-et']       = 0x045E, -- Amharic - Ethiopia
	['nso-za']      = 0x046C, -- Sesotho sa Leboa - South Africa
	['ar-tn']       = 0x1C01, -- Arabic - Tunisia
	['ml-in']       = 0x044C, -- Malayalam - India
	['fr-lu']       = 0x140C, -- French - Luxembourg
	['fr-ch']       = 0x100C, -- French - Switzerland
	['hy-am']       = 0x042B, -- Armenian - Armenia
	['fr-fr']       = 0x040C, -- French - France
	['ar-ae']       = 0x3801, -- Arabic - U.A.E.
	['fr-be']       = 0x080C, -- French - Belgium
	['en-tt']       = 0x2C09, -- English - Trinidad and Tobago
	['zu-za']       = 0x0435, -- isiZulu - South Africa
	['fr-mc']       = 0x180C, -- French - Principality of Monaco
	['bg-bg']       = 0x0402, -- Bulgarian - Bulgaria
	['sr-latn-ba']  = 0x181A, -- Serbian (Latin) - Bosnia and Herzegovina
	['pl-pl']       = 0x0415, -- Polish - Poland
	['km-kh']       = 0x0453, -- Khmer - Cambodia
	['bs-latn-ba']  = 0x141A, -- Bosnian (Latin) - Bosnia and Herzegovina
	['ky-kg']       = 0x0440, -- Kyrgyz - Kyrgyzstan
	['pa-in']       = 0x0446, -- Punjabi - India
	['as-in']       = 0x044D, -- Assamese - India
	['fil-ph']      = 0x0464, -- Filipino - Philippines
	['nb-no']       = 0x0414, -- Norwegian (Bokmal) - Norway
	['tt-ru']       = 0x0444, -- Tatar - Russia
	['mn-mn']       = 0x0450, -- Mongolian (Cyrillic) - Mongolia
	['dsb-de']      = 0x082E, -- Lower Sorbian - Germany
	['ko-kr']       = 0x0412, -- Korean - Korea
	['id-id']       = 0x0421, -- Indonesian - Indonesia
	['de-de']       = 0x0407, -- German - Germany
	['co-fr']       = 0x0483, -- Corsican - France
	['quc-latn-gt'] = 0x0486, -- K’iche - Guatemala
	['sr-cyrl-ba']  = 0x1C1A, -- Serbian (Cyrillic) - Bosnia and Herzegovina
	['bs-cyrl-ba']  = 0x201A, -- Bosnian (Cyrillic) - Bosnia and Herzegovina
	['ru-ru']       = 0x0419, -- Russian - Russia
	['te-in']       = 0x044A, -- Telugu - India
	['en-gb']       = 0x0809, -- English - United Kingdom
	['hr-ba']       = 0x101A, -- Croatian (Latin) - Bosnia and Herzegovina
	['quz-bo']      = 0x046B, -- Quechua - Bolivia
	['sq-al']       = 0x041C, -- Albanian - Albania
	['mn-mong-cn']  = 0x0850, -- Mongolian (Traditional) - People’s Republic of China
	['en-us']       = 0x0409, -- English - United States
	['hr-hr']       = 0x041A, -- Croatian - Croatia
	['az-cyrl-az']  = 0x082C, -- Azerbaijani (Cyrillic) - Azerbaijan
	['quz-ec']      = 0x086B, -- Quechua - Ecuador
	['sa-in']       = 0x044F, -- Sanskrit - India
	['syr-sy']      = 0x045A, -- Syriac - Syria
	['pt-br']       = 0x0416, -- Portuguese - Brazil
	['pt-pt']       = 0x0816, -- Portuguese - Portugal
	['de-at']       = 0x0C07, -- German - Austria
	['quz-pe']      = 0x0C6B, -- Quechua - Peru
	['rw-rw']       = 0x0487, -- Kinyarwanda - Rwanda
	['de-ch']       = 0x0807, -- German - Switzerland
	['lb-lu']       = 0x046E, -- Luxembourgish - Luxembourg
	['arn-cl']      = 0x047A, -- Mapudungun - Chile
	['vi-vn']       = 0x042A, -- Vietnamese - Vietnam
	['ha-latn-ng']  = 0x0468, -- Hausa (Latin) - Nigeria
	['es-ec']       = 0x300A, -- Spanish - Ecuador
	['kk-kz']       = 0x043F, -- Kazakh - Kazakhstan
	['th-th']       = 0x041E, -- Thai - Thailand
	['gl-es']       = 0x0456, -- Galician - Galician
	['ii-cn']       = 0x0478, -- Yi - People’s Republic of China
	['sw-ke']       = 0x0441, -- Kiswahili - Kenya
	['cs-cz']       = 0x0405, -- Czech - Czech Republic
	['en-in']       = 0x4009, -- English - India
	['smj-se']      = 0x143B, -- Sami (Lule) - Sweden
	['sv-fi']       = 0x081D, -- Swedish - Finland
	['sah-ru']      = 0x0485, -- Sakha - Russia
	['en-zw']       = 0x3009, -- English - Zimbabwe
	['wo-sn']       = 0x0488, -- Wolof - Senegal
	['en-ie']       = 0x1809, -- English - Ireland
	['es-us']       = 0x540A, -- Spanish - United States
	['es-hn']       = 0x480A, -- Spanish - Honduras
	['bo-cn']       = 0x0451, -- Tibetan - People’s Republic of China
	['dv-mv']       = 0x0465, -- Divehi - Maldives
	['mk-mk']       = 0x042F, -- Macedonian - North Macedonia
	['es-gt']       = 0x100A, -- Spanish - Guatemala
	['et-ee']       = 0x0425, -- Estonian - Estonia
	['ro-ro']       = 0x0418, -- Romanian - Romania
	['kok-in']      = 0x0457, -- Konkani - India
	['es-mx']       = 0x080A, -- Spanish - Mexico
	['ka-ge']       = 0x0437, -- Georgian - Georgia
	['es-py']       = 0x3C0A, -- Spanish - Paraguay
	['mt-mt']       = 0x043A, -- Maltese - Malta
	['en-jm']       = 0x2009, -- English - Jamaica
	['es-pa']       = 0x180A, -- Spanish - Panama
	['zh-cn']       = 0x0804, -- Chinese - People’s Republic of China
	['da-dk']       = 0x0406, -- Danish - Denmark
	['nl-nl']       = 0x0413, -- Dutch - Netherlands
	['rm-ch']       = 0x0417, -- Romansh - Switzerland
	['smn-fi']      = 0x243B, -- Sami (Inari) - Finland
	['prs-af']      = 0x048C, -- Dari - Afghanistan
	['zh-sg']       = 0x1004, -- Chinese - Singapore
	['sv-se']       = 0x041D, -- Swedish - Sweden
	['ar-iq']       = 0x0801, -- Arabic - Iraq
	['hi-in']       = 0x0439, -- Hindi - India
	['ar-ly']       = 0x1001, -- Arabic - Libya
	['uz-cyrl-uz']  = 0x0843, -- Uzbek (Cyrillic) - Uzbekistan
	['ca-es']       = 0x0403, -- Catalan - Catalan
	['ne-np']       = 0x0461, -- Nepali - Nepal
	['nl-be']       = 0x0813, -- Dutch - Belgium
	['ar-sa']       = 0x0401, -- Arabic - Saudi Arabia
	['en-au']       = 0x0C09, -- English - Australia
	['mi-nz']       = 0x0481, -- Maori - New Zealand
	['smj-no']      = 0x103B, -- Sami (Lule) - Norway
	['he-ps']       = 0x040D, -- Hebrew - Palestine
	['es-ar']       = 0x2C0A, -- Spanish - Argentina
	['hu-hu']       = 0x040E, -- Hungarian - Hungary
	['az-latn-az']  = 0x042C, -- Azerbaijani (Latin) - Azerbaijan
	['zh-hk']       = 0x0C04, -- Chinese - Hong Kong SAR
	['ga-ie']       = 0x083C, -- Irish - Ireland
	['en-ph']       = 0x3409, -- English - Republic of the Philippines
	['fo-fo']       = 0x0438, -- Faroese - Faroe Islands
	['uk-ua']       = 0x0422, -- Ukrainian - Ukraine
	['ur-pk']       = 0x0420, -- Urdu - Islamic Republic of Pakistan
	['tg-cyrl-tj']  = 0x0428, -- Tajik (Cyrillic) - Tajikistan
	['zh-mo']       = 0x1404, -- Chinese - Macao SAR
	['bn-bd']       = 0x0845, -- Bangla - Bangladesh
	['ta-in']       = 0x0449, -- Tamil - India
}
local windows_id_language = swapkeyvalue(windows_language_id)


return {
	magic_numbers = magic_numbers,

  record_name_code = record_name_code,
  record_code_name = record_code_name,

  platform_name_id = platform_name_id,
  platform_id_name = platform_id_name,

  unicode_encoding_id = unicode_encoding_id,
  unicode_id_encoding = unicode_id_encoding,

  macintosh_encoding_id = macintosh_encoding_id,
  macintosh_id_encoding = macintosh_id_encoding,
  macintosh_language_id = macintosh_language_id,
  macintosh_id_language = macintosh_id_language,

  windows_encoding_id = windows_encoding_id,
  windows_id_encoding = windows_id_encoding,
  windows_language_id = windows_language_id,
  windows_id_language = windows_id_language,
}
