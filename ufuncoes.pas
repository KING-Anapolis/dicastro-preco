unit uFuncoes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, uVar, Windows, Registry, Dialogs;

var
  GMutex: THandle;

  procedure PGravaINI(const SECAO, CHAVE, VALOR: String);
  function PLerINI(const SECAO, CHAVE, PADRAO: String): String;
  procedure GravaLog(const Mensagem: String; const Tipo: String = 'INFO');

implementation

// Ini
procedure PGravaINI(const SECAO, CHAVE, VALOR: String);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'conf.ini');
  try
    Ini.WriteString(SECAO, CHAVE, VALOR);
  finally
    Ini.Free;
  end;
end;

function PLerINI(const SECAO, CHAVE, PADRAO: String): String;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'conf.ini');
  try
    Result := Trim(Ini.ReadString(SECAO, CHAVE, PADRAO));

    if Result = '' then
      Result := PADRAO;
  finally
    Ini.Free;
  end;
end;

procedure GravaLog(const Mensagem: String; const Tipo: String = 'INFO');
var
  Arq: TextFile;
  PastaLog: String;
  NomeArquivo: String;
begin
  PastaLog := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Logs';

  if not DirectoryExists(PastaLog) then
    ForceDirectories(PastaLog);

  NomeArquivo := IncludeTrailingPathDelimiter(PastaLog) +
                 FormatDateTime('yyyy-mm-dd', Now) + '-Dicastro.log';

  AssignFile(Arq, NomeArquivo);

  if FileExists(NomeArquivo) then
    Append(Arq)
  else
    Rewrite(Arq);

  try
    Writeln(Arq,
      FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) +
      ' [' + UpperCase(Tipo) + '] ' +
      Mensagem);
  finally
    CloseFile(Arq);
  end;
end;

end.

