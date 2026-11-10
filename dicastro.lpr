program dicastro;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  SysUtils, Forms, u_frm_login_teste, zcomponent, uDm, uFuncoes, uVar, uFrmMain, rxnew,
  uFrmCadastro, uGrupoEdit, uMarcaEdit, uSetorEdit, uSubGrupoEdit,
  printer4lazarus, datetimectrls, uConf, uTema, uIcones, uDarkStyleParams,
  uMetaDarkStyle, uDarkStyleSchemes, uAtualiza, uInstancia
  { you can add units after this };

{$R *.res}

begin
  { Instância única: se já estiver aberto, traz a janela existente para a frente. }
  if not GarantirInstanciaUnica then Exit;
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  { Modo escuro nativo (barras de rolagem, abas, combos) — precisa vir antes
    de Application.Initialize. O esquema segue conf.ini [DICASTRO] TEMA. }
  if UpperCase(PLerINI('DICASTRO', 'TEMA', 'CLARO')) = 'ESCURO' then
  begin
    PreferredAppMode := pamForceDark;
    ApplyMetaDarkStyle(DefaultDark);
  end
  else
    { claro: Windows nativo puro (sem o componente de dark mode) }
    PreferredAppMode := pamForceLight;
  Application.Initialize;
  InstalarTema;
  Application.CreateForm(Tdata, data);
  IniciarAtualizacaoAutomatica;
  //Application.CreateForm(Tfrm_login, frm_login);
  frm_login := Tfrm_login.Create(nil);
  frm_login.ShowModal;

  { Fechou o login sem entrar (X, ESC, Alt+F4): encerra sem carregar o sistema. }
  if (not LoginConcluido) or Application.Terminated then
  begin
    frm_login.Free;
    Exit;
  end;

  Application.CreateForm(Tfrm_p, frm_p);
  PrincipalAberto := True;

  frm_login.Hide;
  frm_login.Free;
  Application.CreateForm(TfrmCadastro, frmCadastro);
  Application.CreateForm(TfrmGrupo, frmGrupo);
  Application.CreateForm(TfrmMarca, frmMarca);
  Application.CreateForm(TfrmSetor, frmSetor);
  Application.CreateForm(TfrmSubGrupo, frmSubGrupo);
  Application.CreateForm(TfrmConf, frmConf);
  AgendarNovidades;
  Application.Run;
end.

