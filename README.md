# font-name

A simple font parser to extract font names and information.
Currently, only supports OpenType and TrueType fonts,
and the interface is not stable, will change whenever more fonts are added.

As of now, this parses the [Name Table](https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6name.html) of a SFNT-housed font and returns the raw structure.

## Dependencies

This module requires `string.unpack` in order to work, which was introduced in Lua 5.3.
The module generally does not make any other dependencies, if you were
to get `string.unpack` on PUC Lua 5.1/5.2 or LuaJIT (such as by using [lua-compat-5.3](https://github.com/lunarmodules/lua-compat-5.3))
it should work as expected.

## Documentation

Work in Progress. The code is fully typed and documented using the [LuaLS](https://github.com/LuaLS/lua-language-server/) doc-comments.

### License

All code under this repository is licensed under The MIT License.
See [[LICENSE]] for details.
