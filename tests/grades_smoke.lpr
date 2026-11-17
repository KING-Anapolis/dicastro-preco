program grades_smoke;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  Interfaces, Forms, SysUtils, Classes, DB, DBGrids, BufDataset, uGrades;

type
  TT = class
    procedure Ajusta(AGrade: TCustomDBGrid);
  end;

var
  Falhas: Integer = 0;
  Ini: String;
  Chamadas: Integer = 0;

procedure Confere(ACond: Boolean; const AMsg: String);
begin
  if ACond then WriteLn('ok   ', AMsg)
  else begin WriteLn('FALHA ', AMsg); Inc(Falhas); end;
end;

procedure TT.Ajusta(AGrade: TCustomDBGrid);
var
  Cols: TDBGridColumns;
  I: Integer;
begin
  Inc(Chamadas);
  Cols := TDBGrid(AGrade).Columns;
  for I := 0 to Cols.Count - 1 do Cols[I].Width := 100;   { "melhor tamanho" }
end;

function NovaGrade(out DS: TBufDataset; out Fonte: TDataSource): TDBGrid;
var
  I: Integer;
begin
  DS := TBufDataset.Create(nil);
  DS.FieldDefs.Add('A', ftInteger);
  DS.FieldDefs.Add('B', ftString, 20);
  DS.FieldDefs.Add('C', ftString, 20);
  DS.FieldDefs.Add('D', ftString, 20);
  DS.CreateDataset;
  DS.AppendRecord([1, 'x', 'y', 'z']);
  Fonte := TDataSource.Create(nil);
  Fonte.DataSet := DS;
  Result := TDBGrid.Create(nil);
  Result.Name := 'gTeste';
  Result.DataSource := Fonte;
  Result.Columns.Clear;
  for I := 0 to 3 do
    with Result.Columns.Add do
    begin
      FieldName := DS.Fields[I].FieldName;
      Title.Caption := FieldName;
      Width := 50;
    end;
end;

var
  T: TT;
  G: TDBGrid;
  DS: TBufDataset;
  Fonte: TDataSource;
  M: TGerenciadorGrades;
  Ordem: String;
  I: Integer;
begin
  Application.Initialize;
  T := TT.Create;
  Ini := GetTempDir(False) + 'grades_smoke.ini';
  if FileExists(Ini) then DeleteFile(Ini);

  { --- regra do % --- }
  Confere(PadraoBuscaLike('abc') = 'abc%', 'sem % busca pelo comeco');
  Confere(PadraoBuscaLike('  abc ') = 'abc%', 'trim');
  Confere(PadraoBuscaLike('%abc') = '%abc', '%abc = termina com (SQL)');
  Confere(PadraoBuscaLike('%abc%') = '%abc%', '%abc% = contem');
  Confere(PadraoBuscaLike('a%c') = 'a%c', 'a%c literal');
  Confere(PadraoBuscaLike('') = '', 'vazio');

  { --- 1a execucao: padrao, auto ligado --- }
  G := NovaGrade(DS, Fonte);
  M := TGerenciadorGrades.Create(nil, Ini);
  M.OnAjustar := @T.Ajusta;
  M.Registrar(G, 'Teste', ['A']);
  Confere(not M.TemLayoutSalvo(G), 'sem layout salvo no inicio');
  M.Ajustar(G);
  Confere(G.Columns[1].Width = 100, 'auto-ajuste ligado por padrao');

  { usuario muda largura de B e ordem, oculta C }
  G.Columns[1].Width := 333;
  TDBGrid(G).OnColumnSized(G);               { evento do arrastar da borda }
  G.Columns[3].Index := 0;                   { D vai para o inicio }
  G.Columns[3].Visible := True;
  G.Columns.Items[3].Visible := False;       { oculta quem esta em 4o }
  M.SalvarTudo;

  M.Ajustar(G);                              { novo auto-ajuste (ex.: dados novos) }
  Confere((G.Columns[1].Width = 100) and (G.Columns[2].Width = 333), 'auto-ajuste mexe so nas nao manuais (A=100, B manual=333)');
  I := 0;
  Confere(True, 'ordem apos mover: ' + G.Columns[0].FieldName + G.Columns[1].FieldName + G.Columns[2].FieldName + G.Columns[3].FieldName);
  Ordem := G.Columns[0].FieldName + G.Columns[1].FieldName + G.Columns[2].FieldName + G.Columns[3].FieldName;
  M.SalvarTudo;
  M.Free; G.Free; Fonte.Free; DS.Free;

  { --- 2a execucao: tudo restaurado --- }
  Chamadas := 0;
  G := NovaGrade(DS, Fonte);
  M := TGerenciadorGrades.Create(nil, Ini);
  M.OnAjustar := @T.Ajusta;
  M.Registrar(G, 'Teste', ['A']);
  Confere(M.TemLayoutSalvo(G), 'layout salvo existe');
  M.Ajustar(G);
  Confere(G.Columns[0].FieldName + G.Columns[1].FieldName + G.Columns[2].FieldName + G.Columns[3].FieldName = Ordem, 'ordem restaurada: ' + Ordem);
  I := 0;
  Confere(G.Columns[3].Visible = False, 'visibilidade restaurada (ultima oculta)');
  for I := 0 to 3 do
    if G.Columns[I].FieldName = 'B' then
      Confere(G.Columns[I].Width = 333, 'largura manual de B restaurada e preservada apos auto-ajuste (' + IntToStr(G.Columns[I].Width) + ')');
  M.SalvarTudo;
  M.Free; G.Free; Fonte.Free; DS.Free;

  WriteLn('falhas: ', Falhas);
  Halt(Falhas);
end.
