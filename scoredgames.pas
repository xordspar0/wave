unit scoredgames;

interface

type Gem = Byte;

type ScoredGame = record
  sum  : Integer;
  gems : Array[0..4] of Gem;
end;

type ScoredGameList = record
  games : ^scoredgames.ScoredGame;
  len   : LongInt;
  cap   : LongInt;
end;

implementation

end.
