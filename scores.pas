unit scores;

interface

uses
  SDL3,

  arenas,
  game,
  scoredgames,
  phases;

type State = record
  renderer : PSDL_Renderer;
  back     : Boolean;
  scores   : scoredgames.ScoredGameList;
end;

function New(a : arenas.Arena; renderer : PSDL_Renderer) : scores.State;
function Update(var state : scores.State) : phases.Phase;
procedure Draw(state : scores.State);

procedure KeyDown(var state : scores.State; key : TSDL_Keycode);

implementation

uses
  scoredgamepersistence,
  running;

function New(a : arenas.Arena; renderer : PSDL_Renderer) : scores.State;
begin
  New.renderer := renderer;
  New.back := False;
  { TODO: Refresh scores on every visit, not at program start. }
  New.scores := scoredgamepersistence.SelectTop5ScoredGames(a);
end;

function Update(var state : scores.State) : phases.Phase;
begin
  if state.back then
  begin
    Update := phases.Phase.mainmenu;
    state.back := False;
  end
  else
    Update := phases.Phase.scores;
end;

procedure Draw(state : scores.State);
var
  row : Integer;
  col : Integer;
  gem : game.Gem;
begin
  gem.visible := True;
  for row := 0 to state.Scores.len-1 do
  begin
    gem.y := 50 + 15 * row;
    for col := Low(state.Scores.games[row].gems) to High(state.Scores.games[row].gems) do
    begin
      gem.x := 50 + 10 * col;
      gem.hue := state.Scores.games[row].gems[col];
      running.DrawGem(state.renderer, gem);
    end;
  end;
end;

procedure KeyDown(var state : scores.State; key : TSDL_Keycode);
begin
	case key of
		SDLK_ESCAPE: state.back := True;
	end;
end;

end.
