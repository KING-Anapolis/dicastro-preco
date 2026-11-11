unit uTema;

{$mode ObjFPC}{$H+}
{$codepage utf8}

{
  Tema visual central do Dicastro.

  - Dois temas: CLARO (padrão) e ESCURO. Preferência em conf.ini:
        [DICASTRO]
        TEMA=CLARO   (ou ESCURO)
  - InstalarTema deve ser chamado uma única vez no .lpr, logo após
    Application.Initialize. A partir daí TODO formulário criado recebe o
    tema automaticamente no primeiro Show, sem alterar cada unit.
  - AlternarTema troca claro/escuro em tempo de execução (Ctrl+T).
  - Contraste: todo texto de label/checkbox é verificado contra o fundo real
    (razão WCAG 4,5:1) e corrigido quando ilegível.
  - Grades: sem linhas verticais, linha selecionada em "pílula" arredondada,
    texto centralizado na vertical e com recuo, cabeçalho plano.
}

interface

uses
  Windows, UxTheme, Classes, SysUtils, Graphics, Controls, Forms, StdCtrls,
  ExtCtrls,
  ComCtrls, DBGrids, Grids, DBCtrls, DB, Math, Types, LCLType,
  DateTimePicker, RxDBGrid, ColorSpeedButton, BGRABitmap, BGRABitmapTypes,
  uFuncoes;

type
  TPaleta = record
    Fundo: TColor;           { fundo de formulários e abas }
    Superficie: TColor;      { grades, campos de edição }
    Zebra: TColor;           { linha alternada }
    Borda: TColor;
    Texto: TColor;
    TextoSuave: TColor;
    Destaque: TColor;
    CabecalhoFundo: TColor;
    CabecalhoTexto: TColor;
    Selecao: TColor;
    Alerta: TColor;          { texto de alerta (ex.: estoque zerado) }
  end;

const
  MARKUP_VERDE = 49;    { > 49%  verde    (igual ao cadastro) }
  MARKUP_AMARELO = 29;  { > 29%  amarelo; abaixo disso vermelho }

var
  Paleta: TPaleta;
  TemaEscuro: Boolean = False;

procedure InstalarTema;
procedure AlternarTema;
procedure AplicarTema(AForm: TCustomForm);
procedure CorMarkup(AValor: Double; out Fundo, Texto: TColor);
function CorFaixaMarkup(AValor: Double): TColor;
function MisturarCor(A, B: TColor; APerc: Integer): TColor;
function Contraste(A, B: TColor): Double;

{ Desenho moderno de célula de grade (fundo zebra, pílula de seleção, texto
  centralizado). Usado pelas grades que não têm desenho próprio. }
procedure PintarCelulaModerna(AGrade: TCustomDBGrid; const ARect: TRect;
  AColuna: TColumn; AEstado: TGridDrawState; ACorTexto: TColor = clDefault;
  AEstilo: TFontStyles = []; ARecuoDireita: Integer = 0;
  ASemTexto: Boolean = False; AFundo: TColor = clDefault);

{ Faz as colunas preencherem a largura da grade; ACampos (separados por ;) 
  são as colunas que absorvem a sobra (as demais mantêm a largura). }
procedure PreencherColunas(AGrade: TCustomDBGrid; const ACampos: String);

implementation

uses
  Buttons, uMetaDarkStyle, uDarkStyleSchemes, uWin32WidgetSetDark, uInstancia;

const
  FONTE_PADRAO = 'Segoe UI';

type
  { Acesso aos membros protegidos. }
  TGradeAcesso = class(TCustomDBGrid);
  TControlAcesso = class(TControl);
  TWinAcesso = class(TWinControl);

  TTemaHook = class
    procedure FormAdicionado(Sender: TObject; Form: TCustomForm);
    procedure PrimeiroShow(Sender: TObject);
    procedure PintarFundoAba(Sender: TObject);
    procedure BtnParams(Sender: TObject; Field: TField; AFont: TFont;
      var Background: TColor; var SortMarker: TSortMarker; IsDown: Boolean);
    procedure CelulaGenerica(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
  end;

var
  Hook: TTemaHook;
  Instalado: Boolean = False;

procedure DefinirPaleta;
begin
  if TemaEscuro then
  begin
    Paleta.Fundo          := RGBToColor(24, 26, 31);
    Paleta.Superficie     := RGBToColor(33, 36, 43);
    Paleta.Zebra          := RGBToColor(38, 42, 50);
    Paleta.Borda          := RGBToColor(58, 63, 74);
    Paleta.Texto          := RGBToColor(232, 234, 238);
    Paleta.TextoSuave     := RGBToColor(160, 167, 180);
    Paleta.Destaque       := RGBToColor(77, 148, 255);
    Paleta.CabecalhoFundo := RGBToColor(44, 48, 57);
    Paleta.CabecalhoTexto := RGBToColor(200, 206, 217);
    Paleta.Selecao        := RGBToColor(34, 64, 110);
    Paleta.Alerta         := RGBToColor(255, 120, 120);
  end
  else
  begin
    Paleta.Fundo          := RGBToColor(243, 245, 248);
    Paleta.Superficie     := RGBToColor(255, 255, 255);
    Paleta.Zebra          := RGBToColor(248, 250, 252);
    Paleta.Borda          := RGBToColor(221, 226, 233);
    Paleta.Texto          := RGBToColor(28, 36, 50);
    Paleta.TextoSuave     := RGBToColor(88, 98, 115);
    Paleta.Destaque       := RGBToColor(25, 100, 220);
    Paleta.CabecalhoFundo := RGBToColor(234, 239, 246);
    Paleta.CabecalhoTexto := RGBToColor(48, 60, 80);
    Paleta.Selecao        := RGBToColor(214, 230, 255);
    Paleta.Alerta         := RGBToColor(185, 28, 28);
  end;
end;

procedure CorMarkup(AValor: Double; out Fundo, Texto: TColor);
begin
  if AValor > MARKUP_VERDE then
  begin
    if TemaEscuro then
    begin
      Fundo := RGBToColor(27, 77, 46);  Texto := RGBToColor(134, 239, 172);
    end
    else
    begin
      Fundo := RGBToColor(198, 239, 206); Texto := RGBToColor(0, 97, 0);
    end;
  end
  else if AValor > MARKUP_AMARELO then
  begin
    if TemaEscuro then
    begin
      Fundo := RGBToColor(92, 74, 12);  Texto := RGBToColor(253, 224, 71);
    end
    else
    begin
      Fundo := RGBToColor(255, 235, 156); Texto := RGBToColor(156, 95, 0);
    end;
  end
  else
  begin
    if TemaEscuro then
    begin
      Fundo := RGBToColor(94, 28, 28);  Texto := RGBToColor(252, 165, 165);
    end
    else
    begin
      Fundo := RGBToColor(255, 199, 206); Texto := RGBToColor(156, 0, 6);
    end;
  end;
end;

function CorFaixaMarkup(AValor: Double): TColor;
var
  F, T: TColor;
begin
  CorMarkup(AValor, F, T);
  Result := T;
end;

function MisturarCor(A, B: TColor; APerc: Integer): TColor;
var
  CA, CB: LongInt;
begin
  CA := ColorToRGB(A);
  CB := ColorToRGB(B);
  Result := RGBToColor(
    Red(CA) + (Red(CB) - Red(CA)) * APerc div 100,
    Green(CA) + (Green(CB) - Green(CA)) * APerc div 100,
    Blue(CA) + (Blue(CB) - Blue(CA)) * APerc div 100);
end;

function LuminanciaRel(AColor: TColor): Double;
  function Canal(V: Integer): Double;
  var
    S: Double;
  begin
    S := V / 255;
    if S <= 0.03928 then Result := S / 12.92
    else Result := Power((S + 0.055) / 1.055, 2.4);
  end;
var
  C: LongInt;
begin
  C := ColorToRGB(AColor);
  Result := 0.2126 * Canal(Red(C)) + 0.7152 * Canal(Green(C)) +
    0.0722 * Canal(Blue(C));
end;

function Contraste(A, B: TColor): Double;
var
  LA, LB: Double;
begin
  LA := LuminanciaRel(A);
  LB := LuminanciaRel(B);
  if LA < LB then
  begin
    LA := LuminanciaRel(B);
    LB := LuminanciaRel(A);
  end;
  Result := (LA + 0.05) / (LB + 0.05);
end;

function ClaroDemais(AColor: TColor): Boolean;
var
  C: Longint;
begin
  C := ColorToRGB(AColor);
  Result := (Red(C) * 299 + Green(C) * 587 + Blue(C) * 114) div 1000 > 150;
end;

function CorPadraoSistema(AColor: TColor): Boolean;
begin
  Result := (AColor = clBtnFace) or (AColor = clDefault) or
    (AColor = clForm) or (AColor = clWindow) or (AColor = clWhite) or
    (AColor = clMoneyGreen);
end;

function FonteSegura(const ANome: String): Boolean;
begin
  { não troca fontes de símbolos/ícones }
  Result := not (SameText(ANome, 'Wingdings') or SameText(ANome, 'Webdings') or
    SameText(ANome, 'Marlett') or SameText(ANome, 'Segoe MDL2 Assets') or
    SameText(ANome, 'Segoe Fluent Icons'));
end;

procedure AplicarFonte(AControl: TControl);
begin
  if (not TControlAcesso(AControl).ParentFont) and
     FonteSegura(AControl.Font.Name) and
     not SameText(AControl.Font.Name, FONTE_PADRAO) then
    AControl.Font.Name := FONTE_PADRAO;
end;

{ Cor de fundo real atrás de um controle (primeiro ancestral com cor própria). }
function FundoEfetivo(AControl: TControl): TColor;
var
  P: TWinControl;
begin
  P := AControl.Parent;
  while Assigned(P) do
  begin
    if (not TControlAcesso(P).ParentColor) and (P.Color <> clDefault) then
      Exit(P.Color);
    P := P.Parent;
  end;
  Result := Paleta.Fundo;
end;

{ Garante legibilidade: se o texto não atinge 4,5:1 contra o fundo real,
  usa a cor de texto do tema (ou preto/branco como último recurso). }
procedure GarantirContraste(AControl: TControl; AMinimo: Double = 4.5);
var
  Fundo, Atual: TColor;
begin
  if (AControl is TLabel) and not TLabel(AControl).Transparent then
    Fundo := AControl.Color
  else
    Fundo := FundoEfetivo(AControl);
  Atual := AControl.Font.Color;
  if Contraste(Atual, Fundo) >= AMinimo then Exit;

  if Contraste(Paleta.Texto, Fundo) >= 4.5 then
    AControl.Font.Color := Paleta.Texto
  else if LuminanciaRel(Fundo) > 0.4 then
    AControl.Font.Color := clBlack
  else
    AControl.Font.Color := clWhite;
end;

{ Aplica o estilo escuro nativo do Windows (barras de rolagem, bordas de
  campos e combos). No tema claro volta ao padrão. }
procedure TemaNativo(AControl: TWinControl; const AClasseEscura: WideString);
begin
  if not AControl.HandleAllocated then Exit;
  if TemaEscuro then
    SetWindowTheme(AControl.Handle, PWideChar(AClasseEscura), nil)
  else
    SetWindowTheme(AControl.Handle, nil, nil);
end;

{ ---------------- Grades ---------------- }

procedure PintarCelulaModerna(AGrade: TCustomDBGrid; const ARect: TRect;
  AColuna: TColumn; AEstado: TGridDrawState; ACorTexto: TColor;
  AEstilo: TFontStyles; ARecuoDireita: Integer; ASemTexto: Boolean;
  AFundo: TColor);
const
  RECUO = 10;
  RAIO = 14;
var
  Cv: TCanvas;
  DS: TDataSet;
  Campo: TField;
  Sel, Par, Primeira, Ultima: Boolean;
  I, X, Y, Larg: Integer;
  Txt: String;
  Alinha: TAlignment;
  TS: TTextStyle;
begin
  if not Assigned(AColuna) or not Assigned(AColuna.Field) then Exit;
  Campo := AColuna.Field;
  if Campo.DataType in [ftBoolean, ftBlob, ftGraphic, ftMemo, ftFmtMemo] then
    Exit;  { mantém o desenho padrão da grade }

  Cv := AGrade.Canvas;
  DS := Campo.DataSet;
  Sel := (gdSelected in AEstado) and not
    (Assigned(DS) and DS.Active and DS.IsEmpty);
  Par := Assigned(DS) and DS.Active and Odd(DS.RecNo);

  { fundo da linha }
  if AFundo <> clDefault then Cv.Brush.Color := AFundo
  else if Par then Cv.Brush.Color := Paleta.Superficie
  else Cv.Brush.Color := Paleta.Zebra;
  Cv.FillRect(ARect);

  { pílula de seleção, recortada na célula para não vazar para as vizinhas }
  if Sel then
  begin
    Primeira := True;
    Ultima := True;
    for I := 0 to AColuna.Index - 1 do
      if TGradeAcesso(AGrade).Columns[I].Visible then Primeira := False;
    for I := AColuna.Index + 1 to TGradeAcesso(AGrade).Columns.Count - 1 do
      if TGradeAcesso(AGrade).Columns[I].Visible then Ultima := False;

    Cv.Brush.Color := Paleta.Selecao;
    Cv.Pen.Color := Paleta.Selecao;
    Cv.ClipRect := ARect;
    Cv.Clipping := True;
    try
      if Primeira and Ultima then
        Cv.RoundRect(ARect.Left + 3, ARect.Top + 2, ARect.Right - 3,
          ARect.Bottom - 2, RAIO, RAIO)
      else if Primeira then
        Cv.RoundRect(ARect.Left + 3, ARect.Top + 2, ARect.Right + RAIO,
          ARect.Bottom - 2, RAIO, RAIO)
      else if Ultima then
        Cv.RoundRect(ARect.Left - RAIO, ARect.Top + 2, ARect.Right - 3,
          ARect.Bottom - 2, RAIO, RAIO)
      else
        Cv.FillRect(ARect.Left, ARect.Top + 2, ARect.Right, ARect.Bottom - 2);
    finally
      Cv.Clipping := False;
    end;
  end;

  if ASemTexto then Exit;

  { dataset vazio: o campo ainda guarda o texto do último registro (linha
    "fantasma"); a grade desenha uma linha em branco }
  if Assigned(DS) and DS.Active and DS.IsEmpty then Exit;

  { texto: centralizado na vertical, com recuo e alinhamento da coluna }
  Cv.Brush.Style := bsClear;
  Cv.Font.Style := AEstilo;
  if ACorTexto = clDefault then Cv.Font.Color := Paleta.Texto
  else Cv.Font.Color := ACorTexto;

  Txt := Campo.DisplayText;
  Alinha := AColuna.Alignment;
  if (Alinha = taLeftJustify) and
     (Campo.DataType in [ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftInteger,
        ftSmallint, ftLargeint, ftWord]) then
    Alinha := taRightJustify;

  Larg := Cv.TextWidth(Txt);
  Y := ARect.Top + (ARect.Bottom - ARect.Top - Cv.TextHeight('Ag')) div 2;
  case Alinha of
    taRightJustify: X := ARect.Right - RECUO - ARecuoDireita - Larg;
    taCenter: X := ARect.Left + (ARect.Right - ARect.Left - Larg) div 2;
  else
    X := ARect.Left + RECUO;
  end;
  if X < ARect.Left + 2 then X := ARect.Left + 2;
  { a grade pode ter deixado TextStyle alinhado à direita/centro, o que
    faria o TextRect ignorar X; força alinhamento à esquerda }
  TS := Cv.TextStyle;
  TS.Alignment := taLeftJustify;
  TS.Layout := tlTop;
  TS.Clipping := True;
  Cv.TextStyle := TS;
  Cv.TextRect(ARect, X, Y, Txt);
  Cv.Brush.Style := bsSolid;
  Cv.Font.Style := [];
end;

procedure TemaGrade(AGrade: TCustomDBGrid);
var
  G: TGradeAcesso;
  I: Integer;
begin
  G := TGradeAcesso(AGrade);
  G.Color := Paleta.Superficie;
  G.AlternateColor := Paleta.Zebra;
  G.FixedColor := Paleta.CabecalhoFundo;
  G.FixedHotColor := Paleta.Selecao;
  G.GridLineColor := Paleta.Borda;
  G.FixedGridLineColor := Paleta.Borda;
  G.SelectedColor := Paleta.Selecao;
  G.FocusRectVisible := False;
  G.TitleStyle := tsStandard;
  G.Flat := True;
  G.BorderStyle := bsNone;
  G.Font.Color := Paleta.Texto;
  G.TitleFont.Color := Paleta.CabecalhoTexto;
  G.TitleFont.Style := [fsBold];
  if FonteSegura(G.Font.Name) then G.Font.Name := FONTE_PADRAO;
  if FonteSegura(G.TitleFont.Name) then G.TitleFont.Name := FONTE_PADRAO;

  { visual limpo: só linhas horizontais suaves }
  G.Options := G.Options - [dgColLines] + [dgRowLines];

  for I := 0 to G.Columns.Count - 1 do
  begin
    G.Columns[I].Title.Font.Color := Paleta.CabecalhoTexto;
    G.Columns[I].Title.Font.Style := [fsBold];
    G.Columns[I].Title.Color := Paleta.CabecalhoFundo;
  end;

  { grades sem desenho próprio passam a usar o desenho moderno }
  if Assigned(Hook) then
  begin
    if AGrade is TRxDBGrid then
    begin
      if not Assigned(TRxDBGrid(AGrade).OnGetBtnParams) then
        TRxDBGrid(AGrade).OnGetBtnParams := @Hook.BtnParams;
    end;
    if AGrade is TRxDBGrid then
    begin
      if not Assigned(TRxDBGrid(AGrade).OnDrawColumnCell) then
        TRxDBGrid(AGrade).OnDrawColumnCell := @Hook.CelulaGenerica;
    end
    else if AGrade is TDBGrid then
      if not Assigned(TDBGrid(AGrade).OnDrawColumnCell) then
        TDBGrid(AGrade).OnDrawColumnCell := @Hook.CelulaGenerica;
  end;
  G.Invalidate;
end;

{ ---------------- Botões ---------------- }

{ ---------------- Botão arredondado ---------------- }

type
  { Sem campos novos: o VMT das instâncias de TColorSpeedButton é trocado por
    este em tempo de execução (ver ArredondarBotao), mantendo Click, Enabled,
    glifo, âncoras e eventos exatamente como estavam. }
  TBotaoRedondo = class(TColorSpeedButton)
  protected
    procedure PaintBackground(var PaintRect: TRect); override;
  end;

procedure TBotaoRedondo.PaintBackground(var PaintRect: TRect);
var
  Bmp: TBGRABitmap;
  Cor, Borda: TColor;
  Raio: Single;
  W, H: Integer;
begin
  W := Width;
  H := Height;
  if (W <= 0) or (H <= 0) then Exit;
  if (Toggle and Pressed) then
  begin
    Cor := StateActive.Color;  Borda := StateActive.BorderColor;
  end
  else
    case FState of
      bsDisabled:
        begin Cor := StateDisabled.Color; Borda := StateDisabled.BorderColor; end;
      bsDown, bsExclusive:
        begin Cor := StateActive.Color; Borda := StateActive.BorderColor; end;
      bsHot:
        begin Cor := StateHover.Color; Borda := StateHover.BorderColor; end;
    else
      Cor := StateNormal.Color;  Borda := StateNormal.BorderColor;
    end;

  Raio := Min(W, H) * 0.30;
  if Raio > 14 then Raio := 14;

  Bmp := TBGRABitmap.Create(W, H, ColorToBGRA(ColorToRGB(FundoEfetivo(Self))));
  try
    Bmp.FillRoundRectAntialias(0.5, 0.5, W - 0.5, H - 0.5, Raio, Raio,
      ColorToBGRA(ColorToRGB(Cor)));
    if Borda <> Cor then
      Bmp.RoundRectAntialias(0.5, 0.5, W - 0.5, H - 0.5, Raio, Raio,
        ColorToBGRA(ColorToRGB(Borda)), 1);
    Bmp.Draw(Canvas, 0, 0, True);
  finally
    Bmp.Free;
  end;
end;

procedure ArredondarBotao(ABtn: TColorSpeedButton);
begin
  if ABtn.ClassType = TColorSpeedButton then
  begin
    PPointer(ABtn)^ := Pointer(TBotaoRedondo);
    ABtn.Invalidate;
  end;
end;

procedure TemaBotao(ABtn: TColorSpeedButton);
var
  Cap: String;
  Primario: Boolean;
  Normal, Hover, Ativo, Borda, TextoBtn: TColor;
begin
  Cap := UpperCase(ABtn.Caption);
  Primario := (Pos('SALVAR', Cap) > 0) or (Pos('ENTRAR', Cap) > 0) or
    (Pos('CONFIRMAR', Cap) > 0) or (Pos('APLICAR', Cap) > 0) or
    (Pos('GRAVAR', Cap) > 0) or (Cap = 'OK');
  if Primario then
  begin
    Normal := Paleta.Destaque;
    Hover := MisturarCor(Paleta.Destaque, clBlack, 14);
    Ativo := MisturarCor(Paleta.Destaque, clBlack, 28);
    Borda := Normal;
    TextoBtn := clWhite;
  end
  else
  begin
    Normal := Paleta.Superficie;
    Hover := Paleta.CabecalhoFundo;
    Ativo := Paleta.Selecao;
    Borda := Paleta.Borda;
    Borda := MisturarCor(Paleta.Borda, Paleta.TextoSuave, 45);
    TextoBtn := Paleta.Texto;
  end;
  ABtn.StateNormal.Color := Normal;
  ABtn.StateNormal.BorderColor := Borda;
  ABtn.StateHover.Color := Hover;
  ABtn.StateHover.BorderColor := Borda;
  ABtn.StateActive.Color := Ativo;
  ABtn.StateActive.BorderColor := Borda;
  ABtn.Font.Color := TextoBtn;
  ArredondarBotao(ABtn);
  ABtn.Invalidate;
end;

{ ---------------- Formulário ---------------- }
{ O Windows pinta a página de um TTabSheet com o tema claro, ignorando Color.
  Um TPaintBox (controle gráfico) no fundo da pilha garante a cor do tema
  sem cobrir rótulos e ícones. }
procedure GarantirFundoAba(ATab: TTabSheet);
var
  Comp: TComponent;
  PB: TPaintBox;
begin
  Comp := ATab.FindComponent('tema_fundo');
  if Comp is TPaintBox then
    PB := TPaintBox(Comp)
  else
  begin
    PB := TPaintBox.Create(ATab);
    PB.Name := 'tema_fundo';
    PB.Parent := ATab;
    PB.Align := alClient;
    PB.OnPaint := @Hook.PintarFundoAba;
  end;
  PB.SendToBack;
  PB.Invalidate;
end;

{ ---------------- CheckBox moderno ---------------- }

{ O controle nativo ignora cores no tema escuro (fica uma caixa branca). Este
  desenho substitui o visual: o TCheckBox original continua existindo
  (invisível) e guarda Checked/OnClick, então o código existente não muda. }
type
  TCheckVisual = class(TComponent)
  public
    Check: TCheckBox;
    PB: TPaintBox;
    procedure Pintar(Sender: TObject);
    procedure Clicou(Sender: TObject);
    procedure Mudou(Sender: TObject);
  end;

procedure TCheckVisual.Pintar(Sender: TObject);
const
  LADO = 16;
var
  Cv: TCanvas;
  Y: Integer;
begin
  Cv := PB.Canvas;
  Cv.Brush.Color := FundoEfetivo(PB);
  Cv.FillRect(0, 0, PB.Width, PB.Height);
  Y := (PB.Height - LADO) div 2;
  if Check.Checked then
  begin
    Cv.Brush.Color := Paleta.Destaque;
    Cv.Pen.Color := Paleta.Destaque;
  end
  else
  begin
    Cv.Brush.Color := Paleta.Superficie;
    Cv.Pen.Color := Paleta.TextoSuave;
  end;
  Cv.Pen.Width := 1;
  Cv.RoundRect(0, Y, LADO, Y + LADO, 6, 6);
  if Check.Checked then
  begin
    Cv.Pen.Color := clWhite;
    Cv.Pen.Width := 2;
    Cv.MoveTo(4, Y + 8);
    Cv.LineTo(7, Y + 11);
    Cv.LineTo(12, Y + 5);
  end;
  Cv.Brush.Style := bsClear;
  Cv.Font.Assign(Check.Font);
  Cv.Font.Color := Paleta.Texto;
  Cv.TextOut(LADO + 8, (PB.Height - Cv.TextHeight('Ag')) div 2, Check.Caption);
  Cv.Brush.Style := bsSolid;
end;

procedure TCheckVisual.Clicou(Sender: TObject);
begin
  Check.Checked := not Check.Checked;  { dispara o OnClick/OnChange original }
  PB.Invalidate;
end;

procedure TCheckVisual.Mudou(Sender: TObject);
begin
  PB.Invalidate;
end;

procedure ModernizarCheckBox(ACheck: TCheckBox);
var
  V: TCheckVisual;
  Comp: TComponent;
  Medida: TBitmap;
  Larg: Integer;
begin
  if (ACheck.Parent = nil) or (ACheck.Owner = nil) then Exit;
  if (not ACheck.Visible) and (ACheck.Owner.FindComponent('tema_chk_' + ACheck.Name) = nil) then Exit;
  Comp := ACheck.Owner.FindComponent('tema_chk_' + ACheck.Name);
  if Comp is TCheckVisual then
  begin
    TCheckVisual(Comp).PB.Invalidate;
    Exit;
  end;
  V := TCheckVisual.Create(ACheck.Owner);
  V.Name := 'tema_chk_' + ACheck.Name;
  V.Check := ACheck;
  V.PB := TPaintBox.Create(V);
  V.PB.Parent := ACheck.Parent;
  Medida := TBitmap.Create;
  try
    Medida.Canvas.Font.Assign(ACheck.Font);
    Larg := 16 + 8 + Medida.Canvas.TextWidth(ACheck.Caption) + 10;
  finally
    Medida.Free;
  end;
  if Larg < ACheck.Width then Larg := ACheck.Width;
  V.PB.SetBounds(ACheck.Left, ACheck.Top, Larg, ACheck.Height);
  V.PB.Anchors := ACheck.Anchors;
  V.PB.Cursor := crHandPoint;
  V.PB.OnPaint := @V.Pintar;
  V.PB.OnClick := @V.Clicou;
  if not Assigned(ACheck.OnChange) then ACheck.OnChange := @V.Mudou;
  ACheck.Visible := False;
end;

{ Rótulos que ficam parcialmente escondidos atrás do campo logo abaixo
  (letras cortadas): sobe o rótulo até encostar acima do campo. }
procedure CorrigirRotulos(AForm: TCustomForm);
var
  I, J: Integer;
  L: TLabel;
  C: TControl;
begin
  for I := 0 to AForm.ComponentCount - 1 do
  begin
    if not (AForm.Components[I] is TLabel) then Continue;
    L := TLabel(AForm.Components[I]);
    if (L.Parent = nil) or not L.Visible then Continue;
    for J := 0 to L.Parent.ControlCount - 1 do
    begin
      C := L.Parent.Controls[J];
      if (C = L) or (not C.Visible) or (C is TLabel) then Continue;
      if (C.Top > L.Top) and (C.Top < L.Top + L.Height) and
         (C.Left < L.Left + L.Width) and (C.Left + C.Width > L.Left) then
      begin
        L.Top := C.Top - L.Height - 1;
        Break;
      end;
    end;
  end;
end;


procedure AplicarTema(AForm: TCustomForm);
var
  I: Integer;
  C: TComponent;
begin
  if not Assigned(AForm) then Exit;
  AForm.DisableAutoSizing;
  try
    AForm.Color := Paleta.Fundo;
    if FonteSegura(AForm.Font.Name) then AForm.Font.Name := FONTE_PADRAO;
    AForm.Font.Color := Paleta.Texto;

    { 1ª passada: contêineres (para o contraste enxergar o fundo final) }
    for I := 0 to AForm.ComponentCount - 1 do
    begin
      C := AForm.Components[I];
      if C is TTabSheet then
      begin
        TWinAcesso(C).ParentBackground := False;
        TTabSheet(C).Color := Paleta.Fundo;
        GarantirFundoAba(TTabSheet(C));
      end
      else if C is TPanel then
      begin
        { respeita faixas coloridas (ex.: título); troca só fundos neutros }
        if (TemaEscuro and ClaroDemais(TPanel(C).Color)) or
           (not TemaEscuro and CorPadraoSistema(TPanel(C).Color)) then
          TPanel(C).Color := Paleta.Fundo;
      end
      else if C is TGroupBox then
        TGroupBox(C).Color := Paleta.Fundo;
    end;

    { 2ª passada: demais controles }
    for I := 0 to AForm.ComponentCount - 1 do
    begin
      C := AForm.Components[I];

      if C is TCustomDBGrid then
      begin
        TemaGrade(TCustomDBGrid(C));
      end
      else if C is TColorSpeedButton then
        TemaBotao(TColorSpeedButton(C))
      else if C is TDateTimePicker then
      begin
        TDateTimePicker(C).Color := Paleta.Superficie;
        TDateTimePicker(C).Font.Color := Paleta.Texto;
      end
      else if (C is TCustomEdit) or (C is TCustomComboBox) or
              (C is TDBLookupComboBox) then
      begin
        TControl(C).Color := Paleta.Superficie;
        TControl(C).Font.Color := Paleta.Texto;
      end
      else if (C is TLabel) or (C is TCheckBox) or (C is TRadioButton) then
      begin
        if C is TCheckBox then
          ModernizarCheckBox(TCheckBox(C))
        else
          GarantirContraste(TControl(C), 7);
      end
      else if (C is TPageControl) and TPageControl(C).ShowTabs then
        TPageControl(C).Style := tsFlatButtons;

      if (C is TControl) and not (C is TCustomDBGrid) then
        AplicarFonte(TControl(C));
    end;
    CorrigirRotulos(AForm);
  finally
    AForm.EnableAutoSizing;
  end;
  AForm.Invalidate;
end;

{ ---------------- Hook ---------------- }

procedure TTemaHook.FormAdicionado(Sender: TObject; Form: TCustomForm);
begin
  if Assigned(Form) and not (csDesigning in Form.ComponentState) then
    Form.AddHandlerFirstShow(@PrimeiroShow);
end;

procedure TTemaHook.PrimeiroShow(Sender: TObject);
begin
  if Sender is TCustomForm then
    AplicarTema(TCustomForm(Sender));
end;

procedure TTemaHook.BtnParams(Sender: TObject; Field: TField; AFont: TFont;
  var Background: TColor; var SortMarker: TSortMarker; IsDown: Boolean);
begin
  AFont.Color := Paleta.CabecalhoTexto;
  AFont.Style := [fsBold];
  Background := Paleta.CabecalhoFundo;
end;

{ ACampos: nomes separados por ';' em ordem de prioridade; o primeiro
  absorve mais da sobra de largura. As demais colunas mantêm a largura. }
procedure PreencherColunas(AGrade: TCustomDBGrid; const ACampos: String);
var
  G: TGradeAcesso;
  L: TStringList;
  I, P: Integer;
begin
  G := TGradeAcesso(AGrade);
  L := TStringList.Create;
  try
    L.Delimiter := ';';
    L.StrictDelimiter := True;
    L.DelimitedText := ACampos;
    for I := 0 to G.Columns.Count - 1 do
    begin
      P := L.IndexOf(G.Columns[I].FieldName);
      if P >= 0 then
        G.Columns[I].SizePriority := L.Count - P
      else
        G.Columns[I].SizePriority := 0;
    end;
  finally
    L.Free;
  end;
  G.AutoFillColumns := True;
end;

procedure TTemaHook.PintarFundoAba(Sender: TObject);
var
  PB: TPaintBox;
begin
  PB := Sender as TPaintBox;
  PB.Canvas.Brush.Color := Paleta.Fundo;
  PB.Canvas.FillRect(0, 0, PB.Width, PB.Height);
end;

procedure TTemaHook.CelulaGenerica(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if Sender is TCustomDBGrid then
    PintarCelulaModerna(TCustomDBGrid(Sender), Rect, Column, State);
end;

procedure InstalarTema;
begin
  if Instalado then Exit;
  Instalado := True;
  TemaEscuro := UpperCase(PLerINI('DICASTRO', 'TEMA', 'CLARO')) = 'ESCURO';
  DefinirPaleta;
  Hook := TTemaHook.Create;
  Screen.AddHandlerFormAdded(@Hook.FormAdicionado);
end;

procedure AlternarTema;
begin
  { O componente de dark mode so configura barras de rolagem, bordas e abas
    na criacao das janelas; trocar com o sistema aberto deixa partes escuras
    no tema claro. Por isso grava a escolha e reabre o programa (sem pedir
    login novamente). }
  TemaEscuro := not TemaEscuro;
  if TemaEscuro then
    PGravaINI('DICASTRO', 'TEMA', 'ESCURO')
  else
    PGravaINI('DICASTRO', 'TEMA', 'CLARO');
  ReiniciarAplicacao;
  Application.Terminate;
end;

end.
