unit luaheaders;

{$linklib lua}
{$mode objfpc}{$H+}

{
To build liblua.a, use included makefile.ultibo.armv6
built with gcc-arm-none-eabi-5_3-2016q1 toolkit, other versions may or
may not work. Include it in your search path with:

PATH=$PATH:/home/you/gcc-arm-none-eabi-5_3-2016q1/bin/

Copy the makefile in the lua "src" folder and run:

make -f makefile.ultibo.armv7 a
ok for rpiZ
make -f makefile.ultibo.armv6 a


}

interface

uses 
  Syscalls, ctypes,

  VC4 // this is needed for some reason to pull in some math function that otherwise won't link
      // not sure which of the many libraries imported there is needed, no time to research :)
  ;

const
LUALIB = 'lua';


{

Below is an incomplete port of constants, macros and api.
I just translated the main ones, others should be easy to add.

}

LUA_ERRSYNTAX : cint = 3;
LUA_OK : cint = 0;
LUA_MULTRET: cint = -1;

type Plua_State = pointer;
  Plua_KContext = pointer;
  Plua_KFunction = pointer;
  Plua_CFunction = function(L: Plua_State): cint; cdecl;
  lua_Number = cfloat;
  lua_Integer = cint;



// macros

procedure lua_pushcfunction (luaState: Plua_State; fn:Plua_CFunction);inline;
function luaL_loadfile(luaState: Plua_State; filename: PChar): cint;inline;
function lua_pcall(luaState: Plua_State; nargs, nresults, errfunc: cint): cint;inline;
procedure lua_register(luaState: Plua_State; name:PChar; fn:Plua_CFunction);inline;
procedure lua_call(luaState: Plua_State; nargs:cint32;  nresults: cint32);inline;
function lua_tointeger(luaState: Plua_State; idx:cint):lua_Integer;inline;
function lua_tonumber(luaState: Plua_State; idx:cint):lua_Number;inline;
function lua_getextraspace(luaState: Plua_State):pointer;inline;
function lua_tostring(luaState: Plua_State; idx:cint):pchar;inline;
procedure lua_newtable(luaState: Plua_State);inline;
procedure lua_pop(luaState: Plua_State; n:cint);inline;

// actual api
function luaL_newstate(): Plua_State; cdecl; external LUALIB;
procedure luaL_openlibs(luaState: Plua_State); cdecl; external LUALIB;
procedure lua_pushcclosure (luaState: Plua_State; fn:Plua_CFunction; n:cint) ; cdecl; external LUALIB;
function lua_gettop(luaState: Plua_State):cint; cdecl; external LUALIB;
function luaL_loadfilex(luaState: Plua_State; filename: PChar; cmode:PChar):cint; cdecl; external LUALIB;
function luaL_loadstring(luaState: Plua_State; s: PChar): cint; cdecl; external LUALIB;
function lua_pcallk(luaState: Plua_State; nargs, nresults, errfunc: cint; ctx:Plua_KContext; k:Plua_KFunction): cint; cdecl; external LUALIB;
procedure lua_setglobal (luaState: Plua_State; name:Pchar); cdecl; external LUALIB;
procedure lua_callk(luaState: Plua_State; nargs:cint;  nresults: cint; ctx:Plua_KContext; k:Plua_KFunction); cdecl; external LUALIB;
procedure lua_pushnil(luaState: Plua_State); cdecl; external LUALIB;
procedure lua_pushnumber(luaState: Plua_State; n:lua_Number); cdecl; external LUALIB;
procedure lua_pushinteger(luaState: Plua_State; n: lua_Integer); cdecl; external LUALIB;
function lua_pushstring (luaState: Plua_State; s:Pchar):pchar; cdecl; external LUALIB;
function lua_pushlstring  (luaState: Plua_State; s:Pchar; len:csize_t):pchar; cdecl; external LUALIB;
procedure lua_pushboolean(luaState: Plua_State; n: cint); cdecl; external LUALIB;
function  lua_tonumberx (luaState: Plua_State; idx:cint; pisnum:pcint):lua_Number; cdecl; external LUALIB;
function lua_tointegerx (luaState: Plua_State; idx:cint; pisnum:pcint):lua_Integer; cdecl; external LUALIB;
function lua_toboolean(luaState: Plua_State; idx:cint):cint; cdecl; external LUALIB;
function lua_tolstring (luaState: Plua_State; idx:cint; len:pcsize_t):pchar; cdecl; external LUALIB;
function lua_getglobal(luaState: Plua_State; name:pchar):cint; cdecl; external LUALIB;
function lua_isnumber (luaState: Plua_State; idx:cint):cint; cdecl; external LUALIB;
procedure lua_close (luaState: Plua_State); cdecl; external LUALIB;
procedure lua_createtable (luaState: Plua_State; narray, nrec:cint); external LUALIB;
procedure lua_settable (luaState: Plua_State; idx:cint); external LUALIB;
procedure lua_seti (luaState: Plua_State; idx:cint; n:lua_Integer); external LUALIB;
procedure lua_setfield (luaState: Plua_State; idx:cint; k:pchar); external LUALIB;
function lua_getfield(luaState: Plua_State; idx:cint; k:pchar):cint; external LUALIB;
function lua_geti(luaState: Plua_State; idx:cint; n:lua_Integer):cint; external LUALIB;
procedure lua_settop(luaState: Plua_State; idx:cint); external LUALIB;

implementation

(*
#define lua_pop(L,n)            lua_settop(L, -(n)-1)
*)
procedure lua_pop(luaState: Plua_State; n:cint);
begin
  lua_settop(luaState, -(n)-1);
end;

(*
#define lua_newtable(L)         lua_createtable(L, 0, 0)
*)

procedure lua_newtable(luaState: Plua_State);
begin
  lua_createtable(luaState, 0, 0)
end;

(*
#define lua_getextraspace(L)    ((void * )((char * )(L) - LUA_EXTRASPACE))
*)
function lua_getextraspace(luaState: Plua_State):pointer;
begin
  result:=luaState - sizeof(pointer); // really depends on config
end;
(*
#define lua_tostring(L,i)       lua_tolstring(L, (i), NULL)
*)
function lua_tostring(luaState: Plua_State; idx:cint):pchar;
begin
  result:=lua_tolstring(luaState, idx, nil);
end;

(*
#define lua_tonumber(L,i)       lua_tonumberx(L,(i),NULL)
*)

function lua_tonumber(luaState: Plua_State; idx:cint):lua_Number;
begin
result:=lua_tonumberx(luaState, idx,  nil);
end;

(*
#define lua_tointeger(L,i)      lua_tointegerx(L,(i),NULL)
*)

function lua_tointeger(luaState: Plua_State; idx:cint):lua_Integer;
begin
result:=lua_tointegerx(luaState, idx, nil);
end;

(*
#define luaL_loadfile(L,f)      luaL_loadfilex(L,f,NULL)
*)
function luaL_loadfile(luaState: Plua_State; filename: PChar): cint;
begin
  result:=luaL_loadfilex(luaState, filename, nil);
end;


(*
#define lua_pcall(L,n,r,f)      lua_pcallk(L, (n), (r), (f), 0, NULL)
*)
function lua_pcall(luaState: Plua_State; nargs, nresults, errfunc: cint): cint;
begin
  result:=lua_pcallk(luaState, nargs, nresults, errfunc, nil, nil);
end;

(*
#define lua_call(L,n,r)         lua_callk(L, (n), (r), 0, NULL)
*)
procedure lua_call(luaState: Plua_State; nargs, nresults: cint);
begin
  lua_callk(luaState, nargs, nresults, nil, nil);
end;


(*
#define lua_pushcfunction(L,f)  lua_pushcclosure(L, (f), 0)
*)
procedure lua_pushcfunction (luaState: Plua_State; fn:Plua_CFunction);
begin
  lua_pushcclosure(luaState, fn, 0);
end;


(*
#define lua_register(L,n,f) (lua_pushcfunction(L, (f)), lua_setglobal(L, (n)))
*)
procedure lua_register(luaState: Plua_State; name:PChar; fn:Plua_CFunction);
begin
  lua_pushcfunction(luaState, fn);
  lua_setglobal(luaState, name);
end;

end.
