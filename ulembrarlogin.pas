unit uLembrarLogin;

{$mode ObjFPC}{$H+}

{
  "Lembrar do último usuário" da tela de login.

  Guarda em conf.ini, seção [LOGIN]:
    LEMBRAR = 1 / 0
    USUARIO = último usuário que entrou
    SENHA   = senha criptografada pelo Windows (DPAPI, em hexadecimal)

  A senha nunca fica em texto puro: o DPAPI amarra a criptografia ao usuário
  do Windows, então só quem está logado nesse mesmo usuário consegue abrir.
  Em outro usuário/máquina a leitura falha e o login volta a ser pedido.
}

interface

uses
  Classes, SysUtils, Windows, uFuncoes;

const
  SECAO_LOGIN = 'LOGIN';

{ True quando há um login lembrado e a senha pôde ser recuperada. }
function LerLoginLembrado(out AUsuario, ASenha: String): Boolean;
{ Grava (ou apaga, se ALembrar = False) o login do último acesso. }
procedure GravarLoginLembrado(ALembrar: Boolean; const AUsuario,
  ASenha: String);
{ Esquece o login lembrado: a próxima abertura volta a pedir usuário e senha. }
procedure EsquecerLoginLembrado;
function UsuarioLembrado: String;

implementation

type
  DATA_BLOB = record
    cbData: DWORD;
    pbData: PByte;
  end;
  PDATA_BLOB = ^DATA_BLOB;

const
  CRYPTPROTECT_UI_FORBIDDEN = $1;

function CryptProtectData(pDataIn: PDATA_BLOB; szDataDescr: PWideChar;
  pOptionalEntropy: PDATA_BLOB; pvReserved: Pointer; pPromptStruct: Pointer;
  dwFlags: DWORD; pDataOut: PDATA_BLOB): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptProtectData';

function CryptUnprotectData(pDataIn: PDATA_BLOB; ppszDataDescr: PPWideChar;
  pOptionalEntropy: PDATA_BLOB; pvReserved: Pointer; pPromptStruct: Pointer;
  dwFlags: DWORD; pDataOut: PDATA_BLOB): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptUnprotectData';

const
  TEXTO_ENTROPIA = 'dicastro-preco/login';

function Entropia(out B: DATA_BLOB): PDATA_BLOB;
begin
  B.cbData := Length(TEXTO_ENTROPIA);
  B.pbData := PByte(PAnsiChar(TEXTO_ENTROPIA));
  Result := @B;
end;

function BytesParaHex(P: PByte; N: Integer): String;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to N - 1 do
    Result := Result + IntToHex(P[I], 2);
end;

function HexParaBytes(const S: String; out B: TBytes): Boolean;
var
  I, V: Integer;
begin
  Result := False;
  B := nil;
  if (S = '') or Odd(Length(S)) then Exit;
  SetLength(B, Length(S) div 2);
  for I := 0 to High(B) do
  begin
    if not TryStrToInt('$' + Copy(S, I * 2 + 1, 2), V) then Exit;
    B[I] := V;
  end;
  Result := True;
end;

function Proteger(const ATexto: String; out AHex: String): Boolean;
var
  Entrada, Saida, Ent: DATA_BLOB;
begin
  Result := False;
  AHex := '';
  if ATexto = '' then Exit;
  Entrada.cbData := Length(ATexto);
  Entrada.pbData := PByte(PAnsiChar(ATexto));
  FillChar(Saida, SizeOf(Saida), 0);
  if not CryptProtectData(@Entrada, nil, Entropia(Ent), nil, nil,
     CRYPTPROTECT_UI_FORBIDDEN, @Saida) then Exit;
  try
    AHex := BytesParaHex(Saida.pbData, Saida.cbData);
    Result := True;
  finally
    LocalFree(HLOCAL(Saida.pbData));
  end;
end;

function Desproteger(const AHex: String; out ATexto: String): Boolean;
var
  Dados: TBytes;
  Entrada, Saida, Ent: DATA_BLOB;
begin
  Result := False;
  ATexto := '';
  if not HexParaBytes(AHex, Dados) then Exit;
  Entrada.cbData := Length(Dados);
  Entrada.pbData := @Dados[0];
  FillChar(Saida, SizeOf(Saida), 0);
  if not CryptUnprotectData(@Entrada, nil, Entropia(Ent), nil, nil,
     CRYPTPROTECT_UI_FORBIDDEN, @Saida) then Exit;
  try
    SetString(ATexto, PAnsiChar(Saida.pbData), Saida.cbData);
    Result := True;
  finally
    if Saida.cbData > 0 then
      FillChar(Saida.pbData^, Saida.cbData, 0);
    LocalFree(HLOCAL(Saida.pbData));
  end;
end;

function UsuarioLembrado: String;
begin
  Result := '';
  if PLerINI(SECAO_LOGIN, 'LEMBRAR', '0') = '1' then
    Result := PLerINI(SECAO_LOGIN, 'USUARIO', '');
end;

function LerLoginLembrado(out AUsuario, ASenha: String): Boolean;
begin
  AUsuario := UsuarioLembrado;
  ASenha := '';
  Result := (AUsuario <> '') and
    Desproteger(PLerINI(SECAO_LOGIN, 'SENHA', ''), ASenha);
end;

procedure GravarLoginLembrado(ALembrar: Boolean; const AUsuario,
  ASenha: String);
var
  Hex: String;
begin
  try
    if ALembrar and Proteger(ASenha, Hex) then
    begin
      PGravaINI(SECAO_LOGIN, 'LEMBRAR', '1');
      PGravaINI(SECAO_LOGIN, 'USUARIO', AUsuario);
      PGravaINI(SECAO_LOGIN, 'SENHA', Hex);
    end
    else
      EsquecerLoginLembrado;
  except
    on E: Exception do
      GravaLog('Falha ao gravar o login lembrado: ' + E.Message, 'ERRO');
  end;
end;

procedure EsquecerLoginLembrado;
begin
  try
    PGravaINI(SECAO_LOGIN, 'LEMBRAR', '0');
    PGravaINI(SECAO_LOGIN, 'USUARIO', '');
    PGravaINI(SECAO_LOGIN, 'SENHA', '');
  except
    on E: Exception do
      GravaLog('Falha ao limpar o login lembrado: ' + E.Message, 'ERRO');
  end;
end;

end.
