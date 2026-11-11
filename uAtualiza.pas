unit uAtualiza;

{ Atualização automatica via GitHub Releases.

  Fluxo:
   1. Em segundo plano consulta  https://api.github.com/repos/<REPO>/releases/latest
      (sem internet / sem release: segue em silencio, so grava log).
   2. Se a tag (ex.: v3.1.0) for maior que APP_VERSAO, mostra um pop-up com
      barra de progresso e baixa o primeiro asset .exe da release para atualiza.novo.exe.
   3. Um .cmd espera o programa fechar, troca o exe e (se o sistema principal
      ainda não abriu) reabre o programa ja atualizado. Se o usuario ja estiver
      trabalhando, nada e interrompido: a troca ocorre quando ele fechar.
   4. Na primeira abertura apos atualizar, mostra um pop-up de sucesso.
   5. Qualquer falha depois de achar uma versão nova mostra um pop-up que
      orienta o cliente a falar com o suporte do sistema.

  Chaves criadas automaticamente em conf.ini ([ATUALIZACAO]):
     REPO=usuario/repositorio   (vazio = desligado)
     ATIVO=S
     SUPORTE_NOME= / SUPORTE_FONE= / SUPORTE_EMAIL=   (exibidos nos erros)
     VERSAO_INSTALADA=          (controle interno)

  Usa o curl.exe que ja vem no Windows 10/11 (TLS nativo, sem DLLs extras). }

{$mode objfpc}{$H+}

interface

const
  APP_VERSAO = '3.0.2';
  REPO_PADRAO = 'KING-Anapolis/dicastro-preco';

var
  { Setar True depois que a tela principal abrir. }
  PrincipalAberto: Boolean = False;

procedure IniciarAtualizacaoAutomatica;

{ Agenda o pop-up de novidades (so aparece se o sistema acabou de ser
  atualizado). Chamar logo antes de Application.Run, depois do login. }
procedure AgendarNovidades;

implementation

uses
  Classes, SysUtils, Math, ExtCtrls, Process, IniFiles, fpjson, jsonparser, Forms, Controls,
  Graphics, LCLType, LCLIntf, uFuncoes, uTema;

type
  TModoPop = (mpProgresso, mpSucesso, mpAviso, mpErro, mpNovidades);

  { Pop-up moderno desenhado em codigo (cantos arredondados, tema claro/escuro). }
  TPopAtualiza = class(TForm)
  private
    FModo: TModoPop;
    FTitulo, FMensagem, FDetalhe: string;
    FSuporte: TStringList;
    FPerc: Integer;
    FBtn: TRect;
    FBtnHot: Boolean;
    function Esc(N: Integer): Integer;
    procedure Pintar(Sender: TObject);
    procedure Arrastar(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Mover(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Tecla(Sender: TObject; var Key: Word; Shift: TShiftState);
    function Cor: TColor;
  public
    constructor CriarPop(AModo: TModoPop; const ATitulo, AMensagem: string;
      const ADetalhe: string = '');
    destructor Destroy; override;
    procedure DefinirProgresso(APerc: Integer; const AMensagem: string);
  end;

  TAtualizaThread = class(TThread)
  private
    FPop: TPopAtualiza;
    FNovoExe, FTag, FMsg, FDetalhe: string;
    FPerc: Integer;
    procedure MostrarProgresso;
    procedure AtualizarProgresso;
    procedure FecharProgresso;
    procedure Aplicar;
    procedure MostrarErro;
    procedure Falha(const AMsg: string);
  protected
    procedure Execute; override;
  public
    constructor Create;
  end;

{ ---------------------------------------------------------------- INI ---- }

procedure GarantirChaves;
var
  Ini: TIniFile;

  procedure Chave(const K, V: string);
  begin
    if not Ini.ValueExists('ATUALIZACAO', K) then
      Ini.WriteString('ATUALIZACAO', K, V);
  end;

begin
  try
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'conf.ini');
    try
      Chave('REPO', REPO_PADRAO);
      Chave('ATIVO', 'S');
      Chave('SUPORTE_NOME', 'King Tecnologia');
      Chave('SUPORTE_FONE', '62 9447-9690');
      Chave('SUPORTE_EMAIL', 'borgesv770@gmail.com');
      Chave('VERSAO_INSTALADA', '');
    finally
      Ini.Free;
    end;
  except
    { pasta somente-leitura: segue sem criar as chaves }
  end;
end;

function CaminhoCurl: string;
begin
  Result := GetEnvironmentVariable('SystemRoot') + '\System32\curl.exe';
  if not FileExists(Result) then
    Result := 'curl.exe';
end;

function VersaoNum(const V: string): Int64;
var
  S: string;
  Partes: TStringList;
  I, N: Integer;
begin
  Result := 0;
  S := Trim(V);
  if (S <> '') and (UpCase(S[1]) = 'V') then
    Delete(S, 1, 1);
  Partes := TStringList.Create;
  try
    Partes.Delimiter := '.';
    Partes.StrictDelimiter := True;
    Partes.DelimitedText := S;
    for I := 0 to 3 do
    begin
      if I < Partes.Count then
        N := StrToIntDef(Partes[I], 0)
      else
        N := 0;
      Result := Result * 1000 + N;
    end;
  finally
    Partes.Free;
  end;
end;

{ ------------------------------------------------------------- Pop-up ---- }

constructor TPopAtualiza.CriarPop(AModo: TModoPop; const ATitulo, AMensagem: string;
  const ADetalhe: string);
var
  Linhas: Integer;
  S: string;
begin
  inherited CreateNew(nil);
  FModo := AModo;
  FTitulo := ATitulo;
  FMensagem := AMensagem;
  FDetalhe := ADetalhe;
  FSuporte := TStringList.Create;

  if AModo = mpErro then
  begin
    FSuporte.Add('Fale com o suporte do sistema:');
    S := PLerINI('ATUALIZACAO', 'SUPORTE_NOME', 'King Tecnologia');
    if S <> '' then FSuporte.Add(S);
    S := PLerINI('ATUALIZACAO', 'SUPORTE_FONE', '62 9447-9690');
    if S <> '' then FSuporte.Add('Telefone / WhatsApp: ' + S);
    S := PLerINI('ATUALIZACAO', 'SUPORTE_EMAIL', 'borgesv770@gmail.com');
    if S <> '' then FSuporte.Add('E-mail: ' + S);
  end;

  if AModo = mpNovidades then
  begin
    FSuporte.Text := ADetalhe;
    FDetalhe := '';
  end;

  BorderStyle := bsNone;
  Position := poScreenCenter;
  FormStyle := fsStayOnTop;
  KeyPreview := True;
  DoubleBuffered := True;
  Color := Paleta.Superficie;
  Font.Name := 'Segoe UI';

  Width := Esc(480);
  case AModo of
    mpProgresso: Height := Esc(190);
    mpNovidades: Height := Esc(100) + FSuporte.Count * Esc(28) + Esc(84);
    mpErro:
    begin
      Linhas := FSuporte.Count;
      if FDetalhe <> '' then Inc(Linhas, 2);
      Height := Esc(250) + Linhas * Esc(20);
    end;
  else
    Height := Esc(210);
  end;

  FBtn := Rect(Width - Esc(150), Height - Esc(64), Width - Esc(28), Height - Esc(24));

  OnPaint := @Pintar;
  OnMouseDown := @Arrastar;
  OnMouseMove := @Mover;
  OnKeyDown := @Tecla;

  { cantos arredondados }
  LCLIntf.SetWindowRgn(Handle,
    LCLIntf.CreateRoundRectRgn(0, 0, Width + 1, Height + 1, Esc(20), Esc(20)), True);
end;

destructor TPopAtualiza.Destroy;
begin
  FSuporte.Free;
  inherited Destroy;
end;

function TPopAtualiza.Esc(N: Integer): Integer;
begin
  Result := N * Screen.PixelsPerInch div 96;
end;

function TPopAtualiza.Cor: TColor;
begin
  case FModo of
    mpSucesso: Result := RGBToColor(34, 160, 90);
    mpAviso: Result := RGBToColor(230, 150, 20);
    mpErro: Result := RGBToColor(220, 60, 60);
  else
    Result := Paleta.Destaque;
  end;
end;

procedure TPopAtualiza.DefinirProgresso(APerc: Integer; const AMensagem: string);
begin
  FPerc := APerc;
  if AMensagem <> '' then
    FMensagem := AMensagem;
  Invalidate;
end;

procedure TPopAtualiza.Arrastar(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (FModo <> mpProgresso) and PtInRect(FBtn, Point(X, Y)) then
  begin
    ModalResult := mrOk;
    Exit;
  end;
  LCLIntf.ReleaseCapture;
  LCLIntf.SendMessage(Handle, $00A1, HTCAPTION, 0);
end;

procedure TPopAtualiza.Mover(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Hot: Boolean;
begin
  Hot := (FModo <> mpProgresso) and PtInRect(FBtn, Point(X, Y));
  if Hot <> FBtnHot then
  begin
    FBtnHot := Hot;
    Invalidate;
  end;
end;

procedure TPopAtualiza.Tecla(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (FModo <> mpProgresso) and ((Key = VK_RETURN) or (Key = VK_ESCAPE)) then
    ModalResult := mrOk;
end;

procedure TPopAtualiza.Pintar(Sender: TObject);
var
  C: TCanvas;
  Acc: TColor;
  R, Tr: TRect;
  X, Y, Larg: Integer;
  I: Integer;
  Est: array[0..9] of TPoint;
  Estilo: TTextStyle;
  Txt: string;
begin
  C := Canvas;
  Acc := Cor;

  { fundo + borda }
  C.Brush.Color := Paleta.Superficie;
  C.Pen.Color := Paleta.Borda;
  C.Pen.Width := 1;
  C.FillRect(0, 0, Width, Height);

  { faixa de destaque no topo }
  C.Brush.Color := Acc;
  C.Pen.Style := psClear;
  C.FillRect(0, 0, Width, Esc(5));
  C.Pen.Style := psSolid;

  { icone em circulo }
  X := Esc(28);
  Y := Esc(28);
  C.Brush.Color := MisturarCor(Acc, Paleta.Superficie, 18);
  C.Pen.Style := psClear;
  C.Ellipse(X, Y, X + Esc(44), Y + Esc(44));
  C.Pen.Style := psSolid;
  C.Pen.Color := Acc;
  C.Pen.Width := Esc(3);
  C.Pen.EndCap := pecRound;
  C.Pen.JoinStyle := pjsRound;
  case FModo of
    mpNovidades:
    begin
      { estrela de 5 pontas }
      C.Brush.Color := Acc;
      C.Pen.Width := 1;
      for I := 0 to 9 do
      begin
        if Odd(I) then Larg := Esc(8) else Larg := Esc(13);
        Est[I] := Point(X + Esc(22) + Round(Larg * Sin(I * Pi / 5)),
          Y + Esc(23) - Round(Larg * Cos(I * Pi / 5)));
      end;
      C.Polygon(Est);
    end;
    mpSucesso:
      C.Polyline([Point(X + Esc(12), Y + Esc(23)), Point(X + Esc(19), Y + Esc(30)),
        Point(X + Esc(32), Y + Esc(15))]);
    mpProgresso:
    begin
      C.Line(X + Esc(22), Y + Esc(11), X + Esc(22), Y + Esc(31));
      C.Polyline([Point(X + Esc(14), Y + Esc(24)), Point(X + Esc(22), Y + Esc(32)),
        Point(X + Esc(30), Y + Esc(24))]);
    end;
  else
    C.Line(X + Esc(22), Y + Esc(11), X + Esc(22), Y + Esc(25));
    C.Brush.Color := Acc;
    C.Ellipse(X + Esc(20), Y + Esc(29), X + Esc(24), Y + Esc(33));
  end;
  C.Pen.Width := 1;

  { titulo }
  C.Brush.Style := bsClear;
  C.Font.Name := 'Segoe UI';
  C.Font.Style := [fsBold];
  C.Font.Size := 13;
  C.Font.Color := Paleta.Texto;
  C.TextOut(Esc(86), Esc(30), FTitulo);

  { mensagem }
  FillChar(Estilo, SizeOf(Estilo), 0);
  Estilo.Wordbreak := True;
  Estilo.SingleLine := False;
  Estilo.Layout := tlTop;
  C.Font.Style := [];
  C.Font.Size := 10;
  C.Font.Color := Paleta.TextoSuave;
  Tr := Rect(Esc(86), Esc(58), Width - Esc(28), Esc(58) + Esc(60));
  C.TextRect(Tr, Tr.Left, Tr.Top, FMensagem, Estilo);

  if FModo = mpProgresso then
  begin
    { barra de progresso }
    Larg := Width - Esc(86) - Esc(28);
    R := Rect(Esc(86), Height - Esc(52), Esc(86) + Larg - Esc(48), Height - Esc(40));
    C.Brush.Color := Paleta.Borda;
    C.Pen.Style := psClear;
    C.RoundRect(R.Left, R.Top, R.Right, R.Bottom, R.Bottom - R.Top, R.Bottom - R.Top);
    if FPerc > 0 then
    begin
      C.Brush.Color := Acc;
      C.RoundRect(R.Left, R.Top,
        R.Left + Max(R.Bottom - R.Top, (R.Right - R.Left) * FPerc div 100),
        R.Bottom, R.Bottom - R.Top, R.Bottom - R.Top);
    end;
    C.Pen.Style := psSolid;
    C.Brush.Style := bsClear;
    C.Font.Style := [fsBold];
    C.Font.Size := 9;
    C.Font.Color := Paleta.Texto;
    Txt := IntToStr(FPerc) + '%';
    C.TextOut(R.Right + Esc(10), R.Top - Esc(3), Txt);
  end
  else
  begin
    Y := Esc(122);
    if FModo = mpErro then
    begin
      { caixa do suporte }
      R := Rect(Esc(28), Y, Width - Esc(28),
        Y + FSuporte.Count * Esc(20) + Esc(18));
      C.Brush.Style := bsSolid;
      C.Brush.Color := Paleta.CabecalhoFundo;
      C.Pen.Color := Paleta.Borda;
      C.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Esc(12), Esc(12));
      C.Brush.Style := bsClear;
      C.Font.Size := 10;
      for I := 0 to FSuporte.Count - 1 do
      begin
        if I = 0 then C.Font.Style := [fsBold] else C.Font.Style := [];
        C.Font.Color := Paleta.Texto;
        C.TextOut(R.Left + Esc(14), R.Top + Esc(9) + I * Esc(20), FSuporte[I]);
      end;
      Y := R.Bottom + Esc(8);
      if FDetalhe <> '' then
      begin
        C.Font.Style := [];
        C.Font.Size := 8;
        C.Font.Color := Paleta.TextoSuave;
        Tr := Rect(Esc(28), Y, Width - Esc(28), Y + Esc(34));
        C.TextRect(Tr, Tr.Left, Tr.Top, 'Detalhe técnico: ' + FDetalhe, Estilo);
      end;
    end;

    if FModo = mpNovidades then
    begin
      C.Font.Size := 10;
      for I := 0 to FSuporte.Count - 1 do
      begin
        Y := Esc(100) + I * Esc(28);
        C.Brush.Style := bsSolid;
        C.Brush.Color := MisturarCor(Acc, Paleta.Superficie, 18);
        C.Pen.Style := psClear;
        C.Ellipse(Esc(28), Y, Esc(28) + Esc(20), Y + Esc(20));
        C.Pen.Style := psSolid;
        C.Pen.Color := Acc;
        C.Pen.Width := Esc(2);
        C.Polyline([Point(Esc(33), Y + Esc(10)), Point(Esc(36), Y + Esc(13)),
          Point(Esc(42), Y + Esc(7))]);
        C.Pen.Width := 1;
        C.Brush.Style := bsClear;
        C.Font.Style := [];
        C.Font.Color := Paleta.Texto;
        C.TextOut(Esc(58), Y + Esc(1), FSuporte[I]);
      end;
    end;

    { botao }
    C.Brush.Style := bsSolid;
    if FBtnHot then
      C.Brush.Color := MisturarCor(Acc, clBlack, 12)
    else
      C.Brush.Color := Acc;
    C.Pen.Style := psClear;
    C.RoundRect(FBtn.Left, FBtn.Top, FBtn.Right, FBtn.Bottom, Esc(14), Esc(14));
    C.Pen.Style := psSolid;
    C.Brush.Style := bsClear;
    C.Font.Style := [fsBold];
    C.Font.Size := 10;
    C.Font.Color := clWhite;
    Txt := 'Entendi';
    C.TextOut(FBtn.Left + (FBtn.Right - FBtn.Left - C.TextWidth(Txt)) div 2,
      FBtn.Top + (FBtn.Bottom - FBtn.Top - C.TextHeight(Txt)) div 2, Txt);
  end;
end;

procedure MostrarPop(AModo: TModoPop; const ATitulo, AMensagem: string;
  const ADetalhe: string = '');
var
  P: TPopAtualiza;
begin
  P := TPopAtualiza.CriarPop(AModo, ATitulo, AMensagem, ADetalhe);
  try
    P.ShowModal;
  finally
    P.Free;
  end;
end;

{ ------------------------------------------------------------ Thread ---- }

constructor TAtualizaThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;

procedure TAtualizaThread.MostrarProgresso;
begin
  FPop := TPopAtualiza.CriarPop(mpProgresso, 'Atualizando o sistema',
    'Baixando a versão ' + FTag + '. Aguarde, não feche o programa.');
  FPop.Show;
  Application.ProcessMessages;
end;

procedure TAtualizaThread.AtualizarProgresso;
begin
  if FPop <> nil then
    FPop.DefinirProgresso(FPerc, FMsg);
end;

procedure TAtualizaThread.FecharProgresso;
begin
  FreeAndNil(FPop);
end;

procedure TAtualizaThread.MostrarErro;
begin
  FreeAndNil(FPop);
  MostrarPop(mpErro, 'Não foi possivel atualizar',
    'Houve um problema ao instalar a nova versão do sistema. ' +
    'Você pode continuar usando o programa normalmente.', FDetalhe);
end;

procedure TAtualizaThread.Falha(const AMsg: string);
begin
  FDetalhe := AMsg;
  GravaLog('Falha na atualização automatica: ' + AMsg, 'ERRO');
  Synchronize(@MostrarErro);
end;

procedure TAtualizaThread.Execute;
var
  Repo, Saida, UrlExe, Tmp, Dir: string;
  J: TJSONData;
  Assets: TJSONArray;
  I: Integer;
  F: TFileStream;
  Cab: array[0..1] of Char;
  Total, Atual: Int64;
  P: TProcess;
  Achou: Boolean;
begin
  Achou := False;
  try
    Repo := PLerINI('ATUALIZACAO', 'REPO', REPO_PADRAO);
    if (Repo = '') or (UpperCase(PLerINI('ATUALIZACAO', 'ATIVO', 'S')) <> 'S') then
      Exit;

    Dir := ExtractFilePath(ParamStr(0));
    Tmp := Dir + 'atualiza.baixando.tmp';
    FNovoExe := Dir + 'atualiza.novo.exe';

    { Troca ja agendada (outra instancia aberta): não mexe em nada. }
    if FileExists(Dir + 'atualiza.cmd') then
      Exit;
    if FileExists(FNovoExe) then
      DeleteFile(FNovoExe);

    if not RunCommand(CaminhoCurl, ['-s', '-L', '--max-time', '15',
      '-H', 'User-Agent: updater',
      '-H', 'Accept: application/vnd.github+json',
      'https://api.github.com/repos/' + Repo + '/releases/latest'],
      Saida, [poNoConsole]) then
      Exit;

    Total := 0;
    UrlExe := '';
    J := GetJSON(Saida);
    try
      if not (J is TJSONObject) then Exit;
      FTag := TJSONObject(J).Get('tag_name', '');
      if VersaoNum(FTag) <= VersaoNum(APP_VERSAO) then
        Exit;

      Assets := TJSONObject(J).Get('assets', TJSONArray(nil));
      if Assets <> nil then
        for I := 0 to Assets.Count - 1 do
          if LowerCase(ExtractFileExt(Assets.Objects[I].Get('name', ''))) = '.exe' then
          begin
            UrlExe := Assets.Objects[I].Get('browser_download_url', '');
            Total := Assets.Objects[I].Get('size', Int64(0));
            Break;
          end;
    finally
      J.Free;
    end;
    if UrlExe = '' then
      Exit;

    { A partir daqui existe versão nova: erros avisam o usuario. }
    Achou := True;
    Synchronize(@MostrarProgresso);

    DeleteFile(Tmp);
    P := TProcess.Create(nil);
    try
      P.Executable := CaminhoCurl;
      P.Parameters.AddStrings(['-s', '-L', '--fail', '--max-time', '900',
        '-o', Tmp, UrlExe]);
      P.Options := [poNoConsole];
      P.Execute;
      while P.Running do
      begin
        Sleep(150);
        if (Total > 0) and FileExists(Tmp) then
        begin
          try
            F := TFileStream.Create(Tmp, fmOpenRead or fmShareDenyNone);
            try Atual := F.Size; finally F.Free; end;
          except
            Atual := 0;
          end;
          FPerc := Integer(Atual * 100 div Total);
          if FPerc > 99 then FPerc := 99;
          FMsg := 'Baixando a versão ' + FTag + ' (' +
            IntToStr(Atual div 1048576) + ' de ' + IntToStr(Total div 1048576) +
            ' MB). Não feche o programa.';
          Synchronize(@AtualizarProgresso);
        end;
      end;
      if P.ExitStatus <> 0 then
      begin
        Falha('download (código ' + IntToStr(P.ExitStatus) + ')');
        Exit;
      end;
    finally
      P.Free;
    end;

    { Valida: tamanho minimo e assinatura "MZ" de executável Windows. }
    if not FileExists(Tmp) then
    begin
      Falha('arquivo não baixado');
      Exit;
    end;
    F := TFileStream.Create(Tmp, fmOpenRead or fmShareDenyNone);
    try
      Cab[0] := #0; Cab[1] := #0;
      if F.Size >= 1024 * 1024 then
        F.ReadBuffer(Cab, 2);
      if (F.Size < 1024 * 1024) or (Total > 0) and (F.Size <> Total) or
         (Cab[0] <> 'M') or (Cab[1] <> 'Z') then
      begin
        FreeAndNil(F);
        DeleteFile(Tmp);
        Falha('arquivo baixado inválido');
        Exit;
      end;
    finally
      F.Free;
    end;

    if not RenameFile(Tmp, FNovoExe) then
    begin
      Falha('não foi possível gravar ' + ExtractFileName(FNovoExe));
      Exit;
    end;

    GravaLog('Atualização ' + FTag + ' baixada.');
    FPerc := 100;
    FMsg := 'Instalando a versão ' + FTag + '...';
    Synchronize(@AtualizarProgresso);
    Synchronize(@Aplicar);
  except
    on E: Exception do
      if Achou then
        Falha(E.Message)
      else
        GravaLog('Verificação de atualização: ' + E.Message, 'ERRO');
  end;
end;

procedure TAtualizaThread.Aplicar;
var
  Exe, Dir, Cmd: string;
  L: TStringList;
  P: TProcess;
  Reabrir: Boolean;
begin
  Exe := ParamStr(0);
  Dir := ExtractFilePath(Exe);
  Cmd := Dir + 'atualiza.cmd';
  Reabrir := not PrincipalAberto;

  try
    L := TStringList.Create;
    try
      L.Add('@echo off');
      L.Add('set TENT=0');
      L.Add(':tenta');
      L.Add('set /a TENT+=1');
      L.Add('if %TENT% GTR 3600 goto fim');
      L.Add('ping -n 2 127.0.0.1 >nul');
      L.Add('move /y "' + FNovoExe + '" "' + Exe + '" >nul 2>&1');
      L.Add('if exist "' + FNovoExe + '" goto tenta');
      if Reabrir then
        L.Add('start "" "' + Exe + '"');
      L.Add(':fim');
      L.Add('del "%~f0"');
      L.SaveToFile(Cmd);
    finally
      L.Free;
    end;

    P := TProcess.Create(nil);
    try
      P.Executable := 'cmd.exe';
      P.Parameters.Add('/c');
      P.Parameters.Add('"' + Cmd + '"');
      P.CurrentDirectory := Dir;
      P.Options := [poNoConsole];
      P.Execute;
    finally
      P.Free;
    end;
  except
    on E: Exception do
    begin
      DeleteFile(FNovoExe);
      FDetalhe := E.Message;
      GravaLog('Falha ao agendar a troca do executável: ' + E.Message, 'ERRO');
      MostrarErro;
      Exit;
    end;
  end;

  if Reabrir then
  begin
    { Reabre o programa; o pop-up de sucesso aparece na proxima abertura. }
    if FPop <> nil then
    begin
      FPop.DefinirProgresso(100, 'Reiniciando o sistema com a versão ' + FTag + '...');
      Application.ProcessMessages;
      Sleep(900);
    end;
    FecharProgresso;
    Application.Terminate;
  end
  else
  begin
    FecharProgresso;
    MostrarPop(mpAviso, 'Atualização pronta',
      'A versão ' + FTag + ' foi baixada e será instalada quando você ' +
      'fechar o sistema. Nada precisa ser feito agora.');
  end;
end;

{ ------------------------------------------------------------ Entrada ---- }

{ Novidades exibidas depois do login na primeira abertura de cada versao.
  A CADA RELEASE: edite esta lista com o que mudou (uma linha por item). }
function NovidadesDaVersao: string;
begin
  Result :=
    'Sugestão de compra: coluna de quantidade destacada' + LineEnding +
    'Espaço em item já lançado atualiza a quantidade' + LineEnding +
    'Backspace remove o item do pedido de compra' + LineEnding +
    'Botão direito na linha: excluir do pedido' + LineEnding +
    'Ao excluir, a quantidade volta ao valor sugerido' + LineEnding +
    'Corrigido erro ao lançar o mesmo item novamente';
end;

var
  NovidadesPendentes: Boolean = False;

{ Compara a versao gravada no INI com a do executavel. Se mudou (ou e a
  primeira vez), as novidades serao mostradas apos o login. }
procedure DetectarAtualizacao;
var
  Ini: TIniFile;
begin
  try
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'conf.ini');
    try
      NovidadesPendentes :=
        Trim(Ini.ReadString('ATUALIZACAO', 'VERSAO_INSTALADA', '')) <> APP_VERSAO;
    finally
      Ini.Free;
    end;
  except
    NovidadesPendentes := False;
  end;
end;

type
  TAgendaNovidades = class
  private
    FTimer: TTimer;
    procedure Tick(Sender: TObject);
  public
    procedure Iniciar;
    procedure Disparar(Data: PtrInt);
  end;

{ Espera a tela principal aparecer para so entao mostrar o pop-up. }
procedure TAgendaNovidades.Iniciar;
begin
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 300;
  FTimer.OnTimer := @Tick;
end;

procedure TAgendaNovidades.Tick(Sender: TObject);
begin
  if (Application.MainForm <> nil) and Application.MainForm.Visible and
     Application.MainForm.HandleAllocated then
  begin
    FTimer.Enabled := False;
    Disparar(0);
  end;
end;

procedure TAgendaNovidades.Disparar(Data: PtrInt);
var
  Ini: TIniFile;
begin
  if not NovidadesPendentes then Exit;
  { garante a tela principal na frente antes do pop-up }
  if Application.MainForm <> nil then
  begin
    Application.MainForm.BringToFront;
    LCLIntf.SetForegroundWindow(Application.MainForm.Handle);
  end;
  NovidadesPendentes := False;
  { grava antes de mostrar: se algo falhar, nao repete a cada abertura }
  try
    Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'conf.ini');
    try
      Ini.WriteString('ATUALIZACAO', 'VERSAO_INSTALADA', APP_VERSAO);
    finally
      Ini.Free;
    end;
  except
  end;
  MostrarPop(mpNovidades, 'Novidades da versão ' + APP_VERSAO,
    'Confira o que há de novo nesta atualização:', NovidadesDaVersao);
end;

var
  Agenda: TAgendaNovidades;

procedure AgendarNovidades;
begin
  if not NovidadesPendentes then Exit;
  if Agenda = nil then Agenda := TAgendaNovidades.Create;
  Agenda.Iniciar;
end;

procedure IniciarAtualizacaoAutomatica;
begin
  GarantirChaves;
  { remove sobras de uma troca ja concluida }
  if not FileExists(ExtractFilePath(ParamStr(0)) + 'atualiza.cmd') then
    DeleteFile(ExtractFilePath(ParamStr(0)) + 'atualiza.baixando.tmp');
  DetectarAtualizacao;
  TAtualizaThread.Create.Start;
end;

end.
