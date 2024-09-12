unit scores;

interface

uses
  sdl2,

  scoredgames,
  phases;

type State = record
  renderer : PSDL_Renderer;
  back     : Boolean;
  scores   : Array[0..4] of scoredgames.ScoredGame;
end;

function New(renderer : PSDL_Renderer) : scores.State;
function Update(var state : scores.State) : phases.Phase;
procedure Draw(state : scores.State);

procedure KeyDown(var state : scores.State; key : TSDL_Keycode);

implementation

uses
  game,
  running;

function New(renderer : PSDL_Renderer) : scores.State;
var
  scores   : Array[0..4] of scoredgames.ScoredGame = (
    (sum: 654; gems: (175, 223, 12, 98, 146)),
    (sum: 667; gems: (166, 218, 159, 68, 56)),
    (sum: 846; gems: (109, 243, 63, 229, 202)),
    (sum: 805; gems: (151, 196, 155, 175, 128)),
    (sum: 774; gems: (160, 216, 2, 188, 208))
  );
begin
  New.renderer := renderer;
  New.back := False;
  New.scores := scores;
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
  for row := Low(state.Scores) to High(state.Scores) do
  begin
    gem.y := 50 + 15 * row;
    for col := Low(state.Scores[row].gems) to High(state.Scores[row].gems) do
    begin
      gem.x := 50 + 10 * col;
      gem.hue := state.Scores[row].gems[col];
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
