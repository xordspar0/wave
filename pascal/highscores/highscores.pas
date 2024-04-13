uses
	sdl2,
	sqldb,
	sqlite3conn,
	sysutils;

type
	Character = record
		x,y : Smallint;
	end;

	Gem = record
		x,y     : Smallint;
		hue     : Byte;
		visible : Boolean;
	end;

	RGB = record
		r, g, b : byte;
	end;

	Gamestate = record
		window   : PSDL_Window;
		renderer : PSDL_Renderer;
		c        : Character;
		gems     : Array [0..19] of Gem;
		loot     : Array [0..4] of Gem;
		lootNum  : Smallint;
	end;


function HueToRGB(hue : byte) : RGB;
const
	primary : Byte = 255;
	oneSixth : Byte = 42;
var
	color : RGB;
	secondary : Byte;
begin
	secondary := Abs(primary - Abs((hue - oneSixth) mod (oneSixth * 2) * 6));
	case hue div oneSixth of
	0: begin
		color.r := primary;
		color.g := secondary;
		color.b := 0;
	end;
	1: begin
		color.r := secondary;
		color.g := primary;
		color.b := 0;
	end;
	2: begin
		color.r := 0;
		color.g := primary;
		color.b := secondary;
	end;
	3: begin
		color.r := 0;
		color.g := secondary;
		color.b := primary;
	end;
	4: begin
		color.r := secondary;
		color.g := 0;
		color.b := primary;
	end;
	5: begin
		color.r := primary;
		color.g := 0;
		color.b := secondary;
	end;
	end;

	HueToRGB := color;
end;

function Init() : Gamestate;
var
	game : Gamestate;
begin
	game.window := Nil;
	game.renderer := Nil;

	SDL_Init(SDL_INIT_VIDEO);
	SDL_CreateWindowAndRenderer(640, 480, 0, @game.window, @game.renderer);

	Init := game;
end;

function GameSetup(game : Gamestate) : Gamestate;
var
	i : Smallint;
begin
	game.c.x := 0;
	game.c.y := 0;

	for i := Low(game.gems) to High(game.gems) div 2 do
	with game.gems[i] do
	begin
		x := i * 10 + 20;
		y := 30;
		hue := i * 25;
		visible := true;
	end;
	for i := High(game.gems) div 2 + 1 to High(game.gems) do
	with game.gems[i] do
	begin
		x := (i - (High(game.gems) div 2 + 1)) * 10 + 20;
		y := 40;
		hue := Random(256);
		visible := true;
	end;

	game.lootNum := 0;

	GameSetup := game;
end;

function Grab(game : Gamestate) : Gamestate;
var
	i : Smallint;
begin
	for i := Low(game.gems) to High(game.gems) do
	with game.gems[i] do
	begin
		if visible and (x = game.c.x) and (y = game.c.y) then
		begin
			if game.lootNum <= High(game.loot) then
			begin
				game.loot[game.lootNum] := game.gems[i];
				game.lootNum := game.lootNum + 1;
				game.gems[i].visible := false;
			end;
		end;
	end;

	Grab := game;
end;

procedure DrawCharacter(r : PSDL_Renderer; c : Character);
var
	rect : TSDL_Rect;
begin
	SDL_SetRenderDrawColor(r, 255, 0, 0, 0);

	with rect do
	begin
		x := c.x;
		y := c.y;
		w := 10;
		h := 10;
	end;

	SDL_RenderFillRect(r, @rect);
end;

procedure DrawGems(r : PSDL_Renderer; gems : Array of Gem);
var
	g  : Gem;
	rect : TSDL_Rect;
	color : RGB;
begin
	for g in gems do
	begin
		if g.visible then
		begin
			with rect do
			begin
				x := g.x + 1;
				y := g.y + 1;
				w := 8;
				h := 8;
			end;

			color := HueToRGB(g.hue);
			SDL_SetRenderDrawColor(r, color.r, color.g, color.b, 0);
			SDL_RenderFillRect(r, @rect);
		end;
	end;
end;

function ScoreGame(game : Gamestate) : Integer;
var
	conn   : TSQLite3Connection;
	t      : TSQLTransaction;
	q      : TSQLQuery;
	i      : Smallint = 0;
	sum    : Integer = 0;
	gameId : Integer = 0;
begin
	conn := TSQLite3Connection.Create(nil);
	conn.DatabaseName := 'scores.db';
	t := TSQLTransaction.Create(conn);
	conn.Transaction := t;
	conn.Open;

	t.StartTransaction;
	conn.ExecuteDirect('CREATE TABLE if not exists games (id integer primary key, sum integer);');
	conn.ExecuteDirect('CREATE TABLE if not exists scores (score integer, game_id integer, foreign key (game_id) references games(id));');
	t.Commit;

	t.StartTransaction;

	for i := Low(game.loot) to game.lootNum - 1 do
	begin
		sum := sum + game.loot[i].hue;
	end;

	q := TSQLQuery.Create(nil);
	q.Database := conn;
	q.Transaction := t;
	q.SQL.Text := 'INSERT INTO games (sum) VALUES (:sum) RETURNING id;';
	q.Params.ParamByName('sum').AsInteger := sum;
	q.Open;
	gameId := q.FieldByName('id').AsInteger;
	q.Close;

	for i := Low(game.loot) to game.lootNum - 1 do
	begin
		q.SQL.Text := 'INSERT INTO scores (score, game_id) VALUES (:score, :game_id);';
		q.Params.ParamByName('score').AsInteger := game.loot[i].hue;
		q.Params.ParamByName('game_id').AsInteger := gameId;
		q.ExecSQL;
	end;

	t.Commit;

	ScoreGame := sum;
end;

procedure Gameloop(game : Gamestate);
var
	phase : (running, score, quit) = running;
	event : TSDL_Event;
begin
	while phase <> quit do
	begin

		case phase of
		running:
		begin
			while SDL_PollEvent(@event) = 1 do
			begin
				case event.type_ of
				SDL_QUITEV: phase := quit;
				SDL_KEYDOWN:
					if event.key.repeat_ = 0 then
					case event.key.keysym.sym of
					SDLK_UP:    game.c.y -= 10;
					SDLK_DOWN:  game.c.y += 10;
					SDLK_LEFT:  game.c.x -= 10;
					SDLK_RIGHT: game.c.x += 10;
					end;
				end;
			end;

			game := Grab(game);

			if game.lootNum = 5 then
				phase := score;
		end;

		score:
		begin
			Writeln('Game over!');
			Writeln('Score: ', ScoreGame(game));

			phase := quit;
		end;

		end;

		SDL_SetRenderDrawColor(game.renderer, 0, 0, 0, 0);
		SDL_RenderClear(game.renderer);

		DrawGems(game.renderer, game.gems);
		DrawCharacter(game.renderer, game.c);

		SDL_RenderPresent(game.renderer);
		SDL_Delay(20);
	end;
end;

var
	game : Gamestate;
begin
	game := Init();
	game := Gamesetup(game);
	Gameloop(game);
end.
