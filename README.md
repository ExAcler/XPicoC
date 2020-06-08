# Description

XPicoC is a Lua implementation of a very small C intepreter designed for embedded systems, PicoC. It is originally designed to bypass the ban on progammability in C that Texas Instruments imposes on its flagship graphing calculator, the TI-Nspire CX series. It aims to let people write and execute C programs on TI-Nspire CX graphing calculators without the need to do jailbreaking as some famous projects like Ndless do. Despite those, it is also a successful and maybe the first implementation of a C intepreter with full functionality, like the support of pointer arithmetic, on the Lua scripting language. It is also tested on Lua 5.3.5 on macOS 10.14.6 and is easy to be ported to other platforms.

You can find the PicoC project here: https://github.com/jpoirier/picoc

For some techical details, please refer to the original PicoC project.

# Deploying XPicoC

You can find two .sh files inside the repository root directory.

The merge.sh will generate an executable Lua script named lua_picoc.lua, which is designed to use with desktop versions of Lua, in the same directory.

The merge_tilua.sh will generate a Lua script named tilua_picoc.lua, which is designed to use with TI-Lua, in the same directory. To use it with TI-Lua, you need to first have TI-Nspire CX Student Software or Teacher Software installed on your PC or Mac. Then you should follow these instructions:

1. Start TI-Nspire CX Student Software or Teacher Software.
2. Create a new TI-Nspire document.
3. Insert a TI-Lua script into the document.
4. Copy the content of tilua_picoc.lua to clipboard.
5. Paste the content of tilua_picoc.lua inside the script editor.
6. Click Set Script on the toolbar.

# Running XPicoC

### Desktop Lua
If you deploy XPicoC on a desktop version of Lua, then you will be able to use it just like how you use the original PicoC. Just type:

lua lua_picoc.lua \[arguments\]

and you are done.

Please read the original PicoC README for information about command line arguments.

### TI-Lua
If you deploy XPicoC on TI-Lua, then things are different.

After you click Set Script when you deploy XPicoC, the document Page 1.1 will become a Command Prompt and automatically enter the PicoC Interactive Mode. You can play with it by directly typing in C statements; however, if you would like to run a piece of C code, it is also simple. Just follow these instructions:

1. Inserts a Notes application into the TI-Nspire document.
2. Type in your C code inside the Notes application.
3. Press Ctrl+A to select all of your code, and press Ctrl+C to copy it.
4. Switch back to Page 1.1, Press Ctrl+V (or press the Menu key and select Run > Run code from clipboard)

We are currently working on adding more features to let you use the Command Prompt more easily.

# C Standard Library Functions

For a list of supported C standard and custom libraries, please read c_libraries.md. 

# Unimplemented Features

We have implemented most of the features and functions from PicoC, but not all.

XPicoC's variable memory system is implemented in a different way than PicoC. Every pointer in XPicoC must be derived from another variable, either using the ampersand (&) operator, or using array addressing. The derivation process is automatically done by the interpreter and users cannot intervene. The "address" stored in a pointer variable is meaningless. If you use brute force to change this "address", the pointer will become corrupt.

Here is a list of unimplemented (and not planned to implement) features and functions:

1. Assigning an absolute address (except for 0) to a pointer will give an error.
2. A pointer containing a corrupt "address" will be considered a null pointer.
3. Finding the difference of two pointers (pointer1 - pointer2) referencing different variables will give an error.
4. Every variable has fixed size; performing out-of-bounds operations on a variable that is not inside a struct will always give 0 for the out-of-bounds part.

# Copyright and Contributions

This project is developed by Jimmy Lin from Xhorizon, by courtesy of Zik Saleeba and Joseph Poirier.

XPicoC is published under the "New BSD License", see the LICENSE file.

Feel free to send a Pull Request if you would like to make contributions.
