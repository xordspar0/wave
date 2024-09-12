unit scoredgames;

interface

type Gem = Byte;

type ScoredGame = record
  sum  : Integer;
  gems : Array[0..4] of Gem;
end;

type ScoredGameList = record
  cap   : LongInt;
  games : ^scoredgames.ScoredGame;
end;

implementation

end.
