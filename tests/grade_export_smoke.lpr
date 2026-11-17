program grade_export_smoke;

{$mode objfpc}{$H+}
{$codepage utf8}

{ Gera PDF (retrato e paisagem) e XLSX a partir de uma grade, sem banco. }

uses
  Interfaces, Forms, SysUtils, Classes, DB, DBGrids, BufDataset,
  uComprasExport, uGradeExport;

procedure EmpresaFalsa(out E: TEmpresaCabecalho);
begin
  E := Default(TEmpresaCabecalho);
  E.Razao := 'EMPRESA TESTE LTDA';
  E.Fantasia := 'Teste';
  E.CNPJ := '00.000.000/0001-00';
  E.IE := '123';
  E.Endereco := 'Rua A, 10';
  E.Cidade := 'Goiania';
  E.Estado := 'Goias (GO)';
end;

function NovaGrade(AColunas: Integer; ALargura: Integer;
  out DS: TBufDataset; out Fonte: TDataSource): TDBGrid;
var
  I: Integer;
  C: TColumn;
begin
  DS := TBufDataset.Create(nil);
  for I := 0 to AColunas - 1 do
    if I = 0 then DS.FieldDefs.Add('ID', ftInteger)
    else if I = 1 then DS.FieldDefs.Add('DESCR', ftString, 60)
    else if I mod 2 = 0 then DS.FieldDefs.Add('F' + IntToStr(I), ftFloat)
    else DS.FieldDefs.Add('T' + IntToStr(I), ftString, 30);
  DS.CreateDataset;
  for I := 1 to 60 do
  begin
    DS.Append;
    DS.Fields[0].AsInteger := I;
    DS.Fields[1].AsString := 'Produto de teste número ' + IntToStr(I) + ' açúcar';
    DS.Post;
  end;
  DS.First;
  Fonte := TDataSource.Create(nil);
  Fonte.DataSet := DS;
  Result := TDBGrid.Create(nil);
  Result.DataSource := Fonte;
  Result.Columns.Clear;
  for I := 0 to AColunas - 1 do
  begin
    C := Result.Columns.Add;
    C.FieldName := DS.Fields[I].FieldName;
    C.Title.Caption := 'Col ' + IntToStr(I);
    C.Width := ALargura;
  end;
end;

procedure Gera(const Nome: String; ACols, ALarg: Integer);
var
  DS: TBufDataset;
  Fonte: TDataSource;
  G: TDBGrid;
  Dest: String;
begin
  G := NovaGrade(ACols, ALarg, DS, Fonte);
  try
    Dest := GetTempDir(False);
    ExportarGradePDF(G, 'Listagem ' + Nome, 'Filtro: teste', Dest + Nome + '.pdf');
    ExportarGradeExcel(G, 'Listagem ' + Nome, 'Filtro: teste', Dest + Nome + '.xlsx');
    if DS.FieldByName('ID').AsInteger <> 1 then
      raise Exception.Create('posição do dataset alterada');
    WriteLn(Nome, ': ok  paisagem=', PrecisaPaisagem([ALarg * ACols]));
  finally
    G.Free; Fonte.Free; DS.Free;
  end;
end;

begin
  Application.Initialize;
  ProvedorEmpresaGrade := @EmpresaFalsa;
  Gera('grade_retrato', 4, 120);
  Gera('grade_paisagem', 10, 120);
end.
