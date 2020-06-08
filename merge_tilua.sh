mv -f tilua_picoc.lua ~/.Trash
cat lua_libraries/bitop/funcs.lua >> tilua_picoc.lua
cat clibrary.lua include.lua >> tilua_picoc.lua
cat cstdlib/stdio.lua cstdlib/stdlib.lua cstdlib/math.lua cstdlib/string.lua >> tilua_picoc.lua
cat picoc_custom_libs/console.lua >> tilua_picoc.lua
cat expression.lua heap.lua interpreter.lua lex.lua parse.lua platform.lua pointer.lua table.lua type.lua variable.lua >> tilua_picoc.lua
cat platform/platform_tilua.lua >> tilua_picoc.lua