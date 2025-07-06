unit game;

interface

uses
	scoredgames;

type
	Character = record
		x,y : Smallint;
	end;

	Die = record
		x,y   : Integer;
		r     : Integer;
		value : Byte;
	end;

	State = record
		c           : Character;
		dice        : Array [0..19] of Die;
	end;

function New() : State;
function ScoreGame(state : game.State) : scoredgames.ScoredGame;

implementation

uses
	SDL3;

function New() : State;
var
	i : Smallint;
	g : State;
begin
	g.c.x := 0;
	g.c.y := 0;

	for i := Low(g.dice) to High(g.dice) do
	with g.dice[i] do
	begin
		x := i * 40 + 20;
		y := 30;
		r := 0;
		value := i mod 6 + 1;
	end;

	New := g;
end;

function ScoreGame(state : game.State) : scoredgames.ScoredGame;
begin
	ScoreGame.sum := 0;

	// for i := Low(state.loot) to High(state.loot) do
	// begin
	// 	ScoreGame.gems[i] := state.loot[i].hue;
	// 	ScoreGame.sum := ScoreGame.sum + state.loot[i].hue;
	// end;
end;

end.
