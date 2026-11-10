unit u_frm_login;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, ColorSpeedButton;

type

  { Tfrm_login }

  Tfrm_login = class(TForm)
    btn_entrar: TColorSpeedButton;
    btn_sair: TColorSpeedButton;
    edt_usuario: TEdit;
    edt_senha: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lb_sair: TLabel;
    pnl_usuario: TPanel;
    pnl_senha: TPanel;
    pnl_usu_line: TPanel;
    pnl_lateral: TPanel;
    pnl_fundo: TPanel;
    pnl_senha_line: TPanel;
    procedure btn_sairClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lb_sairClick(Sender: TObject);
  private

  public

  end;

var
  frm_login: Tfrm_login;

implementation

{$R *.lfm}

{ Tfrm_login }

procedure Tfrm_login.lb_sairClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure Tfrm_login.FormActivate(Sender: TObject);
begin
  pnl_fundo.Left:= round((frm_login.Width - pnl_fundo.Width) / 2);
  pnl_fundo.Top:= round((frm_login.Height - pnl_fundo.Height) / 2);
end;

procedure Tfrm_login.btn_sairClick(Sender: TObject);
begin
  Application.Terminate;
end;

end.

