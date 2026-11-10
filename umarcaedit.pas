unit uMarcaEdit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBCtrls, ColorSpeedButton, uDm, DB;

type

  { TfrmMarca }

  TfrmMarca = class(TForm)
    btnCancelar: TColorSpeedButton;
    btnSalvar: TColorSpeedButton;
    dsMarca: TDataSource;
    edtID: TDBEdit;
    edtDescricao: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    pnlFundo: TPanel;
    pnlTitulo: TPanel;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    FModoCadastro: Boolean;
  public
    function NovaMarca: Boolean;
    function EditarMarca(AID: Integer): Boolean;
  end;

var
  frmMarca: TfrmMarca;

implementation

{$R *.lfm}

{ TfrmMarca }

procedure TfrmMarca.btnCancelarClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmMarca.btnSalvarClick(Sender: TObject);
begin
  if Trim(edtDescricao.Text) = '' then
  begin
    MessageDlg('Informe a descrição da marca.',
      mtWarning,[mbOK],0);
    edtDescricao.SetFocus;
    Exit;
  end;

  ModalResult := mrOK;
end;

function TfrmMarca.NovaMarca: Boolean;
begin
  FModoCadastro := True;

  data.qryMarca.Close;
  data.qryMarca.SQL.Text :=
    'select * from tb_prod_marca';
  data.qryMarca.Open;

  data.qryMarca.Append;

  data.qryMarca.FieldByName('PMAR_ID').AsInteger :=
    data.GetSequencia('tb_prod_marca','PMAR_ID');

  data.qryMarca.FieldByName('PMAR_EMPRESA').AsInteger := 1;

  Result := (ShowModal = mrOK);

  if Result then
    data.qryMarca.Post
  else
    data.qryMarca.Cancel;
end;

function TfrmMarca.EditarMarca(AID: Integer): Boolean;
begin
  data.qryMarca.Close;
  data.qryMarca.SQL.Text :=
    'select * from tb_prod_marca '+
    'WHERE PMAR_ID = :ID';
  data.qryMarca.ParamByName('ID').AsInteger := AID;
  data.qryMarca.Open;

  if data.qryMarca.IsEmpty then
    Exit(False);

  data.qryMarca.Edit;

  Result := (ShowModal = mrOK);

  if Result then
    data.qryMarca.Post
  else
    data.qryMarca.Cancel;
end;

end.

