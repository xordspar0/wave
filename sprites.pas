unit sprites;

interface

uses
	SDL3;

type
	Sprite = (
		DieFace,
		DieFaceShadow,
		DieDot
	);

	SpriteData = record
		spritesheetName : String;
		spritesheet     : PSDL_Texture;
		rect            : TSDL_FRect;
	end;

	SpriteDataList = array of SpriteData;

function Load(renderer : PSDL_Renderer) : SpriteDataList;

implementation

uses
	SDL3_Image;

function newSpriteData(
	spritesheetName : String;
	spriteSheet : PSDL_Texture;
	rect : TSDL_FRect
) : SpriteData;
begin
	newSpriteData.spriteSheetName := spriteSheetName;
	newSpriteData.spriteSheet := spriteSheet;
	newSpriteData.rect := rect;
end;

function newRect(x, y, w, h : Single) : TSDL_FRect;
begin
	newRect.x := x;
	newRect.y := y;
	newRect.w := w;
	newRect.h := h;
end;

function Load(renderer : PSDL_Renderer) : SpriteDataList;
var
	dice : PSDL_Texture;
begin
	{ TODO: Load this from a config file or something. }
	dice := IMG_LoadTexture(renderer, 'dice.png');
	if dice = Nil then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, 'Failed to load spritesheet: %s', [SDL_GetError()]);
	end;

	Load := [];
	SetLength(Load, Ord(High(Sprite)) + 1);

	Load[Ord(Sprite.DieFace)] := newSpriteData(
		'dice.png',
		dice,
		newRect(0, 0, 32, 32)
	);

	Load[Ord(Sprite.DieFaceShadow)] := newSpriteData(
		'dice.png',
		dice,
		newRect(32, 0, 32, 32)
	);

	Load[Ord(Sprite.DieDot)] := newSpriteData(
		'dice.png',
		dice,
		newRect(64, 0, 6, 6)
	);

	Writeln(Length(Load), Ord(Sprite.DieFace), Ord(Sprite.DieFaceShadow));
end;

end.
