set ZBS_ROOT=C:\Lua\ZeroBraneStudioEduPack-1.30-win32
set LUA_PATH=.\?.lua;%ZBS_ROOT%\lualibs/?/?.lua;%ZBS_ROOT%\lualibs/?.lua
set LUA_CPATH=%ZBS_ROOT%\bin/?.dll;%ZBS_ROOT%\bin/clibs52/?.dll
cd "C:\Program Files\Wireshark"
tshark.exe -X lua_script:C:\wireshark_plugin_iso8583_lua\lua\Iso8583.lua
::-f "tcp port 8664"
::-r "C:\wireshark_plugin_iso8583_lua\all.pcapng"
