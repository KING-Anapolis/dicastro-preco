program filter_checkbox_smoke;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, SysUtils, DateUtils, DB, ZDataset, uVar, uDm,
  uFrmMain;

var
  Formulario: Tfrm_p;
  UltimaVenda: TZQuery;
  DataVenda: TDateTime;
  Modo, Contagem, ContagemPositivos: Integer;
  EncontrouZero: Boolean;
  Saida: TextFile;
begin
  Application.Initialize;
  CarregaVariaveis;
  data := Tdata.Create(nil);
  try
    if not data.ConectaDB then Halt(2);
    UltimaVenda := TZQuery.Create(nil);
    try
      UltimaVenda.Connection := data.zCon;
      UltimaVenda.SQL.Text :=
        'SELECT MAX(PEV_DT_FATURAMENTO) AS ULTIMA ' +
        'FROM TB_PEDIDO_VENDA WHERE PEV_STATUS = ''F''';
      UltimaVenda.Open;
      if UltimaVenda.FieldByName('ULTIMA').IsNull then
        DataVenda := Date
      else
        DataVenda := UltimaVenda.FieldByName('ULTIMA').AsDateTime;
    finally
      UltimaVenda.Free;
    end;
    Formulario := Tfrm_p.Create(nil);
    try
      AssignFile(Saida,
        ExtractFilePath(ParamStr(0)) + 'filter_checkbox_smoke.txt');
      Rewrite(Saida);
      try
        for Modo := 0 to 1 do
        begin
          with Formulario.qryProdutosComprar do
          begin
            Close;
            ParamByName('DT_INICIAL').AsDate := StartOfTheMonth(DataVenda);
            ParamByName('DT_FINAL').AsDate := EndOfTheMonth(DataVenda);
            ParamByName('DESC').DataType := ftString;
            ParamByName('DESC').Clear;
            ParamByName('FOR').DataType := ftInteger;
            ParamByName('FOR').Clear;
            ParamByName('GRU').DataType := ftInteger;
            ParamByName('GRU').Clear;
            ParamByName('MAR').DataType := ftInteger;
            ParamByName('MAR').Clear;
            ParamByName('SUBG').DataType := ftInteger;
            ParamByName('SUBG').Clear;
            ParamByName('SET').DataType := ftInteger;
            ParamByName('SET').Clear;
            ParamByName('PRODUTOS_ZERO').AsInteger := Modo;
            Open;
            Contagem := 0;
            ContagemPositivos := 0;
            EncontrouZero := False;
            while not Eof do
            begin
              if (Modo = 0) and (FieldByName('COMPRAR').AsFloat <= 0) then
                raise Exception.Create('Produto zero no modo normal.');
              if FieldByName('COMPRAR').AsFloat = 0 then
                EncontrouZero := True
              else
                Inc(ContagemPositivos);
              Inc(Contagem);
              Next;
            end;
            if (Modo = 1) and not EncontrouZero then
              raise Exception.Create('Nenhum produto zero no modo listar todos.');
            if (Modo = 1) and (Contagem <= ContagemPositivos) then
              raise Exception.Create('O modo listar todos não incluiu produtos positivos.');
            WriteLn(Saida, 'modo=', Modo, ' registros=', Contagem);
          end;
        end;
      finally
        CloseFile(Saida);
      end;
    finally
      Formulario.Free;
    end;
  finally
    data.Free;
  end;
end.
