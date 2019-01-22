program ReplicadorFirebird;

uses
  FastMM4,
  Forms,
  uSentinela5 in 'uSentinela5.pas' {frmSentinela5},
  uframeMemos in 'uframeMemos.pas' {frameMemos: TFrame},
  udlgSentinelaConfig in 'udlgSentinelaConfig.pas' {dlgSentinelaConfig},
  uCrypt in 'uCrypt.pas',
  uSobre in 'uSobre.pas' {dlgSobre},
  uIgnorarErros in 'uIgnorarErros.pas' {dlgIgnorarErros},
  uXml in 'uXml.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Replicador Firebird';
  Application.CreateForm(TfrmSentinela5, frmSentinela5);
  Application.Run;
end.
