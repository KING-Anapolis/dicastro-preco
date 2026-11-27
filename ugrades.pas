unit uGrades;

{$mode ObjFPC}{$H+}
{$codepage utf8}

{
  Gerenciador de layout das grades (TDBGrid / TRxDBGrid).

  O que ele faz por grade registrada:
    - lembra largura, ordem e visibilidade das colunas (arquivo grades.ini);
    - o usuário arrasta o cabeçalho para mudar a ordem e a borda para mudar a
      largura; tudo é gravado na hora e restaurado na próxima abertura;
    - "Ajustar colunas automaticamente" é um modo que o usuário liga/desliga no
      botão direito. Ele NUNCA trava: se o usuário muda a largura de uma
      coluna, essa coluna passa a ser "manual" (fica salva) e o ajuste
      automático deixa de mexer nela. "Melhor tamanho agora" refaz tudo;
    - menu de botão direito com a lista de colunas (marcar/desmarcar);
    - imprimir listagem (PDF aberto no visualizador), salvar PDF e Excel.
}

interface

uses
  Classes, SysUtils, DB, Controls, Graphics, Grids, DBGrids, Menus, Dialogs,
  Forms, IniFiles, LCLIntf, uGradeExport;

type
  TGradeAjusteEvent = procedure(AGrade: TCustomDBGrid) of object;
  TGradeTextoEvent = function(AGrade: TCustomDBGrid): String of object;
  TGradeMenuEvent = procedure(AGrade: TCustomDBGrid;
    AMenu: TPopupMenu) of object;

  TGradeItem = class
  public
    Grade: TCustomDBGrid;
    Titulo: String;
    AutoAjuste: Boolean;
    LayoutAplicado: Boolean;
    Ocupado: Boolean;
    Preencher: Boolean;       { estica a coluna principal até a borda }
    Bloqueadas: TStringList;  { colunas que não podem ser ocultadas }
    Manuais: TStringList;     { colunas cuja largura o usuário definiu }
    Larguras: TStringList;    { Campo=Largura da última vez conhecida }
    Padrao: TStringList;      { ordem e visibilidade de fábrica: Campo=V|H }
    constructor Create;
    destructor Destroy; override;
  end;

  { TGerenciadorGrades }

  TGerenciadorGrades = class(TComponent)
  private
    FArquivo: String;
    FItens: TList;
    FMenu: TPopupMenu;
    FAtual: TGradeItem;
    FOnAjustar: TGradeAjusteEvent;
    FOnSubtitulo: TGradeTextoEvent;
    FOnMontarMenu: TGradeMenuEvent;
    function Achar(AGrade: TObject): TGradeItem;
    function Secao(AItem: TGradeItem): String;
    procedure GarantirColunas(AItem: TGradeItem);
    procedure CapturarPadrao(AItem: TGradeItem);
    procedure AplicarLayout(AItem: TGradeItem);
    procedure GuardarLarguras(AItem: TGradeItem);
    procedure Salvar(AItem: TGradeItem);
    procedure AjustarPreservandoManuais(AItem: TGradeItem);
    procedure AssumirPreenchimento(AItem: TGradeItem);
    procedure PreencherLargura(AItem: TGradeItem);
    function ColunaPorCampo(AItem: TGradeItem; const ACampo: String): TColumn;
    function Bloqueada(AItem: TGradeItem; const ACampo: String): Boolean;
    function TotalVisiveis(AItem: TGradeItem): Integer;
    procedure ColunaRedimensionada(Sender: TObject);
    procedure ColunaMovida(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure MenuPopup(Sender: TObject);
    procedure ItemAutoClick(Sender: TObject);
    procedure ItemMelhorClick(Sender: TObject);
    procedure ItemColunaClick(Sender: TObject);
    procedure ItemRestaurarClick(Sender: TObject);
    procedure ItemImprimirClick(Sender: TObject);
    procedure ItemPDFClick(Sender: TObject);
    procedure ItemExcelClick(Sender: TObject);
    procedure Exportar(const AFormato: String; AAbrir: Boolean);
    function EscolherArquivo(const AExtensao: String;
      out AArquivo: String): Boolean;
    function PodeExportar(AItem: TGradeItem): Boolean;
    function Subtitulo(AItem: TGradeItem): String;
  public
    constructor Create(AOwner: TComponent; const AArquivo: String);
      reintroduce;
    destructor Destroy; override;
    procedure Registrar(AGrade: TCustomDBGrid; const ATitulo: String;
      const ABloqueadas: array of String);
    { Aplica o layout salvo (na primeira vez) e, se o modo automático estiver
      ligado, ajusta as colunas que o usuário não definiu manualmente. }
    procedure Ajustar(AGrade: TCustomDBGrid; AForcar: Boolean = False);
    { Usa o layout que a grade tem agora como o do usuário (migração). }
    procedure AdotarLayoutAtual(AGrade: TCustomDBGrid);
    { Chamar quando a grade mudar de tamanho: no modo automático e sem
      larguras manuais, estica de novo a coluna principal até a borda. }
    procedure GradeRedimensionada(AGrade: TCustomDBGrid);
    function TemLayoutSalvo(AGrade: TCustomDBGrid): Boolean;
    procedure SalvarTudo;
    property OnAjustar: TGradeAjusteEvent read FOnAjustar write FOnAjustar;
    property OnSubtitulo: TGradeTextoEvent read FOnSubtitulo
      write FOnSubtitulo;
    property OnMontarMenu: TGradeMenuEvent read FOnMontarMenu
      write FOnMontarMenu;
  end;

{ Interpreta o texto digitado na busca de descrição no padrão do SQL LIKE:
  sem "%" busca pelo começo ('abc' -> 'abc%'); com "%" respeita o padrão
  exatamente como foi digitado ('%abc%' = contém, '%abc' = termina com). }
function PadraoBuscaLike(const ATexto: String): String;

implementation

type
  TGradeAcesso = class(TCustomDBGrid);

function PadraoBuscaLike(const ATexto: String): String;
begin
  Result := Trim(ATexto);
  if Result = '' then Exit;
  if Pos('%', Result) = 0 then
    Result := Result + '%';
end;

{ TGradeItem }

constructor TGradeItem.Create;
begin
  inherited Create;
  AutoAjuste := True;
  Bloqueadas := TStringList.Create;
  Manuais := TStringList.Create;
  Larguras := TStringList.Create;
  Padrao := TStringList.Create;
  Manuais.CaseSensitive := False;
  Bloqueadas.CaseSensitive := False;
end;

destructor TGradeItem.Destroy;
begin
  Bloqueadas.Free;
  Manuais.Free;
  Larguras.Free;
  Padrao.Free;
  inherited Destroy;
end;

{ TGerenciadorGrades }

constructor TGerenciadorGrades.Create(AOwner: TComponent;
  const AArquivo: String);
begin
  inherited Create(AOwner);
  FArquivo := AArquivo;
  FItens := TList.Create;
  FMenu := TPopupMenu.Create(Self);
  FMenu.OnPopup := @MenuPopup;
end;

destructor TGerenciadorGrades.Destroy;
var
  I: Integer;
begin
  for I := 0 to FItens.Count - 1 do
    TGradeItem(FItens[I]).Free;
  FItens.Free;
  inherited Destroy;
end;

function TGerenciadorGrades.Achar(AGrade: TObject): TGradeItem;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItens.Count - 1 do
    if TGradeItem(FItens[I]).Grade = AGrade then
      Exit(TGradeItem(FItens[I]));
end;

function TGerenciadorGrades.Secao(AItem: TGradeItem): String;
begin
  Result := 'Grade.' + AItem.Grade.Name;
end;

procedure TGerenciadorGrades.Registrar(AGrade: TCustomDBGrid;
  const ATitulo: String; const ABloqueadas: array of String);
var
  Item: TGradeItem;
  I: Integer;
begin
  Item := TGradeItem.Create;
  Item.Grade := AGrade;
  Item.Titulo := ATitulo;
  for I := Low(ABloqueadas) to High(ABloqueadas) do
    Item.Bloqueadas.Add(ABloqueadas[I]);
  FItens.Add(Item);
  TGradeAcesso(AGrade).Options := TGradeAcesso(AGrade).Options +
    [dgColumnResize, dgColumnMove];
  TGradeAcesso(AGrade).OnColumnSized := @ColunaRedimensionada;
  TGradeAcesso(AGrade).OnColumnMoved := @ColunaMovida;
  AGrade.PopupMenu := FMenu;
end;

function TGerenciadorGrades.TemLayoutSalvo(AGrade: TCustomDBGrid): Boolean;
var
  Item: TGradeItem;
  Ini: TIniFile;
begin
  Result := False;
  Item := Achar(AGrade);
  if (Item = nil) or not FileExists(FArquivo) then Exit;
  Ini := TIniFile.Create(FArquivo);
  try
    Result := Ini.SectionExists(Secao(Item));
  finally
    Ini.Free;
  end;
end;

function TGerenciadorGrades.ColunaPorCampo(AItem: TGradeItem;
  const ACampo: String): TColumn;
var
  Cols: TDBGridColumns;
  I: Integer;
begin
  Result := nil;
  Cols := ColunasDe(AItem.Grade);
  for I := 0 to Cols.Count - 1 do
    if SameText(Cols[I].FieldName, ACampo) then
      Exit(Cols[I]);
end;

function TGerenciadorGrades.Bloqueada(AItem: TGradeItem;
  const ACampo: String): Boolean;
begin
  Result := AItem.Bloqueadas.IndexOf(ACampo) >= 0;
end;

function TGerenciadorGrades.TotalVisiveis(AItem: TGradeItem): Integer;
var
  Cols: TDBGridColumns;
  I: Integer;
begin
  Result := 0;
  Cols := ColunasDe(AItem.Grade);
  for I := 0 to Cols.Count - 1 do
    if Cols[I].Visible then Inc(Result);
end;

procedure TGerenciadorGrades.GarantirColunas(AItem: TGradeItem);
var
  Cols: TDBGridColumns;
  DS: TDataSet;
  I: Integer;
begin
  Cols := ColunasDe(AItem.Grade);
  if Cols.Count > 0 then Exit;
  if not Assigned(AItem.Grade.DataSource) then Exit;
  DS := AItem.Grade.DataSource.DataSet;
  if not Assigned(DS) or not DS.Active then Exit;
  for I := 0 to DS.FieldCount - 1 do
    if DS.Fields[I].Visible then
      with Cols.Add do
      begin
        FieldName := DS.Fields[I].FieldName;
        Title.Caption := DS.Fields[I].DisplayLabel;
      end;
end;

procedure TGerenciadorGrades.CapturarPadrao(AItem: TGradeItem);
var
  Cols: TDBGridColumns;
  I: Integer;
begin
  AItem.Padrao.Clear;
  Cols := ColunasDe(AItem.Grade);
  for I := 0 to Cols.Count - 1 do
    if Cols[I].Visible then
      AItem.Padrao.Add(Cols[I].FieldName + '=V')
    else
      AItem.Padrao.Add(Cols[I].FieldName + '=H');
end;

procedure TGerenciadorGrades.GuardarLarguras(AItem: TGradeItem);
var
  Cols: TDBGridColumns;
  I: Integer;
begin
  AItem.Larguras.Clear;
  Cols := ColunasDe(AItem.Grade);
  for I := 0 to Cols.Count - 1 do
    AItem.Larguras.Values[Cols[I].FieldName] := IntToStr(Cols[I].Width);
end;

procedure TGerenciadorGrades.AplicarLayout(AItem: TGradeItem);
var
  Ini: TIniFile;
  Ordem: TStringList;
  Col, Anterior: TColumn;
  Larg, I, Pos: Integer;
  S: String;
begin
  AItem.LayoutAplicado := True;
  if not FileExists(FArquivo) then Exit;
  Ini := TIniFile.Create(FArquivo);
  Ordem := TStringList.Create;
  try
    S := Secao(AItem);
    if not Ini.SectionExists(S) then Exit;
    AItem.AutoAjuste := Ini.ReadBool(S, 'AutoAjuste', True);

    Ordem.StrictDelimiter := True;
    Ordem.Delimiter := ',';
    Ordem.DelimitedText := Ini.ReadString(S, 'Ordem', '');
    Pos := 0;
    for I := 0 to Ordem.Count - 1 do
    begin
      Col := ColunaPorCampo(AItem, Ordem[I]);
      if Col = nil then Continue;
      Col.Index := Pos;
      Inc(Pos);
    end;

    { colunas criadas depois que o layout foi salvo (versão nova): entram
      logo após a coluna que as precede no layout de fábrica, e não no fim }
    if Ordem.Count > 0 then
      for I := 0 to AItem.Padrao.Count - 1 do
      begin
        if Ordem.IndexOf(AItem.Padrao.Names[I]) >= 0 then Continue;
        Col := ColunaPorCampo(AItem, AItem.Padrao.Names[I]);
        if Col = nil then Continue;
        if I = 0 then
          Col.Index := 0
        else
        begin
          Anterior := ColunaPorCampo(AItem, AItem.Padrao.Names[I - 1]);
          if Anterior <> nil then
            if Anterior.Index < Col.Index then
              Col.Index := Anterior.Index + 1
            else
              Col.Index := Anterior.Index;
        end;
      end;

    for I := 0 to ColunasDe(AItem.Grade).Count - 1 do
    begin
      Col := ColunasDe(AItem.Grade)[I];
      if Ini.ValueExists(S, 'V.' + Col.FieldName) then
        Col.Visible := Ini.ReadBool(S, 'V.' + Col.FieldName, True) or
          Bloqueada(AItem, Col.FieldName);
      Larg := Ini.ReadInteger(S, 'L.' + Col.FieldName, 0);
      if Larg >= 20 then Col.Width := Larg;
      if Ini.ReadBool(S, 'M.' + Col.FieldName, False) and
         (AItem.Manuais.IndexOf(Col.FieldName) < 0) then
        AItem.Manuais.Add(Col.FieldName);
    end;
    if TotalVisiveis(AItem) = 0 then
      ColunasDe(AItem.Grade)[0].Visible := True;
  finally
    Ordem.Free;
    Ini.Free;
  end;
end;

procedure TGerenciadorGrades.Salvar(AItem: TGradeItem);
var
  Ini: TIniFile;
  Cols: TDBGridColumns;
  I: Integer;
  S, Ordem: String;
begin
  { nunca grava antes de ter lido: evitaria apagar o layout do usuário }
  if not AItem.LayoutAplicado then Exit;
  Cols := ColunasDe(AItem.Grade);
  if Cols.Count = 0 then Exit;
  try
    Ini := TIniFile.Create(FArquivo);
    try
      S := Secao(AItem);
      Ini.EraseSection(S);
      Ini.WriteBool(S, 'AutoAjuste', AItem.AutoAjuste);
      Ordem := '';
      for I := 0 to Cols.Count - 1 do
      begin
        if Ordem <> '' then Ordem := Ordem + ',';
        Ordem := Ordem + Cols[I].FieldName;
        Ini.WriteBool(S, 'V.' + Cols[I].FieldName, Cols[I].Visible);
        Ini.WriteInteger(S, 'L.' + Cols[I].FieldName, Cols[I].Width);
        if AItem.Manuais.IndexOf(Cols[I].FieldName) >= 0 then
          Ini.WriteBool(S, 'M.' + Cols[I].FieldName, True);
      end;
      Ini.WriteString(S, 'Ordem', Ordem);
    finally
      Ini.Free;
    end;
  except
    { sem permissão de escrita: o layout só não será lembrado }
  end;
end;

procedure TGerenciadorGrades.SalvarTudo;
var
  I: Integer;
begin
  for I := 0 to FItens.Count - 1 do
    Salvar(TGradeItem(FItens[I]));
end;

procedure TGerenciadorGrades.AjustarPreservandoManuais(AItem: TGradeItem);
var
  Guardadas: TStringList;
  Col: TColumn;
  I: Integer;
begin
  if not Assigned(FOnAjustar) then Exit;
  Guardadas := TStringList.Create;
  try
    for I := 0 to AItem.Manuais.Count - 1 do
    begin
      Col := ColunaPorCampo(AItem, AItem.Manuais[I]);
      if Col <> nil then
        Guardadas.Values[Col.FieldName] := IntToStr(Col.Width);
    end;
    FOnAjustar(AItem.Grade);
    for I := 0 to Guardadas.Count - 1 do
    begin
      Col := ColunaPorCampo(AItem, Guardadas.Names[I]);
      if Col <> nil then
        Col.Width := StrToIntDef(Guardadas.ValueFromIndex[I], Col.Width);
    end;
  finally
    Guardadas.Free;
  end;
end;

{ O AutoFillColumns do LCL redistribui as larguras a cada mudança e prende a
  coluna que o usuário tenta esticar/encolher. O gerenciador assume esse papel:
  desliga o recurso e só preenche a largura sob demanda (uma vez). }
procedure TGerenciadorGrades.AssumirPreenchimento(AItem: TGradeItem);
begin
  if TGradeAcesso(AItem.Grade).AutoFillColumns then
  begin
    AItem.Preencher := True;
    TGradeAcesso(AItem.Grade).AutoFillColumns := False;
  end;
end;

procedure TGerenciadorGrades.PreencherLargura(AItem: TGradeItem);
var
  G: TGradeAcesso;
begin
  if not (AItem.Preencher and AItem.AutoAjuste and AItem.LayoutAplicado) then
    Exit;
  if AItem.Manuais.Count > 0 then Exit;
  G := TGradeAcesso(AItem.Grade);
  if not G.HandleAllocated or (G.ClientWidth <= 0) then Exit;
  { liga e desliga: o LCL calcula as larguras uma vez e elas ficam fixas }
  G.AutoFillColumns := True;
  G.AutoFillColumns := False;
end;

procedure TGerenciadorGrades.GradeRedimensionada(AGrade: TCustomDBGrid);
var
  Item: TGradeItem;
begin
  Item := Achar(AGrade);
  if (Item = nil) or Item.Ocupado then Exit;
  AssumirPreenchimento(Item);
  Item.Ocupado := True;
  try
    PreencherLargura(Item);
    GuardarLarguras(Item);
  finally
    Item.Ocupado := False;
  end;
end;

procedure TGerenciadorGrades.Ajustar(AGrade: TCustomDBGrid; AForcar: Boolean);
var
  Item: TGradeItem;
begin
  Item := Achar(AGrade);
  if Item = nil then
  begin
    if Assigned(FOnAjustar) then FOnAjustar(AGrade);
    Exit;
  end;
  AssumirPreenchimento(Item);
  GarantirColunas(Item);
  if ColunasDe(AGrade).Count = 0 then Exit;
  if Item.Ocupado then Exit;
  Item.Ocupado := True;
  try
    if not Item.LayoutAplicado then
    begin
      CapturarPadrao(Item);
      AplicarLayout(Item);
    end;
    if AForcar then Item.Manuais.Clear;
    if Item.AutoAjuste or AForcar then
    begin
      AjustarPreservandoManuais(Item);
      PreencherLargura(Item);
    end;
    GuardarLarguras(Item);
  finally
    Item.Ocupado := False;
  end;
  if AForcar then Salvar(Item);
end;

procedure TGerenciadorGrades.AdotarLayoutAtual(AGrade: TCustomDBGrid);
var
  Item: TGradeItem;
  Cols: TDBGridColumns;
  I: Integer;
begin
  Item := Achar(AGrade);
  if Item = nil then Exit;
  GarantirColunas(Item);
  Cols := ColunasDe(AGrade);
  if Cols.Count = 0 then Exit;
  if not Item.LayoutAplicado then CapturarPadrao(Item);
  Item.LayoutAplicado := True;
  Item.Manuais.Clear;
  for I := 0 to Cols.Count - 1 do
    Item.Manuais.Add(Cols[I].FieldName);
  GuardarLarguras(Item);
  Salvar(Item);
end;

procedure TGerenciadorGrades.ColunaRedimensionada(Sender: TObject);
var
  Item: TGradeItem;
  Cols: TDBGridColumns;
  I, Antes: Integer;
begin
  Item := Achar(Sender);
  if (Item = nil) or Item.Ocupado or not Item.LayoutAplicado then Exit;
  Cols := ColunasDe(Item.Grade);
  for I := 0 to Cols.Count - 1 do
  begin
    Antes := StrToIntDef(Item.Larguras.Values[Cols[I].FieldName],
      Cols[I].Width);
    if (Cols[I].Width <> Antes) and
       (Item.Manuais.IndexOf(Cols[I].FieldName) < 0) then
      Item.Manuais.Add(Cols[I].FieldName);
  end;
  GuardarLarguras(Item);
  Salvar(Item);
end;

procedure TGerenciadorGrades.ColunaMovida(Sender: TObject; FromIndex,
  ToIndex: Integer);
var
  Item: TGradeItem;
begin
  Item := Achar(Sender);
  if (Item = nil) or not Item.LayoutAplicado then Exit;
  Salvar(Item);
end;

{ ----------------------------------------------------------------- menu -- }

procedure TGerenciadorGrades.MenuPopup(Sender: TObject);
var
  Item: TMenuItem;
  Sub: TMenuItem;
  Cols: TDBGridColumns;
  I: Integer;
  Titulo: String;

  function Novo(const ACaption: String; AClick: TNotifyEvent): TMenuItem;
  begin
    Result := TMenuItem.Create(FMenu);
    Result.Caption := ACaption;
    Result.OnClick := AClick;
    FMenu.Items.Add(Result);
  end;

begin
  FAtual := nil;
  FMenu.Items.Clear;
  if not (FMenu.PopupComponent is TCustomDBGrid) then Exit;
  FAtual := Achar(FMenu.PopupComponent);
  if FAtual = nil then Exit;
  GarantirColunas(FAtual);

  if Assigned(FOnMontarMenu) then
    FOnMontarMenu(FAtual.Grade, FMenu);
  if FMenu.Items.Count > 0 then
    Novo('-', nil);

  Item := Novo('Ajustar colunas automaticamente', @ItemAutoClick);
  Item.Checked := FAtual.AutoAjuste;
  Novo('Melhor tamanho agora', @ItemMelhorClick);

  Sub := Novo('Colunas visíveis', nil);
  Cols := ColunasDe(FAtual.Grade);
  for I := 0 to Cols.Count - 1 do
  begin
    Titulo := Cols[I].Title.Caption;
    if Trim(Titulo) = '' then Titulo := Cols[I].FieldName;
    Item := TMenuItem.Create(FMenu);
    Item.Caption := Titulo;
    Item.Checked := Cols[I].Visible;
    Item.Tag := I;
    Item.Enabled := not Bloqueada(FAtual, Cols[I].FieldName);
    Item.OnClick := @ItemColunaClick;
    Sub.Add(Item);
  end;
  Novo('Restaurar layout padrão', @ItemRestaurarClick);

  Novo('-', nil);
  Novo('Imprimir listagem (PDF)', @ItemImprimirClick);
  Novo('Salvar listagem em PDF...', @ItemPDFClick);
  Novo('Exportar para Excel...', @ItemExcelClick);
end;

procedure TGerenciadorGrades.ItemAutoClick(Sender: TObject);
begin
  if FAtual = nil then Exit;
  FAtual.AutoAjuste := not FAtual.AutoAjuste;
  if FAtual.AutoAjuste then Ajustar(FAtual.Grade);
  Salvar(FAtual);
end;

procedure TGerenciadorGrades.ItemMelhorClick(Sender: TObject);
begin
  if FAtual = nil then Exit;
  Ajustar(FAtual.Grade, True);
end;

procedure TGerenciadorGrades.ItemColunaClick(Sender: TObject);
var
  Cols: TDBGridColumns;
  Col: TColumn;
  Idx: Integer;
begin
  if (FAtual = nil) or not (Sender is TMenuItem) then Exit;
  Cols := ColunasDe(FAtual.Grade);
  Idx := TMenuItem(Sender).Tag;
  if (Idx < 0) or (Idx >= Cols.Count) then Exit;
  Col := Cols[Idx];
  if Bloqueada(FAtual, Col.FieldName) then Exit;
  if Col.Visible and (TotalVisiveis(FAtual) <= 1) then Exit;
  Col.Visible := not Col.Visible;
  if FAtual.AutoAjuste then Ajustar(FAtual.Grade);
  GuardarLarguras(FAtual);
  Salvar(FAtual);
  FAtual.Grade.Invalidate;
end;

procedure TGerenciadorGrades.ItemRestaurarClick(Sender: TObject);
var
  Padrao: TStringList;
  Col: TColumn;
  I, Pos: Integer;
begin
  if FAtual = nil then Exit;
  Padrao := FAtual.Padrao;
  Pos := 0;
  for I := 0 to Padrao.Count - 1 do
  begin
    Col := ColunaPorCampo(FAtual, Padrao.Names[I]);
    if Col = nil then Continue;
    Col.Index := Pos;
    Inc(Pos);
    Col.Visible := Padrao.ValueFromIndex[I] <> 'H';
  end;
  FAtual.AutoAjuste := True;
  Ajustar(FAtual.Grade, True);
  FAtual.Grade.Invalidate;
end;

{ -------------------------------------------------------------- exportar -- }

function TGerenciadorGrades.Subtitulo(AItem: TGradeItem): String;
begin
  Result := '';
  if Assigned(FOnSubtitulo) then Result := FOnSubtitulo(AItem.Grade);
end;

function TGerenciadorGrades.PodeExportar(AItem: TGradeItem): Boolean;
var
  DS: TDataSet;
begin
  Result := False;
  DS := nil;
  if Assigned(AItem.Grade.DataSource) then DS := AItem.Grade.DataSource.DataSet;
  if (DS = nil) or not DS.Active or DS.IsEmpty then
  begin
    MessageDlg('Não há registros nesta listagem para exportar.',
      mtInformation, [mbOK], 0);
    Exit;
  end;
  if DS.State in [dsEdit, dsInsert] then DS.Post;
  Result := True;
end;

function TGerenciadorGrades.EscolherArquivo(const AExtensao: String;
  out AArquivo: String): Boolean;
var
  Dlg: TSaveDialog;
  Base: String;
  I: Integer;
begin
  Result := False;
  Base := '';
  for I := 1 to Length(FAtual.Titulo) do
    if FAtual.Titulo[I] in ['A'..'Z', 'a'..'z', '0'..'9', '_'] then
      Base := Base + FAtual.Titulo[I]
    else if FAtual.Titulo[I] = ' ' then
      Base := Base + '_';
  if Base = '' then Base := 'Listagem';
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Title := 'Salvar ' + LowerCase(FAtual.Titulo);
    Dlg.DefaultExt := AExtensao;
    Dlg.FileName := Base + '_' + FormatDateTime('ddmmyyyy', Date) + '.' +
      AExtensao;
    if AExtensao = 'pdf' then
      Dlg.Filter := 'Arquivo PDF (*.pdf)|*.pdf'
    else
      Dlg.Filter := 'Planilha Excel (*.xlsx)|*.xlsx';
    if not Dlg.Execute then Exit;
    AArquivo := Dlg.FileName;
    if not SameText(ExtractFileExt(AArquivo), '.' + AExtensao) then
      AArquivo := ChangeFileExt(AArquivo, '.' + AExtensao);
    if FileExists(AArquivo) and
       (MessageDlg('O arquivo já existe. Deseja substituí-lo?',
         mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;
    Result := True;
  finally
    Dlg.Free;
  end;
end;

procedure TGerenciadorGrades.Exportar(const AFormato: String; AAbrir: Boolean);
var
  Item: TGradeItem;
  Arquivo: String;
begin
  Item := FAtual;
  if Item = nil then Exit;
  if not PodeExportar(Item) then Exit;
  if AAbrir then
    Arquivo := IncludeTrailingPathDelimiter(GetTempDir(False)) + 'Listagem_' +
      Item.Grade.Name + '_' + FormatDateTime('yyyymmdd_hhnnss', Now) + '.pdf'
  else if not EscolherArquivo(AFormato, Arquivo) then
    Exit;
  Screen.Cursor := crHourGlass;
  try
    try
      if AFormato = 'pdf' then
        ExportarGradePDF(Item.Grade, Item.Titulo, Subtitulo(Item), Arquivo)
      else
        ExportarGradeExcel(Item.Grade, Item.Titulo, Subtitulo(Item), Arquivo);
    finally
      Screen.Cursor := crDefault;
    end;
  except
    on E: Exception do
    begin
      MessageDlg('Não foi possível gerar o arquivo:' + LineEnding + E.Message,
        mtError, [mbOK], 0);
      Exit;
    end;
  end;
  if AAbrir then
    OpenDocument(Arquivo)
  else
    MessageDlg('Arquivo salvo em:' + LineEnding + Arquivo,
      mtInformation, [mbOK], 0);
end;

procedure TGerenciadorGrades.ItemImprimirClick(Sender: TObject);
begin
  Exportar('pdf', True);
end;

procedure TGerenciadorGrades.ItemPDFClick(Sender: TObject);
begin
  Exportar('pdf', False);
end;

procedure TGerenciadorGrades.ItemExcelClick(Sender: TObject);
begin
  Exportar('xlsx', False);
end;

end.
