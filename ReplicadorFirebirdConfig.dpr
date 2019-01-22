program ReplicadorFirebirdConfig;

uses
  FastMM4,
  Forms,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  udlgSentinelaConfig in 'udlgSentinelaConfig.pas' {dlgSentinelaConfig},
  uFuncoesReplicacao in 'uFuncoesReplicacao.pas',
  uCrypt in 'uCrypt.pas',
  uSobre in 'uSobre.pas' {dlgSobre};

{$R *.res}



begin
  Application.Initialize;
  Application.Title := 'Replicador Firebird Cfg';
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
