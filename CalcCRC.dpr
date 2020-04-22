program CalcCRC;

uses
  Forms,
  main in 'main.pas' {FCRC};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFCRC, FCRC);
  Application.Run;
end.
