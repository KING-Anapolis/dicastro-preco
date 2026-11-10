unit uFrmMain;

{$mode ObjFPC}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  DBGrids, Grids, DBCtrls, ColorSpeedButton, DBGridsEh, DBCtrlsEh, PrnDbgeh,
  uDm, dxDBGridController, RxDBGrid, Variants, LCLType, ComCtrls, uFrmCadastro,
  uFuncoes, PrintersDlgs, DateTimePicker, DateUtils, Math, uConf, ZDataset,
  ZAbstractRODataset, Types, BufDataset, Menus, IniFiles, uTema, uIcones;

type

  { Tfrm_p }

  Tfrm_p = class(TForm)
    bCompra: TImage;
    bCompra1: TImage;
    bHome: TImage;
    ckProdutos0: TCheckBox;
    ckExportarZero: TCheckBox;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    dbgCompras: TRxDBGrid;
    dbgProdVendas: TDBGrid;
    dbgProdutos: TDBGrid;
    dbgProdCompra: TDBGrid;
    dbgPedidoAtual: TDBGrid;
    dsPedidoAtual: TDataSource;
    dbgVendas: TRxDBGrid;
    dbGrupoCompra: TDBLookupComboBox;
    dbSubGrupoCompra: TDBLookupComboBox;
    dbMarcaCompra: TDBLookupComboBox;
    dbSetorCompra: TDBLookupComboBox;
    dbFornecedorCompra: TDBLookupComboBox;
    edtProdutoCompra: TEdit;
    iLimpar: TImage;
    iSalvarPDF: TImage;
    iSalvarExcel: TImage;
    iFiltrarCompras: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    pgcSystem: TPageControl;
    pnl_produtos: TPanel;
    qryProdutosComprarCOMPRAR: TZFMTBCDField;
    qryProdutosComprarESTOQUE: TZFMTBCDField;
    qryProdutosComprarPRD_DESCRICAO: TZRawStringField;
    qryProdutosComprarPRD_ID: TZIntegerField;
    qryProdutosComprarPRD_UN_VENDA: TZRawStringField;
    qryProdutosComprarPMAR_DESCRICAO: TZRawStringField;
    qryProdutosComprarVENDIDO: TZFMTBCDField;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tmrAtualizacao: TTimer;
    dsVendas: TDataSource;
    dsSugestaoCompras: TDataSource;
    dsProdutos: TDataSource;
    dsCompras: TDataSource;
    dsGrupo: TDataSource;
    dsSubGrupo: TDataSource;
    dsMarca: TDataSource;
    dsSetor: TDataSource;
    dsFornecedor: TDataSource;
    dxDBGridController1: TdxDBGridController;
    Label2: TLabel;
    Label3: TLabel;
    pnl_fundo: TPanel;
    pnl_titulo: TPanel;
    PrintDBGridEh1: TPrintDBGridEh;
    qryProdutosComprar: TZQuery;

    procedure bCompra1Click(Sender: TObject);
    procedure bHomeClick(Sender: TObject);
    procedure bCompraClick(Sender: TObject);
    procedure pgcSystemChange(Sender: TObject);
    procedure TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabSheet2Show(Sender: TObject);
    procedure tmrAtualizacaoTimer(Sender: TObject);
    procedure dbgProdutosDblClick(Sender: TObject);
    procedure MenuColunasPopup(Sender: TObject);
    procedure MenuColunaClick(Sender: TObject);
    procedure dbgProdutosDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);

    procedure dsProdutosDataChange(Sender: TObject; Field: TField);
    procedure dsSugestaoComprasDataChange(Sender: TObject; Field: TField);
    procedure ckProdutos0Click(Sender: TObject);
    procedure iFiltrarComprasClick(Sender: TObject);
    procedure iLimparClick(Sender: TObject);
    procedure iSalvarPDFClick(Sender: TObject);
    procedure iSalvarExcelClick(Sender: TObject);
    procedure FiltroCompraKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbgProdCompraDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
    procedure dbgVendasDrawColumnCell(Sender: TObject;
      const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
    procedure dbgProdCompraKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    procedure dxDBGridController1AfterAggregation(
      Sender: TdxDBGridController);

    procedure dxDBGridController1Localize(Sender: TObject;
      Component: TComponent; ID_Ressource: String;
      var Translation: String);

    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);


  private
    FUltimoProduto: Integer;
    FUltimoProdutoCompras: Integer;
    FUltimoProdutoVendas: Integer;
    FAtualizandoSugestao: Boolean;
    FCarregandoHistorico: Boolean;
    FInicializando: Boolean;
    FConfiguracaoCarregada: Boolean;
    FTamanhoFonte: Integer;
    FLinhasHistorico: Integer;
    FMostrarInativos: Boolean;
    FPeriodoSugestao: String;
    FFiltrosSugestao: String;
    FProdutosCompra: TBufDataset;
    FPedidoAtual: TBufDataset;
    FAlteracoesCompra: TStringList;
    FProdutosPedidoIDs: TStringList;
    FMenuColunas: TPopupMenu;
    FMenuAlvo: TDBGrid;
    FTmrTrocaProduto: TTimer;
    FProdutoPendente: Integer;
    FCardFiltros: TPaintBox;
    FDicaSugestao: TLabel;
    procedure LerPreferencias;
    procedure AplicarPreferencias;

    function ArquivoConfiguracaoGrid: String;
    function ArquivoConfiguracaoColunasCompra: String;

    procedure SalvarConfiguracao;
    procedure CarregarConfiguracao;
    procedure SalvarVisibilidadeColunas(AGrid: TDBGrid);
    procedure CarregarVisibilidadeColunas(AGrid: TDBGrid);

    procedure AbrirDataSet(ADataSet: TDataSet);
    procedure ConfigurarFiltroStatus;
    procedure AtualizarProdutos;
    procedure AtualizarSugestaoCompras;
    procedure ProdutosCompraAfterPost(DataSet: TDataSet);
    procedure InicializarProdutosCompra;
    procedure AdicionarProdutoPedidoAtual;
    procedure AtualizarItemPedidoAtual(AOrigem: TDataSet);
    function PedidoAtualValido: Boolean;
    procedure SalvarAlteracoesCompra;
    procedure AplicarFiltroLookup(AFiltro: TDBLookupComboBox;
      const AParametro: String);
    function ProdutoNoPedido(AProduto: Integer): Boolean;
    function EscolherArquivoCompra(const AExtensao: String;
      out AArquivo: String): Boolean;
    procedure AutoSizeGradePagina2(AGrid: TDBGrid);
    procedure AtualizarHistoricoAtual;
    procedure AtualizarVendasPaginaAtiva(AForcar: Boolean = False);
    procedure CarregarVendasProduto(AProduto: Integer; AForcar: Boolean = False);

    procedure AplicarTamanhoFonte;
    procedure AplicarQuantidadeHistorico;

    procedure AutoSizeDBGridColumns(
      AGrid: TRxDBGrid;
      AMinWidth: Integer = 40;
      AMaxWidth: Integer = 350;
      ASampleRows: Integer = 100
    );

    procedure AutoSizeSBGrid(
      AGrid: TDBGrid;
      AMinWidth: Integer = 40;
      AMaxWidth: Integer = 350;
      ASampleRows: Integer = 100
    );

    procedure CarregarHistoricoProduto(AProduto: Integer;
      AForcarHistorico: Boolean = False);
    procedure AgendarHistorico(AProduto: Integer);
    procedure ModernizarInterface;
    procedure PintarCardFiltros(Sender: TObject);
    procedure TrocaProdutoTimer(Sender: TObject);

  public
  end;

var
  frm_p: Tfrm_p;

implementation

{$R *.lfm}

uses uComprasExport;

{ Tfrm_p }

function Tfrm_p.ArquivoConfiguracaoGrid: String;
begin
  Result := IncludeTrailingPathDelimiter(
    ExtractFilePath(Application.ExeName)
  ) + 'dbgProdutos.ini';
end;

function Tfrm_p.ArquivoConfiguracaoColunasCompra: String;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
    'dbgProdCompra.ini';
end;


procedure Tfrm_p.AbrirDataSet(ADataSet: TDataSet);
begin
  if not Assigned(ADataSet) then
    Exit;

  if not ADataSet.Active then
    ADataSet.Open;
end;


procedure Tfrm_p.ConfigurarFiltroStatus;
begin
  if FMostrarInativos then
    uDm.data.qryProdutos.ParamByName('STATUS').AsString := 'T'
  else
    uDm.data.qryProdutos.ParamByName('STATUS').AsString := 'A';
end;


procedure Tfrm_p.AtualizarHistoricoAtual;
begin
  if pgcSystem.ActivePage = TabSheet2 then
  begin
    AtualizarVendasPaginaAtiva(True);
    Exit;
  end;

  if not uDm.data.qryProdutos.Active then
  begin
    CarregarHistoricoProduto(0);
    Exit;
  end;

  if uDm.data.qryProdutos.IsEmpty then
  begin
    CarregarHistoricoProduto(0);
    Exit;
  end;

  CarregarHistoricoProduto(
    uDm.data.qryProdutos.FieldByName('PRD_ID').AsInteger, True);
end;

procedure Tfrm_p.CarregarVendasProduto(AProduto: Integer; AForcar: Boolean);
begin
  if FInicializando or FCarregandoHistorico then Exit;
  if (not AForcar) and (AProduto = FUltimoProdutoVendas) and
     (((AProduto = 0) and not uDm.data.qryVendas.Active) or
      ((AProduto > 0) and uDm.data.qryVendas.Active)) then Exit;

  FCarregandoHistorico := True;
  try
    uDm.data.qryVendas.Close;
    FUltimoProdutoVendas := 0;
    if AProduto <= 0 then Exit;

    uDm.data.qryVendas.ParamByName('PRODUTO').AsInteger := AProduto;
    uDm.data.qryVendas.ParamByName('LIMITE').AsInteger := FLinhasHistorico;
    uDm.data.qryVendas.Open;
    FUltimoProdutoVendas := AProduto;
    if pgcSystem.ActivePage = TabSheet1 then
      AutoSizeDBGridColumns(dbgVendas)
    else
      AutoSizeGradePagina2(dbgProdVendas);
  finally
    FCarregandoHistorico := False;
  end;
end;

procedure Tfrm_p.AtualizarVendasPaginaAtiva(AForcar: Boolean);
var
  DS: TDataSet;
begin
  if FInicializando or FAtualizandoSugestao then Exit;
  if pgcSystem.ActivePage = TabSheet2 then
    DS := qryProdutosComprar
  else
    DS := uDm.data.qryProdutos;

  if not DS.Active or DS.IsEmpty or (DS.State <> dsBrowse) then
  begin
    CarregarVendasProduto(0);
    Exit;
  end;
  CarregarVendasProduto(DS.FieldByName('PRD_ID').AsInteger, AForcar);
end;


procedure Tfrm_p.SalvarConfiguracao;
begin
  {
    A configuração visual do dbgProdutos pertence ao
    dxDBGridController.

    Não executamos AutoSize antes de salvar, pois queremos
    preservar exatamente largura e posição definidas pelo usuário.
  }

  if not Assigned(dxDBGridController1) then
    Exit;

  if not Assigned(dxDBGridController1.DBGrid) then
    Exit;

  try
    dxDBGridController1.SaveConfiguration(
      ArquivoConfiguracaoGrid
    );

    FConfiguracaoCarregada := True;
  except
    on E: Exception do
      MessageDlg(
        'Não foi possível salvar a configuração da grade.' +
        LineEnding + LineEnding +
        E.Message,
        mtWarning,
        [mbOK],
        0
      );
  end;
  if Assigned(FProdutosCompra) and (dbgProdCompra.Columns.Count > 0) then
    SalvarVisibilidadeColunas(dbgProdCompra);
end;


procedure Tfrm_p.CarregarConfiguracao;
begin
  FConfiguracaoCarregada := False;

  if not Assigned(dxDBGridController1) then
    Exit;

  if not Assigned(dxDBGridController1.DBGrid) then
    Exit;

  {
    Se ainda não existe configuração, fazemos AutoSize uma
    única vez para fornecer um layout inicial adequado.
  }
  if not FileExists(ArquivoConfiguracaoGrid) then
  begin
    AutoSizeSBGrid(dbgProdutos);
    if dbgProdCompra.Columns.Count > 0 then
      CarregarVisibilidadeColunas(dbgProdCompra);
    Exit;
  end;

  try
    dxDBGridController1.LoadConfiguration(
      ArquivoConfiguracaoGrid
    );

    {
      Queremos manter largura, posição e demais propriedades
      visuais, mas iniciar sem filtros e ordenações anteriores.
    }
    dxDBGridController1.ClearAllFilters;
    dxDBGridController1.ClearSort;

    FConfiguracaoCarregada := True;

  except
    on E: Exception do
    begin
      {
        Se o INI estiver inválido/corrompido, não impedimos
        a abertura do formulário.
      }

      FConfiguracaoCarregada := False;

      AutoSizeSBGrid(dbgProdutos);

      MessageDlg(
        'A configuração salva da grade não pôde ser carregada.' +
        LineEnding + LineEnding +
        'Será utilizado o layout padrão.' +
        LineEnding + LineEnding +
        E.Message,
        mtWarning,
        [mbOK],
        0
      );
    end;
  end;
  if dbgProdCompra.Columns.Count > 0 then
    CarregarVisibilidadeColunas(dbgProdCompra);
end;

procedure Tfrm_p.SalvarVisibilidadeColunas(AGrid: TDBGrid);
var
  Ini: TIniFile;
  I: Integer;
  Secao: String;
begin
  if not Assigned(AGrid) then Exit;
  Secao := 'Colunas.' + AGrid.Name;
  Ini := TIniFile.Create(ArquivoConfiguracaoColunasCompra);
  try
    for I := 0 to AGrid.Columns.Count - 1 do
      Ini.WriteBool(Secao, AGrid.Columns[I].FieldName,
        AGrid.Columns[I].Visible);
  finally
    Ini.Free;
  end;
end;

procedure Tfrm_p.CarregarVisibilidadeColunas(AGrid: TDBGrid);
var
  Ini: TIniFile;
  I: Integer;
  Secao: String;
begin
  if not Assigned(AGrid) or
     not FileExists(ArquivoConfiguracaoColunasCompra) then Exit;
  Secao := 'Colunas.' + AGrid.Name;
  Ini := TIniFile.Create(ArquivoConfiguracaoColunasCompra);
  try
    for I := 0 to AGrid.Columns.Count - 1 do
      if Ini.ValueExists(Secao, AGrid.Columns[I].FieldName) then
        AGrid.Columns[I].Visible := Ini.ReadBool(Secao,
          AGrid.Columns[I].FieldName, True);
  finally
    Ini.Free;
  end;
end;

procedure Tfrm_p.MenuColunasPopup(Sender: TObject);
var
  I: Integer;
  Item: TMenuItem;
begin
  FMenuAlvo := nil;
  FMenuColunas.Items.Clear;
  if not (FMenuColunas.PopupComponent is TDBGrid) then Exit;
  FMenuAlvo := TDBGrid(FMenuColunas.PopupComponent);
  if FMenuAlvo <> dbgProdCompra then Exit;

  for I := 0 to FMenuAlvo.Columns.Count - 1 do
  begin
    Item := TMenuItem.Create(FMenuColunas);
    Item.Caption := FMenuAlvo.Columns[I].Title.Caption;
    Item.Checked := FMenuAlvo.Columns[I].Visible;
    Item.AutoCheck := True;
    Item.Tag := I;
    Item.OnClick := @MenuColunaClick;
    Item.Enabled := not SameText(FMenuAlvo.Columns[I].FieldName,
      'PRD_DESCRICAO') and
      not SameText(FMenuAlvo.Columns[I].FieldName, 'COMPRAR');
    FMenuColunas.Items.Add(Item);
  end;
end;

procedure Tfrm_p.MenuColunaClick(Sender: TObject);
var
  Item: TMenuItem;
  Campo: String;
begin
  if not Assigned(FMenuAlvo) or not (Sender is TMenuItem) then Exit;
  Item := TMenuItem(Sender);
  if (Item.Tag < 0) or (Item.Tag >= FMenuAlvo.Columns.Count) then Exit;
  Campo := FMenuAlvo.Columns[Item.Tag].FieldName;
  if SameText(Campo, 'PRD_DESCRICAO') or
     SameText(Campo, 'COMPRAR') then
  begin
    Item.Checked := True;
    Exit;
  end;
  FMenuAlvo.Columns[Item.Tag].Visible := Item.Checked;
  SalvarVisibilidadeColunas(FMenuAlvo);
  FMenuAlvo.Invalidate;
end;


procedure Tfrm_p.LerPreferencias;
begin
  FTamanhoFonte := StrToIntDef(
    PLerINI('DICASTRO', 'TAM_FONTE', '9'), 9);
  if FTamanhoFonte < 6 then FTamanhoFonte := 6;
  if FTamanhoFonte > 32 then FTamanhoFonte := 32;

  FLinhasHistorico := StrToIntDef(
    PLerINI('DICASTRO', 'HIS_LINHAS', '9'), 9);
  if FLinhasHistorico < 1 then FLinhasHistorico := 1;

  FMostrarInativos :=
    PLerINI('DICASTRO', 'MOSTRAR_INATIVOS', '0') = '1';
end;

procedure Tfrm_p.AplicarPreferencias;
var
  FonteAnterior, LinhasAnteriores: Integer;
  InativosAnteriores: Boolean;
begin
  FonteAnterior := FTamanhoFonte;
  LinhasAnteriores := FLinhasHistorico;
  InativosAnteriores := FMostrarInativos;
  LerPreferencias;

  if FonteAnterior <> FTamanhoFonte then
    AplicarTamanhoFonte;

  if InativosAnteriores <> FMostrarInativos then
    AtualizarProdutos
  else if LinhasAnteriores <> FLinhasHistorico then
    AplicarQuantidadeHistorico;
end;

procedure Tfrm_p.AplicarTamanhoFonte;
var
  AlturaLinha: Integer;
begin
  dbgProdutos.Font.Size := FTamanhoFonte;
  dbgCompras.Font.Size  := FTamanhoFonte;
  dbgVendas.Font.Size   := FTamanhoFonte;
  dbgProdCompra.Font.Size := FTamanhoFonte;
  dbgProdVendas.Font.Size := FTamanhoFonte;

  if FTamanhoFonte > 12 then
  begin
    dbgProdutos.TitleFont.Size := 12;
    dbgCompras.TitleFont.Size  := 12;
    dbgVendas.TitleFont.Size   := 12;
    dbgProdCompra.TitleFont.Size := 12;
    dbgProdVendas.TitleFont.Size := 12;
  end
  else
  begin
    dbgProdutos.TitleFont.Size := FTamanhoFonte;
    dbgCompras.TitleFont.Size  := FTamanhoFonte;
    dbgVendas.TitleFont.Size   := FTamanhoFonte;
    dbgProdCompra.TitleFont.Size := FTamanhoFonte;
    dbgProdVendas.TitleFont.Size := FTamanhoFonte;
  end;

  dbgProdutos.Canvas.Font.Assign(dbgProdutos.Font);
  AlturaLinha := dbgProdutos.Canvas.TextHeight('Ag') + 10;
  if AlturaLinha < 24 then AlturaLinha := 24;
  dbgProdutos.DefaultRowHeight := AlturaLinha;
  dbgCompras.DefaultRowHeight := AlturaLinha;
  dbgVendas.DefaultRowHeight := AlturaLinha;
  dbgProdCompra.DefaultRowHeight := AlturaLinha;
  dbgProdVendas.DefaultRowHeight := AlturaLinha;

  {
    IMPORTANTE:

    dbgProdutos NÃO recebe AutoSize aqui.

    O usuário pode ter configurado manualmente:
      - Width
      - ordem das colunas
      - demais propriedades

    Fazer AutoSizeSBGrid(dbgProdutos) aqui destruiria a
    configuração personalizada.

    Compras e vendas continuam automáticas porque não utilizam
    essa persistência pelo dxDBGridController.
  }

  AutoSizeDBGridColumns(dbgCompras);
  AutoSizeDBGridColumns(dbgVendas);
  AutoSizeGradePagina2(dbgProdCompra);
  AutoSizeGradePagina2(dbgProdVendas);

  dbgProdutos.Invalidate;
  dbgCompras.Invalidate;
  dbgVendas.Invalidate;
  dbgProdCompra.Invalidate;
  dbgProdVendas.Invalidate;
end;


procedure Tfrm_p.AplicarQuantidadeHistorico;
var
  CodProduto: Integer;
begin
  if FInicializando then
    Exit;

  if pgcSystem.ActivePage = TabSheet2 then
  begin
    AtualizarVendasPaginaAtiva(True);
    Exit;
  end;

  if not uDm.data.qryProdutos.Active or uDm.data.qryProdutos.IsEmpty then Exit;

  CodProduto :=
    uDm.data.qryProdutos.FieldByName('PRD_ID').AsInteger;

  {
    Aqui devemos recarregar mesmo se for o mesmo produto.

    FLinhasHistorico representa a quantidade de linhas do histórico.
    Portanto, mudar 10 para 20 deve executar novamente a consulta
    para o mesmo produto.
  }

  CarregarHistoricoProduto(CodProduto, True);
end;


procedure Tfrm_p.AutoSizeDBGridColumns(
  AGrid: TRxDBGrid;
  AMinWidth: Integer;
  AMaxWidth: Integer;
  ASampleRows: Integer
);
var
  Bmk: TBookmark;
  I: Integer;
  W: Integer;
  TextWidth: Integer;
  Count: Integer;
  S: String;
  DS: TDataSet;
  BookmarkValido: Boolean;
begin
  if not Assigned(AGrid) then
    Exit;

  if not Assigned(AGrid.DataSource) then
    Exit;

  if not Assigned(AGrid.DataSource.DataSet) then
    Exit;

  DS := AGrid.DataSource.DataSet;

  if not DS.Active then
    Exit;

  if AGrid.Columns.Count = 0 then
    Exit;

  AGrid.Canvas.Font.Assign(AGrid.Font);

  BookmarkValido := False;

  DS.DisableControls;
  try

    if not DS.IsEmpty then
    begin
      Bmk := DS.GetBookmark;
      BookmarkValido := True;
    end;

    for I := 0 to AGrid.Columns.Count - 1 do
    begin

      { Largura mínima baseada no título }

      W :=
        AGrid.Canvas.TextWidth(
          AGrid.Columns[I].Title.Caption
        ) + 24;

      if not DS.IsEmpty then
      begin
        DS.First;
        Count := 0;

        while (not DS.Eof) and
              (Count < ASampleRows) do
        begin

          if Assigned(AGrid.Columns[I].Field) then
            S := AGrid.Columns[I].Field.DisplayText
          else
            S := '';

          TextWidth :=
            AGrid.Canvas.TextWidth(S) + 20;

          if TextWidth > W then
            W := TextWidth;

          Inc(Count);
          DS.Next;
        end;
      end;

      if W < AMinWidth then
        W := AMinWidth;

      if W > AMaxWidth then
        W := AMaxWidth;

      AGrid.Columns[I].Width := W;
    end;

    if BookmarkValido and DS.BookmarkValid(Bmk) then
      DS.GotoBookmark(Bmk);

  finally

    if BookmarkValido then
      DS.FreeBookmark(Bmk);

    DS.EnableControls;
  end;
end;


procedure Tfrm_p.AutoSizeSBGrid(
  AGrid: TDBGrid;
  AMinWidth: Integer;
  AMaxWidth: Integer;
  ASampleRows: Integer
);
var
  Bmk: TBookmark;
  I: Integer;
  W: Integer;
  TextWidth: Integer;
  Count: Integer;
  S: String;
  DS: TDataSet;
  BookmarkValido: Boolean;
begin
  if not Assigned(AGrid) then
    Exit;

  if not Assigned(AGrid.DataSource) then
    Exit;

  if not Assigned(AGrid.DataSource.DataSet) then
    Exit;

  DS := AGrid.DataSource.DataSet;

  if not DS.Active then
    Exit;

  if AGrid.Columns.Count = 0 then
    Exit;

  AGrid.Canvas.Font.Assign(AGrid.Font);

  BookmarkValido := False;

  DS.DisableControls;
  try

    if not DS.IsEmpty then
    begin
      Bmk := DS.GetBookmark;
      BookmarkValido := True;
    end;

    for I := 0 to AGrid.Columns.Count - 1 do
    begin

      W :=
        AGrid.Canvas.TextWidth(
          AGrid.Columns[I].Title.Caption
        ) + 24;

      if not DS.IsEmpty then
      begin
        DS.First;
        Count := 0;

        while (not DS.Eof) and
              (Count < ASampleRows) do
        begin

          if Assigned(AGrid.Columns[I].Field) then
            S := AGrid.Columns[I].Field.DisplayText
          else
            S := '';

          TextWidth :=
            AGrid.Canvas.TextWidth(S) + 20;

          if TextWidth > W then
            W := TextWidth;

          Inc(Count);
          DS.Next;
        end;
      end;

      if W < AMinWidth then
        W := AMinWidth;

      if W > AMaxWidth then
        W := AMaxWidth;

      AGrid.Columns[I].Width := W;
    end;

    if BookmarkValido and DS.BookmarkValid(Bmk) then
      DS.GotoBookmark(Bmk);

  finally

    if BookmarkValido then
      DS.FreeBookmark(Bmk);

    DS.EnableControls;
  end;
end;

procedure Tfrm_p.AutoSizeGradePagina2(AGrid: TDBGrid);
var
  DS: TDataSet;
  Bmk: TBookmark;
  Larguras, Minimos: array of Integer;
  I, N, Amostras, Largura, Total, Disponivel, Excesso: Integer;
  Descricao: Integer;
  Campo: TField;
  TemBookmark: Boolean;
begin
  if not Assigned(AGrid) or not Assigned(AGrid.DataSource) then Exit;
  DS := AGrid.DataSource.DataSet;
  if not Assigned(DS) or not DS.Active then Exit;

  if AGrid.Columns.Count = 0 then
    for I := 0 to DS.FieldCount - 1 do
      if DS.Fields[I].Visible then
        with AGrid.Columns.Add do
        begin
          FieldName := DS.Fields[I].FieldName;
          Title.Caption := DS.Fields[I].DisplayLabel;
        end;

  N := AGrid.Columns.Count;
  if N = 0 then Exit;
  SetLength(Larguras, N);
  SetLength(Minimos, N);
  AGrid.Canvas.Font.Assign(AGrid.Font);
  Descricao := -1;
  TemBookmark := False;
  DS.DisableControls;
  try
    if not DS.IsEmpty then
    begin
      Bmk := DS.GetBookmark;
      TemBookmark := True;
    end;
    for I := 0 to N - 1 do
    begin
      Campo := DS.FindField(AGrid.Columns[I].FieldName);
      if Pos('DESCRICAO', UpperCase(AGrid.Columns[I].FieldName)) > 0 then
      begin
        Minimos[I] := 160;
        Descricao := I;
      end
      else if Assigned(Campo) and (Campo.DataType in
        [ftSmallint, ftInteger, ftLargeint, ftFloat, ftCurrency,
         ftBCD, ftFMTBcd]) then
        Minimos[I] := 70
      else
        Minimos[I] := 85;

      Largura := AGrid.Canvas.TextWidth(AGrid.Columns[I].Title.Caption) + 20;
      if Assigned(Campo) and not DS.IsEmpty then
      begin
        DS.First;
        Amostras := 0;
        while not DS.Eof and (Amostras < 80) do
        begin
          Largura := Max(Largura,
            AGrid.Canvas.TextWidth(Campo.DisplayText) + 18);
          Inc(Amostras);
          DS.Next;
        end;
      end;
      if Largura < Minimos[I] then Largura := Minimos[I];
      if I = Descricao then
        Largura := Min(Largura, 440)
      else if Assigned(Campo) and (Campo.DataType in
        [ftSmallint, ftInteger, ftLargeint, ftFloat, ftCurrency,
         ftBCD, ftFMTBcd]) then
        Largura := Min(Largura, 125)
      else
        Largura := Min(Largura, 200);
      Larguras[I] := Largura;
    end;

    Disponivel := AGrid.ClientWidth - 36;
    if Disponivel < 0 then Disponivel := 0;
    Total := 0;
    for I := 0 to N - 1 do Inc(Total, Larguras[I]);
    Excesso := Total - Disponivel;
    if Excesso > 0 then
    begin
      if Descricao >= 0 then
      begin
        Largura := Min(Excesso, Larguras[Descricao] - Minimos[Descricao]);
        Dec(Larguras[Descricao], Largura);
        Dec(Excesso, Largura);
      end;
      for I := 0 to N - 1 do
        if (Excesso > 0) and (I <> Descricao) then
        begin
          Largura := Min(Excesso, Larguras[I] - Minimos[I]);
          Dec(Larguras[I], Largura);
          Dec(Excesso, Largura);
        end;
    end
    else if (Descricao >= 0) and (Total < Disponivel) then
      Larguras[Descricao] := Min(480,
        Larguras[Descricao] + Disponivel - Total);

    for I := 0 to N - 1 do
      AGrid.Columns[I].Width := Larguras[I];

    if TemBookmark and DS.BookmarkValid(Bmk) then
      DS.GotoBookmark(Bmk);
  finally
    if TemBookmark then DS.FreeBookmark(Bmk);
    DS.EnableControls;
  end;
end;


procedure Tfrm_p.CarregarHistoricoProduto(AProduto: Integer;
  AForcarHistorico: Boolean);
begin
  if FInicializando or (pgcSystem.ActivePage <> TabSheet1) then Exit;
  if AProduto <= 0 then
  begin
    uDm.data.qryCompras.Close;
    FUltimoProdutoCompras := 0;
    CarregarVendasProduto(0);
    Exit;
  end;

  if AForcarHistorico or (AProduto <> FUltimoProdutoCompras) or
     not uDm.data.qryCompras.Active then
  begin
    uDm.data.qryCompras.Close;
    FUltimoProdutoCompras := -1;
    uDm.data.qryCompras.ParamByName('PRODUTO').AsInteger := AProduto;
    uDm.data.qryCompras.ParamByName('LIMITE').AsInteger := FLinhasHistorico;
    uDm.data.qryCompras.Open;
    FUltimoProdutoCompras := AProduto;
    AutoSizeDBGridColumns(dbgCompras);
  end;

  CarregarVendasProduto(AProduto, AForcarHistorico);

end;


procedure Tfrm_p.FormShow(Sender: TObject);
begin
  FInicializando := True;
  InicializarProdutosCompra;
  ModernizarInterface;
  if not Assigned(FMenuColunas) then
  begin
    FMenuColunas := TPopupMenu.Create(Self);
    FMenuColunas.OnPopup := @MenuColunasPopup;
    dbgProdCompra.PopupMenu := FMenuColunas;
  end;
  FUltimoProdutoVendas := -1;
  FUltimoProdutoCompras := -1;

  try
    { Atribuição em código: funciona mesmo sem OnClick no .lfm. }
    bHome.OnClick := @bHomeClick;
    bCompra.OnClick := @bCompraClick;
    pgcSystem.ActivePageIndex := 0;
    DateTimePicker1.Date := StartOfTheMonth(Date);
    DateTimePicker2.Date := Date;

    Self.SetBounds(
      Screen.WorkAreaLeft,
      Screen.WorkAreaTop,
      Screen.WorkAreaWidth,
      Screen.WorkAreaHeight
    );

    {
      Vincula o controller antes de restaurar sua configuração.
    }

    dxDBGridController1.DBGrid := dbgProdutos;
    dxDBGridController1.Navigator.VisibleButtons := [];

    {
      Carrega preferências simples primeiro.

      FInicializando evita que os OnChange executem consultas
      e AutoSize durante a montagem do formulário.
    }

    LerPreferencias;

    {
      Abre apenas datasets que ainda estiverem fechados.
    }

    ConfigurarFiltroStatus;
    if uDm.data.qryProdutos.Active then
      uDm.data.qryProdutos.Close;
    AbrirDataSet(uDm.data.qryProdutos);
    AbrirDataSet(uDm.data.qryGrupo);
    AbrirDataSet(uDm.data.qrySubGrupo);
    AbrirDataSet(uDm.data.qryMarca);
    AbrirDataSet(uDm.data.qrySetor);
    AbrirDataSet(uDm.data.qryFornecedor);

    {
      Primeiro aplicamos a fonte.
      Depois restauramos a configuração da grade.

      Isso é proposital: a configuração persistida pelo usuário
      deve ser a última palavra sobre largura/posição.
    }

    AplicarTamanhoFonte;

    CarregarConfiguracao;
    FormResize(Self);

  finally
    FInicializando := False;
  end;

  {
    Carrega o histórico somente depois que toda a interface
    estiver inicializada.
  }

  FUltimoProduto := -1;

  if uDm.data.qryProdutos.Active and
     (not uDm.data.qryProdutos.IsEmpty) then
  begin
    FUltimoProduto :=
      uDm.data.qryProdutos.FieldByName('PRD_ID').AsInteger;

    CarregarHistoricoProduto(FUltimoProduto);
  end;

  { Atualização automática a cada 1 minuto. }
  tmrAtualizacao.Interval := 60000;
  tmrAtualizacao.Enabled := True;
end;

procedure Tfrm_p.InicializarProdutosCompra;
var
  I: Integer;
  Coluna: TColumn;
begin
  if Assigned(FProdutosCompra) then Exit;
  FAlteracoesCompra := TStringList.Create;
  FAlteracoesCompra.Sorted := True;
  FAlteracoesCompra.Duplicates := dupIgnore;
  FProdutosPedidoIDs := TStringList.Create;
  FProdutosPedidoIDs.Sorted := True;
  FProdutosPedidoIDs.Duplicates := dupIgnore;
  FProdutosCompra := TBufDataset.Create(Self);
  FProdutosCompra.FieldDefs.Add('PRD_ID', ftInteger);
  FProdutosCompra.FieldDefs.Add('PRD_DESCRICAO', ftString, 100);
  FProdutosCompra.FieldDefs.Add('PRD_UN_VENDA', ftString, 20);
  FProdutosCompra.FieldDefs.Add('PMAR_DESCRICAO', ftString, 100);
  FProdutosCompra.FieldDefs.Add('VENDIDO', ftFloat);
  FProdutosCompra.FieldDefs.Add('ESTOQUE', ftFloat);
  FProdutosCompra.FieldDefs.Add('SUGERIDO', ftFloat);
  FProdutosCompra.FieldDefs.Add('COMPRAR', ftFloat);
  FProdutosCompra.CreateDataset;
  FProdutosCompra.FieldByName('COMPRAR').DisplayLabel := 'Comprar';
  FProdutosCompra.FieldByName('SUGERIDO').DisplayLabel := 'Quantidade Sugerida';
  FProdutosCompra.FieldByName('PRD_UN_VENDA').DisplayLabel := 'Unidade';
  FProdutosCompra.FieldByName('VENDIDO').DisplayLabel := 'Vendido';
  FProdutosCompra.FieldByName('ESTOQUE').DisplayLabel := 'Estoque';
  FProdutosCompra.FieldByName('PRD_ID').DisplayLabel := 'ID';
  FProdutosCompra.FieldByName('PRD_DESCRICAO').DisplayLabel := 'Descrição';
  FProdutosCompra.FieldByName('PMAR_DESCRICAO').DisplayLabel := 'Marca';
  (FProdutosCompra.FieldByName('VENDIDO') as TNumericField).DisplayFormat :=
    '0.######';
  (FProdutosCompra.FieldByName('ESTOQUE') as TNumericField).DisplayFormat :=
    '0.######';
  (FProdutosCompra.FieldByName('SUGERIDO') as TNumericField).DisplayFormat :=
    '0.######';
  (FProdutosCompra.FieldByName('COMPRAR') as TNumericField).DisplayFormat :=
    '0.######';
  FProdutosCompra.AfterPost := @ProdutosCompraAfterPost;
  dsSugestaoCompras.DataSet := FProdutosCompra;
  dbgProdCompra.Columns.Clear;
  for I := 0 to 5 do
  begin
    Coluna := dbgProdCompra.Columns.Add;
    case I of
      0: Coluna.FieldName := 'VENDIDO';
      1: Coluna.FieldName := 'ESTOQUE';
      2: Coluna.FieldName := 'COMPRAR';
      3: Coluna.FieldName := 'PRD_ID';
      4: Coluna.FieldName := 'PRD_DESCRICAO';
      5: Coluna.FieldName := 'PMAR_DESCRICAO';
    end;
    Coluna.Title.Caption := FProdutosCompra.FieldByName(Coluna.FieldName).DisplayLabel;
    Coluna.ReadOnly := not SameText(Coluna.FieldName, 'COMPRAR');
  end;

  FPedidoAtual := TBufDataset.Create(Self);
  FPedidoAtual.FieldDefs.Assign(FProdutosCompra.FieldDefs);
  FPedidoAtual.CreateDataset;
  FPedidoAtual.FieldByName('PRD_ID').DisplayLabel := 'Código';
  FPedidoAtual.FieldByName('PRD_DESCRICAO').DisplayLabel := 'Descrição';
  FPedidoAtual.FieldByName('PRD_UN_VENDA').DisplayLabel := 'Unidade';
  FPedidoAtual.FieldByName('PMAR_DESCRICAO').DisplayLabel := 'Marca';
  FPedidoAtual.FieldByName('VENDIDO').DisplayLabel := 'Qtd. Vendida';
  FPedidoAtual.FieldByName('ESTOQUE').DisplayLabel := 'Qtd. Estoque';
  FPedidoAtual.FieldByName('SUGERIDO').DisplayLabel := 'Qtd. Sugerida';
  FPedidoAtual.FieldByName('COMPRAR').DisplayLabel := 'Qtd. Pedido';
  (FPedidoAtual.FieldByName('VENDIDO') as TNumericField).DisplayFormat :=
    '0.######';
  (FPedidoAtual.FieldByName('ESTOQUE') as TNumericField).DisplayFormat :=
    '0.######';
  (FPedidoAtual.FieldByName('SUGERIDO') as TNumericField).DisplayFormat :=
    '0.######';
  (FPedidoAtual.FieldByName('COMPRAR') as TNumericField).DisplayFormat :=
    '0.######';
  dsPedidoAtual.DataSet := FPedidoAtual;
  dbgPedidoAtual.Columns.Clear;
  for I := 0 to 3 do
  begin
    Coluna := dbgPedidoAtual.Columns.Add;
    case I of
      0: Coluna.FieldName := 'PRD_ID';
      1: Coluna.FieldName := 'PRD_DESCRICAO';
      2: Coluna.FieldName := 'PRD_UN_VENDA';
      3: Coluna.FieldName := 'COMPRAR';
    end;
    Coluna.Title.Caption := FPedidoAtual.FieldByName(Coluna.FieldName).DisplayLabel;
    Coluna.ReadOnly := True;
  end;
end;

procedure Tfrm_p.AdicionarProdutoPedidoAtual;
var
  ID: Integer;
  Quantidade: Double;
  Origem, Destino: TDataSet;
begin
  if not Assigned(FProdutosCompra) or not FProdutosCompra.Active or
     FProdutosCompra.IsEmpty then Exit;
  if FProdutosCompra.State in [dsEdit, dsInsert] then FProdutosCompra.Post;

  { O pedido aceita somente quantidades positivas. Leia o valor já editado
    na grade antes de criar ou atualizar a linha do pedido. }
  Quantidade := FProdutosCompra.FieldByName('COMPRAR').AsFloat;
  if not (Quantidade > 0) then
  begin
    MessageDlg('Informe uma quantidade maior que zero para adicionar o produto.',
      mtWarning, [mbOK], 0);
    Exit;
  end;

  ID := FProdutosCompra.FieldByName('PRD_ID').AsInteger;
  Origem := FProdutosCompra;
  Destino := FPedidoAtual;
  if not Destino.Locate('PRD_ID', ID, []) then
    Destino.Append
  else
    Destino.Edit;

  Destino.FieldByName('PRD_ID').AsInteger := ID;
  Destino.FieldByName('PRD_DESCRICAO').AsString :=
    Origem.FieldByName('PRD_DESCRICAO').AsString;
  Destino.FieldByName('PRD_UN_VENDA').AsString :=
    Origem.FieldByName('PRD_UN_VENDA').AsString;
  Destino.FieldByName('PMAR_DESCRICAO').AsString :=
    Origem.FieldByName('PMAR_DESCRICAO').AsString;
  Destino.FieldByName('VENDIDO').AsFloat :=
    Origem.FieldByName('VENDIDO').AsFloat;
  Destino.FieldByName('ESTOQUE').AsFloat :=
    Origem.FieldByName('ESTOQUE').AsFloat;
  Destino.FieldByName('SUGERIDO').AsFloat :=
    Origem.FieldByName('SUGERIDO').AsFloat;
  Destino.FieldByName('COMPRAR').AsFloat :=
    Origem.FieldByName('COMPRAR').AsFloat;
  Destino.Post;
  FProdutosPedidoIDs.Add(IntToStr(ID));
end;

function Tfrm_p.ProdutoNoPedido(AProduto: Integer): Boolean;
begin
  Result := Assigned(FProdutosPedidoIDs) and (AProduto > 0) and
    (FProdutosPedidoIDs.IndexOf(IntToStr(AProduto)) >= 0);
end;

procedure Tfrm_p.AtualizarItemPedidoAtual(AOrigem: TDataSet);
var
  ID: Integer;
begin
  if not FPedidoAtual.Active then Exit;
  ID := AOrigem.FieldByName('PRD_ID').AsInteger;
  if not FPedidoAtual.Locate('PRD_ID', ID, []) then Exit;
  FPedidoAtual.Edit;
  FPedidoAtual.FieldByName('PRD_DESCRICAO').AsString :=
    AOrigem.FieldByName('PRD_DESCRICAO').AsString;
  FPedidoAtual.FieldByName('PRD_UN_VENDA').AsString :=
    AOrigem.FieldByName('PRD_UN_VENDA').AsString;
  FPedidoAtual.FieldByName('PMAR_DESCRICAO').AsString :=
    AOrigem.FieldByName('PMAR_DESCRICAO').AsString;
  FPedidoAtual.FieldByName('VENDIDO').AsFloat :=
    AOrigem.FieldByName('VENDIDO').AsFloat;
  FPedidoAtual.FieldByName('ESTOQUE').AsFloat :=
    AOrigem.FieldByName('ESTOQUE').AsFloat;
  FPedidoAtual.FieldByName('SUGERIDO').AsFloat :=
    AOrigem.FieldByName('SUGERIDO').AsFloat;
  FPedidoAtual.FieldByName('COMPRAR').AsFloat :=
    AOrigem.FieldByName('COMPRAR').AsFloat;
  FPedidoAtual.Post;
end;

function Tfrm_p.PedidoAtualValido: Boolean;
var
  Bmk: TBookmark;
begin
  Result := False;
  if not Assigned(FPedidoAtual) or not FPedidoAtual.Active or
     FPedidoAtual.IsEmpty then Exit;
  if FPedidoAtual.State in [dsEdit, dsInsert] then FPedidoAtual.Post;
  FPedidoAtual.DisableControls;
  Bmk := FPedidoAtual.GetBookmark;
  try
    FPedidoAtual.First;
    while not FPedidoAtual.Eof do
    begin
      if FPedidoAtual.FieldByName('COMPRAR').AsFloat > 0 then
        Exit(True);
      FPedidoAtual.Next;
    end;
  finally
    if FPedidoAtual.BookmarkValid(Bmk) then FPedidoAtual.GotoBookmark(Bmk);
    FPedidoAtual.FreeBookmark(Bmk);
    FPedidoAtual.EnableControls;
  end;
end;

procedure Tfrm_p.SalvarAlteracoesCompra;
var
  Chave, Valor: String;
  I: Integer;
begin
  if not Assigned(FProdutosCompra) or not FProdutosCompra.Active then Exit;
  if FProdutosCompra.State in [dsEdit, dsInsert] then FProdutosCompra.Post;
  FProdutosCompra.DisableControls;
  try
    FProdutosCompra.First;
    while not FProdutosCompra.Eof do
    begin
      Chave := IntToStr(FProdutosCompra.FieldByName('PRD_ID').AsInteger);
      Valor := FloatToStr(FProdutosCompra.FieldByName('COMPRAR').AsFloat);
      I := FAlteracoesCompra.IndexOfName(Chave);
      if I >= 0 then
      begin
        FAlteracoesCompra.Delete(I);
        FAlteracoesCompra.Add(Chave + '=' + Valor);
      end;
      FProdutosCompra.Next;
    end;
  finally
    FProdutosCompra.EnableControls;
  end;
end;

procedure Tfrm_p.ProdutosCompraAfterPost(DataSet: TDataSet);
var
  Chave: String;
  ProdutoID: Integer;
begin
  if FAtualizandoSugestao then Exit;
  ProdutoID := DataSet.FieldByName('PRD_ID').AsInteger;
  Chave := IntToStr(ProdutoID);
  FAlteracoesCompra.Values[Chave] :=
    FloatToStr(DataSet.FieldByName('COMPRAR').AsFloat);

  AtualizarItemPedidoAtual(DataSet);
end;


procedure Tfrm_p.FormClose(
  Sender: TObject;
  var CloseAction: TCloseAction
);
begin
  tmrAtualizacao.Enabled := False;

  {
    Centraliza a persistência no fechamento real do formulário.

    Assim funciona para:
      - botão fechar
      - X
      - Alt+F4
      - Close
      - outros caminhos normais de fechamento
  }

  SalvarConfiguracao;
  FreeAndNil(FAlteracoesCompra);
  FreeAndNil(FProdutosPedidoIDs);

end;


procedure Tfrm_p.Label2Click(Sender: TObject);
begin
  {
    Não salvamos manualmente aqui.

    FormClose é o único responsável pela persistência.
  }

  Close;
end;


procedure Tfrm_p.Label3Click(Sender: TObject);
begin
  Application.Minimize;
end;


procedure Tfrm_p.Label5Click(Sender: TObject);
begin
end;


procedure Tfrm_p.FormResize(Sender: TObject);
const
  MargemLateral = 12;
  MargemSuperior = 8;
  MargemInferior = 18;
  EspacoEntreGrades = 10;
  EspacoHistorico = 12;
  AlturaMinimaHistorico = 110;
var
  AreaLargura, AreaAltura: Integer;
  AlturaProdutos, TopoHistorico, AlturaHistorico: Integer;
  LarguraGrade, AlturaSugestao, AlturaPedido, TopoVendas: Integer;
begin
  if not Assigned(pnl_produtos) or
     not Assigned(dbgCompras) or
     not Assigned(dbgVendas) then Exit;

  if not Assigned(pnl_produtos.Parent) or
     not Assigned(dbgCompras.Parent) then Exit;

  { As medidas são relativas ao container, não à janela inteira.
    Isso evita o PageControl consumir parte da área útil. }
  AreaLargura := pnl_produtos.Parent.ClientWidth;
  AreaAltura := pnl_produtos.Parent.ClientHeight;
  if (AreaLargura <= 0) or (AreaAltura <= 0) then Exit;

  { Produtos ocupam aproximadamente 62% da área disponível. }
  AlturaProdutos := (AreaAltura * 62) div 100;
  if AlturaProdutos > AreaAltura - MargemSuperior -
      EspacoHistorico - MargemInferior - AlturaMinimaHistorico then
    AlturaProdutos := AreaAltura - MargemSuperior -
      EspacoHistorico - MargemInferior - AlturaMinimaHistorico;
  if AlturaProdutos < 0 then AlturaProdutos := 0;

  pnl_produtos.SetBounds(
    MargemLateral, MargemSuperior,
    AreaLargura - 2 * MargemLateral, AlturaProdutos);

  TopoHistorico := pnl_produtos.Top + pnl_produtos.Height + EspacoHistorico;
  AlturaHistorico := AreaAltura - TopoHistorico - MargemInferior;
  if AlturaHistorico < 0 then AlturaHistorico := 0;

  LarguraGrade := (AreaLargura - 2 * MargemLateral - EspacoEntreGrades) div 2;
  if LarguraGrade < 0 then LarguraGrade := 0;

  dbgCompras.SetBounds(MargemLateral, TopoHistorico,
    LarguraGrade, AlturaHistorico);
  dbgVendas.SetBounds(MargemLateral + LarguraGrade + EspacoEntreGrades,
    TopoHistorico, LarguraGrade, AlturaHistorico);

  if Assigned(TabSheet2) and (TabSheet2.ClientWidth > 0) then
  begin
    LarguraGrade := (TabSheet2.ClientWidth - 2 * MargemLateral -
      EspacoEntreGrades) div 2;
    if LarguraGrade < 0 then LarguraGrade := 0;
    AlturaSugestao := TabSheet2.ClientHeight - 104 - MargemInferior;
    if AlturaSugestao < 0 then AlturaSugestao := 0;
    dbgProdCompra.SetBounds(MargemLateral, 104, LarguraGrade,
      AlturaSugestao);
    AlturaPedido := (AlturaSugestao - 44) div 2;
    if AlturaPedido < 70 then AlturaPedido := 70;
    TopoVendas := 120 + AlturaPedido + 28;
    dbgPedidoAtual.SetBounds(MargemLateral + LarguraGrade +
      EspacoEntreGrades, 120, LarguraGrade, AlturaPedido);
    dbgProdVendas.SetBounds(MargemLateral + LarguraGrade +
      EspacoEntreGrades, TopoVendas, LarguraGrade,
      TabSheet2.ClientHeight - TopoVendas - MargemInferior);
    Label13.SetBounds(MargemLateral + LarguraGrade +
      EspacoEntreGrades, 104, Label13.Width, Label13.Height);
    Label12.SetBounds(MargemLateral + LarguraGrade +
      EspacoEntreGrades, TopoVendas - 16, Label12.Width, Label12.Height);
  end;
end;

procedure Tfrm_p.dsProdutosDataChange(
  Sender: TObject;
  Field: TField
);
var
  CodProduto: Integer;
begin
  if FInicializando or (pgcSystem.ActivePage <> TabSheet1) then
    Exit;

  if not uDm.data.qryProdutos.Active then
    Exit;

  if uDm.data.qryProdutos.IsEmpty then
  begin
    FUltimoProduto := -1;
    if Assigned(FTmrTrocaProduto) then
      FTmrTrocaProduto.Enabled := False;
    CarregarHistoricoProduto(0);
    Exit;
  end;

  if uDm.data.qryProdutos.State <> dsBrowse then Exit;

  CodProduto :=
    uDm.data.qryProdutos.FieldByName('PRD_ID').AsInteger;

  if CodProduto = FUltimoProduto then
    Exit;

  FUltimoProduto := CodProduto;
  AgendarHistorico(CodProduto);
end;

{ Debounce: ao percorrer a grade com as setas, só consulta o histórico
  quando o usuário para numa linha (evita 2 consultas por linha). }
procedure Tfrm_p.AgendarHistorico(AProduto: Integer);
begin
  if not Assigned(FTmrTrocaProduto) then
  begin
    FTmrTrocaProduto := TTimer.Create(Self);
    FTmrTrocaProduto.Enabled := False;
    FTmrTrocaProduto.Interval := 150;
    FTmrTrocaProduto.OnTimer := @TrocaProdutoTimer;
  end;
  FProdutoPendente := AProduto;
  FTmrTrocaProduto.Enabled := False;
  FTmrTrocaProduto.Enabled := True;
end;

procedure Tfrm_p.TrocaProdutoTimer(Sender: TObject);
begin
  FTmrTrocaProduto.Enabled := False;
  CarregarHistoricoProduto(FProdutoPendente);
end;

procedure Tfrm_p.dsSugestaoComprasDataChange(Sender: TObject; Field: TField);
begin
  if FInicializando or FAtualizandoSugestao or
     (pgcSystem.ActivePage <> TabSheet2) then Exit;
  AtualizarVendasPaginaAtiva;
end;

procedure Tfrm_p.ckProdutos0Click(Sender: TObject);
begin
  if not FInicializando and qryProdutosComprar.Active then
    AtualizarSugestaoCompras;
end;

procedure Tfrm_p.AtualizarSugestaoCompras;
var
  ProdutoAtual: Integer;
  Chave: String;
  ValorManual: Double;
  IndiceAlteracao: Integer;
begin
  if FInicializando or FAtualizandoSugestao then Exit;
  if (DateTimePicker1.Date <= 0) or (DateTimePicker2.Date <= 0) then
  begin
    MessageDlg('Informe as datas inicial e final.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if DateTimePicker1.Date > DateTimePicker2.Date then
  begin
    MessageDlg('A data inicial deve ser anterior à data final.',
      mtWarning, [mbOK], 0);
    Exit;
  end;

  ProdutoAtual := 0;
  if FProdutosCompra.Active and not FProdutosCompra.IsEmpty then
    ProdutoAtual := FProdutosCompra.FieldByName('PRD_ID').AsInteger;
  SalvarAlteracoesCompra;

  FAtualizandoSugestao := True;
  qryProdutosComprar.DisableControls;
  try
    qryProdutosComprar.Close;
    qryProdutosComprar.ParamByName('DT_INICIAL').AsDate := DateTimePicker1.Date;
    qryProdutosComprar.ParamByName('DT_FINAL').AsDate := DateTimePicker2.Date;

    if Trim(edtProdutoCompra.Text) = '' then
    begin
      qryProdutosComprar.ParamByName('DESC').DataType := ftString;
      qryProdutosComprar.ParamByName('DESC').Clear
    end
    else
      qryProdutosComprar.ParamByName('DESC').AsString := Trim(edtProdutoCompra.Text);

    AplicarFiltroLookup(dbGrupoCompra, 'GRU');
    AplicarFiltroLookup(dbSubGrupoCompra, 'SUBG');
    AplicarFiltroLookup(dbMarcaCompra, 'MAR');
    AplicarFiltroLookup(dbSetorCompra, 'SET');
    AplicarFiltroLookup(dbFornecedorCompra, 'FOR');
    qryProdutosComprar.ParamByName('PRODUTOS_ZERO').AsInteger :=
      Ord(ckProdutos0.Checked);

    qryProdutosComprar.Open;
    InicializarProdutosCompra;
    FProdutosCompra.DisableControls;
    try
      FProdutosCompra.First;
      while not FProdutosCompra.Eof do
        FProdutosCompra.Delete;
      qryProdutosComprar.First;
      while not qryProdutosComprar.Eof do
      begin
        Chave := IntToStr(qryProdutosComprar.FieldByName('PRD_ID').AsInteger);
        FProdutosCompra.Append;
        FProdutosCompra.FieldByName('PRD_ID').AsInteger :=
          qryProdutosComprar.FieldByName('PRD_ID').AsInteger;
        FProdutosCompra.FieldByName('PRD_DESCRICAO').AsString :=
          qryProdutosComprar.FieldByName('PRD_DESCRICAO').AsString;
        FProdutosCompra.FieldByName('PRD_UN_VENDA').AsString :=
          qryProdutosComprar.FieldByName('PRD_UN_VENDA').AsString;
        FProdutosCompra.FieldByName('PMAR_DESCRICAO').AsString :=
          qryProdutosComprar.FieldByName('PMAR_DESCRICAO').AsString;
        FProdutosCompra.FieldByName('VENDIDO').AsFloat :=
          qryProdutosComprar.FieldByName('VENDIDO').AsFloat;
        if Abs(FProdutosCompra.FieldByName('VENDIDO').AsFloat) < 0.0000005 then
          FProdutosCompra.FieldByName('VENDIDO').AsFloat := 0;
        FProdutosCompra.FieldByName('ESTOQUE').AsFloat :=
          qryProdutosComprar.FieldByName('ESTOQUE').AsFloat;
        if Abs(FProdutosCompra.FieldByName('ESTOQUE').AsFloat) < 0.0000005 then
          FProdutosCompra.FieldByName('ESTOQUE').AsFloat := 0;
        FProdutosCompra.FieldByName('SUGERIDO').AsFloat :=
          qryProdutosComprar.FieldByName('COMPRAR').AsFloat;
        if Abs(FProdutosCompra.FieldByName('SUGERIDO').AsFloat) < 0.0000005 then
          FProdutosCompra.FieldByName('SUGERIDO').AsFloat := 0;
        FProdutosCompra.FieldByName('COMPRAR').AsFloat :=
          FProdutosCompra.FieldByName('SUGERIDO').AsFloat;
        if Abs(FProdutosCompra.FieldByName('COMPRAR').AsFloat) < 0.0000005 then
          FProdutosCompra.FieldByName('COMPRAR').AsFloat := 0;
        IndiceAlteracao := FAlteracoesCompra.IndexOfName(Chave);
        if IndiceAlteracao >= 0 then
        begin
          ValorManual := StrToFloatDef(
            FAlteracoesCompra.ValueFromIndex[IndiceAlteracao],
            FProdutosCompra.FieldByName('COMPRAR').AsFloat);
          FProdutosCompra.FieldByName('COMPRAR').AsFloat := ValorManual;
        end;
        FProdutosCompra.Post;
        AtualizarItemPedidoAtual(FProdutosCompra);
        qryProdutosComprar.Next;
      end;
    finally
      FProdutosCompra.EnableControls;
    end;
    if (ProdutoAtual > 0) and not FProdutosCompra.IsEmpty then
      FProdutosCompra.Locate('PRD_ID', ProdutoAtual, []);

    FPeriodoSugestao := FormatDateTime('dd/mm/yyyy', DateTimePicker1.Date) +
      ' a ' + FormatDateTime('dd/mm/yyyy', DateTimePicker2.Date);
    FFiltrosSugestao := '';
    if Trim(edtProdutoCompra.Text) <> '' then
      FFiltrosSugestao := 'Descrição: ' + Trim(edtProdutoCompra.Text);
    if not qryProdutosComprar.ParamByName('GRU').IsNull then
      FFiltrosSugestao := FFiltrosSugestao + '  Grupo: ' + dbGrupoCompra.Text;
    if not qryProdutosComprar.ParamByName('SUBG').IsNull then
      FFiltrosSugestao := FFiltrosSugestao + '  Subgrupo: ' + dbSubGrupoCompra.Text;
    if not qryProdutosComprar.ParamByName('MAR').IsNull then
      FFiltrosSugestao := FFiltrosSugestao + '  Marca: ' + dbMarcaCompra.Text;
    if not qryProdutosComprar.ParamByName('SET').IsNull then
      FFiltrosSugestao := FFiltrosSugestao + '  Setor: ' + dbSetorCompra.Text;
    if not qryProdutosComprar.ParamByName('FOR').IsNull then
      FFiltrosSugestao := FFiltrosSugestao + '  Fornecedor: ' +
        dbFornecedorCompra.Text;
  finally
    qryProdutosComprar.EnableControls;
    FAtualizandoSugestao := False;
  end;
  AutoSizeGradePagina2(dbgProdCompra);
  AutoSizeGradePagina2(dbgPedidoAtual);
  AtualizarVendasPaginaAtiva;
end;

procedure Tfrm_p.AplicarFiltroLookup(AFiltro: TDBLookupComboBox;
  const AParametro: String);
var
  Chave: Variant;
begin
  Chave := AFiltro.KeyValue;
  qryProdutosComprar.ParamByName(AParametro).Clear;
  qryProdutosComprar.ParamByName(AParametro).DataType := ftInteger;
  if VarIsNull(Chave) or VarIsEmpty(Chave) then Exit;
  if VarAsType(Chave, varInteger) > 0 then
    qryProdutosComprar.ParamByName(AParametro).AsInteger := Chave;
end;

procedure Tfrm_p.FiltroCompraKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) or (Key = VK_BACK) then
  begin
    TDBLookupComboBox(Sender).KeyValue := Null;
    Key := 0;
  end;
end;

procedure Tfrm_p.iFiltrarComprasClick(Sender: TObject);
begin
  AtualizarSugestaoCompras;
  if not dbgProdCompra.Visible then
    dbgProdCompra.Visible:= True;

  if not dbgProdVendas.Visible then
    dbgProdVendas.Visible := True;
  dbgPedidoAtual.Visible := True;
  if Assigned(FDicaSugestao) then FDicaSugestao.Visible := False;
  Label12.Visible := True;
  Label13.Visible := True;
end;

procedure Tfrm_p.iLimparClick(Sender: TObject);
var
  I: Integer;
begin
  FAtualizandoSugestao := True;
  try
    { Fechar primeiro a consulta e apagar seus valores para uma próxima execução limpa. }
    if qryProdutosComprar.Active then
      qryProdutosComprar.Close;
    for I := 0 to qryProdutosComprar.Params.Count - 1 do
      qryProdutosComprar.Params[I].Clear;

    { A grade de vendas compartilha o dataset com a página de histórico. }
    uDm.data.qryVendas.Close;
    FUltimoProdutoVendas := -1;

    DateTimePicker1.Date := StartOfTheMonth(Date);
    DateTimePicker2.Date := Date;
    edtProdutoCompra.Clear;
    dbGrupoCompra.KeyValue := Null;
    dbSubGrupoCompra.KeyValue := Null;
    dbMarcaCompra.KeyValue := Null;
    dbSetorCompra.KeyValue := Null;
    dbFornecedorCompra.KeyValue := Null;
    ckProdutos0.Checked := False;
    ckExportarZero.Checked := False;

    if Assigned(FProdutosCompra) and FProdutosCompra.Active then
    begin
      FProdutosCompra.DisableControls;
      try
        if FProdutosCompra.State in [dsEdit, dsInsert] then
          FProdutosCompra.Cancel;
        FProdutosCompra.First;
        while not FProdutosCompra.IsEmpty do
          FProdutosCompra.Delete;
      finally
        FProdutosCompra.EnableControls;
      end;
    end;
    if Assigned(FPedidoAtual) and FPedidoAtual.Active then
    begin
      FPedidoAtual.DisableControls;
      try
        if FPedidoAtual.State in [dsEdit, dsInsert] then
          FPedidoAtual.Cancel;
        FPedidoAtual.First;
        while not FPedidoAtual.IsEmpty do
          FPedidoAtual.Delete;
      finally
        FPedidoAtual.EnableControls;
      end;
    end;
    if Assigned(FAlteracoesCompra) then
      FAlteracoesCompra.Clear;
    if Assigned(FProdutosPedidoIDs) then
      FProdutosPedidoIDs.Clear;

    FPeriodoSugestao := '';
    FFiltrosSugestao := '';
    dbgProdCompra.Visible := False;
    dbgProdVendas.Visible := False;
    dbgPedidoAtual.Visible := False;
    if Assigned(FDicaSugestao) then FDicaSugestao.Visible := True;
    Label12.Visible := False;
    Label13.Visible := False;
  finally
    FAtualizandoSugestao := False;
  end;
end;

function Tfrm_p.EscolherArquivoCompra(const AExtensao: String;
  out AArquivo: String): Boolean;
var
  Dialogo: TSaveDialog;
begin
  Result := False;
  Dialogo := TSaveDialog.Create(Self);
  try
    Dialogo.Title := 'Salvar sugestão de compras';
    Dialogo.DefaultExt := AExtensao;
    Dialogo.FileName := 'Compra_' + FormatDateTime('ddmmyyyy', Date) +
      '.' + AExtensao;
    if AExtensao = 'pdf' then
      Dialogo.Filter := 'Arquivo PDF (*.pdf)|*.pdf'
    else
      Dialogo.Filter := 'Planilha Excel (*.xlsx)|*.xlsx';
    if not Dialogo.Execute then Exit;
    AArquivo := Dialogo.FileName;
    if not SameText(ExtractFileExt(AArquivo), '.' + AExtensao) then
      AArquivo := ChangeFileExt(AArquivo, '.' + AExtensao);
    if FileExists(AArquivo) and
       (MessageDlg('O arquivo já existe. Deseja substituí-lo?',
         mtConfirmation, [mbYes, mbNo], 0) <> mrYes) then Exit;
    Result := True;
  finally
    Dialogo.Free;
  end;
end;

procedure Tfrm_p.iSalvarPDFClick(Sender: TObject);
var
  Arquivo: String;
begin
  if FProdutosCompra.State in [dsEdit, dsInsert] then FProdutosCompra.Post;
  if not PedidoAtualValido then
  begin
    ShowMessage('Não foram selecionados produtos ou quantidades para o pedido de compras.');
    Exit;
  end;
  if not EscolherArquivoCompra('pdf', Arquivo) then Exit;
  try
    ExportarComprasPDF(FPedidoAtual, Arquivo, FPeriodoSugestao,
      ExtractFilePath(Application.ExeName) + 'logo.png');
    MessageDlg('PDF salvo em:' + LineEnding + Arquivo,
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Não foi possível salvar o PDF:' + LineEnding + E.Message,
        mtError, [mbOK], 0);
  end;
end;

procedure Tfrm_p.iSalvarExcelClick(Sender: TObject);
var
  Arquivo: String;
begin
  if FProdutosCompra.State in [dsEdit, dsInsert] then FProdutosCompra.Post;
  if not PedidoAtualValido then
  begin
    ShowMessage('Não foram selecionados produtos ou quantidades para o pedido de compras.');
    Exit;
  end;
  if not EscolherArquivoCompra('xlsx', Arquivo) then Exit;
  try
    ExportarComprasExcel(FPedidoAtual, Arquivo, FPeriodoSugestao);
    MessageDlg('Planilha salva em:' + LineEnding + Arquivo,
      mtInformation, [mbOK], 0);
  except
    on E: Exception do
      MessageDlg('Não foi possível salvar a planilha:' + LineEnding + E.Message,
        mtError, [mbOK], 0);
  end;
end;


procedure Tfrm_p.AtualizarProdutos;
var
  ProdutoAtual: Integer;
begin
  ProdutoAtual := 0;

  if uDm.data.qryProdutos.Active and
     (not uDm.data.qryProdutos.IsEmpty) then
    ProdutoAtual :=
      uDm.data.qryProdutos.FieldByName('PRD_ID').AsInteger;

  uDm.data.qryProdutos.DisableControls;
  try
    uDm.data.qryProdutos.Close;

    ConfigurarFiltroStatus;

    uDm.data.qryProdutos.Open;

    if ProdutoAtual > 0 then
      uDm.data.qryProdutos.Locate(
        'PRD_ID',
        ProdutoAtual,
        []
      );

  finally
    uDm.data.qryProdutos.EnableControls;
  end;

  FUltimoProduto := -1;

  if not uDm.data.qryProdutos.IsEmpty then
  begin
    ProdutoAtual :=
      uDm.data.qryProdutos.FieldByName('PRD_ID').AsInteger;

    FUltimoProduto := ProdutoAtual;
    if pgcSystem.ActivePage = TabSheet1 then
      CarregarHistoricoProduto(ProdutoAtual, True);
  end
  else
  begin
    uDm.data.qryCompras.Close;
    if pgcSystem.ActivePage = TabSheet1 then
      CarregarVendasProduto(0);
  end;

  dbgProdutos.Invalidate;
  dbgCompras.Invalidate;
  dbgVendas.Invalidate;
end;


procedure Tfrm_p.FormKeyDown(
  Sender: TObject;
  var Key: Word;
  Shift: TShiftState
);
begin
  if (Key = VK_SPACE) and dbgProdCompra.Focused then
  begin
    AdicionarProdutoPedidoAtual;
    dbgPedidoAtual.Visible := True;
    Key := 0;
    Exit;
  end;

  { Ctrl + T = alterna tema claro/escuro }
  if (Key = Ord('T')) and (ssCtrl in Shift) then
  begin
    Key := 0;
    AlternarTema;
    Exit;
  end;

  { Ctrl + A = atualização completa }
  if (Key = Ord('A')) and
     (ssCtrl in Shift) then
  begin
    Key := 0;
    if pgcSystem.ActivePage = TabSheet2 then
      AtualizarSugestaoCompras
    else
      AtualizarProdutos;
    Exit;
  end;
end;

{ Markup das vendas: mesmos limites do cadastro (ufrmcadastro.FormataMarkup)
  verde > 49%, amarelo > 29%, vermelho abaixo disso. Exibido como "selo"
  arredondado colorido dentro da célula. }
procedure Tfrm_p.dbgVendasDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  Grade: TCustomDBGrid;
  Fundo, Texto: TColor;
  Valor: Double;
  S: String;
  Selo: TRect;
  Larg, Alt: Integer;
begin
  Grade := Sender as TCustomDBGrid;
  if not Assigned(Column) or not Assigned(Column.Field) then Exit;

  if not SameText(Column.FieldName, 'MARKUP') then
  begin
    PintarCelulaModerna(Grade, Rect, Column, State);
    Exit;
  end;

  { fundo/seleção da linha, sem texto }
  PintarCelulaModerna(Grade, Rect, Column, State, clDefault, [], 0, True);

  if Column.Field.IsNull then
  begin
    { sem custo cadastrado: não há como calcular }
    Grade.Canvas.Brush.Style := bsClear;
    Grade.Canvas.Font.Color := Paleta.TextoSuave;
    Grade.Canvas.Font.Style := [];
    S := 's/ custo';
    Grade.Canvas.TextRect(Rect,
      Rect.Left + (Rect.Right - Rect.Left - Grade.Canvas.TextWidth(S)) div 2,
      Rect.Top + (Rect.Bottom - Rect.Top - Grade.Canvas.TextHeight(S)) div 2, S);
    Grade.Canvas.Brush.Style := bsSolid;
    Exit;
  end;

  Valor := Column.Field.AsFloat;
  CorMarkup(Valor, Fundo, Texto);  { verde / amarelo / vermelho do tema }
  S := FormatFloat('0.0', Valor) + '%';

  Grade.Canvas.Font.Style := [fsBold];
  Larg := Grade.Canvas.TextWidth(S) + 18;
  Alt := Grade.Canvas.TextHeight(S) + 6;
  Selo := Classes.Rect(
    Rect.Left + (Rect.Right - Rect.Left - Larg) div 2,
    Rect.Top + (Rect.Bottom - Rect.Top - Alt) div 2, 0, 0);
  Selo.Right := Selo.Left + Larg;
  Selo.Bottom := Selo.Top + Alt;

  Grade.Canvas.Brush.Color := Fundo;
  Grade.Canvas.Pen.Color := Fundo;
  Grade.Canvas.RoundRect(Selo, Alt, Alt);
  Grade.Canvas.Brush.Style := bsClear;
  Grade.Canvas.Font.Color := Texto;
  Grade.Canvas.TextOut(Selo.Left + 9,
    Selo.Top + (Alt - Grade.Canvas.TextHeight(S)) div 2, S);
  Grade.Canvas.Brush.Style := bsSolid;
  Grade.Canvas.Font.Style := [];
end;

procedure Tfrm_p.dbgProdCompraKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then
  begin
    AdicionarProdutoPedidoAtual;
    dbgPedidoAtual.Visible := True;
    Key := 0;
  end;
end;


procedure Tfrm_p.bHomeClick(Sender: TObject);
begin
  pgcSystem.ActivePageIndex := 0;
end;

{ ---------- Visual moderno: ícones vetoriais e barra de filtros ---------- }


procedure Tfrm_p.PintarCardFiltros(Sender: TObject);
var
  PB: TPaintBox;
begin
  PB := Sender as TPaintBox;
  PB.Canvas.Brush.Color := Paleta.Fundo;
  PB.Canvas.FillRect(0, 0, PB.Width, PB.Height);
  PB.Canvas.Brush.Color := Paleta.Superficie;
  PB.Canvas.Pen.Color := Paleta.Borda;
  PB.Canvas.Pen.Width := 1;
  PB.Canvas.RoundRect(0, 0, PB.Width, PB.Height, 16, 16);
  { filete de destaque na lateral esquerda }
  PB.Canvas.Brush.Color := Paleta.Destaque;
  PB.Canvas.Pen.Color := Paleta.Destaque;
  PB.Canvas.RoundRect(0, 10, 5, PB.Height - 10, 5, 5);
end;

procedure Tfrm_p.ModernizarInterface;
var
  I: Integer;
  Ctl: TControl;
  HoverTitulo, AZUL_TITULO: TColor;
begin
  { barra de título: glifos brancos, chip translúcido no hover }
  AZUL_TITULO := pnl_titulo.Color;
  HoverTitulo := MisturarCor(AZUL_TITULO, clWhite, 22);
  EstilizarIcone(bHome, icHome, clWhite, AZUL_TITULO, HoverTitulo, AZUL_TITULO);
  EstilizarIcone(bCompra, icCarrinho, clWhite, AZUL_TITULO, HoverTitulo, AZUL_TITULO);
  EstilizarIcone(bCompra1, icEngrenagem, clWhite, AZUL_TITULO, HoverTitulo, AZUL_TITULO);

  { colunas ocupam toda a largura; a descrição/fornecedor/cliente absorve a sobra }
  PreencherColunas(dbgProdutos, 'PRD_DESCRICAO');
  PreencherColunas(dbgCompras, 'FORNECEDOR');
  PreencherColunas(dbgVendas, 'CLIENTE;VENDEDOR');

  { barra de filtros: card arredondado atrás dos controles }
  if not Assigned(FCardFiltros) then
  begin
    for I := 0 to TabSheet2.ControlCount - 1 do
    begin
      Ctl := TabSheet2.Controls[I];
      if Ctl.Top + Ctl.Height <= 100 then
      begin
        Ctl.Left := Ctl.Left + 18;
        Ctl.Top := Ctl.Top + 4;
      end;
    end;
    FCardFiltros := TPaintBox.Create(Self);
    FCardFiltros.Parent := TabSheet2;
    FCardFiltros.SetBounds(6, 0, TabSheet2.ClientWidth - 12, 102);
    FCardFiltros.Anchors := [akTop, akLeft, akRight];
    FCardFiltros.OnPaint := @PintarCardFiltros;
    FCardFiltros.SendToBack;
  end;
  FCardFiltros.Invalidate;

  for I := 0 to TabSheet2.ControlCount - 1 do
    if TabSheet2.Controls[I] is TLabel then
      if TabSheet2.Controls[I].Top < 100 then
        TLabel(TabSheet2.Controls[I]).Font.Color := Paleta.TextoSuave;


  { o fundo da aba é um TPaintBox criado pela uTema; garante que fique abaixo do cartão }
  if Assigned(TabSheet2.FindComponent('tema_fundo')) then
    TControl(TabSheet2.FindComponent('tema_fundo')).SendToBack;

  { estado vazio: orienta o usuário antes do primeiro filtro }
  if not Assigned(FDicaSugestao) then
  begin
    FDicaSugestao := TLabel.Create(Self);
    FDicaSugestao.Parent := TabSheet2;
    FDicaSugestao.AutoSize := True;
    FDicaSugestao.Font.Size := 11;
    FDicaSugestao.Caption :=
      'Defina os filtros acima e clique em Filtrar (funil azul) ou ' +
      'pressione Enter para listar a sugestão de compra.';
    FDicaSugestao.SetBounds(24, 130, 0, 0);
  end;
  FDicaSugestao.Font.Color := Paleta.TextoSuave;
  FDicaSugestao.Visible := not dbgProdCompra.Visible;
  Label12.Visible := dbgProdVendas.Visible;
  Label13.Visible := dbgPedidoAtual.Visible;

  Label12.Font.Style := [fsBold];
  Label13.Font.Style := [fsBold];
  Label12.Font.Color := Paleta.Texto;
  Label13.Font.Color := Paleta.Texto;
  EstilizarIcone(iFiltrarCompras, icFiltro, clWhite, Paleta.Destaque,
    MisturarCor(Paleta.Destaque, clBlack, 18), Paleta.Superficie);
  EstilizarIcone(iLimpar, icLimpar, Paleta.TextoSuave, Paleta.Borda,
    MisturarCor(Paleta.Borda, Paleta.TextoSuave, 35), Paleta.Superficie);
  EstilizarIcone(iSalvarPDF, icPdf, clWhite, RGBToColor(220, 38, 38),
    RGBToColor(185, 28, 28), Paleta.Superficie);
  EstilizarIcone(iSalvarExcel, icExcel, clWhite, RGBToColor(22, 163, 74),
    RGBToColor(21, 128, 61), Paleta.Superficie);
end;

procedure Tfrm_p.bCompraClick(Sender: TObject);
begin
  if pgcSystem.PageCount > 1 then
    pgcSystem.ActivePageIndex := 1;
end;

procedure Tfrm_p.bCompra1Click(Sender: TObject);
begin
  if not Assigned(uConf.frmConf) then
    raise Exception.Create('O formulário de configurações não foi criado.');
  uConf.frmConf.ShowModal;
  AplicarPreferencias;
end;

procedure Tfrm_p.pgcSystemChange(Sender: TObject);
begin
  FormResize(Self);
  if FInicializando then Exit;
  if pgcSystem.ActivePage = TabSheet1 then
  begin
    if uDm.data.qryProdutos.Active and not uDm.data.qryProdutos.IsEmpty then
      CarregarHistoricoProduto(
        uDm.data.qryProdutos.FieldByName('PRD_ID').AsInteger)
    else
      CarregarHistoricoProduto(0);
  end
  else
    AtualizarVendasPaginaAtiva;
end;

procedure Tfrm_p.TabSheet2ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

procedure Tfrm_p.TabSheet2Show(Sender: TObject);
begin
  FormResize(Self);
end;


procedure Tfrm_p.tmrAtualizacaoTimer(Sender: TObject);
begin
  if FInicializando then
    Exit;

  { Janela em segundo plano: não consulta o banco à toa. }
  if not Application.Active then
    Exit;

  { Evita reentrada do timer enquanto as consultas estão sendo executadas. }
  tmrAtualizacao.Enabled := False;
  try
    { No automático atualizamos apenas os históricos.
      Ctrl+A e alteração da preferência de inativos fazem atualização completa. }
    AtualizarHistoricoAtual;
  finally
    tmrAtualizacao.Enabled := True;
  end;
end;


procedure Tfrm_p.FormKeyPress(
  Sender: TObject;
  var Key: Char
);
begin
end;


procedure Tfrm_p.dbgProdutosDblClick(Sender: TObject);
begin
  if not dsProdutos.DataSet.Active then
    Exit;

  if dsProdutos.DataSet.IsEmpty then
    Exit;

  data.qryRegistro.Close;

  data.qryRegistro.ParamByName('ID').AsInteger :=
    dsProdutos.DataSet
      .FieldByName('PRD_ID')
      .AsInteger;

  data.qryRegistro.Open;

  if data.qryRegistro.RecordCount > 0 then
  begin

    MessageDlg(
      'Não é possível editar este produto, pois ele está sendo utilizado.' +
      LineEnding + LineEnding +

      'Usuário: ' +
      data.qryRegistro
        .FieldByName('USUARIO')
        .AsString +
      LineEnding +

      'Data: ' +
      FormatDateTime(
        'dd/mm/yyyy hh:nn:ss',
        data.qryRegistro
          .FieldByName('DATA')
          .AsDateTime
      ) +
      LineEnding + LineEnding +

      'Feche ou desbloqueie o registro no ERP antes de tentar novamente.',

      mtWarning,
      [mbOK],
      0
    );

    Exit;
  end;

  {
    Registra o bloqueio antes de abrir o cadastro.
  }

  data.RegistrarUsoProduto(
    dsProdutos.DataSet
      .FieldByName('PRD_ID')
      .AsInteger
  );

  frmCadastro := TfrmCadastro.Create(nil);

  try

    frmCadastro.CarregaProduto(
      dsProdutos.DataSet
        .FieldByName('PRD_ID')
        .AsInteger
    );

    if frmCadastro.ShowModal = mrOk then
      dsProdutos.DataSet.Refresh;

  finally

    frmCadastro.Free;

    data.RemoverUsoProduto(
      dsProdutos.DataSet
        .FieldByName('PRD_ID')
        .AsInteger
    );

  end;
end;


procedure Tfrm_p.dbgProdutosDrawColumnCell(
  Sender: TObject;
  const Rect: TRect;
  DataCol: Integer;
  Column: TColumn;
  State: TGridDrawState
);
var
  CorTexto: TColor;
  Estilo: TFontStyles;
  Recuo: Integer;
  MkCusto: Double;
  Faixa: TRect;
begin
  if not Assigned(Column) or not Assigned(Column.Field) then
    Exit;

  CorTexto := clDefault;
  Estilo := [];
  Recuo := 0;

  { Alerta de ruptura: estoque zerado ou negativo em vermelho e negrito }
  if SameText(Column.FieldName, 'ESTOQUE') and
     (not Column.Field.IsNull) and (Column.Field.AsFloat <= 0) then
  begin
    CorTexto := Paleta.Alerta;
    Estilo := [fsBold];
  end;

  { Preço de venda: reserva espaço para a faixa de markup à direita }
  MkCusto := 0;
  if SameText(Column.FieldName, 'PRD_PRECO_VENDA') then
  begin
    MkCusto := Column.Field.DataSet.FieldByName('PRD_PRECO_CUSTO').AsFloat;
    if MkCusto > 0 then Recuo := 12;
  end;

  PintarCelulaModerna(dbgProdutos, Rect, Column, State, CorTexto, Estilo, Recuo);

  if (Recuo > 0) and not Column.Field.IsNull then
  begin
    { pílula vertical colorida: verde / amarelo / vermelho conforme o markup }
    Faixa := Classes.Rect(Rect.Right - 10, Rect.Top + 7, Rect.Right - 5,
      Rect.Bottom - 7);
    dbgProdutos.Canvas.Brush.Color := CorFaixaMarkup(
      (Column.Field.AsFloat - MkCusto) / MkCusto * 100);
    dbgProdutos.Canvas.Pen.Color := dbgProdutos.Canvas.Brush.Color;
    dbgProdutos.Canvas.RoundRect(Faixa, 5, 5);
  end;
end;

procedure Tfrm_p.dbgProdCompraDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  LinhaComCompra: Boolean;
begin
  if not Assigned(Column) or not Assigned(Column.Field) or
     not Assigned(Column.Field.DataSet) or
     not Column.Field.DataSet.Active or Column.Field.DataSet.IsEmpty then
  begin
    dbgProdCompra.DefaultDrawColumnCell(Rect, DataCol, Column, State);
    Exit;
  end;

  { linhas já incluídas no pedido ficam em vermelho e negrito }
  LinhaComCompra := ProdutoNoPedido(
    Column.Field.DataSet.FieldByName('PRD_ID').AsInteger);
  if LinhaComCompra then
    PintarCelulaModerna(dbgProdCompra, Rect, Column, State,
      Paleta.Alerta, [fsBold])
  else
    PintarCelulaModerna(dbgProdCompra, Rect, Column, State);
end;


procedure Tfrm_p.dxDBGridController1Localize(
  Sender: TObject;
  Component: TComponent;
  ID_Ressource: String;
  var Translation: String
);
begin
  if ID_Ressource = msg_search then
    Translation := 'Digite para pesquisar...';
end;


procedure Tfrm_p.dxDBGridController1AfterAggregation(
  Sender: TdxDBGridController
);
begin
end;

end.
