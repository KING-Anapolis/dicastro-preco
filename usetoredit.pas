unit uSetorEdit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBCtrls, ColorSpeedButton, uDm, DB;

type

  { TfrmSetor }

  TfrmSetor = class(TForm)
    btnCancelar: TColorSpeedButton;
    btnSalvar: TColorSpeedButton;
    dsSetor: TDataSource;
    edtDescricao: TDBEdit;
    edtID: TDBEdit;
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
    function NovoSetor: Boolean;
    function EditarSetor(AID: Integer): Boolean;
  end;

var
  frmSetor: TfrmSetor;

implementation

{$R *.lfm}

{ TfrmSetor }

procedure TfrmSetor.btnCancelarClick(Sender: TObject);
begin
  self.Close;
end;

procedure TfrmSetor.btnSalvarClick(Sender: TObject);
begin
  if Trim(edtDescricao.Text) = '' then
  begin
    MessageDlg('Informe a descrição do setor.',
      mtWarning,[mbOK],0);
    edtDescricao.SetFocus;
    Exit;
  end;

  ModalResult := mrOK;
end;

function TfrmSetor.NovoSetor: Boolean;
begin
  FModoCadastro := True;

  data.qrySetor.Close;
  data.qrySetor.SQL.Text :=
    'select * from tb_setor';
  data.qrySetor.Open;

  data.qrySetor.Append;

  data.qrySetor.FieldByName('SET_ID').AsInteger :=
    data.GetSequencia('tb_setor','SET_ID');

  data.qrySetor.FieldByName('SET_EMPRESA').AsInteger := 1;

  Result := (ShowModal = mrOK);

  if Result then
    data.qrySetor.Post
  else
    data.qrySetor.Cancel;
end;

function TfrmSetor.EditarSetor(AID: Integer): Boolean;
begin
  data.qrySetor.Close;
  data.qrySetor.SQL.Text :=
    'select * from tb_setor '+
    'WHERE SET_ID = :ID';
  data.qrySetor.ParamByName('ID').AsInteger := AID;
  data.qrySetor.Open;

  if data.qrySetor.IsEmpty then
    Exit(False);

  data.qrySetor.Edit;

  Result := (ShowModal = mrOK);

  if Result then
    data.qrySetor.Post
  else
    data.qrySetor.Cancel;
end;

end.

