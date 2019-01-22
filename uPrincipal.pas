unit uPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvWizard, JvWizardRouteMapList, JvWizardRouteMapNodes,
  JvWizardRouteMapSteps, JvExControls, JvComponent,
  StdCtrls, Grids, Buttons, ExtCtrls, DB, uib, uiblib,
  ImgList, VirtualTrees,
  JvSimpleXml, AppEvnts, PngSpeedButton;

type
  TfrmPrincipal = class(TForm)
    pc: TJvWizard;
    tsWelcome: TJvWizardWelcomePage;
    tsConexao: TJvWizardInteriorPage;
    tsSelecao: TJvWizardInteriorPage;
    tsConfigOrigem: TJvWizardInteriorPage;
    JvWizardRouteMapNodes1: TJvWizardRouteMapNodes;
    tsFim: TJvWizardInteriorPage;
    mmoPrep: TMemo;
    dbOrigem: TuibDataBase;
    mmoSQL: TMemo;
    ImageList1: TImageList;
    Panel1: TPanel;
    btnGravarEspecificacao: TSpeedButton;
    vt: TVirtualStringTree;
    edtPrefix: TEdit;
    Label3: TLabel;
    edtPos: TEdit;
    Label8: TLabel;
    pnlTop: TPanel;
    PNGButton2: TPNGSpeedButton;
    btnEdit: TPNGSpeedButton;
    xml: TJvSimpleXML;
    opendlg: TOpenDialog;
    GroupBox1: TGroupBox;
    dbDestino: TuibDataBase;
    tsConfigDestino: TJvWizardInteriorPage;
    mmoDest: TMemo;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    lblPathOrigem: TLabel;
    lblPathDestino: TLabel;
    ApplicationEvents1: TApplicationEvents;
    Panel3: TPanel;
    Panel4: TPanel;
    btnCriaConfig: TPNGSpeedButton;
    btnRemoveConfig: TPNGSpeedButton;
    edtAbout: TPNGSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    PNGButton1: TPNGSpeedButton;
    Label4: TLabel;
    Label5: TLabel;
    gboxAdvancedOptions: TGroupBox;
    chkUdf: TCheckBox;
    chkBlob: TCheckBox;
    procedure pcCancelButtonClick(Sender: TObject);
    procedure tsConexaoExitPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
    procedure btnGravarEspecificacaoClick(Sender: TObject);
    procedure pcFinishButtonClick(Sender: TObject);
    procedure btnRemoveConfigClick(Sender: TObject);
    procedure btnCriaConfigClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure vtGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean;
      var ImageIndex: Integer);
    procedure vtEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure btnEditClick(Sender: TObject);
    procedure PNGButton4Click(Sender: TObject);
    procedure PNGButton2Click(Sender: TObject);
    procedure vtClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure edtAboutClick(Sender: TObject);
    procedure vtMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure vt2009GetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vt2009IncrmentalSearch(Sender: TBaseVirtualTree;
      Node: PVirtualNode; const SearchText: string; var Result: Integer);
    procedure vt2009NewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: string);
  private
  public
    procedure AbreArquivo(const AFileName: string);
    procedure Reconnect;
    function GetUserReplicacaoOrigem  : string;
    function GetUserReplicacaoDestino : string;
    function GetPassReplicacaoOrigem  : string;
    function GetPassReplicacaoDestino : string;
    function GetPassAdminDestino : string;
    function GetPassAdminOrigem  : string;
    function GetPathOrigem : string;
    function GetPathDestino : string;
    function GetLibOrigem : string;
    function GetLibDestino : string;
    function GetCharSetOrigem : TCharacterSet;
    function GetCharSetDestino : TCharacterSet;


    procedure CriaUsers;
    procedure RemoveUsers;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses uFuncoesReplicacao, Math, udlgSentinelaConfig, uCrypt, uSobre;

{$R *.dfm}

procedure TfrmPrincipal.pcCancelButtonClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmPrincipal.tsConexaoExitPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
  Reconnect;
  if dbOrigem.Connected and dbDestino.Connected then
    Arvore.MontaArvore;
end;

procedure TfrmPrincipal.btnGravarEspecificacaoClick(Sender: TObject);
begin
  mmoPrep.Lines.Clear;
  Arvore.AtualizaBanco(GetUserReplicacaoOrigem,nil);
  Banco.CriaTriggers2(GetUserReplicacaoOrigem,nil);
end;

procedure TfrmPrincipal.pcFinishButtonClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmPrincipal.btnRemoveConfigClick(Sender: TObject);
begin
  Reconnect;
  if not(dbOrigem.Connected and dbDestino.Connected) then Exit;

  if (MessageBox(0, 'Deseja realmente remover as triggers e tabelas de controle do banco de dados origem?', '', MB_ICONQUESTION or MB_YESNO) = idYes) then
  begin
    Banco.RemoveTriggers;
    Banco.RemoveTabelasConfiguracao(dbOrigem);
  end;
  if (MessageBox(0, 'Deseja realmente remover as tabelas de controle do banco de dados destino?', '', MB_ICONQUESTION or MB_YESNO) = idYes) then
  begin
    Banco.RemoveTabelasConfiguracao(dbDestino);
  end;
  if (MessageBox(0, 'Deseja realmente remover os usuários de replicação dos bancos de dados?', '', MB_ICONQUESTION or MB_YESNO) = idYes) then
  begin
    RemoveUsers;
  end;

  tsConexao.VisibleButtons := tsConexao.VisibleButtons - [bkNext];
end;

procedure TfrmPrincipal.btnCriaConfigClick(Sender: TObject);
begin
  Reconnect;
  if not(dbOrigem.Connected and dbDestino.Connected) then Exit;
  
  if (MessageBox(0, 'Deseja realmente criar triggers e tabelas de controle?', '', MB_ICONQUESTION or MB_YESNO) = idYes) then
  begin
    if (MessageBox(0, 'Criar na Origem?', '', MB_ICONQUESTION or MB_YESNO) = idYes) then
      Banco.CriaConfiguracaoOrigem(GetUserReplicacaoOrigem);
    if (MessageBox(0, 'Criar no Destino?', '', MB_ICONQUESTION or MB_YESNO) = idYes) then
      Banco.CriaConfiguracaoDestino(GetUserReplicacaoDestino);
    CriaUsers;
    tsConexao.VisibleButtons := tsConexao.VisibleButtons + [bkNext];    
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  vt.NodeDataSize  := SizeOf(TAdicInfoTree);
  Self.Caption := Application.Title + ' ' + cAppVersion;
end;

procedure TfrmPrincipal.vtGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
var
  Data: PAdicInfoTree;
begin
  if (Kind in [ikNormal, ikSelected]) then
  begin
    ImageIndex := -1;
    Data := Sender.GetNodeData(Node);
    if Assigned(Data) then
    begin
      case Column of
        1 : begin
              ImageIndex := IfThen(Data.FPk,0,1);
              if (Data.FCampo='') then
                ImageIndex := -1
            end;
        2 : ImageIndex := IfThen(Data.FSelected,2,3);
        4 :
          begin
            if Data.FCampo = '' then
              ImageIndex := 4;
          end;
      end;
    end;
  end;

end;

procedure TfrmPrincipal.vtEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  Allowed := Column in ([3,5,6]);
end;

procedure TfrmPrincipal.AbreArquivo(const AFileName: string);
begin
  if not FileExists(AFileName) then Exit;
    try
      xml.LoadFromFile(AFileName);
      lblPathOrigem.Caption := 'Origem: '+ xml.Root.Items.ItemNamed['dborigem'].Items.Value('database');
      lblPathDestino.Caption := 'Destino: '+ xml.Root.Items.ItemNamed['dbdestino'].Items.Value('database');
    except
      MessageDlg('Arquivo inválido', mtWarning, [mbOK], 0);
    end;
end;

procedure TfrmPrincipal.btnEditClick(Sender: TObject);
var
  lCfg : TdlgSentinelaConfig;
begin
  lCfg := TdlgSentinelaConfig.Create(Self,opendlg.FileName);
  try
    if lCfg.ShowModal= mrOk then
    begin
      AbreArquivo(lCfg.FFileName);
    end;
  finally
    lCfg.Free;
  end;
end;

procedure TfrmPrincipal.PNGButton4Click(Sender: TObject);
var
  lCfg : TdlgSentinelaConfig;
begin
  lCfg := TdlgSentinelaConfig.Create(Self,'');
  try
    if lCfg.ShowModal=mrOk then
    begin
      if (MessageBox(0, 'Abrir a nova configuração?', '', MB_ICONQUESTION or MB_YESNO) = idYes) then
        AbreArquivo(lCfg.FFileName);
    end;
  finally
    lCfg.Free;
  end;
end;

procedure TfrmPrincipal.PNGButton2Click(Sender: TObject);
begin
  if opendlg.Execute then
  begin
    AbreArquivo(opendlg.FileName);
  end;
end;

procedure TfrmPrincipal.Reconnect;
begin
  try
    with dbOrigem do
    begin
      Connected    := false;
      CharacterSet := GetCharSetOrigem;
      LibraryName  := GetLibOrigem;
      DatabaseName := GetPathOrigem;
      UserName     := 'SYSDBA';
      PassWord     := GetPassAdminOrigem;
      Connected    := true;
    end;
  except
    on e:exception do
    begin
      if Pos('Your user name and password are not defined',e.Message)>0 then
      begin
        MessageDlg('A senha do SYSDBA da base de origem esta incorreta.', mtError, [mbOK], 0);
        Abort;
      end else
      begin
        raise;
      end;
    end;
  end;
  try
    with dbDestino do
    begin
      Connected    := false;
      CharacterSet := GetCharSetDestino;
      LibraryName  := GetLibDestino;
      DatabaseName := GetPathDestino;
      UserName     := 'SYSDBA';
      PassWord     := GetPassAdminDestino;
      Connected    := true;
    end;
  except
    on e:exception do
    begin
      if Pos('Your user name and password are not defined',e.Message)>0 then
      begin
        MessageDlg('A senha do SYSDBA da base de destino esta incorreta', mtError, [mbOK], 0);
        Abort;
      end else
      begin
        raise;
      end;
    end;
  end;
end;

procedure TfrmPrincipal.vt2009GetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
var
  Data: PAdicInfoTree;
begin
  Data := Sender.GetNodeData(Node);
  if Assigned(Data) then
  begin
    if Column = 0 then
    begin
      if Sender.GetNodeLevel(Node) = 0 then
      begin
        CellText := Data.FTabela;
      end else if Sender.GetNodeLevel(Node) = 1 then
      begin
        CellText := Data.FCampo;
      end;
    end else if Column = 3 then
    begin
      if Data.FCampo = '' then
        CellText := Data.FNewTAbela
      else
        CellText := Data.FNewCampo;
    end else if (Column = 5) and (Data.FCampo='') then
    begin
      CellText := Data.FTriggerName;
    end else if (Column=6) then
    begin
      CellText := Data.FCondicaoExtra;
    end else
    begin
      CellText := '';
    end;

  end;

end;

procedure TfrmPrincipal.vt2009IncrmentalSearch(Sender: TBaseVirtualTree;
  Node: PVirtualNode; const SearchText: string; var Result: Integer);
var
  sCompare1, sCompare2 : string;
  DisplayText : String;
begin
  vt2009GetText( Sender, Node, 0 {Column}, ttNormal, DisplayText );
  sCompare1 := SearchText;
  sCompare2 := DisplayText;

  // By using StrLIComp we can specify a maximum length to compare. This allows us to find also nodes
  // which match only partially. Don't forget to specify the shorter string length as search length.
  Result := StrLIComp( pchar(sCompare1), pchar(sCompare2), Min(Length(sCompare1), Length(sCompare2)) )

end;

procedure TfrmPrincipal.vt2009NewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: string);
var
  Data : PAdicInfoTree;
begin
  Data := Sender.GetNodeData(Node);
  if (Column = 3) and (Data.FCampo='') then
    Data.FNewTAbela := NewText
  else if (Column = 3) and (Data.FCampo<>'') then
    Data.FNewCampo := NewText
  else if (Column = 5) and (Data.FCampo='') then
    Data.FTriggerName := NewText
  else if (Column = 6) then
    Data.FCondicaoExtra := NewText;
end;

procedure TfrmPrincipal.vtClick(Sender: TObject);
var
  Data, DataChild : PAdicInfoTree;
  lTmp : THitInfo;
  x,y : integer;
  lNode : PVirtualNode;
  lSel, lBreaked : Boolean;

begin
  x := vt.ScreenToClient(Mouse.CursorPos).X;
  y := vt.ScreenToClient(Mouse.CursorPos).Y;

  Vt.GetHitTestInfoAt(X,Y,true,lTmp);

  if not Assigned(lTmp.HitNode) then Exit;

  Data := vt.GetNodeData(lTmp.HitNode);

  if not Assigned(Data) then Exit;

  case lTmp.HitColumn of
    1 : Data.FPk       := not Data.FPk;
    2 : Data.FSelected := not Data.FSelected;
    3 : vt.EditNode(lTmp.HitNode, 3);
    4 : if Data.FCampo = '' then
        begin
          pc.SelectNextPage;
          mmoPrep.Lines.Clear;
          Arvore.AtualizaBanco(GetUserReplicacaoOrigem,lTmp.HitNode);
          Banco.CriaTriggers2(GetUserReplicacaoOrigem,lTmp.HitNode);
        end;
  else
    Exit;
  end;
  if lTmp.HitColumn = 3 then Exit;

  if Data.FCampo='' then //Clicado em table
  begin
    lNode := vt.GetFirstChild(lTmp.HitNode);
    while Assigned(lNode) do
    begin
      DataChild           := vt.GetNodeData(lNode);
      DataChild.FSelected := Data.FSelected;
      lNode               := vt.GetNextSibling(lNode);
    end;
    vt.InvalidateChildren(lTmp.HitNode,true);
  end else
  begin
    lNode     := vt.GetFirstChild(vt.GetVisibleParent(lTmp.HitNode));
    DataChild := vt.GetNodeData(lNode);
    lSel      := DataChild.FSelected;
    lBreaked  := false;
    while Assigned(lNode) do
    begin
      DataChild := vt.GetNodeData(lNode);
      if lSel <> DataChild.FSelected then
      begin
        lBreaked := true;
        Break;
      end;
      lNode := vt.GetNextSibling(lNode);
    end;
    Data := vt.GetNodeData(vt.GetVisibleParent(lTmp.HitNode));
    if lBreaked then
      Data.FSelected := true
    else
      Data.FSelected := lSel;

    vt.InvalidateNode(vt.GetVisibleParent(lTmp.HitNode));
    vt.InvalidateChildren(vt.GetVisibleParent(lTmp.HitNode),false);
  end;


end;

function TfrmPrincipal.GetUserReplicacaoOrigem: string;
begin
  Result := xml.Root.Items.ItemNamed['dborigem'].Items.ItemNamed['usuarioreplicacao'].Value;
end;

function TfrmPrincipal.GetPathDestino: string;
begin
  Result := xml.Root.Items.ItemNamed['dbdestino'].Items.Value('database');
end;

function TfrmPrincipal.GetPathOrigem: string;
begin
  Result := xml.Root.Items.ItemNamed['dborigem'].Items.Value('database');
end;

procedure TfrmPrincipal.CriaUsers;
begin
  if Banco.ExisteUser(ExtractHost(GetPathOrigem),GetUserReplicacaoOrigem,GetLibOrigem,GetPassAdminOrigem) then
    Banco.ModificaUserPass(ExtractHost(GetPathOrigem),GetUserReplicacaoOrigem,GetPassReplicacaoOrigem,GetLibOrigem,GetPassAdminOrigem)
  else
    Banco.AdicionaUser(ExtractHost(GetPathOrigem),GetUserReplicacaoOrigem,GetPassReplicacaoOrigem,GetLibOrigem,GetPassAdminOrigem);

  if not Banco.ExisteUser(ExtractHost(GetPathOrigem),GetUserReplicacaoOrigem,GetLibOrigem,GetPassAdminOrigem) then
    MessageDlg('Não foi possível criar o usuário '+GetUserReplicacaoOrigem+' na origem'#13#10'Você pode criar manualmente.', mtWarning, [mbOK], 0);

  if Banco.ExisteUser(ExtractHost(GetPathDestino),GetUserReplicacaoDestino,GetLibDestino,GetPassAdminDestino) then
    Banco.ModificaUserPass(ExtractHost(GetPathDestino),GetUserReplicacaoDestino,GetPassReplicacaoDestino,GetLibDestino,GetPassAdminDestino)
  else
    Banco.AdicionaUser(ExtractHost(GetPathDestino),GetUserReplicacaoDestino,GetPassReplicacaoDestino,GetLibDestino,GetPassAdminDestino);

  if not Banco.ExisteUser(ExtractHost(GetPathDestino),GetUserReplicacaoDestino,GetLibDestino,GetPassAdminDestino) then
    MessageDlg('Não foi possível criar o usuário '+GetUserReplicacaoDestino+' no destino'#13#10'Você pode criar manualmente.', mtWarning, [mbOK], 0);
end;

function TfrmPrincipal.GetPassReplicacaoDestino: string;
begin
  Result := Decrypt(xml.Root.Items.ItemNamed['dbdestino'].Items.ItemNamed['passwordreplicacao'].Value);
end;

function TfrmPrincipal.GetPassReplicacaoOrigem: string;
begin
  Result := Decrypt(xml.Root.Items.ItemNamed['dborigem'].Items.ItemNamed['passwordreplicacao'].Value);
end;

function TfrmPrincipal.GetUserReplicacaoDestino: string;
begin
  Result := xml.Root.Items.ItemNamed['dbdestino'].Items.ItemNamed['usuarioreplicacao'].Value;
end;

function TfrmPrincipal.GetLibDestino: string;
begin
  Result := xml.Root.Items.ItemNamed['dbdestino'].Items.Value('libraryname');
end;

function TfrmPrincipal.GetLibOrigem: string;
begin
  Result := xml.Root.Items.ItemNamed['dborigem'].Items.Value('libraryname');
end;

function TfrmPrincipal.GetPassAdminDestino: string;
begin
  Result := Decrypt(xml.Root.Items.ItemNamed['dbdestino'].Items.ItemNamed['passwordadmin'].Value);
end;

function TfrmPrincipal.GetPassAdminOrigem: string;
begin
  Result := Decrypt(xml.Root.Items.ItemNamed['dborigem'].Items.ItemNamed['passwordadmin'].Value);
end;

procedure TfrmPrincipal.SpeedButton1Click(Sender: TObject);
begin
  Banco.ModificaTriggersDestino(GetUserReplicacaoDestino);
end;

procedure TfrmPrincipal.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  btnEdit.Enabled          := (pc.ActivePage = tsConexao) and (GetPathOrigem<>'') and (GetPathDestino<>'');
  btnCriaConfig.Enabled    := btnEdit.Enabled;
  btnRemoveConfig.Enabled  := btnEdit.Enabled;
  if btnEdit.Enabled then
    tsConexao.EnabledButtons := tsConexao.EnabledButtons + [bkNext]
  else
    tsConexao.EnabledButtons := tsConexao.EnabledButtons - [bkNext];
end;

procedure TfrmPrincipal.RemoveUsers;
begin
  if Banco.ExisteUser(ExtractHost(GetPathOrigem),GetUserReplicacaoOrigem,GetLibOrigem,GetPassAdminOrigem) then
    Banco.RemoveUser(ExtractHost(GetPathOrigem),GetUserReplicacaoOrigem,GetLibOrigem,GetPassAdminOrigem);
  if Banco.ExisteUser(ExtractHost(GetPathDestino),GetUserReplicacaoDestino,GetLibDestino,GetPassAdminDestino) then
    Banco.RemoveUser(ExtractHost(GetPathDestino),GetUserReplicacaoDestino,GetLibDestino,GetPassAdminDestino);
end;

procedure TfrmPrincipal.edtAboutClick(Sender: TObject);
begin
  with TdlgSobre.Create(Self) do
  begin
    lblTit.Caption := Self.Caption;
    Show;
  end;
end;

function TfrmPrincipal.GetCharSetDestino: TCharacterSet;
begin
  Result := StrToCharacterSet(xml.Root.Items.ItemNamed['dbdestino'].Items.Value('charset','NONE'));
end;

function TfrmPrincipal.GetCharSetOrigem: TCharacterSet;
begin
  Result := StrToCharacterSet(xml.Root.Items.ItemNamed['dborigem'].Items.Value('charset','NONE'));
end;

procedure TfrmPrincipal.vtMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
//  Data : PAdicInfoTree;
  lTmp : THitInfo;


begin
//  x := vt.ScreenToClient(Mouse.CursorPos).X;
//  y := vt.ScreenToClient(Mouse.CursorPos).Y;
  Vt.GetHitTestInfoAt(X,Y,true,lTmp);
//  if not Assigned(lTmp.HitNode) then Exit;
//  Data := vt.GetNodeData(lTmp.HitNode);
//  if not Assigned(Data) then Exit;
  case lTmp.HitColumn of
    1,2,4 : Screen.Cursor := crHandPoint;
  else
    Screen.Cursor := crDefault;
  end;
end;

end.



