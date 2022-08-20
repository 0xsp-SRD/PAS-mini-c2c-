unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, unit2, Controls, fpjson, jsonparser, Graphics,
  Dialogs, StdCtrls, FPHTTPClient, opensslsockets;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
   // procedure IdSSLIOHandlerSocketOpenSSL1GetPassword(var Password: String);
  private

  public

  end;

var
  Form1: TForm1;

implementation



{$R *.lfm}

{ TForm1 }

procedure TForm1.CheckBox1Change(Sender: TObject);
begin

end;

function POST_Requester(URL_DATA,payload:string):string;
var
FPHTTPClient: TFPHTTPClient;
Resultget : string;
begin
	FPHTTPClient := TFPHTTPClient.Create(nil);
	FPHTTPClient.AllowRedirect := True;
	   try
	   Resultget := FPHTTPClient.FormPost(URL_DATA,payload);
	   POST_Requester := Resultget;

	   except
	      on E: exception do
	         writeln(E.Message);
	   end;
	FPHTTPClient.Free;

	end;

procedure TForm1.Button1Click(Sender: TObject);
var
jObject : TJSONobject;
rs,tmp,token,proc,port : string;
 jData : TJSONData;
 payload : string;
begin



 if checkbox1.Checked  then
 proc := 'https://'
 else
 proc := 'http://';

 payload := 'user='+edit3.text+'&pwd='+edit4.Text;

 try

  rs := POST_Requester(proc+edit1.Text+':'+edit2.Text+'/auth/',payload);  // connect to the auth end-point

  jData := GetJSON(rs);
  tmp := jdata.asjson;
  tmp := jdata.formatjson;
  jobject := TJSONObject(jdata);

 token := jobject.FindPath('token').AsString;  // find the token and copy it

 if length(token) > 7 then
 begin
  // show dashboard
   form2.Label1.Caption:=token;
   form2.ShowModal;
  end;

   except
   on E: Exception do
      ShowMessage('not able to proceed,check if the information is correct');

  end;
  end;

end.

