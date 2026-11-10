program export_smoke;

{$mode objfpc}{$H+}
{$codepage utf8}

uses
  Interfaces, Forms, SysUtils, DB, BufDataset, uVar, uDm,
  uComprasExport;

var
  Dados: TBufDataset;
  Destino: String;
begin
  Application.Initialize;
  CarregaVariaveis;
  data := Tdata.Create(nil);
  try
    if not data.ConectaDB then Halt(2);
    Dados := TBufDataset.Create(nil);
    try
      Dados.FieldDefs.Add('PRD_ID', ftInteger);
      Dados.FieldDefs.Add('PRD_DESCRICAO', ftString, 120);
      Dados.FieldDefs.Add('PRD_UN_VENDA', ftString, 20);
      Dados.FieldDefs.Add('VENDIDO', ftFloat);
      Dados.FieldDefs.Add('ESTOQUE', ftFloat);
      Dados.FieldDefs.Add('SUGERIDO', ftFloat);
      Dados.FieldDefs.Add('COMPRAR', ftFloat);
      Dados.CreateDataset;
      Destino := GetTempDir(False);

      Dados.AppendRecord([101, 'Café especial', 'UN', 100.5, 60, 40.5, 40.5]);
      Dados.Edit;
      Dados.FieldByName('COMPRAR').AsFloat := 55.25;
      Dados.Post;
      Dados.First;
      ExportarComprasPDF(Dados, Destino + 'compras_positivas.pdf',
        '01/10/2026 a 14/10/2026', '');
      ExportarComprasExcel(Dados, Destino + 'compras_positivas.xlsx',
        '01/10/2026 a 14/10/2026');
      if (Dados.FieldByName('PRD_ID').AsInteger <> 101) or
         (Dados.FieldByName('COMPRAR').AsFloat <> 55.25) then
        raise Exception.Create('A edição ou posição do dataset não foi preservada.');

      Dados.Delete;
      Dados.AppendRecord([102, 'Açúcar cristal', 'KG', 100, 100, 0, 0]);
      Dados.First;
      ExportarComprasPDF(Dados, Destino + 'compras_zero.pdf',
        '01/10/2026 a 14/10/2026', '');
      ExportarComprasExcel(Dados, Destino + 'compras_zero.xlsx',
        '01/10/2026 a 14/10/2026');
      if (Dados.FieldByName('PRD_ID').AsInteger <> 102) or
         (Dados.FieldByName('COMPRAR').AsFloat <> 0) then
        raise Exception.Create('A visualização ou posição foi alterada.');
    finally
      Dados.Free;
    end;
  finally
    data.Free;
  end;
end.
