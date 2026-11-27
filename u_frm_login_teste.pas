unit u_frm_login_teste;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
Buttons, ColorSpeedButton, FileUtil, uFuncoes, uVar, uDm, uFrmMain, uAtualiza, uInstancia,
uLembrarLogin;

type

  { Tfrm_login }

  Tfrm_login = class(TForm)
    btn_entrar: TColorSpeedButton;
    btn_sair: TColorSpeedButton;
    ck_lembrar: TCheckBox;
    edt_senha: TEdit;
    edt_usuario: TEdit;
    img_login: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lb_sair: TLabel;
    pnl_fundo: TPanel;
    pnl_lateral: TPanel;
    pnl_senha: TPanel;
    pnl_senha_line: TPanel;
    pnl_usuario: TPanel;
    pnl_usu_line: TPanel;
    procedure btn_entrarClick(Sender: TObject);
    procedure btn_sairClick(Sender: TObject);
    procedure edt_senhaKeyPress(Sender: TObject; var Key: char);
    procedure edt_usuarioKeyPress(Sender: TObject; var Key: char);
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lb_sairClick(Sender: TObject);
  private
    procedure AutoFechar(Data: PtrInt);
    function TentarLoginLembrado(AConectado: Boolean): Boolean;

  public

  end;

var
  frm_login: Tfrm_login;

implementation

{$R *.lfm}

{ Tfrm_login }

procedure Tfrm_login.FormActivate(Sender: TObject);
begin
  if FileExists(ExtractFilePath(ParamStr(0)) + 'dicastro.png') then
    img_login.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'dicastro.png');
end;

procedure Tfrm_login.FormShow(Sender: TObject);
var
  Conectado: Boolean;
begin
  { Versão sempre igual à do executável (APP_VERSAO em uAtualiza). }
  Label2.Caption := 'Desenvolvido por Borges - www.borgis.com.br' + LineEnding +
    'Versão ' + APP_VERSAO;
  if not FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'fbclient.dll') then
  begin
    GravaLog('Arquivo fbclient.dll não encontrado na pasta da aplicação.', 'ERRO');

    MessageDlg(
      'Atenção',
      'O arquivo fbclient.dll não foi encontrado na pasta da aplicação.' + LineEnding + LineEnding +
      'Não será possível conectar ao banco de dados até que ele seja copiado para a pasta do programa.' + LineEnding +
      'Após copiar o arquivo, feche e abra a aplicação novamente.',
      mtWarning,
      [mbOK],
      0
    );
    Exit;
  end;

  if not FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Conf.INI') then
  begin
    GravaLog('Arquivo CONF.INI não encontrado na pasta da aplicação.', 'ERRO');

    MessageDlg(
      'Atenção',
      'O arquivo CONF.INI não foi encontrado na pasta da aplicação.' + LineEnding + LineEnding +
      'Não será possível conectar ao banco de dados sem os parâmetros do arquivo conf.',
      mtWarning,
      [mbOK],
      0
    );
    Exit;
  end;

  uVar.CarregaVariaveis;
  Conectado := uDm.data.ConectaDB;
  if Conectado then
  begin
    GravaLog('Banco de dados conectado com sucesso','INFO');
  end else
    begin
      MessageDlg(
      'Atenção',
      'Falha ao conectar ao banco de dados, verifique o log para mais detalhes',
      mtWarning,
      [mbOK],
      0
    );
    end;

  GravaLog('App iniciado com sucesso','INFO');

  { Reabertura pedida pelo proprio programa (troca de tema) ou login
    lembrado válido: segue direto, sem mostrar a tela. }
  if ReaberturaValida or TentarLoginLembrado(Conectado) then
  begin
    LoginConcluido := True;
    AlphaBlend := True;
    AlphaBlendValue := 0;
    Application.QueueAsyncCall(@AutoFechar, 0);
  end;
end;

{ Entra sozinho com o último usuário quando "Lembrar" foi marcado. Se a senha
  não confere mais (foi trocada) o lembrete é apagado e a tela é exibida com o
  usuário já preenchido. }
function Tfrm_login.TentarLoginLembrado(AConectado: Boolean): Boolean;
var
  Usuario, Senha: String;
begin
  Result := False;
  ck_lembrar.Checked := False;
  if UsuarioLembrado = '' then Exit;

  if not LerLoginLembrado(Usuario, Senha) then
  begin
    { senha ilegível (outro usuário do Windows / outra máquina) }
    edt_usuario.Text := UsuarioLembrado;
    EsquecerLoginLembrado;
    Exit;
  end;

  edt_usuario.Text := Usuario;
  if not AConectado then Exit;

  try
    Result := uDm.data.UserLogin(Usuario, Senha);
  except
    on E: Exception do
    begin
      GravaLog('Falha no login automático: ' + E.Message, 'ERRO');
      Result := False;
    end;
  end;

  if Result then
    GravaLog('Login automático do usuário lembrado: ' + Usuario, 'INFO')
  else
  begin
    GravaLog('Login lembrado inválido para ' + Usuario +
      '; voltando a pedir a senha.', 'AVISO');
    EsquecerLoginLembrado;
  end;
end;

procedure Tfrm_login.AutoFechar(Data: PtrInt);
begin
  Close;
end;

procedure Tfrm_login.btn_sairClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tfrm_login.edt_senhaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    btn_entrar.Click;
end;

procedure Tfrm_login.edt_usuarioKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    edt_senha.SetFocus;
end;

procedure Tfrm_login.btn_entrarClick(Sender: TObject);
begin
  if not uDm.data.UserLogin(edt_usuario.Text,edt_senha.Text) then
  begin
    MessageDlg(
      'Atenção',
      'Usuário não validado, verifique login e senha',
      mtWarning,
      [mbOK],
      0
    );
  Exit;
  end;
  GravarLoginLembrado(ck_lembrar.Checked, edt_usuario.Text, edt_senha.Text);
  LoginConcluido := True;
  Self.Close;
end;

procedure Tfrm_login.lb_sairClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.

