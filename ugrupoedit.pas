unit uGrupoEdit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  DBCtrls, ColorSpeedButton, uDm;

type

  { TfrmGrupo }

  TfrmGrupo = class(TForm)
    btnCancelar: TColorSpeedButton;
    btnSalvar: TColorSpeedButton;
    dsGrupo: TDataSource;
    edtDescricao: TDBEdit;
    edtID: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    pnlFundo: TPanel;
    pnlTitulo: TPanel;
    procedure btnCancelar1Click(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSalvar1Click(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    FModoCadastro: Boolean;
  public
    function NovoGrupo: Boolean;
    function EditarGrupo(AID: Integer): Boolean;
  end;

var
  frmGrupo: TfrmGrupo;

implementation

{$R *.lfm}

{ TfrmGrupo }

procedure TfrmGrupo.btnSalvarClick(Sender: TObject);
begin
  Self.ModalResult:= mrOK;
end;

procedure TfrmGrupo.btnCancelar1Click(Sender: TObject);
begin

end;

procedure TfrmGrupo.btnCancelarClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmGrupo.btnSalvar1Click(Sender: TObject);
begin
  if Trim(edtDescricao.Text) = '' then
  begin
    MessageDlg('Informe a descrição do grupo.',
      mtWarning,[mbOK],0);
    edtDescricao.SetFocus;
    Exit;
  end;

  ModalResult := mrOK;
end;

function TfrmGrupo.NovoGrupo: Boolean;
begin
  FModoCadastro := True;

  data.qryGrupo.Close;
  data.qryGrupo.SQL.Text :=
    'SELECT * FROM TB_PROD_GRUPO';
  data.qryGrupo.Open;

  data.qryGrupo.Append;

  data.qryGrupo.FieldByName('PGRU_ID').AsInteger :=
    data.GetSequencia('TB_PROD_GRUPO', 'PGRU_ID');

  data.qryGrupo.FieldByName('PGRU_EMPRESA').AsInteger := 1;

  Result := (ShowModal = mrOK);

  if Result then
    data.qryGrupo.Post
  else
    data.qryGrupo.Cancel;
end;

function TfrmGrupo.EditarGrupo(AID: Integer): Boolean;
begin
  data.qryGrupo.Close;
  data.qryGrupo.SQL.Text :=
    'select * from tb_prod_grupo '+
    'WHERE PGRU_ID = :ID';
  data.qryGrupo.ParamByName('ID').AsInteger := AID;
  data.qryGrupo.Open;

  if data.qryGrupo.IsEmpty then
    Exit(False);

  data.qryGrupo.Edit;

  Result := (ShowModal = mrOK);

  if Result then
    data.qryGrupo.Post
  else
    data.qryGrupo.Cancel;
end;

end.

