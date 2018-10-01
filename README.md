# Lua4Ultibo
Integrate Lua 5.3.4 into your Ultibo project

Just include luaheaders.pas and put liblua.a in your library search path and it should work.

The example includes calling a pascal procedure with or without parameters.

The headers are incomplete, i only ported the main api calls and what i needed, but it's easy to expand. Tested only with Raspberry Pi Zero, but should work with others too.
