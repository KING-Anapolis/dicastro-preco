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
  uMetaDarkStyle, uDarkStyleSchemes, uAtualiza
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  { Modo escuro nativo (barras de rolagem, abas, combos) — precisa vir antes
    de Application.Initialize. O esquema segue conf.ini [DICASTRO] TEMA. }
  PreferredAppMode := pamAllowDark;
  if UpperCase(PLerINI('DICASTRO', 'TEMA', 'CLARO')) = 'ESCURO' then
    ApplyMetaDarkStyle(DefaultDark)
  else
    ApplyMetaDarkStyle(DefaultWhite);
  Application.Initialize;
  InstalarTema;
  Application.CreateForm(Tdata, data);
  IniciarAtualizacaoAutomatica;
  //Application.CreateForm(Tfrm_login, frm_login);
  frm_login := Tfrm_login.Create(nil);
  frm_login.ShowModal;

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
  Application.Run;
end.

