unit core;

{$mode ObjFPC}{$H+}

interface


uses
  Classes,dialogs,SysUtils,FPHTTPClient;

 function sync_remote_GET(URL,token:string):string;



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








end.

