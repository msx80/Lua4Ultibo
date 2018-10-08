program luasample;

{$mode objfpc}{$H+}

{ Raspberry Pi Zero Application                                                }
{  Add your program code below, add additional units to the "uses" section if  }
{  required and create new units by selecting File, New Unit from the menu.    }
{                                                                              }
{  To compile your program select Run, Compile (or Run, Build) from the menu.  }

uses
  RaspberryPi,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  console,
  Classes,
  Ultibo,
  luaheaders;


function helloPascal(L: Plua_State): integer; cdecl;
begin
  ConsoleWriteLn('Hello from pascal!');
  result:=0; // number of return values
end;

function sumPascal(L: Plua_State): integer; cdecl;
var i:integer;
    s:single;
begin
  s:=0.0;
  for i:=1 to lua_gettop(l) do
    s:=s+lua_tonumber(l, i);

  lua_pushnumber(l, s);
  result:=1;
end;

procedure sample;
var luas:Plua_State;
begin
  luas := luaL_newstate();
  luaL_openlibs(luas);
  lua_register(luas, 'hello', @helloPascal);
  lua_register(luas, 'sum', @sumPascal);

  luaL_loadstring(luas,
    'print("hello from lua! Version is: ".._VERSION )'+LineEnding+
    'print("Calling pascal now..")'+LineEnding+
    'hello()'+LineEnding+
    'print(sum(1,2))'+LineEnding+
    'print(sum(1.5,2.3,4.7,12.3))'+LineEnding+
    'print("Back in lua, bye!")' );

  if lua_pcall(luas, 0, 0, 0) <> LUA_OK then
    raise Exception.create('Lua error: '+string(lua_tostring(luas, -1))); // error is placed on top of stack

  lua_close(luas);
end;

begin
  ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_FULLSCREEN,True);

  ConsoleWriteLn('Starting sample');
  try
   sample();
  except on e:Exception do
   ConsoleWriteLn(e.Message);
  end;
end.

