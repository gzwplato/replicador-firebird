unit uIgnorarErros;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, JvExCheckLst, JvCheckListBox;

type
  TdlgIgnorarErros = class(TForm)
    chkList: TJvCheckListBox;
    procedure chkListClickCheck(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
  public
  end;

var
  dlgIgnorarErros: TdlgIgnorarErros;

implementation

uses JvSimpleXml, uframeMemos;

{$R *.dfm}

procedure TdlgIgnorarErros.chkListClickCheck(Sender: TObject);
begin
  if chkList.ItemIndex >= 0 then
  begin
    with TframeMemos(Owner) do
    begin
      if chkList.Checked[chkList.ItemIndex] then
        Include(FErros,TTiposErros(chkList.ItemIndex))
      else
        Exclude(FErros,TTiposErros(chkList.ItemIndex));
    end;
  end;
end;

procedure TdlgIgnorarErros.FormCreate(Sender: TObject);
begin
  chkList.Clear;
  chkList.Items.Add('Ignorar Erros de Primary Key');
  chkList.Items.Add('Ignorar Erros de Foreign Key');
  chkList.Items.Add('Reparar Erros de Foreign Key');
  chkList.Items.Add('Ignorar Erros de Qualquer Outro Tipo');
  with TframeMemos(Owner) do
  begin
    chkList.Checked[0] := teIgnorarErroPK in FErros;
    chkList.Checked[1] := teIgnorarErroFK in FErros;
    chkList.Checked[2] := teRepararErroFK in FErros;
    chkList.Checked[3] := teIgnorarErroOutros in FErros;
  end;
end;

procedure TdlgIgnorarErros.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TdlgIgnorarErros.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  with TframeMemos(Owner) do
  begin
    if not FileExists(FFileName) then Exit;
    cfgxml.LoadFromFile(FFileName);
    cfgxml.Root.Items.ItemNamed['ignorarerrospk'].BoolValue := teIgnorarErroPK in FErros;
    cfgxml.Root.Items.ItemNamed['ignorarerrosfk'].BoolValue := teIgnorarErroFK in FErros;
    cfgxml.Root.Items.ItemNamed['repararerrosfk'].BoolValue := teRepararErroFK in FErros;
    cfgxml.Root.Items.ItemNamed['ignorarerrosoutros'].BoolValue := teIgnorarErroOutros in FErros;
    cfgxml.SaveToFile(FFileName);
  end;
end;

end.


