unit uIcones;

{$mode ObjFPC}{$H+}

{
  Ícones vetoriais desenhados em código (sem arquivos de imagem).
  Cada ícone é desenhado em 4x e reduzido com HALFTONE (suavizado) uma única
  vez; depois fica em cache no TImage. O hover só troca o bitmap já pronto,
  portanto não há custo de desenho durante o uso.
}

interface

uses
  Windows, Classes, SysUtils, Types, Graphics, Controls, ExtCtrls;

type
  TIcone = (icHome, icCarrinho, icEngrenagem, icFiltro, icLimpar, icPdf, icExcel);

function CriarIcone(AIcone: TIcone; ALargura, AAltura: Integer;
  ACorGlifo, ACorChip, ACorBase: TColor): TBitmap;

{ Aplica o ícone no TImage, com chip arredondado e efeito hover. }
procedure EstilizarIcone(AImg: TImage; AIcone: TIcone;
  ACorGlifo, ACorChip, ACorHover, ACorBase: TColor);

implementation

type
  TIconeHover = class(TComponent)
  public
    Img: TImage;
    Normal, Hover: TBitmap;
    destructor Destroy; override;
    procedure Entrou(Sender: TObject);
    procedure Saiu(Sender: TObject);
  end;

destructor TIconeHover.Destroy;
begin
  Normal.Free;
  Hover.Free;
  inherited Destroy;
end;

procedure TIconeHover.Entrou(Sender: TObject);
begin
  if Assigned(Hover) then Img.Picture.Assign(Hover);
end;

procedure TIconeHover.Saiu(Sender: TObject);
begin
  if Assigned(Normal) then Img.Picture.Assign(Normal);
end;

procedure Glifo(C: TCanvas; AIcone: TIcone; const S: Integer;
  AGlifo, AChip: TColor);
var
  k: Integer;
  u: Double;
  cx, cy, a: Double;

  function P(X, Y: Double): TPoint;
  begin
    Result := Point(Round(X * u), Round(Y * u));
  end;

  procedure Linha(X1, Y1, X2, Y2: Double; Larg: Double);
  begin
    C.Pen.Width := Round(Larg * u);
    C.MoveTo(Round(X1 * u), Round(Y1 * u));
    C.LineTo(Round(X2 * u), Round(Y2 * u));
  end;

begin
  u := S / 128;
  C.Pen.Style := psSolid;
  C.Pen.Color := AGlifo;
  C.Brush.Color := AGlifo;
  C.Brush.Style := bsSolid;

  case AIcone of
    icHome:
      begin
        C.Polygon([P(64, 22), P(112, 64), P(98, 64), P(98, 106), P(30, 106),
          P(30, 64), P(16, 64)]);
        C.Brush.Color := AChip;
        C.Pen.Color := AChip;
        C.Rectangle(Round(54 * u), Round(76 * u), Round(74 * u), Round(106 * u));
      end;
    icCarrinho:
      begin
        C.Pen.EndCap := pecRound;
        C.Pen.JoinStyle := pjsRound;
        Linha(16, 30, 34, 30, 9);
        Linha(34, 30, 48, 86, 9);
        Linha(48, 86, 100, 86, 9);
        Linha(100, 86, 110, 46, 9);
        Linha(110, 46, 38, 46, 9);
        C.Ellipse(Round(42 * u), Round(92 * u), Round(66 * u), Round(116 * u));
        C.Ellipse(Round(82 * u), Round(92 * u), Round(106 * u), Round(116 * u));
      end;
    icEngrenagem:
      begin
        C.Pen.EndCap := pecFlat;
        for k := 0 to 7 do
        begin
          a := k * Pi / 4;
          Linha(64 + 34 * Cos(a), 64 + 34 * Sin(a),
                64 + 52 * Cos(a), 64 + 52 * Sin(a), 16);
        end;
        C.Ellipse(Round(28 * u), Round(28 * u), Round(100 * u), Round(100 * u));
        C.Brush.Color := AChip;
        C.Pen.Color := AChip;
        C.Ellipse(Round(48 * u), Round(48 * u), Round(80 * u), Round(80 * u));
      end;
    icFiltro:
      begin
        C.Polygon([P(18, 26), P(110, 26), P(76, 68), P(76, 108), P(52, 96),
          P(52, 68)]);
      end;
    icLimpar:
      begin
        C.Pen.EndCap := pecRound;
        Linha(36, 36, 92, 92, 14);
        Linha(92, 36, 36, 92, 14);
      end;
    icPdf, icExcel:
      begin
        C.Rectangle(Round(30 * u), Round(14 * u), Round(98 * u), Round(114 * u));
        C.Brush.Color := AChip;
        C.Pen.Color := AChip;
        if AIcone = icPdf then
        begin
          C.Font.Name := 'Segoe UI';
          C.Font.Style := [fsBold];
          C.Font.Color := AChip;
          C.Font.Height := -Round(34 * u);
          C.Brush.Style := bsClear;
          C.TextOut(Round(64 * u - C.TextWidth('PDF') / 2), Round(46 * u), 'PDF');
        end
        else
        begin
          { grade 3x3 }
          cx := 40; cy := 30;
          for k := 0 to 2 do
          begin
            C.Pen.Color := AChip;
            Linha(cx, cy + k * 28 + 14, 88, cy + k * 28 + 14, 5);
          end;
          Linha(64, 30, 64, 100, 5);
        end;
      end;
  end;
end;

function CriarIcone(AIcone: TIcone; ALargura, AAltura: Integer;
  ACorGlifo, ACorChip, ACorBase: TColor): TBitmap;
const
  ESC = 4;
var
  Big, G: TBitmap;
  Lado, BigLado, Off: Integer;
begin
  Result := TBitmap.Create;
  Result.PixelFormat := pf24bit;
  Result.SetSize(ALargura, AAltura);

  Lado := ALargura;
  if AAltura < Lado then Lado := AAltura;
  BigLado := Lado * ESC;
  Off := Round(BigLado * 0.15);

  Big := TBitmap.Create;
  G := TBitmap.Create;
  try
    Big.PixelFormat := pf24bit;
    Big.SetSize(BigLado, BigLado);
    Big.Canvas.Brush.Color := ACorBase;
    Big.Canvas.Pen.Color := ACorBase;
    Big.Canvas.FillRect(0, 0, BigLado, BigLado);

    { chip arredondado }
    if ACorChip <> ACorBase then
    begin
      Big.Canvas.Brush.Color := ACorChip;
      Big.Canvas.Pen.Color := ACorChip;
      Big.Canvas.RoundRect(0, 0, BigLado, BigLado,
        Round(BigLado * 0.40), Round(BigLado * 0.40));
    end;

    { glifo desenhado à parte (fundo = cor do chip) e encaixado no chip }
    G.PixelFormat := pf24bit;
    G.SetSize(BigLado - 2 * Off, BigLado - 2 * Off);
    G.Canvas.Brush.Color := ACorChip;
    G.Canvas.Pen.Color := ACorChip;
    G.Canvas.FillRect(0, 0, G.Width, G.Height);
    Glifo(G.Canvas, AIcone, G.Width, ACorGlifo, ACorChip);
    Big.Canvas.Draw(Off, Off, G);

    { redução suavizada }
    SetStretchBltMode(Result.Canvas.Handle, HALFTONE);
    SetBrushOrgEx(Result.Canvas.Handle, 0, 0, nil);
    StretchBlt(Result.Canvas.Handle, (ALargura - Lado) div 2,
      (AAltura - Lado) div 2, Lado, Lado, Big.Canvas.Handle, 0, 0,
      BigLado, BigLado, SRCCOPY);
    if ALargura > Lado then
    begin
      Result.Canvas.Brush.Color := ACorBase;
      Result.Canvas.FillRect(0, 0, (ALargura - Lado) div 2, AAltura);
      Result.Canvas.FillRect((ALargura - Lado) div 2 + Lado, 0, ALargura, AAltura);
    end;
  finally
    G.Free;
    Big.Free;
  end;
end;

procedure EstilizarIcone(AImg: TImage; AIcone: TIcone;
  ACorGlifo, ACorChip, ACorHover, ACorBase: TColor);
var
  H: TIconeHover;
  I: Integer;
begin
  H := nil;
  for I := 0 to AImg.ComponentCount - 1 do
    if AImg.Components[I] is TIconeHover then
      H := TIconeHover(AImg.Components[I]);
  if H = nil then
  begin
    H := TIconeHover.Create(AImg);
    H.Img := AImg;
  end;
  FreeAndNil(H.Normal);
  FreeAndNil(H.Hover);
  H.Normal := CriarIcone(AIcone, AImg.Width, AImg.Height,
    ACorGlifo, ACorChip, ACorBase);
  H.Hover := CriarIcone(AIcone, AImg.Width, AImg.Height,
    ACorGlifo, ACorHover, ACorBase);
  AImg.Proportional := False;
  AImg.Stretch := False;
  AImg.Center := True;
  AImg.Transparent := False;
  AImg.OnMouseEnter := @H.Entrou;
  AImg.OnMouseLeave := @H.Saiu;
  AImg.Picture.Assign(H.Normal);
end;

end.
