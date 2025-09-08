unit drawables;

interface

  uses
    SDL3;

  type
    Color = record
      r : Integer;
      g : Integer;
      b : Integer;
    end;
    
  	DrawObjectType = (FilledRect, Texture);

  	DrawSprite = record
  	end;

  	DrawObject = record
  		x : Integer;
  		y : Integer;
      c : Color;
  		case objectType : DrawObjectType of
  		FilledRect : (w : Integer; h : Integer);
  		Texture : (sprite : DrawSprite; r : Double);
  	end;

    DrawObjectList = Array of DrawObject;
  	// DrawObjectList = object
  	// 	items : ^DrawObject;
  	// 	len : Integer;
  	// 	cap : Integer;
  	// end;

  function NewColor(r, g, b : Integer) : Color;
  function NewFilledRect(x, y : Integer; c : Color; w, h : Integer): DrawObject;
  function DrawObjectToString(obj: DrawObject) : UTF8String;
  function DrawObjectsToString(objects: DrawObjectList) : UTF8String;

implementation

  uses sysutils;

  function NewColor(r, g, b : Integer) : Color;
  begin
      NewColor.r := r;
      NewColor.g := g;
      NewColor.b := b;
  end;

  function NewFilledRect(x, y : Integer; c : Color; w, h : Integer): DrawObject;
  begin
    NewFilledRect.x := x;
    NewFilledRect.y := y;
    NewFilledRect.c := c;
    NewFilledRect.objectType := FilledRect;
    NewFilledRect.w := w;
    NewFilledRect.h := h;
  end;

  function TypeToString(t : DrawObjectType) : UTF8String;
  begin
    case t of
    FilledRect: TypeToString := 'FilledRect';
    Texture: TypeToString := 'Texture';
    end;
  end;

  function DrawObjectToString(obj : DrawObject) : UTF8String;
  begin
    DrawObjectToString := sysutils.Format(
      'DrawObject{x:%d y:%d type:%s}',
      [obj.x, obj.y, TypeToString(obj.objectType)]);
  end;

  function DrawObjectsToString(objects : DrawObjectList) : UTF8String;
  var
    i : Integer;
  begin
    DrawObjectsToString := '[ ';

    for i := Low(objects) to High(objects) do
    begin
      DrawObjectsToString += DrawObjectToString(objects[i]) + ' ';
    end;

    DrawObjectsToString += ']';
  end;

end.
