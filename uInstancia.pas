unit uInstancia;

{ Instancia unica: se o programa ja estiver aberto (mesmo executavel, na mesma
  sessao do Windows), a nova execucao traz a janela existente para a frente e
  encerra. Instalacoes em pastas diferentes (ou com nomes de exe diferentes)
  nao se bloqueiam entre si. }

{$mode objfpc}{$H+}

interface

{ True = esta e a primeira instancia e pode continuar.
  False = ja existe outra; a janela dela foi trazida para a frente. }
function GarantirInstanciaUnica: Boolean;

{ Reinicia o programa (ex.: troca de tema). A nova instancia espera esta
  encerrar e pula o login. Depois de chamar, encerre o programa normalmente. }
procedure ReiniciarAplicacao;

{ True se esta execucao e uma reabertura legitima (parametro /reiniciar e
  marcador recente). Consome o marcador. }
function ReaberturaValida: Boolean;

implementation

uses
  Windows, SysUtils, Classes, Process;

var
  Mutex: THandle = 0;

function QueryFullProcessImageNameW(hProcess: THandle; dwFlags: DWORD;
  lpExeName: PWideChar; var lpdwSize: DWORD): BOOL; stdcall;
  external 'kernel32.dll' name 'QueryFullProcessImageNameW';

function NomeMutex: string;
var
  S: string;
  I: Integer;
begin
  S := LowerCase(ParamStr(0));
  for I := 1 to Length(S) do
    if not (S[I] in ['a'..'z', '0'..'9']) then
      S[I] := '_';
  Result := 'Local\app_instancia_' + S;
  if Length(Result) > 240 then
    Result := Copy(Result, 1, 240);
end;

function CaminhoDoProcesso(Pid: DWORD): string;
var
  H: THandle;
  Buf: array[0..1023] of WideChar;
  N: DWORD;
begin
  Result := '';
  H := OpenProcess($1000 { PROCESS_QUERY_LIMITED_INFORMATION }, False, Pid);
  if H = 0 then Exit;
  try
    N := Length(Buf);
    if QueryFullProcessImageNameW(H, 0, @Buf[0], N) then
      Result := UTF8Encode(WideString(PWideChar(@Buf[0])));
  finally
    CloseHandle(H);
  end;
end;

var
  Meu: string;
  MeuPid: DWORD;
  Alvo: HWND;

function EnumJanelas(Wnd: HWND; Param: LPARAM): BOOL; stdcall;
var
  Pid: DWORD;
begin
  Result := True;
  if not IsWindowVisible(Wnd) then Exit;
  if GetWindow(Wnd, GW_OWNER) <> 0 then Exit;
  GetWindowThreadProcessId(Wnd, @Pid);
  if Pid = MeuPid then Exit;
  if SameText(CaminhoDoProcesso(Pid), Meu) then
  begin
    Alvo := Wnd;
    Result := False;
  end;
end;

procedure TrazerParaFrente;
var
  Fg, ThFg, ThMeu: DWORD;
begin
  Meu := ParamStr(0);
  MeuPid := GetCurrentProcessId;
  Alvo := 0;
  { a outra instancia pode estar terminando de abrir: tenta por ~3 s }
  Fg := 0;
  while (Alvo = 0) and (Fg < 15) do
  begin
    EnumWindows(@EnumJanelas, 0);
    if Alvo = 0 then Sleep(200);
    Inc(Fg);
  end;
  if Alvo = 0 then Exit;

  if IsIconic(Alvo) then
    ShowWindow(Alvo, SW_RESTORE)
  else
    ShowWindow(Alvo, SW_SHOW);

  { contorna a trava do Windows contra roubo de foco }
  ThFg := GetWindowThreadProcessId(GetForegroundWindow, nil);
  ThMeu := GetCurrentThreadId;
  if (ThFg <> 0) and (ThFg <> ThMeu) then
    AttachThreadInput(ThMeu, ThFg, True);
  BringWindowToTop(Alvo);
  SetForegroundWindow(Alvo);
  if (ThFg <> 0) and (ThFg <> ThMeu) then
    AttachThreadInput(ThMeu, ThFg, False);
end;

function MarcadorSessao: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'sessao.tmp';
end;

function ParamReiniciar: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), '/reiniciar') then Exit(True);
end;

procedure ReiniciarAplicacao;
var
  L: TStringList;
  P: TProcess;
begin
  L := TStringList.Create;
  try
    L.Add(FloatToStr(Now));
    L.SaveToFile(MarcadorSessao);
  finally
    L.Free;
  end;
  P := TProcess.Create(nil);
  try
    P.Executable := ParamStr(0);
    P.Parameters.Add('/reiniciar');
    P.CurrentDirectory := ExtractFilePath(ParamStr(0));
    P.Execute;
  finally
    P.Free;
  end;
end;

function ReaberturaValida: Boolean;
var
  L: TStringList;
  T: Double;
begin
  Result := False;
  if not ParamReiniciar then Exit;
  if not FileExists(MarcadorSessao) then Exit;
  L := TStringList.Create;
  try
    try
      L.LoadFromFile(MarcadorSessao);
      T := StrToFloatDef(Trim(L.Text), 0);
      Result := (T > 0) and ((Now - T) < 60 / 86400);
    except
      Result := False;
    end;
  finally
    L.Free;
  end;
  DeleteFile(MarcadorSessao);
end;

function GarantirInstanciaUnica: Boolean;
var
  Tent: Integer;
begin
  Mutex := CreateMutexW(nil, True, PWideChar(WideString(NomeMutex)));
  { reabertura: espera a instancia anterior terminar de fechar (ate ~20 s) }
  Tent := 0;
  while ParamReiniciar and (Mutex <> 0) and
        (GetLastError = ERROR_ALREADY_EXISTS) and (Tent < 80) do
  begin
    CloseHandle(Mutex);
    Sleep(250);
    Inc(Tent);
    Mutex := CreateMutexW(nil, True, PWideChar(WideString(NomeMutex)));
  end;
  if (Mutex <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    TrazerParaFrente;
    Result := False;
    Exit;
  end;
  Result := True;
end;

end.
