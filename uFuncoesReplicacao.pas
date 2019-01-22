unit uFuncoesReplicacao;

interface

uses Windows, StdCtrls, Forms, Controls, DB, Messages, uib, Dialogs, ComCtrls, Classes, SysUtils, VirtualTrees;

type
  PAdicInfoTree = ^TAdicInfoTree;
  TAdicInfoTree = record
    FTabela     : string;
    FNewTAbela  : string;
    FCampo      : string;
    FNewCampo   : string;
    FPk         : boolean;
    FSelected   : boolean;
    FImageIndex : integer;
    FBlob       : boolean;
    FTriggerName   : String;
    FCondicaoExtra : String;
  end;

  Banco = class
    class function  ExisteTable(ADB : TuibDataBase; const ATableName: string): Boolean;
    class function  ExisteTrigger(ADB : TuibDataBase; const ATriggerName: string): Boolean;
    class function  ExisteGenerator(ADB : TuibDataBase; const AGenName : string): Boolean;
    class function ExisteField(ADB: TuibDataBase; const ATableName,
      AFieldName: string): Boolean;

    class function  ExisteUser(AHost, AUser, AVendorLib, ASYSDBAPass : String) : boolean;
    class procedure AdicionaUser(AHost, AUser, APass, AVendorLib, ASYSDBAPass : string);
    class procedure ModificaUserPass(AHost, AUser, APass, AVendorLib, ASYSDBAPass : string);
    class procedure RemoveUser(AHost, AUser, AVendorLib, ASYSDBAPass : String);

    class procedure CriaConfiguracaoOrigem(const AUserReplicador : string);
    class procedure CriaConfiguracaoDestino(const AUserReplicador : string);
//    class procedure CriaTriggers(const AUserReplicador : string);
    class procedure CriaTriggers2(const AUserReplicador: string; ANode : PVirtualNode);
    class procedure ModificaTriggersDestino(const AUserReplicador : string);
    class procedure RemoveTabelasConfiguracao(ADB : TuibDataBase);
    class procedure RemoveTriggers;
    class procedure RemoveTriggersDaTabela(ATabela : String);
    class procedure RecompilaTrigger(const AName, ASource : string);
    class procedure SetGrants(ADB : TuibDataBase; const ATableName,AUserReplicacao : string);

    class procedure ExecSQL(ADB : TUIBDataBase; const ASQL : String);
  private


  end;
  Arvore = class
    class procedure MontaArvore;
    class procedure AtualizaBanco(const AUserReplicador : string; ANode : PVirtualNode);
  end;


const
  cAppVersion = '1.0.12';

function ExtractHost(ADBPath: string): string;

implementation



uses uPrincipal, uibLib, StrUtils;

{ Banco }

function ExtractHost(ADBPath: string): string;
var
  lPos : integer;
begin
  Result := '';
  lPos := Pos(':',ADBPath);
  if lPos > 0 then
  begin
    Result := Copy(ADBPath,0,lPos-1);
    lPos := Pos('/',Result);
    if lPos > 0 then
    begin
      Result := Copy(Result,0,lPos-1);
    end;
  end;


  if Result='' then
  begin
    ShowMessage('Não foi possível criar os usuários.');
  end;


end;


class procedure Banco.AdicionaUser(AHost, AUser, APass, AVendorLib,
  ASYSDBAPass: string);
type
  TAdicProc = procedure(AHost, AUser, APass, AFirstName, AMiddleName, ALastName, ALibraryName, ASYSDBAPass : PChar); stdcall;
var
  lInstance : THandle;
  lAdicProc : TAdicProc;
begin
  lInstance := SafeLoadLibrary('ReplicadorFirebirdSec.dll');
  if (lInstance <> 0) then
  begin
    lAdicProc := GetProcAddress(lInstance,'AdicionaUser');
    lAdicProc(PChar(AHost), PChar(AUser), PChar(APass), nil, nil, nil, PChar(AVendorLib), PChar(ASYSDBAPass));
  end
end;


class procedure Banco.CriaConfiguracaoOrigem(const AUserReplicador : string);
begin
  with TuibScript.Create(nil) do
  begin
    try
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;
      if not Banco.ExisteGenerator(frmPrincipal.dbOrigem,'RDB$GEN_REPLICADOR') then
      begin
        Script.Add('CREATE GENERATOR RDB$GEN_REPLICADOR;');
      end;
      if not Banco.ExisteTable(frmPrincipal.dbOrigem,'RDB$RPL_TABELAS') then
      begin
        Script.Add('CREATE TABLE RDB$RPL_TABELAS');
        Script.Add('(TABELA          VARCHAR(32) NOT NULL,');
        Script.Add(' CAMPO           VARCHAR(32) NOT NULL,');
        Script.Add(' PK              CHAR(1) ,');
        Script.Add(' NEW_TABELA          VARCHAR(32),');
        Script.Add(' NEW_CAMPO           VARCHAR(32), TRIGGER_NAME VARCHAR(32),');
        Script.Add(' PRIMARY KEY(TABELA,CAMPO));');
      end;
//      if not Banco.ExisteTable(frmPrincipal.dbOrigem,'RDB$RPL_CHANGES') then
//      begin
//        Script.Add('CREATE TABLE RDB$RPL_CHANGES');
//        Script.Add('(LOG_ID          INTEGER NOT NULL PRIMARY KEY,');
//        Script.Add(' TABELA          VARCHAR(32) NOT NULL,');
//        Script.Add(' OPERACAO        CHAR(1) CHECK (OPERACAO IN (''I'',''U'',''D'')),');
//        Script.Add(' TRIGGER_PREFIX  VARCHAR(10),');
//        Script.Add(' SQL_SCRIPT      BLOB SUB_TYPE TEXT SEGMENT SIZE 80 NOT NULL);');
//      end;
      if not Banco.ExisteTable(frmPrincipal.dbOrigem,'RDB$RPL_CHANGES_XML') then
      begin
        Script.Add('CREATE TABLE RDB$RPL_CHANGES_XML');
        Script.Add(' (LOG_ID   INTEGER NOT NULL ,');
        Script.Add('  XML      BLOB SUB_TYPE TEXT SEGMENT SIZE 80 NOT NULL,');
        Script.Add('  TABELA   VARCHAR(100),');        
        Script.Add('  PRIMARY KEY(LOG_ID));');
      end;
//      if not Banco.ExisteTrigger(frmPrincipal.dbOrigem,'RDB$RPL_INCCHANGES') then
//      begin
//        Script.Add('CREATE TRIGGER RDB$RPL_INCCHANGES FOR RDB$RPL_CHANGES');
//        Script.Add('BEFORE INSERT AS');
//        Script.Add('BEGIN');
//        Script.Add('  NEW.LOG_ID = GEN_ID(RDB$GEN_REPLICADOR, 1 );');
//        Script.Add('END;');
//      end;
      Script.Add(Format('GRANT ALL ON RDB$RPL_TABELAS TO %s;',[AUserReplicador]));
//      Script.Add(Format('GRANT ALL ON RDB$RPL_CHANGES TO %s;',[AUserReplicador]));
      Script.Add(Format('GRANT ALL ON RDB$RPL_CHANGES_XML TO %s;',[AUserReplicador]));

      if Script.Count>0 then
        ExecuteScript;
    finally
      Free;
    end;
  end;
end;
class procedure Banco.CriaConfiguracaoDestino(const AUserReplicador : string);
begin
  with TuibScript.Create(nil) do
  begin
    try
      Transaction := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbDestino;
      if not Banco.ExisteTable(frmPrincipal.dbDestino,'RDB$RPL_COMMITED') then
      begin
        Script.Add('CREATE TABLE RDB$RPL_COMMITED');
        Script.Add('(IDENTIFICADOR  VARCHAR(10) NOT NULL PRIMARY KEY,');
        Script.Add(' LOG                  INTEGER NOT NULL);');
      end;
      Script.Add(Format('GRANT ALL ON RDB$RPL_COMMITED TO %s;',[AUserReplicador]));
      if Script.Count>0 then
        ExecuteScript;
    finally
      Free;
    end;
  end;
end;

//class procedure Banco.CriaTriggers(const AUserReplicador : string);
//const
//  TAM_VARCHAR_TRIGGERS = '32000';
//var
//  strCampos, strValores: string;
//  i,ii : integer;
//
//
//  node, lFieldNode : PVirtualNode;
//  tmp  : PAdicInfoTree;
//
//  lNewCampo,  lCampo : string;
//  lNewTabela, lTabela : string;
//
//  procedure AdicionaFiltros(AScript : TStrings);
//  begin
//    if frmPrincipal.mmoFiltro.Lines.Text<>'' then
//    begin
//      AScript.AddStrings(frmPrincipal.mmoFiltro.Lines);
//    end;
//  end;
//begin
//  node := frmPrincipal.vt.GetFirst;
//  while Assigned(node) do
//  begin
//    tmp := frmPrincipal.vt.GetNodeData(node);
//    if not tmp.FSelected then
//    begin
//      Banco.RemoveTriggersDaTabela(tmp.FTabela);
//      Node := frmPrincipal.vt.GetNextSibling(node);
//      Continue;
//    end;
//    lTabela    := tmp.FTabela;
//    lNewTabela := IfThen(tmp.FNewTAbela='',tmp.FTabela,tmp.FNewTAbela);
//
//    with TuibScript.Create(nil) do
//    begin // criando TRIGGER de INSERT
//      Transaction          := TuibTransaction.Create(nil);
//      Transaction.DataBase := frmPrincipal.dbOrigem;
//      Script.Add(Format('CREATE OR ALTER TRIGGER %s%sI FOR %s',[frmPrincipal.edtPrefix.Text,lTabela,lTabela]));
//      Script.Add(Format('AFTER INSERT POSITION %s AS',[frmPrincipal.edtPos.Text]));
//      Script.Add(Format('DECLARE VARIABLE strCampos VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add(Format('DECLARE VARIABLE strValores VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add(Format('DECLARE VARIABLE SQLScript VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add('BEGIN');
//      Script.Add(Format('IF (USER = ''%s'') THEN EXIT;',[AUserReplicador]));
//      strValores := '''''';
//      strCampos := '';
//
//      AdicionaFiltros(Script);
//      lFieldNode := frmPrincipal.vt.GetFirstChild(node);
//      while Assigned(lFieldNode) do
//      begin
//        tmp := frmPrincipal.vt.GetNodeData(lFieldNode);
//        if not tmp.FSelected then
//        begin
//          lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
//          Continue;
//        end;
//
//        lCampo    := tmp.FCampo;
//        lNewCampo := IfThen(tmp.FNewCampo='',lCampo,tmp.FNewCampo);
//
//        Script.Add(Format('IF (NEW.%s IS NOT NULL) THEN ',[lCampo]));
//        Script.Add(Format('BEGIN /* Inicio do Campo %s->%s */',[lCampo,lNewCampo]));
//        Script.Add(Format('  IF (strCampos IS NULL)  THEN strCampos  = ''%s''; ELSE strCampos = strCampos||'',%s''; ',[lNewCampo,lNewCampo]));
//        Script.Add(Format('  IF (strValores IS NULL) THEN strValores = ''''''''||NEW.%s||''''''''; ELSE strValores = strValores ||'','' || '''''''' ||NEW.%s||'''''''';',[lCampo,lCampo]));
////        if tmp.FPk then
////        begin
////          if strValores = '''''' then
////            strValores := '''' + NOME_CAMPO + ' = ''''''|| NEW.' + NOME_CAMPO + '||'''''''''
////          else
////            strValores := strValores + Format('||'',''||''%s  = ''|| NEW.%s||''''''''',[NOME_CAMPO,NOME_CAMPO]);
////        end;
//        Script.Add(Format('END /* Fim do Campo %s->%s */',[lCampo,lNewCampo]));
//        lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
//      end;//fim do for nos campos
//      Script.Add(Format('sqlScript = ''INSERT INTO %s ('' || :strCampos || '') VALUES (''|| :strValores ||'')'';',[lNewTabela]));
//      Script.Add(Format('INSERT INTO RDB$RPL_CHANGES (TABELA,OPERACAO,SQL_Script,TRIGGER_PREFIX) VALUES (''%s'',''I'',:SQLScript,''%s'');',[lTabela,frmPrincipal.edtPrefix.Text]));
//      Script.Add('END; /* Fim da Trigger */');
//      frmPrincipal.mmoPrep.Lines.Add(Format('Criando/Alterando Trigger RDB$RPL%sI',[lTabela]));
////      ShowMessage(Script.Text);
//
//      ExecuteScript;
//    end;//fim with script insert
//    with TuibScript.Create(nil) do
//    begin // criando TRIGGER de UPDATE
//      Transaction          := TuibTransaction.Create(nil);
//      Transaction.DataBase := frmPrincipal.dbOrigem;
//      Script.Add(Format('CREATE OR ALTER TRIGGER %s%sU FOR %s',[frmPrincipal.edtPrefix.Text,lTabela,lTabela]));
//      Script.Add(Format('AFTER UPDATE POSITION %s AS',[frmPrincipal.edtPos.Text]));
//      Script.Add(Format('DECLARE VARIABLE strCampos VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add(Format('DECLARE VARIABLE strValores VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add(Format('DECLARE VARIABLE SQLScript VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add('BEGIN');
//      Script.Add('IF (USER = ''REPLICADORBR'') THEN EXIT;');
//      strValores := '''''';
//      strCampos := '';
//      AdicionaFiltros(Script);
//      lFieldNode := frmPrincipal.vt.GetFirstChild(node);
//      while Assigned(lFieldNode) do
//      begin
//        tmp := frmPrincipal.vt.GetNodeData(lFieldNode);
//        if not tmp.FSelected then
//        begin
//          lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
//          Continue;
//        end;
//        lCampo    := tmp.FCampo;
//        lNewCampo := IfThen(tmp.FNewCampo='',lCampo,tmp.FNewCampo);
//
//        Script.Add(Format('IF ((NEW.%s <> OLD.%s) OR (NEW.%s IS NULL AND OLD.%s IS NOT NULL) OR (NEW.%s IS NOT NULL AND OLD.%s IS NULL)) THEN',[lCampo,lCampo,lCampo,lCampo,lCampo,lCampo]));
//        Script.Add('BEGIN');
//        Script.Add('  IF (NEW.' + lCampo + ' IS NULL) THEN ');
//        Script.Add('  BEGIN');
//        Script.Add('    IF (strCampos IS NULL) THEN');
//        Script.Add('      strCampos = ''' + lNewCampo + ' = NULL''; ELSE');
//        Script.Add('      strCampos = strCampos ||'','' || ''' + lNewCampo + ' = NULL'';');
//        Script.Add('  END ELSE');
//        Script.Add('  BEGIN');
//        Script.Add('    IF (strCampos IS NULL) THEN');
//        Script.Add('      strCampos = ''' + lNewCampo + ' = '''''' || NEW.' + lCampo + '||''''''''; ELSE');
//        Script.Add('      strCampos = strCampos ||'','' || ''' + lNewCampo + ' = ''''''|| NEW.' + lCampo + '||'''''''';');
//        Script.Add('  END');
//        Script.Add('END');
//        if tmp.FPk then
//        begin
//          if strValores = '''''' then
//            strValores := '''' + lNewCampo + ' = ''''''|| OLD.' + lCampo + '||'''''''''
//          else
//            strValores := strValores + '||'' AND ''||''' + lNewCampo + ' = ''''''|| OLD.' + lCampo + '||''''''''';
//        end;
//        lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
//      end;//fim laco campos update
//      Script.Add('strValores = ' + strValores + ';');
//      Script.Add('sqlScript = ''UPDATE ' + lNewTabela + ' SET '' || :strCampos ;');
//      Script.Add('IF (strValores <> '''') THEN ');
//      Script.Add('  SQLScript = SQLScript || '' WHERE ''|| strValores;');
//      Script.Add('IF (SQLScript <> '''') THEN ');
//      Script.Add(Format('  INSERT INTO RDB$RPL_CHANGES (TABELA,OPERACAO,SQL_Script,TRIGGER_PREFIX) VALUES (''%s'',''U'',:SQLScript,''%s'');',[lTabela,frmPrincipal.edtPrefix.Text]));
//      Script.Add('END; /* Fim da Trigger */');
//      frmPrincipal.mmoPrep.Lines.Add(Format('Criando/Alterando Trigger RDB$RPL%sU',[lTabela]));
//      ExecuteScript;
//    end;//fim with script update
//    with TuibScript.Create(nil) do
//    begin // criando TRIGGER de DELETE
//      Transaction          := TuibTransaction.Create(nil);
//      Transaction.DataBase := frmPrincipal.dbOrigem;
//      Script.Add(Format('CREATE OR ALTER TRIGGER %s%sD FOR %s',[frmPrincipal.edtPrefix.Text,lTabela,lTabela]));
//      Script.Add(Format('AFTER DELETE POSITION %s AS',[frmPrincipal.edtPos.Text]));
//      Script.Add(Format('DECLARE VARIABLE strCampos VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add(Format('DECLARE VARIABLE strValores VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add(Format('DECLARE VARIABLE SQLScript VARCHAR(%s);',[TAM_VARCHAR_TRIGGERS]));
//      Script.Add('BEGIN');
//      Script.Add('IF (USER = ''REPLICADORBR'') THEN EXIT;');
//      strValores := '''''';
//      strCampos := '';
//      AdicionaFiltros(Script);
//      lFieldNode := frmPrincipal.vt.GetFirstChild(node);
//      while Assigned(lFieldNode) do
//      begin
//        tmp := frmPrincipal.vt.GetNodeData(lFieldNode);
//        if not tmp.FSelected then
//        begin
//          lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
//          Continue;
//        end;
//        lCampo    := tmp.FCampo;
//        lNewCampo := IfThen(tmp.FNewCampo='',lCampo,tmp.FNewCampo);
//        if tmp.FPk then
//        begin
//          if strValores = '''''' then
//            strValores := '''' + lNewCampo + ' = ''''''|| OLD.' + lCampo + '||'''''''''
//          else
//            strValores := strValores + '||'' AND ''||''' + lNewCampo + ' = ''''''|| OLD.' + lCampo + '||''''''''';
//        end;
//        lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
//      end;//fim laco campos delete
//      Script.Add('strValores = ' + strValores + ';');
//      Script.Add('sqlScript = ''DELETE FROM ' + lNewTabela + ''';');
//      Script.add('IF (strValores <> '''') THEN ');
//      Script.ADD('   SQLScript = SQLScript || '' WHERE ''|| :strValores;');
//      Script.Add(Format('INSERT INTO RDB$RPL_CHANGES (TABELA,OPERACAO,SQL_Script,TRIGGER_PREFIX) VALUES (''%s'',''D'',:SQLScript,''%s'');',[lTabela,frmPrincipal.edtPrefix.Text]));
//      Script.Add('END; /* Fim da Trigger */');
//      frmPrincipal.mmoPrep.Lines.Add(Format('Criando/Alterando Trigger RDB$RPL%sD',[lTabela]));
//      ExecuteScript;
//    end;//fim with script delete
//    Node := frmPrincipal.vt.GetNextSibling(node);
//  end;//fim laco tabelas level 1 da tree
//  frmPrincipal.mmoPrep.Lines.Add('Ok.');
//end;
class procedure Banco.CriaTriggers2(const AUserReplicador : string; ANode : PVirtualNode);
var
  i,ii : integer;

  node, lFieldNode : PVirtualNode;
  tmp  : PAdicInfoTree;

  lNewCampo,  lCampo : string;
  lNewTabela, lTabela : string;

  lNomeTrigger : String;

begin
  if Assigned(ANode) then
    node := ANode
  else
    node := frmPrincipal.vt.GetFirst;


  while Assigned(node) do
  begin
    Application.ProcessMessages;

    tmp := frmPrincipal.vt.GetNodeData(node);
    if not tmp.FSelected then
    begin
      Banco.RemoveTriggersDaTabela(tmp.FTabela);
      Node := frmPrincipal.vt.GetNextSibling(node);
      Continue;
    end;
    lTabela    := tmp.FTabela;
    lNewTabela := IfThen(tmp.FNewTAbela='',tmp.FTabela,tmp.FNewTAbela);

    with TuibScript.Create(nil) do
    begin // criando TRIGGER de INSERT
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;

      lNomeTrigger :=  IfThen(tmp.FTriggerName='', Copy(lTabela,0,30-Length(frmPrincipal.edtPrefix.Text)) , tmp.FTriggerName);

      Script.Add(Format('CREATE OR ALTER TRIGGER %s%sI FOR %s',[frmPrincipal.edtPrefix.Text,lNomeTrigger,lTabela]));
      Script.Add(Format('AFTER INSERT POSITION %s AS',[frmPrincipal.edtPos.Text]));
      if frmPrincipal.chkUdf.Checked or frmPrincipal.chkBlob.Checked then
        Script.Add('DECLARE VARIABLE XML BLOB;')
      else
        Script.Add('DECLARE VARIABLE XML VARCHAR(32000);');

      Script.Add('DECLARE VARIABLE LOG_ID INTEGER;');
      Script.Add('BEGIN');
      Script.Add(Format('IF (USER = ''%s'') THEN EXIT;',[AUserReplicador]));

      Script.Add(tmp.FCondicaoExtra);

      Script.Add('XML = '''';');

      lFieldNode := frmPrincipal.vt.GetFirstChild(node);
      while Assigned(lFieldNode) do
      begin
        tmp := frmPrincipal.vt.GetNodeData(lFieldNode);
        if not tmp.FSelected then
        begin
          lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
          Continue;
        end;

        lCampo    := tmp.FCampo;
        lNewCampo := IfThen(tmp.FNewCampo='',lCampo,tmp.FNewCampo);                                                            //COALESCE(NEW.COD_AVALISTA,'<ISNULL>-1</ISNULL>')
        if frmPrincipal.chkUdf.Checked then
        begin
          Script.Add(Format('XML = :XML || GENXMLCHANGE(''I'',''%s'',''%s'',NEW.%s,NULL); ',[lCampo,lNewCampo,lCampo]));
        end else
        begin
        Script.Add(Format('IF (NEW.%s IS NOT NULL) THEN ',[lCampo]));
        Script.Add(Format('BEGIN /* Inicio do Campo %s->%s */',[lCampo,lNewCampo]));
        Script.Add(Format('  XML = :XML || ''<FC><AF>%s</AF><FN>%s</FN><FIELDVALUE><![CDATA[''||NEW.%s||'']]></FIELDVALUE></FC>'';',[lCampo,lNewCampo,lCampo]));
        Script.Add(Format('END /* Fim do Campo %s->%s */',[lCampo,lNewCampo]));
        end;
        lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
      end;//fim do for nos campos
      Script.Add('IF (:XML = '''') THEN EXIT;');
      Script.Add('LOG_ID = GEN_ID(RDB$GEN_REPLICADOR,1);');
      Script.Add(Format('XML = ''<CHANGE VERSION="2.0" LOG_ID="''||:LOG_ID||''" USER_CHANGE="''||CURRENT_USER||''"><AT>%s</AT><TABLENAME>%s</TABLENAME><OP>I</OP><FIELDCHANGES>''||:XML||''</FIELDCHANGES></CHANGE>'';',[lTabela,lNewTabela]));
//      if frmPrincipal.chkClusterExtensions.Checked then
//        Script.Add(Format('INSERT INTO CLUSTER_CHANGES(LOG_ID,XML) VALUES (GEN_ID(CLUSTER_CHANGES_ID,1),:XML);',[]));
      //Script.Add(Format('IF (USER != ''%s'') THEN ',[AUserReplicador]));
      Script.Add(Format('  INSERT INTO RDB$RPL_CHANGES_XML(LOG_ID,XML,TABELA) VALUES (:LOG_ID,:XML,''%s'');',[lNewTabela]));
      Script.Add('END; /* Fim da Trigger */');
      frmPrincipal.mmoPrep.Lines.Add(Format('Trigger %S%sI',[frmPrincipal.edtPrefix.Text,lNomeTrigger]));
      // Script.SaveToFile('c:\script.i.sql');
      ExecuteScript;
    end;//fim with script insert
    with TuibScript.Create(nil) do
    begin // criando TRIGGER de UPDATE
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;
      Script.Add(Format('CREATE OR ALTER TRIGGER %s%sU FOR %s',[frmPrincipal.edtPrefix.Text,lNomeTrigger,lTabela]));
      Script.Add(Format('AFTER UPDATE POSITION %s AS',[frmPrincipal.edtPos.Text]));
      if frmPrincipal.chkUdf.Checked or frmPrincipal.chkBlob.Checked then
        Script.Add('DECLARE VARIABLE XML BLOB;')
      else
        Script.Add('DECLARE VARIABLE XML VARCHAR(32000);');

      Script.Add('DECLARE VARIABLE LOG_ID INTEGER;');
      Script.Add('DECLARE VARIABLE LTMP VARCHAR(32000);');
      Script.Add('BEGIN');
      Script.Add(Format('IF (USER = ''%s'') THEN EXIT;',[AUserReplicador]));

      Script.Add(tmp.FCondicaoExtra);

      Script.Add('XML = '''';');

      lFieldNode := frmPrincipal.vt.GetFirstChild(node);
      while Assigned(lFieldNode) do
      begin
        tmp := frmPrincipal.vt.GetNodeData(lFieldNode);
        if not tmp.FSelected then
        begin
          lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
          Continue;
        end;
        lCampo    := tmp.FCampo;
        lNewCampo := IfThen(tmp.FNewCampo='',lCampo,tmp.FNewCampo);

        if frmPrincipal.chkUdf.Checked then
        begin
          Script.Add(Format('XML = :XML || GENXMLCHANGE(''U'',''%s'',''%s'',NEW.%s,OLD.%s); ',[lCampo,lNewCampo,lCampo,lCampo]));
        end else
        begin
          Script.Add(Format('IF ((NEW.%s <> OLD.%s) OR (NEW.%s IS NULL AND OLD.%s IS NOT NULL) OR (NEW.%s IS NOT NULL AND OLD.%s IS NULL)) THEN',[lCampo,lCampo,lCampo,lCampo,lCampo,lCampo]));
          Script.Add(Format('BEGIN /* Inicio do Campo %s->%s */',[lCampo,lNewCampo]));
          Script.Add(Format('  IF (NEW.%s IS NULL) THEN BEGIN LTMP = ''-1''; END ELSE BEGIN LTMP = ''''; END',[lCampo]));
          Script.Add(Format('  XML = :XML || ''<FC><AF>%s</AF><FN>%s</FN><FV ISNULL="''||:LTMP||''"><![CDATA[''||COALESCE(CAST(NEW.%s AS VARCHAR(32765)),'''')||'']]></FV></FC>'';',[lCampo,lNewCampo,lCampo]));
          Script.Add(Format('END /* Fim do Campo %s->%s */',[lCampo,lNewCampo]));
        end;
        lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
      end;//fim laco campos update
      Script.Add('IF (:XML = '''') THEN EXIT;');
      lFieldNode := frmPrincipal.vt.GetFirstChild(node);
      while Assigned(lFieldNode) do
      begin
        tmp := frmPrincipal.vt.GetNodeData(lFieldNode);
        if not tmp.FSelected or not tmp.FPk then
        begin
          lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
          Continue;
        end;
        lCampo    := tmp.FCampo;
        lNewCampo := IfThen(tmp.FNewCampo='',lCampo,tmp.FNewCampo);
        if frmPrincipal.chkUdf.Checked then
        begin
          Script.Add(Format('XML = :XML || GENXMLCHANGE(''D'',''%s'',''%s'',NEW.%s,OLD.%s); ',[lCampo,lNewCampo,lCampo,lCampo]));
        end else
        begin
          Script.Add(Format('XML = :XML || ''<FW><AF>%s</AF><FN>%s</FN><FV><![CDATA[''||OLD.%s||'']]></FV></FW>'';',[lCampo,lNewCampo,lCampo]));
        end;

        lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
      end;//fim laco APENAS WHERE
      Script.Add('LOG_ID = GEN_ID(RDB$GEN_REPLICADOR,1);');
      Script.Add(Format('XML = ''<CHANGE VERSION="2.0" LOG_ID="''||:LOG_ID||''" USER_CHANGE="''||CURRENT_USER||''"><AT>%s</AT><TABLENAME>%s</TABLENAME><OP>U</OP><FIELDCHANGES>''||:XML||''</FIELDCHANGES></CHANGE>'';',[lTabela,lNewTabela]));
//      if frmPrincipal.chkClusterExtensions.Checked then
//        Script.Add(Format('INSERT INTO CLUSTER_CHANGES(LOG_ID,XML) VALUES (GEN_ID(CLUSTER_CHANGES_ID,1),:XML);',[]));
      //Script.Add(Format('IF (USER != ''%s'') THEN',[AUserReplicador]));
      Script.Add(Format('  INSERT INTO RDB$RPL_CHANGES_XML(LOG_ID,XML,TABELA) VALUES (:LOG_ID,:XML,''%s'');',[lNewTabela]));
      Script.Add('END; /* Fim da Trigger */');

      frmPrincipal.mmoPrep.Lines.Add(Format('Trigger %S%sU',[frmPrincipal.edtPrefix.Text,lNomeTrigger]));
      Script.SaveToFile('c:\script.u.sql');

      ExecuteScript;
    end;//fim with script update
    with TuibScript.Create(nil) do
    begin // criando TRIGGER de DELETE
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;
      Script.Add(Format('CREATE OR ALTER TRIGGER %s%sD FOR %s',[frmPrincipal.edtPrefix.Text,lNomeTrigger,lTabela]));
      Script.Add(Format('AFTER DELETE POSITION %s AS',[frmPrincipal.edtPos.Text]));
      if frmPrincipal.chkUdf.Checked or frmPrincipal.chkBlob.Checked then
        Script.Add('DECLARE VARIABLE XML BLOB;')
      else
        Script.Add('DECLARE VARIABLE XML VARCHAR(32000);');
      Script.Add('DECLARE VARIABLE LOG_ID INTEGER;');
      Script.Add('BEGIN');
      Script.Add(Format('IF (USER = ''%s'') THEN EXIT;',[AUserReplicador]));

      Script.Add(tmp.FCondicaoExtra);

      Script.Add('XML = '''';');

      lFieldNode := frmPrincipal.vt.GetFirstChild(node);
      while Assigned(lFieldNode) do
      begin
        tmp := frmPrincipal.vt.GetNodeData(lFieldNode);
        if not tmp.FSelected then
        begin
          lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
          Continue;
        end;
        lCampo    := tmp.FCampo;
        lNewCampo := IfThen(tmp.FNewCampo='',lCampo,tmp.FNewCampo);
        if tmp.FPk then
        begin
          if frmPrincipal.chkUdf.Checked then
          begin
            Script.Add(Format('XML = :XML || GENXMLCHANGE(''D'',''%s'',''%s'',NULL,OLD.%s); ',[lCampo,lNewCampo,lCampo]));
          end else
          begin
            Script.Add(Format('XML = :XML || ''<FW><AF>%s</AF><FN>%s</FN><FV><![CDATA[''||OLD.%s||'']]></FV></FW>'';',[lCampo,lNewCampo,lCampo]));
          end;


        end;
        lFieldNode := frmPrincipal.vt.GetNextSibling(lFieldNode);
      end;//fim laco campos delete
      Script.Add('LOG_ID = GEN_ID(RDB$GEN_REPLICADOR,1);');
      Script.Add(Format('XML = ''<CHANGE VERSION="2.0" LOG_ID="''||:LOG_ID||''" USER_CHANGE="''||CURRENT_USER||''"><AT>%s</AT><TABLENAME>%s</TABLENAME><OP>D</OP><FIELDCHANGES>''||:XML||''</FIELDCHANGES></CHANGE>'';',[lTabela,lNewTabela]));
//      if frmPrincipal.chkClusterExtensions.Checked then
//        Script.Add(Format('INSERT INTO CLUSTER_CHANGES(LOG_ID,XML) VALUES (GEN_ID(CLUSTER_CHANGES_ID,1),:XML);',[]));
      //Script.Add(Format('IF (USER != ''%s'') THEN',[AUserReplicador]));
      Script.Add(Format('  INSERT INTO RDB$RPL_CHANGES_XML(LOG_ID,XML,TABELA) VALUES (:LOG_ID,:XML,''%s'');',[lNewTabela]));
      Script.Add('END; /* Fim da Trigger */');
      frmPrincipal.mmoPrep.Lines.Add(Format('Trigger %S%sD',[frmPrincipal.edtPrefix.Text,lNomeTrigger]));
      ExecuteScript;
    end;//fim with script delete

    if Assigned(ANode) then
      Break;//Sair caso seja apenas um node


    Node := frmPrincipal.vt.GetNextSibling(node);
  end;//fim laco tabelas level 1 da tree
  frmPrincipal.mmoPrep.Lines.Add('Ok.');
end;

class function Banco.ExisteGenerator(ADB : TuibDataBase; const AGenName: string): Boolean;
begin
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := ADB;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := ADB;
      SQL.Text := Format('SELECT RDB$GENERATOR_NAME FROM RDB$GENERATORS WHERE RDB$GENERATOR_NAME = ''%S''',[AGenName]);
      Open;
      Result := (Fields.RecordCount > 0);
    finally
      Close(etmCommitRetaining);
      Free;
    end;
  end;

end;

class function Banco.ExisteTable(ADB : TuibDataBase; const ATableName : string): Boolean;
begin
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := ADB;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := ADB;
      SQL.Clear;
      SQL.Add('SELECT DISTINCT RDB$RELATION_NAME AS TABLENAME');
      SQL.Add('FROM RDB$RELATIONS');
      SQL.Add(Format('WHERE RDB$RELATION_NAME = ''%s''',[ATableName]));
      Open;
      Result := (Fields.RecordCount > 0);
    finally
      Close(etmCommitRetaining);
      Free;
    end;
  end;
end;
class function Banco.ExisteField(ADB : TuibDataBase; const ATableName, AFieldName : string): Boolean;
begin
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := ADB;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := ADB;
      SQL.Clear;
      SQL.Add('SELECT DISTINCT RDB$RELATION_NAME AS TABLENAME');
      SQL.Add('FROM RDB$RELATION_FIELDS');
      SQL.Add(Format('WHERE RDB$RELATION_NAME = ''%s''',[ATableName]));
      SQL.Add(Format('AND RDB$FIELD_NAME = ''%s''',[AFieldName]));
      Open;
      Result := (Fields.RecordCount > 0);
    finally
      Close(etmCommitRetaining);
      Free;
    end;
  end;
end;

class function Banco.ExisteTrigger(ADB : TuibDataBase; const ATriggerName: string): Boolean;
begin
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := frmPrincipal.dbOrigem;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;
      SQL.Text := Format('SELECT T.RDB$TRIGGER_NAME FROM RDB$TRIGGERS T WHERE (T.RDB$TRIGGER_NAME = ''%s'')',[ATriggerName]);
      Open;
      Result := (Fields.RecordCount > 0);
    finally
      Close(etmCommitRetaining);
      Free;
    end;
  end;
end;

class function Banco.ExisteUser(AHost, AUser, AVendorLib,
  ASYSDBAPass: String): boolean;
type
  TExisteFunc = function (AHost, AUser, ALibraryName, ASYSDBAPass : PChar): boolean; stdcall;
var
  lInstance : THandle;
  lExisteFunc : TExisteFunc;
begin
  Result := false;
  lInstance := SafeLoadLibrary('ReplicadorFirebirdSec.dll');
  if (lInstance <> 0) then
  begin
    lExisteFunc := GetProcAddress(lInstance,'ExisteUser');
    Result := lExisteFunc(PChar(AHost), PChar(AUser), PChar(AVendorLib), PChar(ASYSDBAPass));
  end;
end;

class procedure Banco.ModificaUserPass(AHost, AUser, APass, AVendorLib,
  ASYSDBAPass: string);
type
  TModProc = procedure(AHost, AUser, APass, AFirstName, AMiddleName, ALastName, ALibraryName, ASYSDBAPass : PChar); stdcall;
var
  lInstance : THandle;
  lModProc : TModProc;
begin
  lInstance := SafeLoadLibrary('ReplicadorFirebirdSec.dll');
  if (lInstance <> 0) then
  begin
    lModProc := GetProcAddress(lInstance,'ModificaUser');
    lModProc(PChar(AHost), PChar(AUser), PChar(APass), nil, nil, nil, PChar(AVendorLib), PChar(ASYSDBAPass));
  end;
end;

class procedure Banco.RemoveTabelasConfiguracao(ADB : TuibDataBase);
begin
  with TuibScript.Create(nil) do
  begin
    try
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := ADB;
      AutoDDL := false;
      if ExisteGenerator(ADB,'RDB$GEN_REPLICADOR') then
        Script.Add('DROP GENERATOR RDB$GEN_REPLICADOR;');
      if ExisteTable(ADB,'RDB$RPL_TABELAS') then
        Script.Add('DROP TABLE     RDB$RPL_TABELAS;');
      if ExisteTable(ADB,'RDB$RPL_CHANGES') then
        Script.Add('DROP TABLE     RDB$RPL_CHANGES;');
      if ExisteTable(ADB,'RDB$RPL_CHANGES2') then
        Script.Add('DROP TABLE     RDB$RPL_CHANGES2;');
      if ExisteTable(ADB,'RDB$RPL_CHANGES_XML') then
        Script.Add('DROP TABLE     RDB$RPL_CHANGES_XML;');
      if ExisteTable(ADB,'RDB$RPL_COMMITED') then
        Script.Add('DROP TABLE     RDB$RPL_COMMITED;');
      if Script.Count>0 then
        ExecuteScript;
    finally
      Transaction.Free;
      Free;
    end;
  end;
end;

class procedure Banco.RemoveTriggers;
begin
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := frmPrincipal.dbOrigem;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;
      SQL.Add('SELECT RDB$TRIGGER_NAME FROM RDB$TRIGGERS');
      SQL.Add('WHERE RDB$TRIGGER_NAME STARTING WITH ''RDB$RPL'' ');
      Open;
      with TuibScript.Create(nil) do
      begin
        DataBase             := frmPrincipal.dbOrigem;
        Transaction          := TuibTransaction.Create(nil);
        Transaction.DataBase := frmPrincipal.dbOrigem;
        while Not Eof do
        begin
          Script.Add('DROP TRIGGER ' + Fields.AsString[0] + ';');
          Next;
        end;
        if Script.Count > 0 then
        begin
          ExecuteScript;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

class procedure Banco.RemoveTriggersDaTabela(ATabela: String);
begin
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := frmPrincipal.dbOrigem;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;
      SQL.Add('SELECT RDB$TRIGGER_NAME FROM RDB$TRIGGERS');
      SQL.Add('WHERE RDB$TRIGGER_NAME STARTING WITH ''RDB$RPL'' ');
      SQL.Add('AND RDB$RELATION_NAME = '+QuotedStr(ATabela));
      Open;
      with TuibScript.Create(nil) do
      begin
        DataBase             := frmPrincipal.dbOrigem;
        Transaction          := TuibTransaction.Create(nil);
        Transaction.DataBase := frmPrincipal.dbOrigem;
        while Not Eof do
        begin
          Script.Add('DROP TRIGGER ' + Fields.AsString[0] + ';');
          Next;
        end;
        if Script.Count > 0 then
        begin
          frmPrincipal.mmoPrep.Lines.Add('Removendo triggers da tabela '+ATabela);
          ExecuteScript;
        end;
      end;
    finally
      Free;
    end;
  end;

end;

class procedure Banco.RemoveUser(AHost, AUser, AVendorLib,
  ASYSDBAPass: String);
type
  TRemProc = procedure(AHost, AUser, APass, AFirstName, AMiddleName, ALastName, ALibraryName, ASYSDBAPass : PChar); stdcall;
var
  lInstance : THandle;
  lRemProc : TRemProc;
begin
  lInstance := SafeLoadLibrary('ReplicadorFirebirdSec.dll');
  if (lInstance <> 0) then
  begin
    lRemProc := GetProcAddress(lInstance,'RemoveUser');
    lRemProc(PChar(AHost), PChar(AUser), nil, nil, nil, nil, PChar(AVendorLib), PChar(ASYSDBAPass));
  end;
end;


class procedure Banco.ModificaTriggersDestino(
  const AUserReplicador: string);
var
  lTableNode : PVirtualNode;
  lTmpTable  : PAdicInfoTree;
  lTableName, lTriggerName, lCondicao : string;
  lTriggerSource : TStringList;
  i : integer;
  procedure lVerb(AText : String);
  begin
    frmPrincipal.mmoDest.Lines.Add(AText);
  end;
begin
  with frmPrincipal do
  begin
    vt.BeginUpdate;
    lTriggerSource := TStringList.Create;
    lCondicao      := Format('IF (USER = ''%s'') THEN EXIT;',[AUserReplicador]);
    try
      lTableNode := vt.GetFirst;
      while Assigned(lTableNode) do
      begin
        lTmpTable := vt.GetNodeData(lTableNode);
        if lTmpTable.FSelected then
        begin
          lTableName := IfThen(lTmpTable.FNewTAbela='',lTmpTable.FTabela,lTmpTable.FNewTAbela);
          Banco.SetGrants(frmPrincipal.dbDestino,lTableName,frmPrincipal.GetUserReplicacaoDestino);
          with TuibQuery.Create(nil) do
          begin
            try
              DataBase             := frmPrincipal.dbDestino;
              Transaction          := TuibTransaction.Create(nil);
              Transaction.DataBase := DataBase;
              FetchBlobs           := true;
              SQL.Text := Format('SELECT T.RDB$TRIGGER_NAME, T.RDB$RELATION_NAME, T.RDB$TRIGGER_SOURCE'+
                '  FROM RDB$TRIGGERS T'+
                '  LEFT JOIN RDB$CHECK_CONSTRAINTS C ON C.RDB$TRIGGER_NAME = T.RDB$TRIGGER_NAME'+
                ' WHERE NOT (T.RDB$TRIGGER_NAME STARTING WITH ''RDB$'')'+
                '   AND T.RDB$TRIGGER_SOURCE IS NOT NULL'+
                '   AND ((T.RDB$SYSTEM_FLAG = 0) OR (T.RDB$SYSTEM_FLAG IS NULL))'+
                '   AND T.RDB$RELATION_NAME = ''%s''',[lTableName]);
              Open;
              while not Eof do
              begin
                lTriggerName        := Trim(Fields.AsString[0]);
                lTriggerSource.Text := Fields.AsString[2];

                if Pos(AnsiUpperCase(lCondicao),AnsiUpperCase(lTriggerSource.Text)) <= 0 then
                begin
                  for i:=0 to lTriggerSource.Count-1 do
                  begin
                    if CompareText('BEGIN',lTriggerSource[i])=0 then
                    begin
                      lTriggerSource.Insert(i+1,lCondicao);
                      Break;
                    end;
                  end;
                  RecompilaTrigger(lTriggerName,lTriggerSource.Text);
                  lVerb(Format('Trigger: %s, Tabela: %s. Modificada e recompilada.',[lTriggerName,lTableName]));
                end else
                begin
                  lVerb(Format('Trigger: %s, Tabela: %s. Ok.',[lTriggerName,lTableName]));
                end;
                Next;
              end;
            finally
              Close(etmCommitRetaining);
              Free;
            end;
          end;

        end;
        lTableNode := vt.GetNextSibling(lTableNode);
      end;
    finally
      vt.EndUpdate;
      lTriggerSource.Free;
    end;
  end;
  lVerb('Ok.');
end;

class procedure Banco.RecompilaTrigger(const AName, ASource: string);
begin
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := frmPrincipal.dbDestino;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := DataBase;
      SQL.Text := Format('ALTER TRIGGER %s'#13#10'%s',[AName,ASource]);
      ExecSQL;
    finally
      Close(etmCommitRetaining);
      Transaction.Free;
      Free;
    end;
  end;
end;

class procedure Banco.SetGrants(ADB: TuibDataBase;
  const ATableName, AUserReplicacao: string);
begin
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := ADB;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := DataBase;
      SQL.Text := Format('GRANT ALL ON %s TO %s',[ATableName,AUserReplicacao]);
      ExecSQL;
    finally
      Close(etmCommitRetaining);
      Transaction.Free;
      Free;
    end;
  end;
end;

class procedure Banco.ExecSQL(ADB: TUIBDataBase; const ASQL: String);
begin
  with TuibScript.Create(nil) do
  begin
    try
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;
      Script.Text := ASQL;
      ExecuteScript;
    finally
      Transaction.Free;
      Free;
    end;
  end;
end;

{ Arvore }

class procedure Arvore.AtualizaBanco(const AUserReplicador : string; ANode : PVirtualNode);
  procedure lVerb(AText : String);
  begin
    frmPrincipal.mmoPrep.Lines.Add(AText);
  end;
  procedure lSQLExec(ASQL : String);
  begin
    with TuibQuery.Create(nil) do
    begin
      try
        DataBase             := frmPrincipal.dbOrigem;
        Transaction          := TuibTransaction.Create(nil);
        Transaction.DataBase := frmPrincipal.dbOrigem;
        SQL.Text := ASQL;
        ExecSQL;
      finally
        Transaction.CommitRetaining;
        Transaction.Free;
        Free;
      end;
    end;
  end;
  function lExiste(ATabela,ACampo : String) : Boolean;
  const
    cSelectSql = 'SELECT TABELA FROM RDB$RPL_TABELAS WHERE (TABELA = ''%s'') AND (CAMPO = ''%s'' )';
  begin
    with TuibQuery.Create(nil) do
    begin
      try
        DataBase             := frmPrincipal.dbOrigem;
        Transaction          := TuibTransaction.Create(nil);
        Transaction.DataBase := frmPrincipal.dbOrigem;
        SQL.Text := Format(cSelectSql,[ATabela,ACampo]);
        Open;
        Result := (Fields.RecordCount > 0);
      finally
        Close(etmCommitRetaining);
        Free;
      end;
    end;
  end;
  procedure lAtualiza(APk,ATabela,ACampo,ANewTabela,ANewCampo,ATriggerName : String);
  const
  end;
  procedure lDeleta(ATabela,ACampo : String);
  const
    cDelSql = 'DELETE FROM RDB$RPL_TABELAS WHERE (TABELA = ''%s'') AND (CAMPO = ''%s'' )';
  begin
    lSQLExec(Format(cDelSql,[ATabela,ACampo]));
  end;
  procedure lInsere(APk,ATabela,ACampo,ANewTabela,ANewCampo,ATriggerName : String);
  const
    cInsSql = 'INSERT INTO RDB$RPL_TABELAS (TABELA,CAMPO,PK,NEW_TABELA,NEW_CAMPO,TRIGGER_NAME) VALUES (''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')';
  begin
    lSQLExec(Format(cInsSql,[ATabela,ACampo,APk,ANewTabela,ANewCampo,ATriggerName]));
  end;
  procedure lInsUpDel(ASel,APk : Boolean; ATabela,ACampo,ANewTabela,ANewCampo,ATriggerName : String);
  var
    cUpdSql : String;
  begin
    if ASel then
    begin //se selecionado
      if lExiste(ATabela,ACampo) then
      begin
        cUpdSql := 'UPDATE RDB$RPL_TABELAS SET PK=''%s'',NEW_TABELA=''%s'',NEW_CAMPO=''%s'',TRIGGER_NAME=''%s'',CONDICAO_EXTRA = %s WHERE (TABELA = ''%s'') AND (CAMPO = ''%s'' )';
        lSQLExec(Format(cUpdSql,[APk,ANewTabela,ANewCampo,ATriggerName,ATabela,ACampo]));


        lAtualiza(IfThen(APk,'T','F'),ATabela,ACampo,ANewTabela,ANewCampo,ATriggerName);
        lVerb(Format('Atualizando: Tabela "%s", Campo "%s"',[ATabela,ACampo]));
      end
      else
      begin
        lInsere(IfThen(APk,'T','F'),ATabela,ACampo,ANewTabela,ANewCampo,ATriggerName);
        lVerb(Format('Inserindo: Tabela "%s", Campo "%s"',[ATabela,ACampo]));
      end;
      //Banco.SetGrants(frmPrincipal.dbOrigem,ATabela,frmPrincipal.GetUserReplicacaoOrigem);

    end
    else
    begin
      if lExiste(ATabela,ACampo) then
      begin
        lDeleta(ATabela,ACampo);
        lVerb(Format('Removendo: Tabela "%s", Campo "%s"',[ATabela,ACampo]));
      end;
    end;
  end;



var
  i : integer;
  lFieldNode, lTableNode : PVirtualNode;
  lTmpTable, lTmpField : PAdicInfoTree;
begin
  with frmPrincipal do
  begin
    vt.BeginUpdate;
    try
    if Assigned(ANode) then
      lTableNode := ANode
    else
      lTableNode := vt.GetFirst;
    while Assigned(lTableNode) do
    begin
      lTmpTable := vt.GetNodeData(lTableNode);
      lInsUpDel(lTmpTable.FSelected,false,lTmpTable.FTabela,'', lTmpTable.FNewTAbela, '', lTmpTable.FTriggerName);
      if lTmpTable.FSelected then
      begin
        lFieldNode := vt.GetFirstChild(lTableNode);
        while Assigned(lFieldNode) do
        begin
          lTmpField := vt.GetNodeData(lFieldNode);
          lInsUpDel(lTmpField.FSelected,lTmpField.FPk,lTmpTable.FTabela,lTmpField.FCampo, lTmpTable.FNewTAbela, lTmpField.FNewCampo, lTmpTable.FTriggerName);
          lFieldNode := vt.GetNextSibling(lFieldNode);
        end;
      end;
      if Assigned(ANode) then
        Break;//Sair caso seja apenas um node

      lTableNode := vt.GetNextSibling(lTableNode);
    end;
    finally
      vt.EndUpdate;
    end;
  end;
  lVerb('Ok.');
end;

class procedure Arvore.MontaArvore;
var
  nodepai, nodetable, nodefield : TTreeNode;
  priortablename, atualtablename, atualfieldname : string;

  lTableNode, lFieldNode : PVirtualNode;
  lTableTmp , lFieldTmp: PAdicInfoTree;
begin
  if not Banco.ExisteField(frmPrincipal.dbOrigem,'RDB$RPL_TABELAS','TRIGGER_NAME') then
  begin
    Banco.ExecSQL(frmPrincipal.dbOrigem,'ALTER TABLE RDB$RPL_TABELAS ADD TRIGGER_NAME VARCHAR(32);');
  end;




  frmPrincipal.vt.Clear;
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase             := frmPrincipal.dbOrigem;
      Transaction          := TuibTransaction.Create(nil);
      Transaction.DataBase := frmPrincipal.dbOrigem;
      SQL.Assign(frmPrincipal.mmoSQL.Lines);
      Open;
//      nodepai := frmPrincipal.tree.Items.Add(nil,frmPrincipal.lblPath.Caption);
      while not Eof do
      begin
        atualtablename := Trim(Fields.ByNameAsString['TABLENAME']);
        if priortablename <> atualtablename then
        begin
          lTableNode          := frmPrincipal.vt.AddChild(nil);
          lTableTmp           := frmPrincipal.vt.GetNodeData(lTableNode);
          lTableTmp.FTabela   := atualtablename;
          lTableTmp.FCampo    := '';
          lTableTmp.FPk       := false;
          lTableTmp.FSelected := false;
          lTableTmp.FNewTabela   := Trim(Fields.ByNameAsString['NEW_TABELA']);
          lTableTmp.FTriggerName := Trim(Fields.ByNameAsString['TRIGGER_NAME']);

          priortablename := atualtablename;
        end;
        atualfieldname      := Trim(Fields.ByNameAsString['FIELDNAME']);
        lFieldNode          := frmPrincipal.vt.AddChild(lTableNode);
        lFieldTmp           := frmPrincipal.vt.GetNodeData(lFieldNode);
        lFieldTmp.FTabela   := atualtablename;
        lFieldTmp.FCampo    := atualfieldname;
        lFieldTmp.FPk       := (Fields.ByNameAsString['PK']          = 'T');
        lFieldTmp.FSelected := (Fields.ByNameAsString['SELECIONADO'] = 'T');
        lFieldTmp.FNewCampo    := Trim(Fields.ByNameAsString['NEW_CAMPO']);
        lFieldTmp.FTriggerName := Trim(Fields.ByNameAsString['TRIGGER_NAME']);


        if not lTableTmp.FSelected and lFieldTmp.FSelected then
        begin //Serve para selecionar a tabela caso algum campo esteja marcado...
          lTableTmp.FSelected := true;
        end;
        Next;
      end;
    finally
      Close(etmCommitRetaining);
      Free;
    end;
  end;
end;



end.





