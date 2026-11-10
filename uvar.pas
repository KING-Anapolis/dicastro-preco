unit uVar;

{$mode ObjFPC}{$H+}

interface

type
  TVariaveis = record
    UserDB: String;
    PassDB: String;
    HostDB: String;
    PathBanco: String;
end;

  var Variaveis: TVariaveis;
  { True somente depois de um login valido (evita abrir o sistema ao fechar o login). }
  var LoginConcluido: Boolean = False;

procedure CarregaVariaveis;

implementation

uses
  Classes, SysUtils, IniFiles, uFuncoes;

procedure CarregaVariaveis;
begin
  Variaveis.UserDB      := uFuncoes.PLerINI('BASE','USUARIO_BD','SYSDBA');
  Variaveis.PassDB      := uFuncoes.PLerINI('BASE','SENHA_BD','masterkey');
  Variaveis.HostDB      := uFuncoes.PLerINI('BASE','SRV','127.0.0.1');
  Variaveis.PathBanco   := uFuncoes.PLerINI('BASE','BNC','C:\UPSYSTEM\DADOS\DADOS.FDB');
end;


end.

