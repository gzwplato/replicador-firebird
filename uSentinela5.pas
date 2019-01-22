unit uSentinela5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, JvExComCtrls, JvComCtrls, ExtCtrls, 
  JvSimpleXml, StdCtrls, JvComponent, JvTrayIcon, AppEvnts, JvComponentBase,ShellAPI,
  Menus, Buttons, PngSpeedButton, pngimage, PngFunctions;

type
  TfrmSentinela5 = class(TForm)
    pnlTop: TPanel;
    pc: TJvPageControl;
    btnExec: TPngSpeedButton;
    PNGButton2: TPngSpeedButton;
    opendlg: TOpenDialog;
    xml: TJvSimpleXML;
    btnEdit: TPngSpeedButton;
    PNGButton4: TPngSpeedButton;
    tray: TJvTrayIcon;
    appevnt: TApplicationEvents;
    imgButton: TImage;
    imgRun: TImage;
    imgIdle: TImage;
    imgErro: TImage;
    edtAbout: TPngSpeedButton;
    mnuTrayPopup: TPopupMenu;
    mnuSobre: TMenuItem;
    N1: TMenuItem;
    mnuRestaurar: TMenuItem;
    mnuMinimizar: TMenuItem;
    N2: TMenuItem;
    mnuFechar: TMenuItem;
    procedure PNGButton2Click(Sender: TObject);
    procedure btnExecClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure PNGButton4Click(Sender: TObject);
    procedure appevntMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure pcDrawTab(Control: TCustomTabControl; TabIndex: Integer;
      const Rect: TRect; Active: Boolean);
    procedure pcMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pcMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtAboutClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure mnuSobreClick(Sender: TObject);
    procedure mnuRestaurarClick(Sender: TObject);
    procedure mnuMinimizarClick(Sender: TObject);
    procedure mnuFecharClick(Sender: TObject);
    procedure mnuTrayPopupPopup(Sender: TObject);
  private
    procedure DropFiles(var Msg: TMessage);
    procedure AbreArquivo(const AFileName : string);
    procedure ShowAbout;
    procedure CloseTab(AIdx : integer);
  public
    { Public declarations }
  end;

var
  frmSentinela5      : TfrmSentinela5;
  vOldWindowProc     : TWndMethod;
  vFirstTimeActivate : Boolean = true;
  vBatchParam        : integer = 0;
  vTimeParam         : integer = 0;


implementation

uses uframeMemos, udlgSentinelaConfig, JvSpin, uib, uSobre, uCrypt;

{$R *.dfm}

procedure TfrmSentinela5.PNGButton2Click(Sender: TObject);
begin
  if opendlg.Execute then
  begin
    AbreArquivo(opendlg.FileName);
  end;
end;

procedure TfrmSentinela5.btnExecClick(Sender: TObject);
var
  lTmp : TMyTabSheet;
begin
  lTmp := TMyTabSheet(pc.ActivePage);
  lTmp.FOwnerFrame.FThread := thReplic.Create(lTmp.FOwnerFrame,true);
  lTmp.FOwnerFrame.FThread.Resume;
end;

procedure TfrmSentinela5.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  i : integer;
begin
  try
    for i:=0 to pc.PageCount-1 do
    begin
      CloseTab(0);
    end;
  finally
    CanClose := true;
  end;
end;

procedure TfrmSentinela5.AbreArquivo(const AFileName: string);
var
  lTs : TMyTabSheet;
begin
  if not FileExists(AFileName) then Exit;
    try
      xml.LoadFromFile(AFileName);
      lTs := TMyTabSheet.Create(pc);
      lTs.Parent      := pc;
      lTs.PageControl := pc;
      lTs.FOwnerFrame := TframeMemos.Create(lTs,AFileName);
      pc.ActivePage := lTs;
      with lTs.FOwnerFrame do
      begin
        Parent := lTs;
        Align  := alClient;
        if vTimeParam > 0 then
          edtTempoTimer.AsInteger:=vTimeParam
        else
          edtTempoTimer.AsInteger:= xml.Root.Items.IntValue('timeinterval',15);

        if vBatchParam > 0 then
          edtQtde.AsInteger := vBatchParam;


        timerrestante.Enabled  := xml.Root.Items.BoolValue('automatico',false);
        btnAuto.Down           := xml.Root.Items.BoolValue('automatico',false);
        lTs.Caption            := xml.Root.Items.Value('nome');
        lblDesc.Caption        := xml.Root.Items.Value('desc');
        if xml.Root.Items.IndexOf('ignorarerrospk')>=0 then
        begin
          if xml.Root.Items.ItemNamed['ignorarerrospk'].BoolValue then
            Include(FErros,teIgnorarErroPK);
        end else
        begin
          Include(FErros,teIgnorarErroPK);//default
        end;

        if xml.Root.Items.ItemNamed['ignorarerrosfk'].BoolValue then
          Include(FErros,teIgnorarErroFK);
        if xml.Root.Items.ItemNamed['ignorarerrosoutros'].BoolValue then
          Include(FErros,teIgnorarErroOutros);
        if xml.Root.Items.ItemNamed['repararerrosfk'].BoolValue then
          Include(FErros,teRepararErroFK);

      end;
    except
      MessageDlg('Arquivo inválido', mtWarning, [mbOK], 0);
    end;
end;

procedure TfrmSentinela5.FormCreate(Sender: TObject);

begin
  vOldWindowProc := pc.WindowProc;
  pc.WindowProc  := DropFiles;
  DragAcceptFiles(pc.Handle, true);


  Self.Caption := Application.Title + ' 1.0.12';
end;

procedure TfrmSentinela5.btnEditClick(Sender: TObject);
var
  lCfg : TdlgSentinelaConfig;
begin
  with TMyTabSheet(pc.ActivePage).FOwnerFrame do
  begin
    lCfg := TdlgSentinelaConfig.Create(Self,FFileName);
    try
      if lCfg.ShowModal= mrOk then
      begin
        TMyTabSheet(pc.ActivePage).Caption :=  lCfg.edtNome.Text;
        edtTempoTimer.AsInteger            :=  lCfg.edtIntervalo.AsInteger;
        lblDesc.Caption                    :=  lCfg.edtDesc.Text;
        timerrestante.Enabled                    :=  lCfg.chkAuto.Checked;
        cfgxml.LoadFromFile(FFileName);
      end;
    finally
      lCfg.Free;
    end;
  end;
end;

procedure TfrmSentinela5.PNGButton4Click(Sender: TObject);
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

procedure TfrmSentinela5.appevntMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin
  btnExec.Enabled := (pc.ActivePageIndex>=0) and (not TMyTabSheet(pc.ActivePage).FOwnerFrame.FRunning);
  btnEdit.Enabled := btnExec.Enabled;
end;

procedure TfrmSentinela5.pcDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  lTH      : integer;
  lCaption : string;
  lRect,lRect2    : TRect;
  function Metade(ARect : TRect; AHeight : integer) : integer;
  begin
    Result := ((ARect.Bottom - ARect.Top) div 2) - (AHeight div 2) + ARect.Top;
  end;
begin
  Control.Canvas.Brush.Color := clBtnFace;
  Control.Canvas.FillRect(Rect);
  Control.Canvas.Font.Size := 7;
  if Active then
    Control.Canvas.Font.Style := [fsBold];

  lCaption := pc.Pages[TabIndex].Caption;
  lTH      := Control.Canvas.TextHeight(lCaption);
  Control.Canvas.TextOut(Rect.Left+5, Metade(Rect,lTh) ,lCaption);

  lRect  := Classes.Rect(Rect.Right-16-5, Metade(Rect,16), Rect.Right-5, Metade(Rect,16)+16);
  lRect2 := Classes.Rect(Rect.Right-16-26, Metade(Rect,16), Rect.Right-26, Metade(Rect,16)+16);
  TPngImage(imgButton.Picture.Graphic).Draw(Control.Canvas,lRect);
  case pc.Pages[TabIndex].ImageIndex of
  0 : TPngImage(imgRun.Picture.Graphic).Draw(Control.Canvas,lRect2);
  1 : TPngImage(imgIdle.Picture.Graphic).Draw(Control.Canvas,lRect2);
  2 : TPngImage(imgErro.Picture.Graphic).Draw(Control.Canvas,lRect2);
  end;


end;

procedure TfrmSentinela5.pcMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var tab:integer;
begin
  tab := pc.IndexOfTabAt(X,Y);
  pc.Tag:=tab;
  if (tab<>-1) and (tab<pc.PageCount) and (pc.TabRect(tab).Right-X<16+5) then
  begin
    pc.Tag:=tab;
    pc.Pages[tab].Tag:=1;
//    pc.Repaint;
  end;
end;

procedure TfrmSentinela5.pcMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var tab:integer;
begin
  try
    if (pc.Tag<>-1) then
    begin
//      pc.Repaint;
      tab := pc.IndexOfTabAt(X,Y);
      if (tab<pc.PageCount) then
      begin
        if (tab=pc.Tag) and (pc.Pages[pc.Tag].Tag=1) and (pc.TabRect(tab).Right-X<16+5) then
        begin
          CloseTab(tab);
          pc.SelectNextPage(true);
          pc.Pages[pc.Tag].Free;
        end else
        begin
          pc.Pages[pc.Tag].Tag:=0;
        end;
      end;
    end;
  finally

  end;
end;

procedure TfrmSentinela5.edtAboutClick(Sender: TObject);
begin
  ShowAbout;
end;

procedure TfrmSentinela5.DropFiles(var Msg: TMessage);
var
  Ind, Quant, Tamanho: integer;
  Arquivo: pchar;
  Path : String;
begin
  inherited;
  if Msg.Msg = WM_DROPFILES then
  begin
    Quant := DragQueryFile(Msg.WParam, $FFFFFFFF, Arquivo, 255) - 1;
    for Ind := 0 to Quant do
    begin
      Tamanho := DragQueryFile(Msg.WParam, Ind, nil, 0) + 1;
      Arquivo := StrAlloc(Tamanho);
      DragQueryFile(Msg.WParam, Ind, Arquivo, Tamanho);
      Path := StrPas(Arquivo);
      if CompareText(ExtractFileExt(Path),'.xml')=0 then
      begin
        AbreArquivo(Path);
      end;
      StrDispose(Arquivo);
    end;
    DragFinish(Msg.WParam);
  end else
  begin
    vOldWindowProc(Msg);
  end;

end;

procedure TfrmSentinela5.FormActivate(Sender: TObject);
var
  i : integer;
  lCurrentParam : PChar;

begin
  if not vFirstTimeActivate then Exit;

  vFirstTimeActivate := false;

  for i:=1 to ParamCount do
  begin
    lCurrentParam := PChar(ParamStr(i));
    if CompareText(ParamStr(i),'-s')=0 then
    begin
      mnuFechar.Enabled    := false;
      mnuRestaurar.Enabled := false;
      mnuMinimizar.Enabled := false;
      tray.Visibility      := tray.Visibility - [tvRestoreDbClick,tvMinimizeDbClick];
    end else if CompareText(ParamStr(i),'-m')=0 then
    begin
      tray.HideApplication;
    end else if StrLIComp(lCurrentParam,'-b',2)=0 then
    begin
      vBatchParam := StrToIntDef( Copy(lCurrentParam,3,StrLen(lCurrentParam)) , 0);
    end else if StrLIComp(lCurrentParam,'-t',2)=0 then
    begin
      vTimeParam  := StrToIntDef( Copy(lCurrentParam,3,StrLen(lCurrentParam)) , 0);
    end else
    begin
      AbreArquivo(ParamStr(i));
    end;
  end;

end;

procedure TfrmSentinela5.mnuSobreClick(Sender: TObject);
begin
  ShowAbout;
end;

procedure TfrmSentinela5.ShowAbout;
begin
  with TdlgSobre.Create(Self) do
  begin
    lblTit.Caption := Self.Caption;
    Show;
  end;
end;

procedure TfrmSentinela5.mnuRestaurarClick(Sender: TObject);
begin
  tray.ShowApplication;
end;

procedure TfrmSentinela5.mnuMinimizarClick(Sender: TObject);
begin
  tray.HideApplication;
end;

procedure TfrmSentinela5.mnuFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSentinela5.CloseTab(AIdx: integer);
var
  i : integer;
  lFrame : TframeMemos;
begin
  i := 1;

  lFrame := TMyTabSheet(pc.Pages[AIdx]).FOwnerFrame;
  lFrame.btnStopNowClick(nil);
  while lFrame.FRunning do
  begin
    SleepEx(100,false);
    Inc(i);
    Application.ProcessMessages;
    if i=50 then
    begin
      lFrame.ForceTerminate(lFrame.FThread);
      lFrame.AddToMessage('Killed.');
      lFrame.Refresh;
      SleepEx(1000,false);
    end;
  end;
end;

procedure TfrmSentinela5.mnuTrayPopupPopup(Sender: TObject);
begin
  if (Windows.GetKeyState(Windows.VK_LSHIFT)<0) and
     (Windows.GetKeyState(Windows.VK_LCONTROL)<0) then
  begin
    mnuRestaurar.Enabled := true;
    mnuFechar.Enabled    := true;
  end;
end;

end.

