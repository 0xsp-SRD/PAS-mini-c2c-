unit core;

{$mode ObjFPC}{$H+}

interface


uses
  Classes,dialogs,SysUtils,FPHTTPClient;

 function sync_remote_GET(URL,token:string):string;

 type
   Tworker = class(Tthread)


   protected



   public
     procedure execute;override;
    constructor create(CreateSuspended : boolean);
   // procedure execute(URL,token:string);
    function sync_remote_GET(URL,token:string):string;
   end;

   var

g_token,c_url,g_payload:string;


implementation



function sync_remote_GET(URL,token:string):string; // this is for GET request only.
var
FPHTTPClient: TFPHTTPClient;
Resultget : string;
begin
	FPHTTPClient := TFPHTTPClient.Create(nil);
	FPHTTPClient.AllowRedirect := True;
        FPHTTPClient.AddHeader('Authorization','Basic '+token);

	   try
	   Resultget := FPHTTPClient.Get(URL);
	   sync_remote_GET := Resultget;

	   except
	      on E: exception do
	         showmessage(E.Message);
	   end;
	FPHTTPClient.Free;

	end;


function Tworker.sync_remote_GET(URL,token:string):string; // this is for GET request only.
var
FPHTTPClient: TFPHTTPClient;
Resultget : string;
begin
	FPHTTPClient := TFPHTTPClient.Create(nil);
	FPHTTPClient.AllowRedirect := True;
        FPHTTPClient.AddHeader('Authorization','Basic '+token);

	   try
	   Resultget := FPHTTPClient.Get(URL);
	   sync_remote_GET := Resultget;

	   except
	      on E: exception do
	         showmessage(E.Message);
	   end;
	FPHTTPClient.Free;

	end;


constructor Tworker.Create(CreateSuspended : boolean);
//var
//WP : Tworker;
begin
inherited Create(CreateSuspended);
    FreeOnTerminate := True;


end;

procedure Tworker.execute;
begin
sync_remote_GET(c_url+g_payload,g_token);
end;


end.

