unit uSubGrupoEdit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBCtrls, ColorSpeedButton, uDm, DB;

type

  { TfrmSubGrupo }

  TfrmSubGrupo = class(TForm)
    btnCancelar: TColorSpeedButton;
    btnSalvar: TColorSpeedButton;
    DBLookupComboBox1: TDBLookupComboBox;
    dsSubGrupo: TDataSource;
    dsGrupo: TDataSource;
    edtDescricao: TDBEdit;
    edtID: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    pnlFundo: TPanel;
    pnlTitulo: TPanel;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    FModoCadastro: Boolean;
  public
    function NovoSubGrupo: Boolean;
    function EditarSubGrupo(AID: Integer): Boolean;
  end;

var
  frmSubGrupo: TfrmSubGrupo;

implementation

{$R *.lfm}

{ TfrmSubGrupo }

procedure TfrmSubGrupo.btnCancelarClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSubGrupo.btnSalvarClick(Sender: TObject);
begin
  if Trim(edtDescricao.Text) = '' then
  begin
    MessageDlg('Informe a descrição do SubGrupo.',
      mtWarning,[mbOK],0);
    edtDescricao.SetFocus;
    Exit;
  end;

  ModalResult := mrOK;
end;

function TfrmSubGrupo.NovoSubGrupo: Boolean;
begin
  FModoCadastro := True;

  data.qrySubGrupo.Close;
  data.qrySubGrupo.SQL.Text :=
    'select * from tb_prod_sub_grupo';
  data.qrySubGrupo.Open;

  data.qrySubGrupo.Append;

  data.qrySubGrupo.FieldByName('PSGR_ID').AsInteger :=
    data.GetSequencia('tb_prod_sub_grupo','PSGR_ID');

  data.qrySubGrupo.FieldByName('PSGR_EMPRESA').AsInteger := 1;

  Result := (ShowModal = mrOK);

  if Result then
    data.qrySubGrupo.Post
  else
    data.qrySubGrupo.Cancel;
end;

function TfrmSubGrupo.EditarSubGrupo(AID: Integer): Boolean;
begin
  data.qrySubGrupo.Close;
  data.qrySubGrupo.SQL.Text :=
    'select * from tb_prod_sub_grupo '+
    'WHERE PSGR_ID = :ID';
  data.qrySubGrupo.ParamByName('ID').AsInteger := AID;
  data.qrySubGrupo.Open;

  if data.qrySubGrupo.IsEmpty then
    Exit(False);

  data.qrySubGrupo.Edit;

  Result := (ShowModal = mrOK);

  if Result then
    data.qrySubGrupo.Post
  else
    data.qrySubGrupo.Cancel;
end;

end.

