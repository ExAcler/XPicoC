mv -f lua_picoc.lua ~/.Trash
cat lua_libraries/bitop/funcs.lua >> lua_picoc.lua
cat clibrary.lua include.lua >> lua_picoc.lua
cat cstdlib/stdio.lua cstdlib/stdlib.lua cstdlib/math.lua cstdlib/string.lua >> lua_picoc.lua
cat expression.lua heap.lua interpreter.lua lex.lua parse.lua platform.lua pointer.lua table.lua type.lua variable.lua >> lua_picoc.lua
cat platform/platform_pclua.lua >> lua_picoc.lua