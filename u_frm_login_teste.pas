unit u_frm_login_teste;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
Buttons, ColorSpeedButton, FileUtil, uFuncoes, uVar, uDm, uFrmMain, uAtualiza;

type

  { Tfrm_login }

  Tfrm_login = class(TForm)
    btn_entrar: TColorSpeedButton;
    btn_sair: TColorSpeedButton;
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
  if uDm.data.ConectaDB then
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
  Self.Close;
end;

procedure Tfrm_login.lb_sairClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.

