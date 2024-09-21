unit arenas;

interface

type Arena = record
  firstFree : Pointer;
  last      : Pointer;
end;

function New(cap : LongInt) : Arena;
function Alloc(var a : Arena; size : LongInt; nElems : LongInt) : Pointer;

implementation

uses
  sysutils;

function New(cap : LongInt) : Arena;
begin
  New.firstFree := GetMem(cap);
  New.last := New.firstFree + cap;
end;

function Alloc(var a : Arena; size : LongInt; nElems : LongInt) : Pointer;
var
  available : LongInt;
begin
  available := a.last - a.firstFree;
  if (available < 0) or (size > available/nElems) then
    Abort();

  Alloc := a.firstFree;
  a.firstFree += size * nElems;
  FillChar(Alloc^, size * nElems, 0);
end;

end.
