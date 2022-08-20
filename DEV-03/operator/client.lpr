program client;

{$mode objfpc}{$H+}

uses

  cthreads,cmem,
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, Unit2, listener, core
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.

