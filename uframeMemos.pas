unit uframeMemos;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, uib, Buttons, ExtCtrls, JvExStdCtrls,
  JvMemo, JvRichEdit, Spin, Mask, JvExMask, JvSpin, JvSimpleXml, JclStrings,
  Menus, JvMenus, JvExControls, JvSpeedButton, JvToolEdit, JvCombobox, jvDesktopAlert;

type
  TframeMemos = class;

  TTiposErros = (teIgnorarErroPK,teIgnorarErroFK,teRepararErroFK,teIgnorarErroOutros);
  TErros = set of TTiposErros;


  thReplic = class(TThread)
  private
    FOwnerFrame : TframeMemos;
    FOcorreuErro : Boolean;
    FUltimaAlteracao       : Integer;
    FAlteracoesDisponiveis : Integer;
    FStrList               : TStringList;
    FdbOrigem              : TUIBDataBase;
    FdbDestino             : TUIBDataBase;
    FTrans                 : TUIBTransaction;
//    FQuery                 : TuibQuery;
  protected
    FMessage    : String;
    FAtual      : integer;
    FImageIndex : integer;
    procedure MyShowMessage;
    procedure MyChangeImageIndex;
    procedure MyOutputScript;
    procedure MyClearOutputScript;
    procedure MyProgress;
    procedure MyShowCommited;
    procedure MyTerminate(Sender : TObject); virtual;
    procedure Execute; override;
    procedure DoReplicarUIB;
    procedure DoChangeImageIndex(AIndex : integer);
    procedure DoShowMessage(AText : string);
    procedure DoShowMessageWithAlert(AText: string);
    procedure MyShowMessageWithAlert;

    procedure DoProgress(AAtual : integer);
    function  MyGetSQLFmt(ADB : TUIBDataBase; const ASQL : String; const Args : array of const) : Variant;
    function  MyGetSQLFmt2(ADB : TUIBDataBase; const ASQL : String; const Args : array of const) : Variant;
    procedure DoConnect;
    procedure GerarScript2;
    procedure doXmlToSQL(AXML : string);
    procedure DoFk(AMessageError : string; ALogID : integer; ALevel : string; ASelect : string = '');
  public
    constructor Create(AOwnerFrame : TframeMemos; CreateSuspended: boolean); virtual;
  end;

  TframeMemos = class(TFrame)
    gboxScripts: TGroupBox;
    gboxStatus: TGroupBox;
    mmoMessages: TRichEdit;
    Panel1: TPanel;
    mmoScript: TMemo;
    lblProgress: TLabel;
    timerrestante: TTimer;
    btnAuto: TSpeedButton;
    btnStopNow: TSpeedButton;
    lblDesc: TLabel;
    Splitter1: TSplitter;
    edtTempoTimer: TJvSpinEdit;
    dbxml: TJvSimpleXML;
    mmoFk: TMemo;
    mmoValidFields: TMemo;
    btnErros: TJvSpeedButton;
    cfgxml: TJvSimpleXML;
    timeralive: TTimer;
    lblTempoRestante: TLabel;
    edtQtde: TJvSpinEdit;
    procedure timerrestanteTimer(Sender: TObject);
    procedure edtTempoTimerChange(Sender: TObject);
    procedure btnStopNowClick(Sender: TObject);
    procedure btnErrosClick(Sender: TObject);
    procedure timeraliveTimer(Sender: TObject);
  private
    { Private declarations }
  public
    FThread                : thReplic;
    FFileName              : string;
    FRunning               : Boolean;
    FParar                 : Boolean;
    FIdentDestino          : string;
    FIdentOrigem           : string;

    FTempoRestante         : integer;


    FWatchDog              : integer;
    FErros  : TErros;
    procedure ResetWatchDog;
    procedure AddToMessage(AText : string);
    procedure ForceTerminate(var AThread : thReplic);

    constructor Create(AOwner: TComponent; AFileName : string); reintroduce;
  end;

  TSQLObj = class
    FSQL         : String;
    FSQLControle : String;
    FLogID       : integer;
  public
    constructor Create(ASQL,ASQLControle : string; ALogID : integer); reintroduce;
  end;


  TMyTabSheet = class(TTabSheet)
  public
    FOwnerFrame  : TframeMemos;
  end;

const
  MIN_WATCHDOG    = 10;
  sPRONTO         = 'Ok.';
  sPRONTO_NENHUMA = 'Ok. Sem alterações!';
  sFk             = 'violation of FOREIGN KEY constraint ';
  sPk             = 'violation of PRIMARY or UNIQUE KEY constraint ';
  sFECHANDO       = 'Fechando.';
  sINATIVIDADE    = '10 min. de inatividade';

implementation

uses uiblib, DateUtils, JclSimpleXml, StrUtils, udlgSentinelaConfig,
  uIgnorarErros, uCrypt, Math, uXml;

{$R *.dfm}

procedure AddColorLineToRich(const StrToAdd: String; RichEdit: TRichEdit); stdcall;
var
   StrLeft: String;
   TempStyle: TFontStyles;
   TempStr: String;
   changed : boolean;

   function FromLeftUntilStr(var OriginalStr: String; const UntilStr: String; const ToEndIfNotFound, Trim: Boolean): String;
   var
      TempPos: Integer;
   begin
      TempPos := Pos(UntilStr, OriginalStr);
      If TempPos > 0 Then
         Begin
            Result := Copy(OriginalStr, 1, TempPos - 1);
            If Trim Then
               Delete(OriginalStr, 1, TempPos - 1);
         End
            Else
         Begin
            If ToEndIfNotFound Then
               Begin
                  Result := OriginalStr;
                  If Trim Then
                     OriginalStr := '';
               End
                  Else
               Result := '';
         End;
   end;

   function FromLeftUntilStrX(var OriginalStr: String; const UntilStr: String; const ToEndIfNotFound, Trim: Boolean): String;
   var
      xStr : String;
   begin
      xStr := Copy(OriginalStr,2,Length(OriginalStr));
      result := '<' + FromLeftUntilStr(xStr,UntilStr,ToEndIfNotFound,Trim);
      OriginalStr := xStr;
   end;

   function StrStartsWith(var OriginalStr: String; const StartsWith: String; const IgnoreCase, Trim: Boolean): Boolean;
   var
      PartOfOriginalStr: String;
      NewStartsWith: String;
   begin
      PartOfOriginalStr := Copy(OriginalStr, 1, Length(StartsWith));
      NewStartsWith := StartsWith;

      If IgnoreCase Then Begin
         PartOfOriginalStr := LowerCase(PartOfOriginalStr);
         NewStartsWith := LowerCase(NewStartsWith);
      End;

      Result := PartOfOriginalStr = NewStartsWith;

      If (Result = True) And (Trim = True) Then
         Delete(OriginalStr, 1, Length(NewStartsWith));
   end;

   procedure AddToStyle(var Style: TFontStyles; AStyle: TFontStyle);
   begin
      If Not (AStyle In Style) Then
         Style := Style + [AStyle];
   end;

   procedure RemoveFromStyle(var Style: TFontStyles; AStyle: TFontStyle);
   begin
      If AStyle In Style Then
         Style := Style - [AStyle];
   end;
begin
   TempStyle := RichEdit.Font.Style;
   StrLeft := StrToAdd;
   RichEdit.SelStart := Length(RichEdit.Text);
   While StrLeft <> '' Do Begin
      If StrStartsWith(StrLeft, '<', True, False) Then
         Begin
            changed := false;
            // Bold Style
            If StrStartsWith(StrLeft, '<b>', True, True) Then
               begin AddToStyle(TempStyle, fsBold); changed := true; end;
            If StrStartsWith(StrLeft, '</b>', True, True) Then
               begin RemoveFromStyle(TempStyle, fsBold); changed := true; end;

            // Italic Style
            If StrStartsWith(StrLeft, '<i>', True, True) Then
               begin AddToStyle(TempStyle, fsItalic); changed := true; end;
            If StrStartsWith(StrLeft, '</i>', True, True) Then
               begin RemoveFromStyle(TempStyle, fsItalic); changed := true; end;

            // Underline Style
            If StrStartsWith(StrLeft, '<u>', True, True) Then
               begin AddToStyle(TempStyle, fsUnderline); changed := true; end;
            If StrStartsWith(StrLeft, '</u>', True, True) Then
               begin RemoveFromStyle(TempStyle, fsUnderline); changed := true; end;

            // Color
            If StrStartsWith(StrLeft, '</color>', True, True) Then
               begin RichEdit.SelAttributes.Color := RichEdit.Font.Color; changed := true; end;
            If StrStartsWith(StrLeft, '<color=', True, True) Then Begin
               TempStr := FromLeftUntilStr(StrLeft, '>', False, True); changed := true;
               Try
                  RichEdit.SelAttributes.Color := StringToColor(TempStr);
               Except
                  RichEdit.SelAttributes.Color := RichEdit.Font.Color;
               End;
               Delete(StrLeft, 1, 1);
            End;

            if not changed then
            begin
                RichEdit.SelAttributes.Style := TempStyle;
                RichEdit.SelText := FromLeftUntilStrX(StrLeft, '<', True, True);
            end;
         End
         Else
         Begin
            RichEdit.SelAttributes.Style := TempStyle;
            RichEdit.SelText := FromLeftUntilStr(StrLeft, '<', True, True);
         End;

      RichEdit.SelStart := Length(RichEdit.Text);
   End;
   RichEdit.SelText := #13#10;
end;

{ thReplic }

constructor thReplic.Create(AOwnerFrame : TframeMemos; CreateSuspended: boolean);
begin
  inherited Create(CreateSuspended);
  FOwnerFrame := AOwnerFrame;

  FOwnerFrame.timerrestante.Enabled    := false;
  FOwnerFrame.lblTempoRestante.Caption := '';

  FOwnerFrame.FParar   := false;
  FOwnerFrame.FRunning := true;

  DoChangeImageIndex(-1);

  FOcorreuErro := false;
  FStrList     := TStringList.Create;

  FdbOrigem  := TUIBDataBase.Create(nil);
  FdbDestino := TUIBDataBase.Create(nil);

  with FOwnerFrame do
  begin

    FIdentOrigem            := cfgxml.Root.Items.ItemNamed['dborigem'].Items.Value('identificador');
    FIdentDestino           := cfgxml.Root.Items.ItemNamed['dbdestino'].Items.Value('identificador');

    FdbOrigem.DatabaseName  := cfgxml.Root.Items.ItemNamed['dborigem'].Items.Value('database');
    FdbOrigem.LibraryName   := cfgxml.Root.Items.ItemNamed['dborigem'].Items.Value('libraryname');
    FdbOrigem.UserName      := cfgxml.Root.Items.ItemNamed['dborigem'].Items.Value('usuarioreplicacao');
    FdbOrigem.PassWord      := Decrypt(cfgxml.Root.Items.ItemNamed['dborigem'].Items.Value('passwordreplicacao'));
    FdbOrigem.CharacterSet  := StrToCharacterSet(cfgxml.Root.Items.ItemNamed['dborigem'].Items.Value('charset','NONE'));

    FdbDestino.DatabaseName := cfgxml.Root.Items.ItemNamed['dbdestino'].Items.Value('database');
    FdbDestino.LibraryName  := cfgxml.Root.Items.ItemNamed['dbdestino'].Items.Value('libraryname');
    FdbDestino.UserName     := cfgxml.Root.Items.ItemNamed['dbdestino'].Items.Value('usuarioreplicacao');
    FdbDestino.PassWord     := Decrypt(cfgxml.Root.Items.ItemNamed['dbdestino'].Items.Value('passwordreplicacao'));
    FdbDestino.CharacterSet := StrToCharacterSet(cfgxml.Root.Items.ItemNamed['dbdestino'].Items.Value('charset','NONE'));
  end;



  FTrans := TuibTransaction.Create(nil);
  FTrans.Options  := [tpNowait, tpReadCommitted, tpRecVersion];
  FTrans.DataBase := FdbDestino;

//  FQuery := TuibQuery.Create(nil);
//  FQuery.DataBase    := FTrans.DataBase;
//  FQuery.Transaction := FTrans;

  OnTerminate     := MyTerminate;
  FreeOnTerminate := true;
end;

procedure thReplic.DoChangeImageIndex(AIndex: integer);
begin
  FImageIndex := AIndex;
  Synchronize(MyChangeImageIndex);
end;

procedure thReplic.DoConnect;
begin
  if not FdbOrigem.Connected then
  begin
    try
      FdbOrigem.Connected := True;
    except
      on e:exception do
      begin
        if Pos('Your user name and password are not defined',e.Message)>0 then
        begin
          DoShowMessage(Format('<color=clred>Usuário ou senha inválidos na base de origem.'#13#10'Usuário:%s'#13#10'Senha:%s'#13#10'Caminho:%s</color>',[FdbOrigem.UserName,FdbOrigem.PassWord,FdbOrigem.DatabaseName]));
        end else
        begin
          DoShowMessage('<color=clred>'+e.Message+'</color>');
        end;
        Abort;
      end;
    end;
  end;
  if not FdbDestino.Connected then
  begin
    try
      FdbDestino.Connected := True;
    except
      on e:exception do
      begin
        if Pos('Your user name and password are not defined',e.Message)>0 then
        begin
          DoShowMessage(Format('<color=clred>Usuário ou senha inválidos na base de origem.'#13#10'Usuário:%s'#13#10'Senha:%s'#13#10'Caminho:%s</color>',[FdbDestino.UserName,FdbDestino.PassWord,FdbDestino.DatabaseName]));
        end else
        begin
          DoShowMessage('<color=clred>'+e.Message+'</color>');
        end;
        Abort;
      end;
    end;
  end;

end;

procedure thReplic.DoFk(AMessageError: string; ALogID: integer; ALevel : string; ASelect : string);
var
  lTable, lConstraint : string;
  lFkTable,
  lFkWhere, lFkWhereValue : string;
  lInsertFields : string;
  lInsertValues : string;
  lSelectFields : string;
  lInsert : string;
  lSelect : string;
  lXml : TJvSimpleXML;
  l : integer;

  function GetFieldValue(AFieldName : string) : string;
  var
    i : integer;
  begin
    Result := '';
    for i:=0 to lxml.Root.Items.ItemNamed['FIELDCHANGES'].Items.Count-1 do
    begin
      if CompareText(AFieldName, lXml.Root.Items.ItemNamed['FIELDCHANGES'].Items.Item[i].Items.Value('FIELDNAME'))=0 then
      begin
        Result := QuotedStr( lXml.Root.Items.ItemNamed['FIELDCHANGES'].Items.Item[i].Items.Value('FIELDVALUE') );
        Break;
      end;
    end;
  end;
  function GetFieldValue2(AFieldName : string) : string;
  var
    lIdx : integer;
  begin
    Result := '';
    with TuibQuery.Create(nil) do
    begin
      try
        DataBase    := FdbOrigem;
        Transaction := TuibTransaction.Create(nil);
        Transaction.Options  := [tpNowait, tpReadCommitted, tpRecVersion];
        Transaction.DataBase := DataBase;
        SQL.Text := ASelect;
        Open;
        lIdx := Fields.GetFieldIndex(AFieldName);
        if (Fields.IsNull[lIdx]) then
          Result := 'NULL'
        else if (Fields.FieldType[lIdx] = uftDate) then
          Result := QuotedStr( FormatDateTime('mm-dd-yyyy', Fields.AsDate[lIdx]) )
        else if (Fields.FieldType[lIdx] = uftTime) then
          Result := QuotedStr( FormatDateTime('hh:nn:ss', Fields.AsTime[lIdx]) )
        else if (Fields.FieldType[lIdx] = uftTimestamp) then
          Result := QuotedStr( FormatDateTime('mm-dd-yyyy hh:nn:ss', Fields.AsDateTime[lIdx]) )
        else if Fields.FieldType[lIdx] in ([uftNumeric,uftDoublePrecision]) then
          Result := StringReplace( Fields.AsString[lIdx],',','.',[rfReplaceAll] )
        else
          Result := QuotedStr(Fields.AsString[lIdx]);
      finally
        Close;
        Transaction.Free;
        Free;
      end;
    end;
  end;
begin
  lConstraint := StrBetween(StrAfter(sFk,AMessageError),'"','"');
  lTable      := StrBetween(StrAfter('on table ',AMessageError),'"','"');
  DoShowMessage(Format('<color=clBlue>Resolvendo "%s" "%s"...</color>',[lConstraint,lTable]));

  if ASelect = '' then
    lXml := TJvSimpleXML.Create(nil);

  with TuibQuery.Create(nil) do
  begin
    try
      DataBase    := FdbOrigem;
      Transaction := TuibTransaction.Create(nil);
      Transaction.Options  := [tpNowait, tpReadCommitted, tpRecVersion];
      Transaction.DataBase := DataBase;
      FetchBlobs := TRUE;
      if ASelect = '' then
      begin
        SQL.Text    := Format('SELECT XML FROM RDB$RPL_CHANGES_XML WHERE LOG_ID = %d',[ALogID]);
        Open;
        lXml.LoadFromString(Fields.ByNameAsString['XML']);
      end;
      Close;
      SQL.Text    := Format(FOwnerFrame.mmoFk.Lines.Text,[lTable,lConstraint]);
      Open;

      lFkWhere := ' WHERE 1=1';
      while Not Eof do
      begin
        lFkTable      := Trim(Fields.ByNameAsString['FK_TABLE']);
        if ASelect = '' then
          lFkWhereValue := GetFieldValue(Trim(Fields.ByNameAsString['ONFIELD']))
        else
          lFkWhereValue := GetFieldValue2(Trim(Fields.ByNameAsString['ONFIELD']));

        if lFkWhereValue='' then
        begin
          raise Exception.Create('Não foi encontrada informação do field '+Trim(Fields.ByNameAsString['ONFIELD']));
        end;
        lFkWhere      := lFkWhere + ' AND ' + Trim(Fields.ByNameAsString['FK_FIELD']) + ' = ' + lFkWhereValue;
        Next;
      end;
      if lFkTable='' then
      begin
        raise Exception.CreateFmt('"%s" não existe na origem.',[lConstraint]);
      end;

      Close;
      SQL.Text := Format(FOwnerFrame.mmoValidFields.Lines.Text,[lFkTable]);
      Open;
      while not Eof do
      begin
        lSelectFields := lSelectFields + ',' + Trim(Fields.ByNameAsString['FIELDNAME']);
        Next;
      end;
      Close;
      Delete(lSelectFields,1,1);
      lSelect  := Format('SELECT %s FROM %s %s ',[lSelectFields,lFkTable,lFkWhere]);
      DoShowMessage(Format('<color=clBlue>%s SELECT * FROM %s %s</color>',[ALevel,lFkTable,lFkWhere]));
      SQL.Text := lSelect;
      Open;
      if Fields.RecordCount=1 then
      begin
        for l:=0 to Fields.FieldCount-1 do
        begin
          lInsertFields := lInsertFields + ',' + Fields.SqlName[l];
          if (Fields.IsNull[l]) then
            lInsertValues := lInsertValues + ',NULL'
          else if (Fields.FieldType[l] = uftDate) then
            lInsertValues := lInsertValues + ',' + QuotedStr( FormatDateTime('mm-dd-yyyy', Fields.AsDate[l]) )
          else if (Fields.FieldType[l] = uftTimestamp) then
            lInsertValues := lInsertValues + ',' + QuotedStr( FormatDateTime('mm-dd-yyyy hh:nn:ss', Fields.AsDateTime[l]) )
          else if Fields.FieldType[l] in ([uftNumeric,uftDoublePrecision]) then
            lInsertValues := lInsertValues + ',' + StringReplace( Fields.AsString[l],',','.',[rfReplaceAll] )
          else
            lInsertValues := lInsertValues + ',' + QuotedStr(Fields.AsString[l]);
        end;
      end else
      begin
        raise Exception.CreateFmt('%s SELECT * FROM %s %s'#13#10'Deve retornar 1 uma linha.',[ALevel,lFkTable,lFkWhere]);
      end;
      Close;
      Delete(lInsertFields,1,1);
      Delete(lInsertValues,1,1);
      lInsert := Format('INSERT INTO %s (%s) VALUES (%s)',[lFkTable,lInsertFields,lInsertValues]);
      try
        DoShowMessage(ALevel+' '+lInsert);
        FTrans.ExecuteImmediate(lInsert);
        FTrans.Commit;
      except
        on e:exception do
        begin
          FTrans.RollBack;
          if (Pos(sFk,e.Message)>0)  then
          begin
            DoFk(e.Message,-1,ALevel+'>',lSelect);
            FTrans.ExecuteImmediate(Format('INSERT INTO %s (%s) VALUES (%s)',[lFkTable,lInsertFields,lInsertValues]));
            FTrans.Commit;
          end else
          begin
            raise Exception.CreateFmt('Erro resolvendo "%s" "%s"... %s',[lConstraint,lTable,e.Message]);
          end;
        end;

      end;
      Sleep(100);
    finally
      if Assigned(lXml) then lXml.Free;
      Close(etmCommitRetaining);
      Transaction.Free;
      Free;
    end;
  end;

end;

procedure thReplic.DoProgress(AAtual: integer);
begin
  FAtual := AAtual;
  Synchronize(MyProgress);
end;

procedure thReplic.DoReplicarUIB;
var
  i : integer;
  lResult : Variant;

  lIgnorarErro   : Boolean;
  lIgnorarMotivo : String;


{$IFDEF WITH_OPTIMIZER}
  lTCPCli    : TIdTCPClient;

  procedure EnviaTCP();
  var
    lMemStream : TMemoryStream;
    lStrStream : TStringStream;
    j : integer;
    lReadLn : String;
  begin
    lStrStream := TStringStream.Create('');
    lMemStream := TMemoryStream.Create;

    j:=0;
    while j < (FStrList.Count) do
    begin
      lStrStream.WriteString(TSQLObj(FStrList.Objects[j]).FSQL+';'#13#10);
      lStrStream.WriteString(TSQLObj(FStrList.Objects[j]).FSQLControle+#13#10);
      lStrStream.WriteString('COMMIT;'#13#10);
      Inc(j);
    end;
    lStrStream.Seek(0,soFromBeginning);
    ZCompressStream(lStrStream,lMemStream);
    lMemStream.Seek(0, soFromBeginning);
    lTCPCli.WriteLn(Format('set %s',[FdbDestino.DatabaseName]));

    lReadLn := lTCPCli.ReadLn;
    if lReadLn <> 'Ok' then
    begin
      DoShowMessage(lReadLn);
      lTCPCli.Disconnect;
      Exit;
    end;

    try
      lTCPCli.OpenWriteBuffer;
      lTCPCli.WriteStream(lMemStream);
      lTCPCli.CloseWriteBuffer;
    finally
      lTCPCli.Disconnect;
      lStrStream.Free;
      lMemStream.Free;
    end;
  end;
{$ENDIF}  


begin
  FOwnerFrame.ResetWatchDog;

  DoConnect;

  lResult := MyGetSQLFmt(FdbDestino,
      'SELECT LOG FROM RDB$RPL_COMMITED WHERE IDENTIFICADOR = ''%s'' ', [FOwnerFrame.FIdentOrigem]);
  if VarIsNull(lResult) then
  begin
    FTrans.ExecuteImmediate(Format('INSERT INTO RDB$RPL_COMMITED (IDENTIFICADOR,LOG) VALUES (''%s'',%d)',[FOwnerFrame.FIdentOrigem,0]));
    FTrans.Commit;
    FUltimaAlteracao := 0;
  end else
  begin
    FUltimaAlteracao := lResult;
  end;

  FOwnerFrame.ResetWatchDog;

  FAlteracoesDisponiveis := MyGetSQLFmt(FdbOrigem,
      'SELECT COALESCE(COUNT(*),0) AS TOTAL FROM RDB$RPL_CHANGES_XML WHERE LOG_ID > %d', [FUltimaAlteracao]);

  if FAlteracoesDisponiveis = 0 then
  begin
    FdbDestino.Connected := false;
    FdbOrigem.Connected := false;
//    Terminate;
    Exit;
  end;

  if Terminated then Exit;

  DoShowMessage(Format('<color=clBlack>Gerando o script...</color><color=clBlue>Última efetuada: %d, Alterações: %d</color>', [FUltimaAlteracao,FAlteracoesDisponiveis]));
  Sleep(100);

  FOwnerFrame.ResetWatchDog;
  GerarScript2;//Adiciona o script no mmoScript

  if Terminated then Exit;
{$IFDEF WITH_OPTIMIZER}
  if FOwnerFrame.chkOptimizer.Checked then
  begin
    lTCPCli := TIdTCPClient.Create(nil);
    try
      lTCPCli.Host := ExtractHost(FdbDestino.DatabaseName);
      lTCPCli.Port := FOwnerFrame.edtOptimizer.AsInteger;
      try
        lTCPCli.Connect(5000);
        EnviaTCP;
      except
        on e:exception do
        begin
          DoShowMessage('Sender Optimizer error. '#13#10+e.Message);
        end;
      end;
    finally
      lTCPCli.Free;
    end;
  end;
  if FOwnerFrame.chkOptimizer.Checked then Exit;
{$ENDIF}

  i:=0;
  while i < (FStrList.Count) do
//  for i:=0 to FStrList.Count-1 do
  begin
    if FOwnerFrame.FParar then
    begin
      Abort;
    end;
    FOwnerFrame.ResetWatchDog;
    if Terminated then Exit;
    if Assigned(FStrList.Objects[i]) then
    begin
      try
        FTrans.ExecuteImmediate(TSQLObj(FStrList.Objects[i]).FSQL);
        FTrans.ExecuteImmediate(TSQLObj(FStrList.Objects[i]).FSQLControle);
        FTrans.Commit;
        DoProgress(i);
        Inc(i);
      except
        on e:Exception do
        begin
          lIgnorarErro   := false;
          FTrans.RollBack;
          if ((teIgnorarErroPK in FOwnerFrame.FErros) and (Pos(sPk,e.Message)>0)) then
          begin
            lIgnorarErro   := true;
            lIgnorarMotivo := 'Pk ignorada';
          end else if ((teIgnorarErroFK in FOwnerFrame.FErros) and not (teRepararErroFK in FOwnerFrame.FErros)) and (Pos(sFk,e.Message)>0) then
          begin
            lIgnorarErro   := true;
            lIgnorarMotivo := 'Fk ignorada';
          end else if (teIgnorarErroOutros in FOwnerFrame.FErros) then
          begin
            lIgnorarErro   := true;
            lIgnorarMotivo := 'Erro ignorado';
          end;
          if (teRepararErroFK in FOwnerFrame.FErros) and (Pos(sFk,e.Message)>0) then
          begin
            //reparar Fks
            if (Pos('DELETE FROM ',TSQLObj(FStrList.Objects[i]).FSQL)=0) then
            begin
              DoFk(e.Message,TSQLObj(FStrList.Objects[i]).FLogID,'>');
              Continue;//Nao incrementa o i e volta pra tentar inserir de novo...
            end;
          end;


          if lIgnorarErro then
          begin
            //ignorar Pks ou Fks
            DoShowMessage(Format('<color=$00000084>%s(%d):'#13#10'%s</color>',[lIgnorarMotivo,TSQLObj(FStrList.Objects[i]).FLogID,TSQLObj(FStrList.Objects[i]).FSQL]));
            try
              FTrans.ExecuteImmediate(TSQLObj(FStrList.Objects[i]).FSQLControle);
              FTrans.Commit;
            except
              on e: exception do
              begin
                FTrans.RollBack;
                DoShowMessage('<color=clRed>Na atualizacao do controle: '#13#10+e.Message+'</color>');
                Break;
              end;
            end;
            DoProgress(i);
            DoChangeImageIndex(2);
            DoShowMessage('<color=clRed>'+e.Message+'</color>');
            Inc(i);
            Continue;
          end;

          DoShowMessage(Format('<color=$00000084>(%d):'#13#10'%s</color>',[TSQLObj(FStrList.Objects[i]).FLogID,TSQLObj(FStrList.Objects[i]).FSQL]));
          DoShowMessageWithAlert(TSQLObj(FStrList.Objects[i]).FSQL);
          raise;
        end;
      end;
    end;
  end;
  if FTrans.InTransaction then
    FTrans.Rollback;

  Synchronize(MyClearOutputScript);
end;

procedure thReplic.DoShowMessage(AText: string);
begin
  FMessage := AText;
  Synchronize(MyShowMessage);
end;

procedure thReplic.DoShowMessageWithAlert(AText: string);
begin
  FMessage := AText;
  Synchronize(MyShowMessageWithAlert);
end;





procedure thReplic.doXmlToSQL(AXML : string);
var
  lOp, lTableName, lHeader, lFields, lValues, lWhere, lSQL : string;
  lFieldName  : string;
  lFieldValue : string;
  i, lLogID : integer;
  lVersion : String;

  lXml : TJclSimpleXML;
begin
  try
    FOwnerFrame.dbxml.LoadFromString(AXML);
  except
    on e:exception do
    begin
      raise Exception.CreateFmt('%s'#13#10'%s',[e.Message,AXML]);
    end;
  end;
  lLogID     := FOwnerFrame.dbxml.Root.Properties.IntValue('LOG_ID');
  lVersion   := FOwnerFrame.dbxml.Root.Properties.Value('VERSION');

  lOp        := FOwnerFrame.dbxml.Root.Items.Value('OP');
  lTableName := FOwnerFrame.dbxml.Root.Items.Value('TABLENAME');
  if CompareText('I',lOp)=0 then
    lHeader := Format('INSERT INTO %s (',[lTableName])
  else if CompareText('U',lOp)=0 then
    lHeader := Format('UPDATE %s SET ',[lTableName])
  else if CompareText('D',lOp)=0 then
    lHeader := Format('DELETE FROM %s '#13#10,[lTableName])
  else
  begin
    Exit;
  end;
  lFields := '';
  lValues := '';
  lWhere  := #13#10' WHERE 1=1';

  if lVersion = '2.0' then
  begin
    lXml := TJclSimpleXML.Create;
    lXml.Options := lXml.Options + [sxoAutoCreate];
    lXml.LoadFromString( AXML );
    try
      for i:=0 to leXMLCount(lXml,'FIELDCHANGES') - 1 do
      begin
        lFieldName  := leXML(lXml,Format('FIELDCHANGES;%d;FN',[i]));
        IF lFieldName='' then
          lFieldName  := leXML(lXml,Format('FIELDCHANGES;%d;FIELDNAME',[i]));

        if (leXMLProp(lXml,Format('FIELDCHANGES;%d;FV',[i]),'ISNULL') = '-1') or
           (leXMLProp(lXml,Format('FIELDCHANGES;%d;FIELDVALUE',[i]),'ISNULL') = '-1') then//IsNull virou prop
          lFieldValue := 'NULL'
        else
        begin
          lFieldValue := leXML(lXml,Format('FIELDCHANGES;%d;FV;0',[i])) ;//Elemento 0, para pegar dentro do CDATA
          if lFieldValue='' then
            lFieldValue := leXML(lXml,Format('FIELDCHANGES;%d;FIELDVALUE;0',[i])) ;//Elemento 0, para pegar dentro do CDATA
          lFieldValue := QuotedStr( lFieldValue );
        end;

        if (CompareText( leXMLName(lXml,Format('FIELDCHANGES;%d',[i])) , 'FC' ) = 0) or
           (CompareText( leXMLName(lXml,Format('FIELDCHANGES;%d',[i])) , 'FIELDCHANGE' ) = 0) then
        begin
          if (CompareText('I',lOp)=0) then
          begin
            lFields := lFields + ',' + lFieldName;
            lValues := lValues + ',' + lFieldValue;
          end else if CompareText('U',lOp)=0 then
          begin
            lValues := lValues + ',' + lFieldName + '=' + lFieldValue;
          end;
        end else
        begin
          lWhere  := lWhere + #13#10' AND ' + lFieldName + '=' + lFieldValue;
        end;
      end;
    finally
      lXml.Free;
    end;
  end else
  begin
    for i:=0 to FOwnerFrame.dbxml.Root.Items.ItemNamed['FIELDCHANGES'].Items.Count-1 do
    begin
      lFieldName  := FOwnerFrame.dbxml.Root.Items.ItemNamed['FIELDCHANGES'].Items.Item[i].Items.Value('FIELDNAME');
       //O QuotedStr tem a função de trocar um quote por dois no meio do texto...
      if FOwnerFrame.dbxml.Root.Items.ItemNamed['FIELDCHANGES'].Items.Item[i].Items.ItemNamed['FIELDVALUE'].Items.ItemNamed['ISNULL'].BoolValue then
        lFieldValue := 'NULL'
      else
        lFieldValue := QuotedStr( FOwnerFrame.dbxml.Root.Items.ItemNamed['FIELDCHANGES'].Items.Item[i].Items.Value('FIELDVALUE') );

      if CompareText(FOwnerFrame.dbxml.Root.Items.ItemNamed['FIELDCHANGES'].Items.Item[i].Name,'FIELDCHANGE')=0 then
      begin
        if (CompareText('I',lOp)=0) then
        begin
          lFields := lFields + ',' + lFieldName;
          lValues := lValues + ',' + lFieldValue;
        end else if CompareText('U',lOp)=0 then
        begin
          lValues := lValues + ',' + lFieldName + '=' + lFieldValue;
        end;
      end else
      begin
        lWhere  := lWhere + #13#10' AND ' + lFieldName + '=' + lFieldValue;
      end;
    end;
  end;
  Delete(lFields,1,1);
  Delete(lValues,1,1);
  if CompareText('I',lOp)=0 then
  begin
    lSQL := lHeader + lFields + ')'#13#10' VALUES ('+ lValues +')';
  end else if CompareText('U',lOp)=0 then
  begin
    lSQL := lHeader + lValues + lWhere;
    if Pos('AND',lWhere)=0 then
    begin
      DoShowMessage('Ops! Ignorado um update sem where! '+lSQL);
      Exit;
    end;
  end else if CompareText('D',lOp)=0 then
  begin
    lSQL := lHeader + lWhere;
    if Pos('AND',lWhere)=0 then
    begin
      DoShowMessage('Ops! Ignorado um delete sem where! '+lSQL);
      Exit;
    end;
  end else
  begin
      DoShowMessage('Ops! Ignorado o comando ! '+lSQL);
      Exit;
  end;

        FStrList.AddObject(
          lSQL+';',
          TSQLObj.Create(
            lSQL,
            Format('UPDATE RDB$RPL_COMMITED SET LOG = %d WHERE IDENTIFICADOR = ''%s'';',[lLogID,FOwnerFrame.FIdentOrigem]),
            lLogID)
        );


end;

procedure thReplic.Execute;
var
  i : integer;
begin
  if HourOfTheDay(Now) in [0..6] then
  begin
    for i := 1 to 30 do
    begin
      Sleep(1000*60);
      FOwnerFrame.ResetWatchDog;
    end;
  end;

  try
    DoChangeImageIndex(0);
    DoReplicarUIB;
    DoChangeImageIndex(1);
  except
    on e:exception do
    begin
      DoChangeImageIndex(2);
      DoShowMessage('<color=clRed>'+e.Message+'</color>');
      DoShowMessageWithAlert(e.Message);
    end;
  end;
end;

//procedure thReplic.GerarScript;
//var
//  lTrans  : TuibTransaction;
//  ALogIni : integer;
//
//begin
//  ALogIni := FUltimaAlteracao + 1;
//
//  if not FdbOrigem.Connected then
//  begin
//    try
//      FdbOrigem.Connected := True;
//    except
//      on e:exception do
//      begin
//        if Pos('Your user name and password are not defined',e.Message)>0 then
//        begin
//          DoShowMessage(Format('<color=clred>Usuário ou senha inválidos na base de origem.'#13#10'Usuário:%s'#13#10'Senha:%s'#13#10'Caminho:%s</color>',[FdbOrigem.UserName,FdbOrigem.PassWord,FdbOrigem.DatabaseName]));
//        end else
//        begin
//          DoShowMessage('<color=clred>'+e.Message+'</color>');
//        end;
//        Exit;
//      end;
//    end;
//  end;
//
//
//  lTrans := TuibTransaction.Create(nil);
//  lTrans.Options  := [tpNowait, tpReadCommitted, tpRecVersion];
//  lTrans.DataBase := FdbOrigem;
//  with TuibQuery.Create(nil) do
//  begin
//    try
//      DataBase    := FdbOrigem;
//      Transaction := lTrans;
//      FetchBlobs  := True;
//      SQL.Text    := 'SELECT FIRST 500 SQL_SCRIPT, LOG_ID FROM RDB$RPL_CHANGES';
//      SQL.Add(Format('WHERE LOG_ID >= %d ORDER BY LOG_ID',[ALogIni]));
//      Open;
//      while FStrList.Count>0 do
//      begin
//        FStrList.Objects[0].Free;
//        FStrList.Delete(0);
//      end;
//      FStrList.Clear;
//      while not EOF do
//      begin
//        if FOwnerFrame.FParar then
//        begin
//          Abort;
//        end;
//        FStrList.AddObject(
//          Fields.AsString[0]+';',
//          TSQLObj.Create(
//            Fields.AsString[0],
//            Format('UPDATE RDB$RPL_COMMITED SET LOG = %d WHERE IDENTIFICADOR = ''%s'';',[Fields.AsInteger[1],FOwnerFrame.FIdentOrigem]),
//            Fields.AsInteger[1])
//        );
//        Next;
//      end;
//      Synchronize(MyOutputScript);
//    finally
//      Close(etmCommitRetaining);
//      lTrans.Free;
//      Free;
//    end;
//  end;
//end;


procedure thReplic.GerarScript2;
var
 lTrans  : TuibTransaction;
 ALogIni : integer;
begin
  while FStrList.Count>0 do
  begin
    FStrList.Objects[0].Free;
  end;
  FStrList.Clear;

  ALogIni := FUltimaAlteracao + 1;

  DoConnect;
  lTrans := TuibTransaction.Create(nil);
  lTrans.Options  := [tpNowait, tpReadCommitted, tpRecVersion];
  lTrans.DataBase := FdbOrigem;

  with TuibQuery.Create(nil) do
  begin
    try
      DataBase    := FdbOrigem;
      Transaction := lTrans;
      FetchBlobs  := True;
      SQL.Text    := Format('SELECT FIRST %d LOG_ID, XML FROM RDB$RPL_CHANGES_XML',[Max(FOwnerFrame.edtQtde.AsInteger,10)]);
      SQL.Add(Format('WHERE LOG_ID >= %d ORDER BY LOG_ID',[ALogIni]));
      Open;

      while not EOF do
      begin
        FOwnerFrame.ResetWatchDog;
        if FOwnerFrame.FParar then
        begin
          Abort;
        end;

        doXmlToSQL(Fields.ByNameAsString['XML']);


        Next;
      end;
      Synchronize(MyOutputScript);
    finally
      Close(etmCommitRetaining);
      lTrans.Free;
      Free;
    end;
  end;
end;


procedure thReplic.MyChangeImageIndex;
begin
  TMyTabSheet(FOwnerFrame.Owner).ImageIndex := FImageIndex;
end;

procedure thReplic.MyClearOutputScript;
begin
  FOwnerFrame.mmoScript.Lines.Clear;
end;

function thReplic.MyGetSQLFmt(ADB: TuibDataBase; const ASQL: String; const Args: array of const): Variant;
var
  lTrans : TuibTransaction;
begin
  if not ADB.Connected then ADB.Connected := True;
  lTrans := TuibTransaction.Create(nil);
  lTrans.Options  := [tpNowait, tpReadCommitted, tpRecVersion];
  lTrans.DataBase := ADB;
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase    := ADB;
      Transaction := lTrans;
      SQL.Text    := Format(ASQL,Args);
      Open;
      if Fields.RecordCount=0 then
        Result := NULL
      else
        Result := Fields.AsVariant[0];
    finally
      Close(etmCommitRetaining);
      lTrans.Free;
      Free;
    end;
  end;
end;

function thReplic.MyGetSQLFmt2(ADB: TuibDataBase; const ASQL: String;
  const Args: array of const): Variant;
var
  lTrans : TuibTransaction;
  i :integer;
begin
  if not ADB.Connected then ADB.Connected := True;
  lTrans := TuibTransaction.Create(nil);
  lTrans.Options  := [tpNowait, tpReadCommitted, tpRecVersion];
  lTrans.DataBase := ADB;
  with TuibQuery.Create(nil) do
  begin
    try
      DataBase    := ADB;
      Transaction := lTrans;
      SQL.Text    := Format(ASQL,Args);
      Open;
      if Fields.FieldCount = 1 then
      begin
        Result := Fields.AsVariant[0]
      end else
      begin
        Result := VarArrayCreate([0,Fields.FieldCount],varVariant);
        for i:=0 to Fields.FieldCount-1 do
          Result[i] := Fields.AsVariant[i];
      end;
    finally
      Close(etmCommitRetaining);
      lTrans.Free;
      Free;
    end;
  end;
end;


procedure thReplic.MyOutputScript;
begin
  FOwnerFrame.mmoScript.Lines.Assign(FStrList);
end;

procedure thReplic.MyProgress;
begin
  FOwnerFrame.lblProgress.Caption := Format('%d de %d',[FAtual+1,FStrList.Count]);
end;

procedure thReplic.MyShowCommited;
begin
  FOwnerFrame.lblProgress.Caption := FOwnerFrame.lblProgress.Caption + ' Commited...';
end;

procedure thReplic.MyShowMessage;
begin
  while FOwnerFrame.mmoMessages.Lines.Count>=100 do
  begin
    FOwnerFrame.mmoMessages.Lines.Delete(0);
  end;

  if (FOwnerFrame.mmoMessages.Lines.Count>0) and
     (Pos(sPRONTO_NENHUMA,FMessage)>0) and
     (Pos(sPRONTO_NENHUMA,FOwnerFrame.mmoMessages.Lines[FOwnerFrame.mmoMessages.Lines.Count-1])>0) then
  begin
    FOwnerFrame.mmoMessages.Lines.Delete(FOwnerFrame.mmoMessages.Lines.Count-1);
  end;
  //Count-1 pois a ultima linha eh um espaco em branco

  FOwnerFrame.AddToMessage(FMessage);
  SendMessage(FOwnerFrame.mmoMessages.Handle, EM_SETSEL, -1, -1);
  SendMessage(FOwnerFrame.mmoMessages.Handle, EM_SCROLLCARET, 0, 0);
end;

procedure thReplic.MyShowMessageWithAlert;
begin
  with TJvDesktopAlert.Create(nil) do
  begin
    AutoFree := True;
    HeaderText  := FOwnerFrame.dbxml.Root.Items.Value('desc');
    MessageText := FMessage;
    StyleOptions.DisplayDuration := 10000;
    Execute;
  end;
end;

procedure thReplic.MyTerminate(Sender: TObject);
var
  lLocalPath : String;
  lLogPath   : String;
  lFileName  : String;
begin
  if FAlteracoesDisponiveis = 0 then
  begin
    FMessage      := '<color=clBlack><b>'+sPRONTO_NENHUMA+'</b></color>';
    Synchronize(MyShowMessage);
  end else if FOwnerFrame.FWatchDog <= 0 then
  begin
    FMessage      := '<color=clBlack><b>Terminado por inatividade</b></color>';
    Synchronize(MyShowMessage);
  end else
  begin
    FMessage      := '<color=clBlack><b>'+sPRONTO+'</b></color>';
    Synchronize(MyShowMessage);
  end;


  if FStrList.Count>0 then
  begin
    lLocalPath := ExtractFilePath(ParamStr(0));
    lLogPath   := lLocalPath+'Logs\'+FOwnerFrame.cfgxml.Root.Items.Value('nome');
    if not DirectoryExists(lLocalPath+'Logs') then
      CreateDir(lLocalPath+'Logs');
    if not DirectoryExists(lLogPath) then
      CreateDir(lLogPath);
    lFileName := lLogPath+'\'+FormatDateTime('yyyy-mm-dd-hh-nn-ss',Now)+'.sql';

    FStrList.SaveToFile(lFileName);
    while FStrList.Count>0 do
    begin
      FStrList.Objects[0].Free;
      FStrList.Delete(0);
    end;
    FStrList.Clear;
  end;


  FTrans.Free;
  FdbOrigem.Connected := false;
  FdbDestino.Connected := false;
  FdbOrigem.Free;
  FdbDestino.Free;

  FOwnerFrame.timerrestante.Enabled := true;
  FOwnerFrame.FTempoRestante := FOwnerFrame.edtTempoTimer.AsInteger;
  FOwnerFrame.FRunning := false;



end;

{ TSQLObj }

constructor TSQLObj.Create(ASQL, ASQLControle: string; ALogID : integer);
begin
  inherited Create;
  FSQL         := ASQL;
  FSQLControle := ASQLControle;
  FLogID       := ALogID;
end;

procedure TframeMemos.timerrestanteTimer(Sender: TObject);
begin
  if not btnAuto.Down then Exit;

  if FParar then
  begin
    timerrestante.Enabled := false;
    lblTempoRestante.Caption := '';
    btnAuto.Down    := false;
    Exit;
  end;

  Dec(FTempoRestante,1);

  lblTempoRestante.Caption := Format('Próxima em %ds',[FTempoRestante]);

  if FTempoRestante > 0 then Exit;

  FThread := thReplic.Create(Self,true);
  FThread.Resume;
end;

procedure TframeMemos.edtTempoTimerChange(Sender: TObject);
begin
  FTempoRestante := Max(15,edtTempoTimer.AsInteger);
end;

procedure TframeMemos.btnStopNowClick(Sender: TObject);
begin
  AddToMessage(sFECHANDO);
  FParar := true;
end;

procedure TframeMemos.btnErrosClick(Sender: TObject);
var
  lDlg : TdlgIgnorarErros;
begin
  lDlg      := TdlgIgnorarErros.Create(Self);
  lDlg.Top  := Application.MainForm.Top + 10;
  lDlg.Left := Application.MainForm.Left + Application.MainForm.Width - lDlg.Width - 10;
  lDlg.Show;

end;

constructor TframeMemos.Create(AOwner: TComponent; AFileName : string);
begin
  inherited Create(AOwner);
  FFileName := AFileName;
  ResetWatchDog;

  cfgxml.LoadFromFile(AFileName);

  FTempoRestante := 15;

  lblTempoRestante.Caption := '';


{$IFDEF WITH_OPTIMIZER}
  edtOptimizer.Visible := true;
  chkOptimizer.Visible := true;
{$ENDIF}
end;

procedure TframeMemos.timeraliveTimer(Sender: TObject);
begin
  Dec(FWatchDog);
  if (FWatchDog <= 0) and FRunning then
  begin
    ForceTerminate(FThread);
    timerrestante.Enabled := true;
    FTempoRestante := edtTempoTimer.AsInteger;
    AddToMessage(sINATIVIDADE);
  end;
end;

procedure TframeMemos.ResetWatchDog;
begin
  FWatchDog := 60 * MIN_WATCHDOG;
end;

procedure TframeMemos.AddToMessage(AText: string);
begin
  AddColorLineToRich(Format('<color=clGray>%s: </color>%s',[FormatDateTime('dd/mmm hh:nn:ss',Now),AText]),mmoMessages);
end;

procedure TframeMemos.ForceTerminate(var AThread: thReplic);
begin
  if Assigned(AThread) then
  begin
    AThread.Terminate;
    AThread := nil;
  end;
  FRunning := false;
  FParar   := false;  
end;

end.

