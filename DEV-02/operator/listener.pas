unit listener;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,Forms, Controls, Graphics, Dialogs, StdCtrls,core;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;

implementation
uses
  unit2;

{$R *.lfm}

{ TForm3 }

procedure TForm3.Button1Click(Sender: TObject);
begin
 //with form2 do
 form2.Button1.Click;

end;

end.

