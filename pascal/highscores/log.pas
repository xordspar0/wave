unit log;

interface

type
  LogLevel = (error, info, debug);

  Logger = record
    dest  : Text;
    level : LogLevel;
  end;

function NewLogger() : Logger;
procedure LogError(l : Logger; msg : String);
procedure  LogInfo(l : Logger; msg : String);
procedure LogDebug(l : Logger; msg : String);

implementation

uses
  DateUtils,
  SysUtils;

function NewLogger() : Logger;
var
  l : Logger;
begin
  l.dest := StdErr;
  l.level := info;
  NewLogger := l;
end;

procedure LogInternal(l : Logger; prefix : String; msg : String);
var
  timestamp : String;
begin
  timestamp := DateToISO8601(Now(), False);
  Writeln(timestamp + prefix + msg);
end;

procedure LogError(l : Logger; msg : String);
begin
  if ord(l.level) >= ord(error) then
  begin
    LogInternal(l, ' ERROR ', msg);
  end;
end;

procedure LogInfo(l : Logger; msg : String);
begin
  if ord(l.level) >= ord(info) then
  begin
    LogInternal(l, '  INFO ', msg);
  end;
end;

procedure LogDebug(l : Logger; msg : String);
begin
  if ord(l.level) >= ord(debug) then
  begin
    LogInternal(l, ' DEBUG ', msg);
  end;
end;

end.
