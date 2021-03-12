program CleoSim3;

uses
  Forms,
  principal in 'principal.pas' {Form1},
  frmExecution in 'frmExecution.pas' {execution},
  frmAbout in 'frmAbout.pas' {About};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Simulador do Cleopatra - EC';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(Texecution, execution);
  Application.CreateForm(TAbout, About);
  Application.Run;
end.
