unit uComprasExport;

{$mode ObjFPC}{$H+}
{$codepage utf8}

interface

uses
  Classes, SysUtils, DB;

procedure ExportarComprasPDF(ADados: TDataSet;
  const AArquivo, APeriodo, ALogo: String);
procedure ExportarComprasExcel(ADados: TDataSet;
  const AArquivo, APeriodo: String);

implementation

uses
  Graphics, Controls, Math, BufDataset, ZDataset, uDm, RLReport, RLTypes,
  RLPDFFilter, fpspreadsheet, fpstypes, fpsallformats;

type
  TEmpresaCabecalho = record
    Razao: String;
    Fantasia: String;
    CNPJ: String;
    IE: String;
    Endereco: String;
    Cidade: String;
    Estado: String;
    Logo: TMemoryStream;
  end;

procedure BuscarEmpresa(out AEmpresa: TEmpresaCabecalho);
var
  Consulta: TZQuery;
begin
  AEmpresa := Default(TEmpresaCabecalho);
  if not Assigned(uDm.data) or not uDm.data.zCon.Connected then
    raise Exception.Create('O banco de dados não está conectado.');

  Consulta := TZQuery.Create(nil);
  try
    Consulta.Connection := uDm.data.zCon;
    Consulta.SQL.Text :=
      'SELECT E.EMP_RAZAO_SOCIAL, E.EMP_FANTASIA, E.EMP_CNPJ, ' +
      'E.EMP_IE, E.EMP_ENDERECO, E.EMP_NUMERO, E.EMP_COMPLEMENTO, ' +
      'C.CID_NOME, S.EST_NOME, S.EST_SIGLA, E.EMP_LOGO ' +
      'FROM TB_EMPRESA E ' +
      'LEFT JOIN TB_CIDADE C ON C.CID_ID = E.EMP_CIDADE ' +
      'LEFT JOIN TB_ESTADO S ON S.EST_ID = C.CID_ESTADO ' +
      'WHERE E.EMP_ID = 1';
    Consulta.Open;
    if Consulta.IsEmpty then
      raise Exception.Create('A empresa de código 1 não foi encontrada.');

    AEmpresa.Razao := Consulta.FieldByName('EMP_RAZAO_SOCIAL').AsString;
    AEmpresa.Fantasia := Consulta.FieldByName('EMP_FANTASIA').AsString;
    AEmpresa.CNPJ := Consulta.FieldByName('EMP_CNPJ').AsString;
    AEmpresa.IE := Consulta.FieldByName('EMP_IE').AsString;
    AEmpresa.Endereco := Consulta.FieldByName('EMP_ENDERECO').AsString;
    if Trim(Consulta.FieldByName('EMP_NUMERO').AsString) <> '' then
      AEmpresa.Endereco := AEmpresa.Endereco + ', ' +
        Consulta.FieldByName('EMP_NUMERO').AsString;
    if Trim(Consulta.FieldByName('EMP_COMPLEMENTO').AsString) <> '' then
      AEmpresa.Endereco := AEmpresa.Endereco + ' - ' +
        Consulta.FieldByName('EMP_COMPLEMENTO').AsString;
    AEmpresa.Cidade := Consulta.FieldByName('CID_NOME').AsString;
    AEmpresa.Estado := Consulta.FieldByName('EST_NOME').AsString;
    if Trim(Consulta.FieldByName('EST_SIGLA').AsString) <> '' then
      if Trim(AEmpresa.Estado) = '' then
        AEmpresa.Estado := Consulta.FieldByName('EST_SIGLA').AsString
      else
        AEmpresa.Estado := AEmpresa.Estado + ' (' +
          Consulta.FieldByName('EST_SIGLA').AsString + ')';
    if not Consulta.FieldByName('EMP_LOGO').IsNull then
    begin
      AEmpresa.Logo := TMemoryStream.Create;
      try
        TBlobField(Consulta.FieldByName('EMP_LOGO')).SaveToStream(
          AEmpresa.Logo);
        AEmpresa.Logo.Position := 0;
      except
        FreeAndNil(AEmpresa.Logo);
        raise;
      end;
    end;
  finally
    Consulta.Free;
  end;
end;

procedure PreservarPosicao(ADados: TDataSet; out ABookmark: TBookmark);
begin
  ADados.DisableControls;
  try
    ABookmark := ADados.GetBookmark;
  except
    ADados.EnableControls;
    raise;
  end;
end;

procedure RestaurarPosicao(ADados: TDataSet; ABookmark: TBookmark);
begin
  try
    if ADados.BookmarkValid(ABookmark) then ADados.GotoBookmark(ABookmark);
  finally
    ADados.FreeBookmark(ABookmark);
    ADados.EnableControls;
  end;
end;

function CriarDadosExportacao(ADados: TDataSet): TBufDataset;
var
  Bmk: TBookmark;
begin
  Result := TBufDataset.Create(nil);
  try
    Result.FieldDefs.Add('PRD_ID', ftInteger);
    Result.FieldDefs.Add('PRD_DESCRICAO', ftString,
      Max(ADados.FieldByName('PRD_DESCRICAO').Size, 1));
    Result.FieldDefs.Add('PRD_UN_VENDA', ftString, 20);
    Result.FieldDefs.Add('COMPRAR', ftFloat);
    Result.CreateDataset;
    PreservarPosicao(ADados, Bmk);
    try
      ADados.First;
      while not ADados.Eof do
      begin
        if ADados.FieldByName('COMPRAR').AsFloat > 0 then
        begin
          Result.Append;
          Result.FieldByName('PRD_ID').AsInteger :=
            ADados.FieldByName('PRD_ID').AsInteger;
          Result.FieldByName('PRD_DESCRICAO').AsString :=
            ADados.FieldByName('PRD_DESCRICAO').AsString;
          Result.FieldByName('PRD_UN_VENDA').AsString :=
            ADados.FieldByName('PRD_UN_VENDA').AsString;
          Result.FieldByName('COMPRAR').AsFloat :=
            ADados.FieldByName('COMPRAR').AsFloat;
          Result.Post;
        end;
        ADados.Next;
      end;
    finally
      RestaurarPosicao(ADados, Bmk);
    end;
    Result.First;
  except
    Result.Free;
    raise;
  end;
end;

procedure ConfigurarRotulo(ARotulo: TRLLabel; AParent: TWinControl;
  const ATexto: String; ALeft, ATop, AWidth, AHeight: Integer;
  ANegrito: Boolean = False);
begin
  ARotulo.Parent := AParent;
  ARotulo.SetBounds(ALeft, ATop, AWidth, AHeight);
  ARotulo.AutoSize := False;
  ARotulo.Caption := ATexto;
  ARotulo.Transparent := True;
  ARotulo.Font.Name := 'Arial';
  ARotulo.Font.Size := 9;
  if ANegrito then ARotulo.Font.Style := [fsBold];
end;

procedure ExportarComprasPDF(ADados: TDataSet;
  const AArquivo, APeriodo, ALogo: String);
const
  Titulos: array[0..3] of String =
    ('ID', 'Descrição', 'Unidade', 'Qtd de Compra');
  Campos: array[0..3] of String =
    ('PRD_ID', 'PRD_DESCRICAO', 'PRD_UN_VENDA', 'COMPRAR');
  Posicoes: array[0..3] of Integer = (0, 52, 430, 530);
  Larguras: array[0..3] of Integer = (48, 370, 95, 150);
var
  Empresa: TEmpresaCabecalho;
  DadosPDF: TBufDataset;
  FontePDF: TDataSource;
  Relatorio: TRLReport;
  Filtro: TRLPDFFilter;
  Cabecalho, Colunas, Detalhes, Totais, Rodape: TRLBand;
  Rotulo: TRLLabel;
  Campo: TRLDBText;
  Soma: TRLDBResult;
  NumeroPagina: TRLSystemInfo;
  Imagem: TRLImage;
  I: Integer;
begin
  BuscarEmpresa(Empresa);
  DadosPDF := nil;
  FontePDF := nil;
  Relatorio := nil;
  Filtro := nil;
  try
    DadosPDF := CriarDadosExportacao(ADados);
    FontePDF := TDataSource.Create(nil);
    FontePDF.DataSet := DadosPDF;
    Relatorio := TRLReport.Create(nil);
    Filtro := TRLPDFFilter.Create(nil);
    Relatorio.Width := 794;
    Relatorio.Height := 1123;
    Relatorio.PageSetup.PaperSize := fpA4;
    Relatorio.DataSource := FontePDF;
    Relatorio.Font.Name := 'Arial';
    Relatorio.Font.Size := 9;
    Relatorio.Title := 'Pedido de compras';

    Cabecalho := TRLBand.Create(Relatorio);
    Cabecalho.Parent := Relatorio;
    Cabecalho.BandType := btHeader;
    Cabecalho.Height := 168;
    if Assigned(Empresa.Logo) and (Empresa.Logo.Size > 0) then
    begin
      Imagem := TRLImage.Create(Relatorio);
      Imagem.Parent := Cabecalho;
      Imagem.SetBounds(0, 4, 68, 68);
      Empresa.Logo.Position := 0;
      Imagem.Picture.LoadFromStream(Empresa.Logo);
      Imagem.Scaled := True;
      Imagem.Center := True;
    end;
    Rotulo := TRLLabel.Create(Relatorio);
    ConfigurarRotulo(Rotulo, Cabecalho, Empresa.Razao,
      78, 2, 630, 24, True);
    Rotulo.Font.Size := 12;
    Rotulo := TRLLabel.Create(Relatorio);
    ConfigurarRotulo(Rotulo, Cabecalho, Empresa.Fantasia,
      78, 26, 630, 19);
    Rotulo := TRLLabel.Create(Relatorio);
    ConfigurarRotulo(Rotulo, Cabecalho,
      'CNPJ: ' + Empresa.CNPJ + '    IE: ' + Empresa.IE,
      78, 46, 630, 19);
    Rotulo := TRLLabel.Create(Relatorio);
    ConfigurarRotulo(Rotulo, Cabecalho, Empresa.Endereco,
      78, 66, 630, 19);
    Rotulo := TRLLabel.Create(Relatorio);
    ConfigurarRotulo(Rotulo, Cabecalho,
      Empresa.Cidade + ' / ' + Empresa.Estado,
      78, 86, 630, 19);
    Rotulo := TRLLabel.Create(Relatorio);
    ConfigurarRotulo(Rotulo, Cabecalho, 'PEDIDO DE COMPRAS',
      0, 111, 710, 26, True);
    Rotulo.Font.Size := 16;
    Rotulo := TRLLabel.Create(Relatorio);
    ConfigurarRotulo(Rotulo, Cabecalho,
      'Período: ' + APeriodo + '    Gerado em: ' +
      FormatDateTime('dd/mm/yyyy hh:nn', Now), 0, 140, 710, 20);

    Colunas := TRLBand.Create(Relatorio);
    Colunas.Parent := Relatorio;
    Colunas.BandType := btColumnHeader;
    Colunas.Height := 24;
    Colunas.Color := $00EAEAEA;
    Colunas.ParentColor := False;
    for I := 0 to 3 do
    begin
      Rotulo := TRLLabel.Create(Relatorio);
      ConfigurarRotulo(Rotulo, Colunas, Titulos[I],
        Posicoes[I], 4, Larguras[I], 18, True);
    end;

    Detalhes := TRLBand.Create(Relatorio);
    Detalhes.Parent := Relatorio;
    Detalhes.BandType := btDetail;
    Detalhes.Height := 23;
    for I := 0 to 3 do
    begin
      Campo := TRLDBText.Create(Relatorio);
      Campo.Parent := Detalhes;
      Campo.SetBounds(Posicoes[I], 3, Larguras[I] - 5, 18);
      Campo.AutoSize := False;
      Campo.DataSource := FontePDF;
      Campo.DataField := Campos[I];
      Campo.Font.Name := 'Arial';
      Campo.Font.Size := 8;
      if I >= 3 then Campo.Alignment := taRightJustify;
    end;

    Totais := TRLBand.Create(Relatorio);
    Totais.Parent := Relatorio;
    Totais.BandType := btSummary;
    Totais.Height := 27;
    Rotulo := TRLLabel.Create(Relatorio);
    ConfigurarRotulo(Rotulo, Totais, 'TOTAIS', 0, 4, 90, 20, True);
    Soma := TRLDBResult.Create(Relatorio);
    Soma.Parent := Totais;
    Soma.SetBounds(Posicoes[3], 4, Larguras[3] - 5, 20);
    Soma.AutoSize := False;
    Soma.DataSource := FontePDF;
    Soma.DataField := Campos[3];
    Soma.Info := riSum;
    Soma.Alignment := taRightJustify;
    Soma.Font.Style := [fsBold];

    Rodape := TRLBand.Create(Relatorio);
    Rodape.Parent := Relatorio;
    Rodape.BandType := btFooter;
    Rodape.Height := 24;
    NumeroPagina := TRLSystemInfo.Create(Relatorio);
    NumeroPagina.Parent := Rodape;
    NumeroPagina.SetBounds(600, 2, 110, 18);
    NumeroPagina.AutoSize := False;
    NumeroPagina.Info := itPageNumber;
    NumeroPagina.Text := 'Página ';
    NumeroPagina.Alignment := taRightJustify;

    Filtro.FileName := AArquivo;
    Filtro.ShowProgress := False;
    if not Relatorio.Prepare then
      raise Exception.Create('Não foi possível preparar o relatório.');
    Filtro.FilterPages(Relatorio.Pages);
  finally
    Filtro.Free;
    Relatorio.Free;
    FontePDF.Free;
    DadosPDF.Free;
    Empresa.Logo.Free;
  end;
end;

procedure ExportarComprasExcel(ADados: TDataSet;
  const AArquivo, APeriodo: String);
const
  Titulos: array[0..3] of String =
    ('ID', 'Descrição', 'Unidade', 'Qtd de Compra');
  Campos: array[0..3] of String =
    ('PRD_ID', 'PRD_DESCRICAO', 'PRD_UN_VENDA', 'COMPRAR');
var
  Empresa: TEmpresaCabecalho;
  DadosExportacao: TBufDataset;
  Livro: TsWorkbook;
  Planilha: TsWorksheet;
  Foto: TPicture;
  Bmk: TBookmark;
  Linha, I: Integer;
  TotalComprar, Escala: Double;
begin
  BuscarEmpresa(Empresa);
  Livro := nil;
  DadosExportacao := nil;
  try
    DadosExportacao := CriarDadosExportacao(ADados);
    Livro := TsWorkbook.Create;
    Planilha := Livro.AddWorksheet('Pedido de compras');
    Planilha.WriteText(0, 1, Empresa.Razao);
    Planilha.WriteFontStyle(0, 1, [fssBold]);
    Planilha.WriteText(1, 1, Empresa.Fantasia);
    Planilha.WriteText(2, 1,
      'CNPJ: ' + Empresa.CNPJ + '    IE: ' + Empresa.IE);
    Planilha.WriteText(3, 1, Empresa.Endereco);
    Planilha.WriteText(4, 1, Empresa.Cidade + ' / ' + Empresa.Estado);
    if Assigned(Empresa.Logo) and (Empresa.Logo.Size > 0) then
    begin
      Foto := TPicture.Create;
      try
        Empresa.Logo.Position := 0;
        Foto.LoadFromStream(Empresa.Logo);
        if (Foto.Width > 0) and (Foto.Height > 0) then
        begin
          Escala := Min(72 / Foto.Width, 72 / Foto.Height);
          Empresa.Logo.Position := 0;
          Planilha.WriteImage(0, 0, Empresa.Logo, 0, 0,
            Escala, Escala);
        end;
      finally
        Foto.Free;
      end;
    end;
    Planilha.WriteText(6, 0, 'PEDIDO DE COMPRAS');
    Planilha.WriteFontStyle(6, 0, [fssBold]);
    Planilha.WriteText(7, 0, 'Período: ' + APeriodo);
    Planilha.WriteText(8, 0, 'Gerado em: ' +
      FormatDateTime('dd/mm/yyyy hh:nn', Now));
    for I := 0 to 3 do
    begin
      Planilha.WriteText(10, I, Titulos[I]);
      Planilha.WriteFontStyle(10, I, [fssBold]);
      Planilha.WriteBackgroundColor(10, I, scSilver);
    end;
    Planilha.WriteColWidth(0, 12, suChars);
    Planilha.WriteColWidth(1, 48, suChars);
    Planilha.WriteColWidth(2, 12, suChars);
    Planilha.WriteColWidth(3, 16, suChars);

    Linha := 11;
    TotalComprar := 0;
    PreservarPosicao(DadosExportacao, Bmk);
    try
      DadosExportacao.First;
      while not DadosExportacao.Eof do
      begin
        for I := 0 to 3 do
        begin
          if I = 0 then
            Planilha.WriteNumber(Linha, I,
              DadosExportacao.FieldByName(Campos[I]).AsInteger)
          else if I = 1 then
            Planilha.WriteText(Linha, I,
              DadosExportacao.FieldByName(Campos[I]).AsString)
          else if I = 2 then
            Planilha.WriteText(Linha, I,
              DadosExportacao.FieldByName(Campos[I]).AsString)
          else
            Planilha.WriteNumber(Linha, I,
              DadosExportacao.FieldByName(Campos[I]).AsFloat, nfFixed, 2);
        end;
        TotalComprar := TotalComprar +
          DadosExportacao.FieldByName('COMPRAR').AsFloat;
        Inc(Linha);
        DadosExportacao.Next;
      end;
    finally
      RestaurarPosicao(DadosExportacao, Bmk);
    end;
    Planilha.WriteText(Linha, 1, 'TOTAIS');
    Planilha.WriteFontStyle(Linha, 1, [fssBold]);
    Planilha.WriteNumber(Linha, 3, TotalComprar, nfFixed, 2);
    Planilha.WriteFontStyle(Linha, 3, [fssBold]);
    Livro.WriteToFile(AArquivo, sfOOXML, True);
  finally
    Livro.Free;
    DadosExportacao.Free;
    Empresa.Logo.Free;
  end;
end;

end.
