unit udlgSentinelaConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ExtCtrls, pngimage, JvSimpleXml, Mask, JvExMask,
  JvSpin, AppEvnts, uiblib, JvExStdCtrls, JvHtControls, PngFunctions;

type
  TdlgSentinelaConfig = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    edtNome: TLabeledEdit;
    edtDesc: TLabeledEdit;
    edtPathOrigem: TLabeledEdit;
    edtFilialOrigem: TLabeledEdit;
    edtLibOrigem: TLabeledEdit;
    edtPathDestino: TLabeledEdit;
    edtFilialDestino: TLabeledEdit;
    edtLibDestino: TLabeledEdit;
    chkAuto: TCheckBox;
    Label1: TLabel;
    Panel1: TPanel;
    imgCancel: TImage;
    imgOk: TImage;
    xml: TJvSimpleXML;
    imgOkAs: TImage;
    savedlg: TSaveDialog;
    edtIntervalo: TJvSpinEdit;
    edtPassDestino: TLabeledEdit;
    edtUserDestino: TLabeledEdit;
    edtUserOrigem: TLabeledEdit;
    edtPassOrigem: TLabeledEdit;
    edtPassSYSDBADestino: TLabeledEdit;
    edtPassSYSDBAOrigem: TLabeledEdit;
    appevnt: TApplicationEvents;
    lblInfo: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    cbxCharSetOrigem: TComboBox;
    cbxCharSetDestino: TComboBox;
    Label7: TLabel;
    Label8: TLabel;
    lblInfoInterval: TJvHTLabel;
    procedure imgCancelClick(Sender: TObject);
    procedure imgOkClick(Sender: TObject);
    procedure imgOkAsClick(Sender: TObject);
    procedure appevntMessage(var Msg: tagMSG; var Handled: Boolean);
  private
    { Private declarations }
  public
    FFileName : string;
    procedure SetXml;
    procedure PopulateComboCharSets;
    constructor Create(AOwner : TComponent; AFileName : string); reintroduce;
  end;

var
  dlgSentinelaConfig: TdlgSentinelaConfig;

implementation

uses uCrypt;



{$R *.dfm}

procedure TdlgSentinelaConfig.imgCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgSentinelaConfig.imgOkClick(Sender: TObject);
begin
  SetXml;
  xml.SaveToFile(FFileName);
  ModalResult := mrOk;
end;

procedure TdlgSentinelaConfig.imgOkAsClick(Sender: TObject);
begin
  SetXml;
  if savedlg.Execute then
  begin
    FFileName := savedlg.FileName;
    xml.SaveToFile(FFileName);
  end;
  ModalResult := mrOk;
end;

procedure TdlgSentinelaConfig.SetXml;
begin
  xml.Root.Name := 'sentinela5';
  xml.Root.Items.ItemNamed['timeinterval'].IntValue  := edtIntervalo.AsInteger;
  xml.Root.Items.ItemNamed['automatico'].BoolValue   := chkAuto.Checked;
  xml.Root.Items.ItemNamed['nome'].Value             := edtNome.Text;
  xml.Root.Items.ItemNamed['desc'].Value             := edtDesc.Text;
  with xml.Root.Items.ItemNamed['dborigem'] do
  begin
    Items.ItemNamed['identificador'].Value      := edtFilialOrigem.Text;
    Items.ItemNamed['database'].Value           := edtPathOrigem.Text;
    Items.ItemNamed['libraryname'].Value        := edtLibOrigem.Text;
    Items.ItemNamed['usuarioreplicacao'].Value  := edtUserOrigem.Text;
    Items.ItemNamed['passwordreplicacao'].Value := Encrypt(edtPassOrigem.Text);
    Items.ItemNamed['passwordadmin'].Value      := Encrypt(edtPassSYSDBAOrigem.Text);
    Items.ItemNamed['charset'].Value            := cbxCharSetOrigem.Items[cbxCharSetOrigem.ItemIndex];
  end;
  with xml.Root.Items.ItemNamed['dbdestino'] do
  begin
    Items.ItemNamed['identificador'].Value      := edtFilialdestino.Text;
    Items.ItemNamed['database'].Value           := edtPathdestino.Text;
    Items.ItemNamed['libraryname'].Value        := edtLibdestino.Text;
    Items.ItemNamed['usuarioreplicacao'].Value  := edtUserDestino.Text;
    Items.ItemNamed['passwordreplicacao'].Value := Encrypt(edtPassDestino.Text);
    Items.ItemNamed['passwordadmin'].Value      := Encrypt(edtPassSYSDBADestino.Text);
    Items.ItemNamed['charset'].Value            := cbxCharSetDestino.Items[cbxCharSetDestino.ItemIndex];
  end;
end;

constructor TdlgSentinelaConfig.Create(AOwner: TComponent;
  AFileName: string);
begin
  inherited Create(AOwner);

  PopulateComboCharSets;

  if not FileExists(AFileName) then Exit;
  xml.LoadFromFile(AFileName);
  FFileName             := AFileName;
  edtNome.Text          := xml.Root.Items.Value('nome');
  edtDesc.Text          := xml.Root.Items.Value('desc');
  edtIntervalo.Value    := xml.Root.Items.IntValue('timeinterval',15);
  chkAuto.Checked       := xml.Root.Items.BoolValue('automatico',false);

  edtPathOrigem.Text    := xml.Root.Items.ItemNamed['dborigem'].Items.Value('database');
  edtFilialOrigem.Text  := xml.Root.Items.ItemNamed['dborigem'].Items.Value('identificador');
  edtLibOrigem.Text     := xml.Root.Items.ItemNamed['dborigem'].Items.Value('libraryname');
  edtUserOrigem.Text    := xml.Root.Items.ItemNamed['dborigem'].Items.Value('usuarioreplicacao');
  edtPassOrigem.Text       := Decrypt(xml.Root.Items.ItemNamed['dborigem'].Items.Value('passwordreplicacao'));
  edtPassSYSDBAOrigem.Text := Decrypt(xml.Root.Items.ItemNamed['dborigem'].Items.Value('passwordadmin'));

  edtPathDestino.Text   := xml.Root.Items.ItemNamed['dbdestino'].Items.Value('database');
  edtFilialDestino.Text := xml.Root.Items.ItemNamed['dbdestino'].Items.Value('identificador');
  edtLibDestino.Text    := xml.Root.Items.ItemNamed['dbdestino'].Items.Value('libraryname');
  edtUserDestino.Text   := xml.Root.Items.ItemNamed['dbdestino'].Items.Value('usuarioreplicacao');
  edtPassDestino.Text       := Decrypt(xml.Root.Items.ItemNamed['dbdestino'].Items.Value('passwordreplicacao'));
  edtPassSYSDBADestino.Text := Decrypt(xml.Root.Items.ItemNamed['dbdestino'].Items.Value('passwordadmin'));



  cbxCharSetOrigem.ItemIndex := cbxCharSetOrigem.Items.IndexOf(xml.Root.Items.ItemNamed['dborigem'].Items.Value('charset','NONE'));
  cbxCharSetDestino.ItemIndex := cbxCharSetDestino.Items.IndexOf(xml.Root.Items.ItemNamed['dbdestino'].Items.Value('charset','NONE'));
end;

procedure TdlgSentinelaConfig.appevntMessage(var Msg: tagMSG;
  var Handled: Boolean);
var
  lOk : Boolean;
begin



  if edtIntervalo.Value < 15 then
    lblInfoInterval.Caption := 'Não pode ser <font color=clred>menor que 15</font>'
  else if edtIntervalo.Value > 999 then
    lblInfoInterval.Caption := 'Não pode ser <font color=clred>maior que 999</font>'
  else
    lblInfoInterval.Caption := '';

  lOk := (lblInfoInterval.Caption = '');

  imgOkAs.Visible := lOk;
  imgOk.Visible   := (FFileName<>'') and FileExists(FFileName) and lOk;

end;

procedure TdlgSentinelaConfig.PopulateComboCharSets;
var
  i : TCharacterSet;
begin
  cbxCharSetOrigem.Items.Clear;
  cbxCharSetDestino.Items.Clear;
  for i:=Low(CharacterSetStr) to High(CharacterSetStr) do
  begin
    cbxCharSetOrigem.Items.Add(CharacterSetStr[i]);
    cbxCharSetDestino.Items.Add(CharacterSetStr[i]);
  end;
  cbxCharSetOrigem.ItemIndex := 0;
  cbxCharSetDestino.ItemIndex := 0;
end;

end.

