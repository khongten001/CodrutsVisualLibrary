unit Cod.Visual.LoadIco;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  Cod.Components;

type

  CAnimType = (canimSpinny, canimDots, canimJustRing, canimCircleRing);

  CLoadAnim = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FAuthor, FSite, FVersion: string;
      FSelect: CAnimType;
      FAnimate,
      FProportional: boolean;
      FAnimationSpeed,
      CFrame: integer;
      FAnimateTimer: TTimer;
      procedure FAnimateTimerEvent(Sender: TObject);
    procedure SetTimerEnable(const Value: boolean);
    procedure SetAnimSpeed(const Value: integer);
    protected
      procedure Paint; override;
    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property Color;
      property ParentColor;

      property ShowHint;
      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;

      property Animation : CAnimType read FSelect write FSelect;
      property Animate : boolean read FAnimate write SetTimerEnable;
      property AnimateSpeed : integer read FAnimationSpeed write SetAnimSpeed;

      property &&&Author: string Read FAuthor;
      property &&&Site: string Read FSite;
      property &&&Version: string Read FVersion;
  end;

implementation

{ CProgress }

constructor CLoadAnim.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '0.2';

  interceptmouse:=True;

  FAnimateTImer := TTimer.Create(nil);
  with FAnimateTimer do begin
    Interval := 10;
    OnTimer := FAnimateTimerEvent;
    Enabled := true;
  end;

  FAnimationSpeed := 10;

  FAnimate := true;
  FSelect := canimSpinny;
  CFrame := 1;

  Width := 40;
  Height := 40;

  FProportional := true;
  FAnimate := true;
end;

destructor CLoadAnim.Destroy;
begin
  FAnimateTimer.Enabled := false;
  FreeAndNil(FAnimateTimer);
  inherited;
end;


procedure CLoadAnim.FAnimateTimerEvent(Sender: TObject);
begin
  CFrame := CFrame + 1;
  if CFrame > 100 then CFrame := 1;
  //
  Paint;
end;

procedure CLoadAnim.Paint;
var
  w, h, i,a,b,c,d: integer;
  Bitmap: TBitMap;
begin
  inherited;
  if FProportional then if Height < Width then Height := Width else Width := Height;

  // Create
  Bitmap := TBitmap.Create(Width, Height);

  // Fill
  with Bitmap.Canvas do begin
    Brush.Color := Self.Color;
    FillRect(ClipRect);
  end;

  // Draw
  case Animation of
    canimSpinny: begin
      with Bitmap.Canvas do begin
        Pen.Width := 2;
        Pen.Color := 12893892;
        Brush.Style := bsClear;
        w := trunc(width / 10);
        h := trunc(height / 10);
        for I := 1 to w do
          Ellipse( w + i, h + i, width - i - w, height - i - h );

        pen.Color := clAqua;
        brush.Color := clAqua;
        a := trunc( cos(CFrame/100 * 360 * pi/180) * (width / 2 - 2 * w) + width / 2 + w );
        b := trunc( sin(CFrame/100 * 360 * pi/180) * (height / 2 - 2 * h) + height / 2 + h );
        c := trunc( cos(CFrame/100 * 360 * pi/180) * (width / 2 - 2 * w) + width / 2 - w );
        d := trunc( sin(CFrame/100 * 360 * pi/180) * (height / 2 - 2 * h) + height / 2 - h );
        Ellipse( a, b,c,d );
      end;
    end;
  end;

  // Free
  Canvas.Draw(0, 0, Bitmap);
  Bitmap.Free;
end;

procedure CLoadAnim.SetAnimSpeed(const Value: integer);
begin
  FAnimationSpeed := Value;
  FAnimateTimer.Interval := FAnimationSpeed;
  Invalidate;
end;

procedure CLoadAnim.SetTimerEnable(const Value: boolean);
begin
  FAnimate := Value;
  FAnimateTimer.Enabled := FAnimate;
end;

end.
