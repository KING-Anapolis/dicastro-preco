unit uFrmCadastro;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, SQLDB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, DBCtrls, Buttons, ComCtrls, DBGrids, ColorSpeedButton, uDm, Windows,
  uGrupoEdit, uMarcaEdit, uSetorEdit, uSubGrupoEdit, ZDataset,
  ZAbstractRODataset, Variants;

type

  { TfrmCadastro }

  TfrmCadastro = class(TForm)
    btnEGrupo: TColorSpeedButton;
    btnEMarca: TColorSpeedButton;
    btnESetor: TColorSpeedButton;
    btnESubGrupo: TColorSpeedButton;
    btnIGrupo: TColorSpeedButton;
    btnIMarca: TColorSpeedButton;
    btnISetor: TColorSpeedButton;
    btnISubGrupo: TColorSpeedButton;
    btnSalvar: TColorSpeedButton;
    btnCancelar: TColorSpeedButton;
    cbbGrupo: TDBLookupComboBox;
    cbbMarca: TDBLookupComboBox;
    cbbSetor: TDBLookupComboBox;
    cbbSubGrupo: TDBLookupComboBox;
    dsUnidades: TDataSource;
    DBGrid1: TDBGrid;
    dsGrupo: TDataSource;
    dsMarca: TDataSource;
    dsProd: TDataSource;
    dsSubGrupo: TDataSource;
    dsSetor: TDataSource;
    edtCusto: TDBEdit;
    edtDescricao: TDBEdit;
    edtId: TDBEdit;
    edtMarkup: TEdit;
    edtReferencia: TDBEdit;
    edtVenda: TDBEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    pnl_fundo: TPanel;
    qryUnidadesPRDU_COD_BARRAS: TZRawStringField;
    qryUnidadesPRDU_PRECO_VENDA: TZFMTBCDField;
    qryUnidadesPRDU_UNIDADE: TZRawStringField;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    qryUnidades: TZQuery;
    procedure btnEGrupoClick(Sender: TObject);
    procedure btnEMarcaClick(Sender: TObject);
    procedure btnESetorClick(Sender: TObject);
    procedure btnESubGrupoClick(Sender: TObject);
    procedure btnIGrupoClick(Sender: TObject);
    procedure btnIMarcaClick(Sender: TObject);
    procedure btnISetorClick(Sender: TObject);
    procedure btnISubGrupoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure cbbGrupoChange(Sender: TObject);
    procedure cbbMarcaChange(Sender: TObject);
    procedure cbbSetorChange(Sender: TObject);
    procedure cbbSubGrupoChange(Sender: TObject);
    procedure edtCustoChange(Sender: TObject);
    procedure edtCustoExit(Sender: TObject);
    procedure edtMarkupChange(Sender: TObject);
    procedure edtMarkupExit(Sender: TObject);
    procedure edtVendaChange(Sender: TObject);
    procedure edtVendaExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabSheet2Show(Sender: TObject);
  private

  public
    procedure CarregaProduto(const ID: Integer);
    procedure FormataMoeda(const Edt: TDBEdit);
    procedure FormataMoedaE(const Edt: TEdit);
    procedure FormataMarkup;
    procedure ChangeMarkup;
    procedure CarregaSubGrupo;
    procedure AtualizaBotaoLookup(ALookup: TDBLookupComboBox;
              AButton: TColorSpeedButton);
  end;

var
  frmCadastro: TfrmCadastro;

implementation

{$R *.lfm}

uses uTema;

{ TfrmCadastro }

procedure TfrmCadastro.btnCancelarClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmCadastro.cbbGrupoChange(Sender: TObject);
begin
  CarregaSubGrupo;
  AtualizaBotaoLookup(cbbGrupo, btnEGrupo);
end;

procedure TfrmCadastro.cbbSubGrupoChange(Sender: TObject);
begin
  AtualizaBotaoLookup(cbbSubGrupo, btnESubGrupo);
end;

procedure TfrmCadastro.cbbMarcaChange(Sender: TObject);
begin
  AtualizaBotaoLookup(cbbMarca, btnEMarca);
end;

procedure TfrmCadastro.cbbSetorChange(Sender: TObject);
begin
  AtualizaBotaoLookup(cbbSetor, btnESetor);
end;

procedure TfrmCadastro.edtCustoChange(Sender: TObject);
begin
  ChangeMarkup;
end;

procedure TfrmCadastro.edtCustoExit(Sender: TObject);
begin
  FormataMoeda(edtCusto);
end;

procedure TfrmCadastro.edtMarkupChange(Sender: TObject);
begin
  FormataMarkup;
end;

procedure TfrmCadastro.edtMarkupExit(Sender: TObject);
begin
  FormataMoedaE(edtMarkup);
  FormataMarkup;
end;

procedure TfrmCadastro.edtVendaChange(Sender: TObject);
begin
  ChangeMarkup;
end;

procedure TfrmCadastro.edtVendaExit(Sender: TObject);
begin
  FormataMoeda(edtVenda);
end;

procedure TfrmCadastro.FormShow(Sender: TObject);
begin
  FormataMoeda(edtCusto);
  FormataMoeda(edtVenda);
  FormataMoedaE(edtMarkup);
  FormataMarkup;
  CarregaSubGrupo;
  AtualizaBotaoLookup(cbbGrupo, btnEGrupo);
  AtualizaBotaoLookup(cbbSubGrupo, btnESubGrupo);
  AtualizaBotaoLookup(cbbMarca, btnEMarca);
  AtualizaBotaoLookup(cbbSetor, btnESetor);
end;

procedure TfrmCadastro.PageControl1Change(Sender: TObject);
begin

end;

procedure TfrmCadastro.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    begin
      ReleaseCapture;
      PostMessage(Self.Handle, WM_SYSCOMMAND, $F012, 0);  // Move o Form inteiro
    end;
end;

procedure TfrmCadastro.TabSheet2Show(Sender: TObject);
begin
  qryUnidades.Close;
  qryUnidades.ParamByName('PROD').Value:= StrToInt(edtId.Text);
  qryUnidades.Open;
end;

procedure TfrmCadastro.btnSalvarClick(Sender: TObject);
begin
  if dsProd.DataSet.State in dsEditModes then
  begin
    if cbbSubGrupo.Text <> '' then
      dsProd.DataSet.FieldByName('PRD_GRUPO').AsInteger := cbbGrupo.KeyValue
    else
      dsProd.DataSet.FieldByName('PRD_GRUPO').Clear;

    if cbbSubGrupo.Text <> '' then
      dsProd.DataSet.FieldByName('PRD_SUBGRUPO').AsInteger := cbbSubGrupo.KeyValue
    else
      dsProd.DataSet.FieldByName('PRD_SUBGRUPO').Clear;

    if cbbSubGrupo.Text <> '' then
      dsProd.DataSet.FieldByName('PRD_SETOR').AsInteger := cbbSetor.KeyValue
    else
      dsProd.DataSet.FieldByName('PRD_SETOR').Clear;

    if cbbSubGrupo.Text <> '' then
      dsProd.DataSet.FieldByName('PRD_MARCA').AsInteger := cbbMarca.KeyValue
    else
      dsProd.DataSet.FieldByName('PRD_MARCA').Clear;

    dsProd.DataSet.Post;
  end;

  ModalResult := mrOk;
end;

procedure TfrmCadastro.btnEGrupoClick(Sender: TObject);
begin
  with TfrmGrupo.Create(nil) do
  try
    EditarGrupo(cbbGrupo.KeyValue);
  finally
    Free;
  end;
  data.qryGrupo.Close;
  data.qryGrupo.SQL.Clear;
  data.qryGrupo.SQL.Text:= 'select * from tb_prod_grupo';
  data.qryGrupo.Open;
end;

procedure TfrmCadastro.btnEMarcaClick(Sender: TObject);
begin
  with TfrmMarca.Create(nil) do
  try
    EditarMarca(cbbMarca.KeyValue);
  finally
    Free;
  end;
  data.qryMarca.Close;
  data.qryMarca.SQL.Clear;
  data.qryMarca.SQL.Text:= 'select * from tb_prod_marca';
  data.qryMarca.Open;
end;

procedure TfrmCadastro.btnESetorClick(Sender: TObject);
begin
  with TfrmSetor.Create(nil) do
  try
    EditarSetor(cbbSetor.KeyValue);
  finally
    Free;
  end;
  data.qrySetor.Close;
  data.qrySetor.SQL.Clear;
  data.qrySetor.SQL.Text:= 'select * from tb_setor';
  data.qrySetor.Open;
end;

procedure TfrmCadastro.btnESubGrupoClick(Sender: TObject);
begin
  with TfrmSubGrupo.Create(nil) do
  try
    EditarSubGrupo(cbbSubGrupo.KeyValue);
  finally
    Free;
  end;
  CarregaSubGrupo;
end;

procedure TfrmCadastro.btnIGrupoClick(Sender: TObject);
begin
  with TfrmGrupo.Create(nil) do
  try
    NovoGrupo;
  finally
    Free;
  end;
  data.qryGrupo.Close;
  data.qryGrupo.SQL.Clear;
  data.qryGrupo.SQL.Text:= 'select * from tb_prod_grupo';
  data.qryGrupo.Open;
  data.zCon.ExecuteDirect(
  'UPDATE TB_SEQUENCIAL ' +
  'SET SEQ_SEQUENCIAL = COALESCE((SELECT MAX(PGRU_ID) FROM TB_PROD_GRUPO), 0) ' +
  'WHERE SEQ_TABELA = ''TB_PROD_GRUPO'''
   );
end;

procedure TfrmCadastro.btnIMarcaClick(Sender: TObject);
begin
  with TfrmMarca.Create(nil) do
  try
    NovaMarca;
  finally
    Free;
  end;
  data.qryMarca.Close;
  data.qryMarca.SQL.Clear;
  data.qryMarca.SQL.Text:= 'select * from tb_prod_marca';
  data.qryMarca.Open;
  data.zCon.ExecuteDirect(
  'UPDATE TB_SEQUENCIAL ' +
  'SET SEQ_SEQUENCIAL = COALESCE((SELECT MAX(PMAR_ID) FROM tb_prod_marca), 0) ' +
  'WHERE SEQ_TABELA = ''tb_prod_marca'''
   );
end;

procedure TfrmCadastro.btnISetorClick(Sender: TObject);
begin
  with TfrmSetor.Create(nil) do
  try
    NovoSetor;
  finally
    Free;
  end;
  data.qrySetor.Close;
  data.qrySetor.SQL.Clear;
  data.qrySetor.SQL.Text:= 'select * from tb_setor';
  data.qrySetor.Open;
  data.zCon.ExecuteDirect(
  'UPDATE TB_SEQUENCIAL ' +
  'SET SEQ_SEQUENCIAL = COALESCE((SELECT MAX(SET_ID) FROM TB_SETOR), 0) ' +
  'WHERE SEQ_TABELA = ''TB_SETOR'''
   );
end;

procedure TfrmCadastro.btnISubGrupoClick(Sender: TObject);
begin
  with TfrmSubGrupo.Create(nil) do
  try
    NovoSubGrupo;
  finally
    Free;
  end;
  CarregaSubGrupo;
  data.zCon.ExecuteDirect(
  'UPDATE TB_SEQUENCIAL ' +
  'SET SEQ_SEQUENCIAL = COALESCE((SELECT MAX(PSGR_ID) FROM TB_PROD_SUB_GRUPO), 0) ' +
  'WHERE SEQ_TABELA = ''TB_PROD_SUB_GRUPO'''
   );
end;

procedure TfrmCadastro.CarregaProduto(const ID: Integer);
begin
  data.qryProdCad.Close;
  data.qryProdCad.ParamByName('ID').Value:= ID;
  data.qryProdCad.Open;
end;

procedure TfrmCadastro.FormataMoeda(const Edt: TDBEdit);
begin
  Edt.Text := FloatToStrF(StrToFloat(Edt.Text),ffFixed,15,2);
end;

procedure TfrmCadastro.FormataMoedaE(const Edt: TEdit);
begin
  Edt.Text := FloatToStrF(StrToFloat(Edt.Text),ffFixed,15,2);
end;

procedure TfrmCadastro.FormataMarkup;
var
  V: Double;
  Fundo, Texto: TColor;
begin
  V := StrToFloatDef(edtMarkup.Text, 0);
  CorMarkup(V, Fundo, Texto);  { mesmas cores/limites do tema }
  edtMarkup.Color := Fundo;
  edtMarkup.Font.Color := Texto;
  edtMarkup.Font.Style := [fsBold];
end;

procedure TfrmCadastro.ChangeMarkup;
var
  Custo, Venda, Markup: Double;
begin
  Custo := StrToFloatDef(edtCusto.Text, 0);
  Venda := StrToFloatDef(edtVenda.Text, 0);

  if Custo > 0 then
    Markup := ((Venda - Custo) / Custo) * 100
  else
    Markup := 0;

  edtMarkup.Text := FormatFloat('0.00', Markup);
end;

procedure TfrmCadastro.CarregaSubGrupo;
begin
  if cbbGrupo.KeyValue > 0 then
    begin
      data.qrySubGrupo.Close;
      data.qrySubGrupo.SQL.Text :=
      'select * from tb_prod_sub_grupo '+
      'WHERE PSGR_GRUPO = :ID';
      data.qrySubGrupo.ParamByName('ID').AsInteger := cbbGrupo.KeyValue;
      data.qrySubGrupo.Open;
    end;
end;

procedure TfrmCadastro.AtualizaBotaoLookup(ALookup: TDBLookupComboBox;
  AButton: TColorSpeedButton);
begin
  AButton.Visible :=
    (not VarIsNull(ALookup.KeyValue)) and
    (VarToStr(ALookup.KeyValue) <> '') and
    (ALookup.KeyValue > 0);
end;

end.

