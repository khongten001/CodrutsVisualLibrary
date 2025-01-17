unit Cod.Visual.Chart;

interface

uses
  SysUtils,
  Classes,
  Vcl.Controls,
  Types,
  Vcl.ExtCtrls,
  Cod.Visual.CPSharedLib,
  Math,
  Vcl.Forms,
  WinApi.Windows,
  Vcl.Graphics,
  Vcl.Themes,
  Vcl.Styles,
  UITypes,
  Cod.Components,
  Cod.Types,
  Cod.Graphics;

type
  CChart = class;

  CChartPresets = (ccpNone, ccpPie, ccpPieSimple, ccpBorderPie, ccpBorderPieModern);
  CChartChange = procedure(Sender : CChart; Position, Max: integer) of object;

  CChartOptions = class(TMPersistent)
    private
      //exceptpreset: boolean;
    published
      //property PresetException: boolean read exceptpreset write exceptpreset;
  end;

  CChartAnimate = class(TMPersistent)
    private
      FAnimations: boolean;
      FInterval, FStep, FAnimateTo: integer;
    published
      property Animations: boolean read FAnimations write FAnimations;
      property Interval: integer read FInterval write FInterval;
      property Step: integer read FStep write FStep;
  end;

  CChart = class(TCustomTransparentControl)
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;
    private
      FAuthor, FSite, FVersion: string;
      FOptions: CChartOptions;
      FColor,
      FColorBG,
      FEmptyColor,
      FPenColor: TColor;
      FAnimation: CChartAnimate;
      FPreset: CChartPresets;
      FWid,
      FPenWid,
      FPosition,
      FMax,
      FStartAngle: integer;
      FOnChange: CChartChange;
      FAutoAngle,
      FEnableEColor,
      FSyncBgColor: boolean;
      FAnimationTimer: TTimer;
      FAccent: CAccentColor;

      procedure FAnimationTimerEvent(Sender: TObject);
      procedure ApplyPreset(const Value: CChartPresets);
      procedure SetPenWidth(const Value: integer);
      procedure SetColorBG(const Value: TColor);
      procedure SetPieColor(const Value: TColor);
      procedure SetPenColor(const Value: TColor);
      procedure SetPosition(const Value: integer);
      procedure SetMax(const Value: integer);
      procedure SetStartAngle(const Value: integer);
      procedure SetAutoAngle(const Value: boolean);
      procedure SetWid(const Value: integer);
      procedure SetEmptyColor(const Value: TColor);
      procedure SetEColor(const Value: boolean);
      procedure SetPresets(const Value: CChartPresets);
      procedure ApplyAccentColor;
      procedure SetAccentColor(const Value: CAccentColor);

    protected
      procedure Paint; override;

    published
      property OnMouseEnter;
      property OnMouseLeave;
      property OnMouseDown;
      property OnMouseUp;
      property OnMouseMove;
      property OnClick;

      property ShowHint;
      property Align;
      property Anchors;
      property Cursor;
      property Visible;
      property Enabled;
      property Constraints;
      property DoubleBuffered;
      property OnChange : CChartChange read FOnChange write FOnChange;

      property FormSyncedColor : boolean read FSyncBgColor write FSyncBgColor;

      property AccentColor: CAccentColor read FAccent write SetAccentColor;
      property ColorEmptyEnable: boolean read FEnableEColor write SetEColor;
      property AutoStartAngle : boolean read FAutoAngle write SetAutoAngle;
      property Presets : CChartPresets read FPreset write SetPresets;
      property Options : CChartOptions read FOptions write FOptions;
      property Color : TColor read FColor write SetPieColor;
      property ColorEmpty : TColor read FEmptyColor write SetEmptyColor;
      property ChartWidth: integer read FWid write SetWid;
      property PenColor : TColor read FPenColor write SetPenColor;
      property PenWidth: integer read FPenWid write SetPenWidth;
      property MaxValue: integer read FMax write SetMax;
      property Position: integer read FPosition write SetPosition;
      property StartingAngle: integer read Fstartangle write SetStartAngle;
      property ColorBackGround : TColor read FColorBG write SetColorBG;
      property Animations: CChartAnimate read FAnimation write FAnimation;

      property &&&Author: string Read FAuthor;
      property &&&Site: string Read FSite;
      property &&&Version: string Read FVersion;
  end;

implementation

{ CChart }

constructor CChart.Create(AOwner: TComponent);
begin
  inherited;
  FAuthor                       := 'Petculescu Codrut';
  FSite                         := 'https://www.codrutsoftware.cf';
  FVersion                      := '1.4';

  interceptmouse:=True;

  FAnimation := CChartAnimate.Create(self);
  with FAnimation do begin
    FAnimations := true;
    FInterval := 1;
    FStep := 1;
  end;

  FAnimationTimer := TTimer.Create(nil);
  with FAnimationTimer do begin
    Interval := FAnimation.Interval;
    OnTimer := FAnimationTimerEvent;
    Enabled := false;
  end;

  FSyncBgColor := true;

  FOptions := CChartOptions.Create(self);
  with FOptions do begin

  end;

  FPreset := CChartPresets.ccpNone;

  FEnableEColor := false;

  FPosition := 75;
  FStartAngle := 90;
  FAutoAngle := true;
  FMax := 100;

  FWid := 100;

  FColor := $00C57517;
  FColorBG := clBtnFace;
  FPenColor := $008E5611;
  FEmptyColor := clSilver;

  FPenWid := 3;

  FAccent := CAccentColor.AccentAdjust;
  ApplyAccentColor;

  Width := 100;
  Height := 100;
end;

destructor CChart.Destroy;
begin
  FreeAndNil(FAnimation);
  FreeAndNil(FOptions);
  FAnimationTimer.Enabled := false;
  FreeAndNil(FAnimationTimer);
  inherited;
end;

procedure CChart.FAnimationTimerEvent(Sender: TObject);
begin
  if FAnimationTimer.Tag = 0 then begin // --
    if FPosition <= FAnimation.FANimateTo then begin
      FPosition := FAnimation.FAnimateTo;
      FAnimationTimer.Enabled := False;
    end  else dec(FPosition,FAnimation.Step)
  end else if FAnimationTimer.Tag = 1 then begin // ++
    if FPosition >= FAnimation.FAnimateTo then begin
      FPosition := FAnimation.FAnimateTo;
      FAnimationTimer.Enabled := False;
    end else inc(FPosition,FAnimation.Step)
  end;
  if Assigned(FOnChange) then FOnChange(self, FPosition, FMax);
  Paint;
end;

procedure CChart.Paint;
var
  c, WRem: integer;
  a, b, percent, startp, r: real;
  P1, P2: TPoint;
  workon: TBitMap;
  bgcolor: TColor;
begin
  inherited;
  ApplyAccentColor;
  ApplyPreset(FPreset);

  if Width > Height then Height := Width;
  if Height > Width then Width := Height;

  c := height div 2;

  workon := TBitMap.Create;
  workon.Width := Width;
  workon.Height := Height;
  try
  with workon.Canvas do begin
    Brush.Color := FColorBG;
    if FSyncBgColor then
     begin
      if StrInArray(TStyleManager.ActiveStyle.Name, nothemes) then begin
        Brush.Color := GetParentForm(Self).Color;
      end else
        Brush.Color := TStyleManager.ActiveStyle.GetSystemColor(clBtnFace);
      end;
    FillRect( Self.ClientRect );
    bgcolor := Brush.Color;

    Pen.Width := FPenWid;
    Pen.Color := FPenColor;

    r := width - FPenWid * 4;

    if FAutoAngle then
      startp := FPosition - Fstartangle
    else
      startp := Fstartangle - 90;

    percent := trunc((FMax - FPosition) / FMax * 360);
    a := DegToRad(startp);
    b := DegToRad(startp + percent);
    p1.X := trunc(c + r * cos(a));
    p1.Y := trunc(c + r * sin(a));
    p2.X := trunc(c + r * cos(b));
    p2.Y := trunc(c + r * sin(b));

    if (FEnableEColor) or (FWid < 100) then begin
      Pen.Style := psClear;
      Brush.Color := FEmptyColor;
      Ellipse(FPenWid, FPenWid, width - FPenWid, height - FPenWid);
    end;

    Brush.Color := FColor;
    if FPenWid <> 0 then Pen.Style := psSolid else Pen.Style := psClear;
    Pie(FPenWid, FPenWid, width - FPenWid, height - FPenWid, p1.X, p1.Y, p2.X, p2.Y);

    if FWid < 100 then begin
      Pen.Width := 0;
      Pen.Style := psClear;
      Brush.Color := bgcolor;
      WRem := trunc(FWid / 100 * c);
      Ellipse(WRem, WRem, Width - WRem, Height - WRem);
    end;
  end;
  finally
    // Finalise
   //Canvas.CopyRect(Rect(0,0,width,height), workon.Canvas, workon.canvas.Self.ClientRect);
   CopyRoundRect(workon.Canvas, MakeRoundRect(Rect(3, 3, Width - 3, Height - 3), 1000, 1000), Canvas, Self.ClientRect);

   workon.Free;
  end;

end;

procedure CChart.SetAccentColor(const Value: CAccentColor);
begin
  FAccent := Value;


  if Value <> CAccentColor.None then
    ApplyAccentColor;

  Paint;
end;

procedure CChart.SetAutoAngle(const Value: boolean);
begin
  FAutoAngle := Value;
end;

procedure CChart.SetColorBG(const Value: TColor);
begin
  FColorBG := Value;
  Paint;
end;

procedure CChart.SetEColor(const Value: boolean);
begin
  FEnableEColor := Value;
  Paint;
end;

procedure CChart.SetEmptyColor(const Value: TColor);
begin
  FEmptyColor := Value;
  Paint;
end;

procedure CChart.SetMax(const Value: integer);
begin
  FMax := Value;
  Paint;
end;

procedure CChart.SetPenColor(const Value: TColor);
begin
  FPenColor := Value;
  Paint;
end;

procedure CChart.SetPenWidth(const Value: integer);
begin
  FPenWid := Value;
  Paint;
end;

procedure CChart.SetPieColor(const Value: TColor);
begin
  FColor := Value;
  Paint;
end;

procedure CChart.SetPosition(const Value: integer);
begin
  if Value <= FMax then begin
    if FAnimation.Animations then begin
        if Value < FPosition then
          FAnimationTimer.Tag :=0 // --
        else if Value > Position then
          FAnimationTimer.Tag := 1; // ++

        FAnimation.FAnimateTo := Value;
        FAnimationTimer.Interval := FAnimation.Interval;
        FAnimationTimer.Enabled := true;
        Paint;
    end else begin
      FPosition := Value;
      if Assigned(FOnChange) then FOnChange(self, FPosition, FMax);
      Paint;
    end;
  end;

  Paint;
end;

procedure CChart.SetPresets(const Value: CChartPresets);
begin
  ApplyPreset(Value);
  Paint;
end;

procedure CChart.ApplyAccentColor;
var
  AccColor: TColor;
begin
  if FAccent = CAccentColor.None then
    Exit;

  AccColor := GetAccentColor(FAccent);

  FColor := AccColor;
  FPenColor := ChangeColorSat(AccColor, -40);
end;

procedure CChart.ApplyPreset(const Value: CChartPresets);
begin
  FPreset := Value;

  if FPreset = ccpNone then Exit;


  case FPreset of
    ccpPie: begin
      FColor := $00C57517;
      FColorBG := clBtnFace;
      FPenColor := $008E5611;
      FEmptyColor := clSilver;

      FEnableEColor := false;

      FAnimation.FAnimations := true;
      FAnimation.FStep := 1;
      FAnimation.FInterval := 1;

      FWid := 100;
      FPosition := 50;
      FAutoAngle := true;
      FMax := 100;
      FPenWid := 3;

      FSyncBgColor := true;
    end;
    ccpPieSimple: begin
      FColor := $00C57517;
      FColorBG := clBtnFace;
      FPenColor := $008E5611;
      FEmptyColor := clSilver;

      FEnableEColor := false;

      FAnimation.FAnimations := true;
      FAnimation.FStep := 1;
      FAnimation.FInterval := 1;

      FWid := 100;
      FAutoAngle := true;
      FMax := 100;
      FPenWid := 0;

      FSyncBgColor := true;
    end;
    ccpBorderPie: begin
      FColor := $00C57517;
      FColorBG := clBtnFace;
      FPenColor := $008E5611;
      FEmptyColor := clSilver;

      FEnableEColor := true;

      FAnimation.FAnimations := true;
      FAnimation.FStep := 1;
      FAnimation.FInterval := 1;

      FWid := 35;
      FAutoAngle := true;
      FMax := 100;
      FPenWid := 0;

      FSyncBgColor := true;
    end;
    ccpBorderPieModern: begin
      FColor := $00C57517;
      FColorBG := clBtnFace;
      FPenColor := $008E5611;
      FEmptyColor := clSilver;

      FEnableEColor := true;

      FAnimation.FAnimations := true;
      FAnimation.FStep := 1;
      FAnimation.FInterval := 1;

      FWid := 35;
      FAutoAngle := true;
      FMax := 100;
      FPenWid := 3;

      FSyncBgColor := true;
    end;
  end;
end;

procedure CChart.SetStartAngle(const Value: integer);
begin
  Fstartangle := Value;
  Paint;
end;

procedure CChart.SetWid(const Value: integer);
begin
  FWid := Value;
  Paint;
end;

end.
