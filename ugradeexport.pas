unit uGradeExport;

{$mode ObjFPC}{$H+}
{$codepage utf8}

{
  Exportação genérica de qualquer grade (TDBGrid / TRxDBGrid) para PDF e Excel.

  Regras:
    - usa SOMENTE as colunas visíveis, na ordem em que o usuário as deixou;
    - o texto exportado é o mesmo exibido na grade (DisplayText);
    - o PDF escolhe sozinho retrato ou paisagem conforme a largura das colunas;
    - a posição do dataset e o estado da grade são preservados.
}

interface

uses
  Classes, SysUtils, DB, DBGrids, Grids, uComprasExport;

type
  TProvedorEmpresa = procedure(out AEmpresa: TEmpresaCabecalho);

var
  { Permite trocar a origem do cabeçalho (usado nos testes, sem banco). }
  ProvedorEmpresaGrade: TProvedorEmpresa;

function ColunasDe(AGrade: TCustomDBGrid): TDBGridColumns;

{ True quando as larguras (em pixels de tela) não cabem em uma página retrato. }
function PrecisaPaisagem(const ALarguras: array of Integer): Boolean;

procedure ExportarGradePDF(AGrade: TCustomDBGrid;
  const ATitulo, ASubtitulo, AArquivo: String);
procedure ExportarGradeExcel(AGrade: TCustomDBGrid;
  const ATitulo, ASubtitulo, AArquivo: String);

implementation

uses
  Graphics, Controls, Math, BufDataset, RLReport, RLTypes, RLPDFFilter,
  fpspreadsheet, fpstypes, fpsallformats;

const
  { Largura útil (px a 96 dpi) da página A4 já descontadas as margens. }
  LARGURA_RETRATO = 710;
  LARGURA_PAISAGEM = 1035;
  { O PDF usa fonte 8 contra 9-10 da tela: o texto ocupa ~90% da largura. }
  FATOR_FONTE = 0.9;

type
  TGradeCrack = class(TCustomDBGrid);

  TColunaExp = record
    Campo: TField;
    Titulo: String;
    Largura: Integer;
    Numerica: Boolean;
  end;
  TColunasExp = array of TColunaExp;

function ColunasDe(AGrade: TCustomDBGrid): TDBGridColumns;
begin
  Result := TGradeCrack(AGrade).Columns;
end;

function PrecisaPaisagem(const ALarguras: array of Integer): Boolean;
var
  I, Total: Integer;
begin
  Total := 0;
  for I := Low(ALarguras) to High(ALarguras) do
    Inc(Total, ALarguras[I]);
  Result := Total * FATOR_FONTE > LARGURA_RETRATO;
end;

function CampoNumerico(ACampo: TField): Boolean;
begin
  Result := ACampo.DataType in [ftSmallint, ftInteger, ftLargeint, ftWord,
    ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftAutoInc];
end;

function ColunasVisiveis(AGrade: TCustomDBGrid): TColunasExp;
var
  Colunas: TDBGridColumns;
  DS: TDataSet;
  I, N: Integer;
  Campo: TField;
  Titulo: String;
begin
  Result := nil;
  if not Assigned(AGrade.DataSource) or
     not Assigned(AGrade.DataSource.DataSet) then
    raise Exception.Create('A listagem não possui dados.');
  DS := AGrade.DataSource.DataSet;
  if not DS.Active then
    raise Exception.Create('A listagem não possui dados.');
  Colunas := ColunasDe(AGrade);
  N := 0;
  SetLength(Result, Colunas.Count);
  for I := 0 to Colunas.Count - 1 do
  begin
    if not Colunas[I].Visible then Continue;
    Campo := DS.FindField(Colunas[I].FieldName);
    if Campo = nil then Continue;
    Titulo := Colunas[I].Title.Caption;
    if Trim(Titulo) = '' then Titulo := Campo.DisplayLabel;
    Result[N].Campo := Campo;
    Result[N].Titulo := Titulo;
    Result[N].Largura := Max(Colunas[I].Width, 30);
    Result[N].Numerica := CampoNumerico(Campo);
    Inc(N);
  end;
  SetLength(Result, N);
  if N = 0 then
    raise Exception.Create('Não há colunas visíveis para exportar.');
end;

{ ------------------------------------------------------------------ PDF -- }

function CriarSnapshot(ADS: TDataSet; const AColunas: TColunasExp;
  out ATotal: Integer): TBufDataset;
var
  Bmk: TBookmark;
  I: Integer;
  Texto: String;
begin
  ATotal := 0;
  Result := TBufDataset.Create(nil);
  try
    for I := 0 to High(AColunas) do
      Result.FieldDefs.Add('C' + IntToStr(I), ftString, 250);
    Result.CreateDataset;
    ADS.DisableControls;
    try
      Bmk := ADS.GetBookmark;
      try
        ADS.First;
        while not ADS.Eof do
        begin
          Result.Append;
          for I := 0 to High(AColunas) do
          begin
            Texto := AColunas[I].Campo.DisplayText;
            Result.Fields[I].AsString := Copy(Texto, 1, 250);
          end;
          Result.Post;
          Inc(ATotal);
          ADS.Next;
        end;
      finally
        if ADS.BookmarkValid(Bmk) then ADS.GotoBookmark(Bmk);
        ADS.FreeBookmark(Bmk);
      end;
    finally
      ADS.EnableControls;
    end;
    Result.First;
  except
    Result.Free;
    raise;
  end;
end;

function NovoRotulo(ARelatorio: TRLReport; APai: TWinControl;
  const ATexto: String; ALeft, ATop, ALargura, AAltura: Integer;
  ATamanho: Integer = 9; ANegrito: Boolean = False;
  AAlinhamento: TRLTextAlignment = taLeftJustify): TRLLabel;
begin
  Result := TRLLabel.Create(ARelatorio);
  Result.Parent := APai;
  Result.SetBounds(ALeft, ATop, ALargura, AAltura);
  Result.AutoSize := False;
  Result.Caption := ATexto;
  Result.Transparent := True;
  Result.Alignment := AAlinhamento;
  Result.Font.Name := 'Arial';
  Result.Font.Size := ATamanho;
  if ANegrito then Result.Font.Style := [fsBold];
end;

procedure ExportarGradePDF(AGrade: TCustomDBGrid;
  const ATitulo, ASubtitulo, AArquivo: String);
var
  Colunas: TColunasExp;
  Empresa: TEmpresaCabecalho;
  Dados: TBufDataset;
  Fonte: TDataSource;
  Relatorio: TRLReport;
  Filtro: TRLPDFFilter;
  Cabecalho, BandaCols, Detalhes, Totais, Rodape: TRLBand;
  Campo: TRLDBText;
  Pagina: TRLSystemInfo;
  Imagem: TRLImage;
  Paisagem: Boolean;
  Alin: TRLTextAlignment;
  Util, I, X, SomaGrade, Total, Tam, Esq, Larg, Linha: Integer;
  Posicoes, Larguras, LargGrade: array of Integer;
begin
  Colunas := ColunasVisiveis(AGrade);
  SetLength(LargGrade, Length(Colunas));
  SomaGrade := 0;
  for I := 0 to High(Colunas) do
  begin
    LargGrade[I] := Colunas[I].Largura;
    Inc(SomaGrade, Colunas[I].Largura);
  end;
  Paisagem := PrecisaPaisagem(LargGrade);
  if Paisagem then Util := LARGURA_PAISAGEM else Util := LARGURA_RETRATO;

  { larguras proporcionais às da grade, preenchendo toda a área útil }
  SetLength(Posicoes, Length(Colunas));
  SetLength(Larguras, Length(Colunas));
  X := 0;
  for I := 0 to High(Colunas) do
  begin
    if I = High(Colunas) then
      Larguras[I] := Util - X
    else
      Larguras[I] := Round(LargGrade[I] * Util / SomaGrade);
    Posicoes[I] := X;
    Inc(X, Larguras[I]);
  end;
  if SomaGrade * FATOR_FONTE > Util * 1.15 then Tam := 7 else Tam := 8;

  Empresa := Default(TEmpresaCabecalho);
  ProvedorEmpresaGrade(Empresa);
  Dados := nil;
  Fonte := nil;
  Relatorio := nil;
  Filtro := nil;
  try
    Dados := CriarSnapshot(AGrade.DataSource.DataSet, Colunas, Total);
    Fonte := TDataSource.Create(nil);
    Fonte.DataSet := Dados;
    Relatorio := TRLReport.Create(nil);
    Filtro := TRLPDFFilter.Create(nil);
    Relatorio.PageSetup.PaperSize := fpA4;
    if Paisagem then
      Relatorio.PageSetup.Orientation := poLandscape
    else
      Relatorio.PageSetup.Orientation := poPortrait;
    Relatorio.DataSource := Fonte;
    Relatorio.Font.Name := 'Arial';
    Relatorio.Font.Size := Tam;
    Relatorio.Title := ATitulo;

    Cabecalho := TRLBand.Create(Relatorio);
    Cabecalho.Parent := Relatorio;
    Cabecalho.BandType := btHeader;
    Cabecalho.Height := 150;
    Esq := 0;
    if Assigned(Empresa.Logo) and (Empresa.Logo.Size > 0) then
    begin
      Imagem := TRLImage.Create(Relatorio);
      Imagem.Parent := Cabecalho;
      Imagem.SetBounds(0, 4, 68, 68);
      Empresa.Logo.Position := 0;
      Imagem.Picture.LoadFromStream(Empresa.Logo);
      Imagem.Scaled := True;
      Imagem.Center := True;
      Esq := 78;
    end;
    Larg := Util - Esq;
    NovoRotulo(Relatorio, Cabecalho, Empresa.Razao, Esq, 2, Larg, 24, 12, True);
    NovoRotulo(Relatorio, Cabecalho, Empresa.Fantasia, Esq, 26, Larg, 19);
    NovoRotulo(Relatorio, Cabecalho,
      'CNPJ: ' + Empresa.CNPJ + '    IE: ' + Empresa.IE, Esq, 44, Larg, 19);
    NovoRotulo(Relatorio, Cabecalho,
      Empresa.Endereco + ' - ' + Empresa.Cidade + ' / ' + Empresa.Estado,
      Esq, 62, Larg, 19);
    NovoRotulo(Relatorio, Cabecalho, UpperCase(ATitulo), 0, 86, Util, 26, 15,
      True, taCenter);
    Linha := 114;
    if Trim(ASubtitulo) <> '' then
    begin
      NovoRotulo(Relatorio, Cabecalho, ASubtitulo, 0, Linha, Util, 18);
      Inc(Linha, 18);
    end;
    NovoRotulo(Relatorio, Cabecalho, 'Gerado em: ' +
      FormatDateTime('dd/mm/yyyy hh:nn', Now), 0, Linha, Util, 18);
    Cabecalho.Height := Linha + 24;

    BandaCols := TRLBand.Create(Relatorio);
    BandaCols.Parent := Relatorio;
    BandaCols.BandType := btColumnHeader;
    BandaCols.Height := 24;
    BandaCols.Color := $00EAEAEA;
    BandaCols.ParentColor := False;
    for I := 0 to High(Colunas) do
    begin
      if Colunas[I].Numerica then Alin := taRightJustify
      else Alin := taLeftJustify;
      NovoRotulo(Relatorio, BandaCols, Colunas[I].Titulo, Posicoes[I] + 2, 4,
        Larguras[I] - 6, 18, Tam, True, Alin);
    end;

    Detalhes := TRLBand.Create(Relatorio);
    Detalhes.Parent := Relatorio;
    Detalhes.BandType := btDetail;
    Detalhes.Height := 21;
    Detalhes.Borders.Sides := sdCustom;
    Detalhes.Borders.DrawBottom := True;
    Detalhes.Borders.Color := $00D9D9D9;
    for I := 0 to High(Colunas) do
    begin
      Campo := TRLDBText.Create(Relatorio);
      Campo.Parent := Detalhes;
      Campo.SetBounds(Posicoes[I] + 2, 3, Larguras[I] - 6, 16);
      Campo.AutoSize := False;
      Campo.DataSource := Fonte;
      Campo.DataField := 'C' + IntToStr(I);
      Campo.Font.Name := 'Arial';
      Campo.Font.Size := Tam;
      if Colunas[I].Numerica then Campo.Alignment := taRightJustify;
    end;

    Totais := TRLBand.Create(Relatorio);
    Totais.Parent := Relatorio;
    Totais.BandType := btSummary;
    Totais.Height := 27;
    NovoRotulo(Relatorio, Totais, 'Total de registros: ' + IntToStr(Total),
      0, 6, Util, 18, 9, True);

    Rodape := TRLBand.Create(Relatorio);
    Rodape.Parent := Relatorio;
    Rodape.BandType := btFooter;
    Rodape.Height := 24;
    Pagina := TRLSystemInfo.Create(Relatorio);
    Pagina.Parent := Rodape;
    Pagina.SetBounds(Util - 110, 2, 110, 18);
    Pagina.AutoSize := False;
    Pagina.Info := itPageNumber;
    Pagina.Text := 'Página ';
    Pagina.Alignment := taRightJustify;

    Filtro.FileName := AArquivo;
    Filtro.ShowProgress := False;
    if not Relatorio.Prepare then
      raise Exception.Create('Não foi possível preparar o relatório.');
    Filtro.FilterPages(Relatorio.Pages);
  finally
    Filtro.Free;
    Relatorio.Free;
    Fonte.Free;
    Dados.Free;
    Empresa.Logo.Free;
  end;
end;

{ ---------------------------------------------------------------- Excel -- }

procedure FormatoNumero(ACampo: TField; out AFormato: TsNumberFormat;
  out ACasas: Integer);
var
  Fmt: String;
  P: Integer;
begin
  AFormato := nfGeneral;
  ACasas := 0;
  if ACampo.DataType in [ftSmallint, ftInteger, ftLargeint, ftWord,
    ftAutoInc] then
  begin
    AFormato := nfFixed;
    Exit;
  end;
  if ACampo.DataType = ftCurrency then
  begin
    AFormato := nfFixed;
    ACasas := 2;
  end;
  if ACampo is TNumericField then
  begin
    Fmt := TNumericField(ACampo).DisplayFormat;
    P := Pos('.', Fmt);
    if P = 0 then P := Pos(',', Fmt);
    if P > 0 then
    begin
      Fmt := Copy(Fmt, P + 1, MaxInt);
      { "0.######" = casas opcionais: deixa o Excel decidir }
      if Pos('#', Fmt) > 0 then
      begin
        AFormato := nfGeneral;
        ACasas := 0;
      end
      else
      begin
        AFormato := nfFixed;
        ACasas := Length(Fmt);
      end;
    end;
  end;
end;

procedure ExportarGradeExcel(AGrade: TCustomDBGrid;
  const ATitulo, ASubtitulo, AArquivo: String);
var
  Colunas: TColunasExp;
  Empresa: TEmpresaCabecalho;
  Livro: TsWorkbook;
  Planilha: TsWorksheet;
  Foto: TPicture;
  DS: TDataSet;
  Bmk: TBookmark;
  I, Linha, Casas, Dados: Integer;
  Fmt: TsNumberFormat;
  Larg: Double;
  Escala: Double;
begin
  Colunas := ColunasVisiveis(AGrade);
  DS := AGrade.DataSource.DataSet;
  Empresa := Default(TEmpresaCabecalho);
  ProvedorEmpresaGrade(Empresa);
  Livro := nil;
  try
    Livro := TsWorkbook.Create;
    Planilha := Livro.AddWorksheet(Copy(StringReplace(ATitulo, '/', '-',
      [rfReplaceAll]), 1, 31));
    Planilha.WriteText(0, 1, Empresa.Razao);
    Planilha.WriteFontStyle(0, 1, [fssBold]);
    Planilha.WriteText(1, 1, Empresa.Fantasia);
    Planilha.WriteText(2, 1, 'CNPJ: ' + Empresa.CNPJ + '    IE: ' + Empresa.IE);
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
          Planilha.WriteImage(0, 0, Empresa.Logo, 0, 0, Escala, Escala);
        end;
      finally
        Foto.Free;
      end;
    end;
    Planilha.WriteText(6, 0, UpperCase(ATitulo));
    Planilha.WriteFontStyle(6, 0, [fssBold]);
    Linha := 7;
    if Trim(ASubtitulo) <> '' then
    begin
      Planilha.WriteText(Linha, 0, ASubtitulo);
      Inc(Linha);
    end;
    Planilha.WriteText(Linha, 0, 'Gerado em: ' +
      FormatDateTime('dd/mm/yyyy hh:nn', Now));
    Inc(Linha, 2);

    for I := 0 to High(Colunas) do
    begin
      Planilha.WriteText(Linha, I, Colunas[I].Titulo);
      Planilha.WriteFontStyle(Linha, I, [fssBold]);
      Planilha.WriteBackgroundColor(Linha, I, scSilver);
      { largura em caracteres aproximada a partir da largura da grade }
      Larg := Max(10, Min(60, Colunas[I].Largura / 7));
      Planilha.WriteColWidth(I, Larg, suChars);
    end;
    Planilha.Options := Planilha.Options + [soHasFrozenPanes];
    Planilha.TopPaneHeight := Linha + 1;
    Inc(Linha);
    Dados := 0;

    DS.DisableControls;
    try
      Bmk := DS.GetBookmark;
      try
        DS.First;
        while not DS.Eof do
        begin
          for I := 0 to High(Colunas) do
          begin
            if Colunas[I].Campo.IsNull then Continue;
            case Colunas[I].Campo.DataType of
              ftSmallint, ftInteger, ftLargeint, ftWord, ftAutoInc:
                Planilha.WriteNumber(Linha, I, Colunas[I].Campo.AsLargeInt);
              ftFloat, ftCurrency, ftBCD, ftFMTBcd:
                begin
                  FormatoNumero(Colunas[I].Campo, Fmt, Casas);
                  if Fmt = nfFixed then
                    Planilha.WriteNumber(Linha, I,
                      Colunas[I].Campo.AsFloat, nfFixed, Casas)
                  else
                    Planilha.WriteNumber(Linha, I, Colunas[I].Campo.AsFloat);
                end;
              ftDate:
                Planilha.WriteDateTime(Linha, I,
                  Colunas[I].Campo.AsDateTime, nfShortDate);
              ftDateTime, ftTimeStamp:
                Planilha.WriteDateTime(Linha, I,
                  Colunas[I].Campo.AsDateTime, nfShortDateTime);
            else
              Planilha.WriteText(Linha, I, Colunas[I].Campo.DisplayText);
            end;
          end;
          Inc(Linha);
          Inc(Dados);
          DS.Next;
        end;
      finally
        if DS.BookmarkValid(Bmk) then DS.GotoBookmark(Bmk);
        DS.FreeBookmark(Bmk);
      end;
    finally
      DS.EnableControls;
    end;
    Inc(Linha);
    Planilha.WriteText(Linha, 0, 'Total de registros: ' + IntToStr(Dados));
    Planilha.WriteFontStyle(Linha, 0, [fssBold]);
    Livro.WriteToFile(AArquivo, sfOOXML, True);
  finally
    Livro.Free;
    Empresa.Logo.Free;
  end;
end;

initialization
  ProvedorEmpresaGrade := @BuscarEmpresa;

end.
