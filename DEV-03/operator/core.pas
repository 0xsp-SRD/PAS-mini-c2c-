unit core;

{$mode ObjFPC}{$H+}

interface


uses
  Classes,dialogs,SysUtils,FPHTTPClient,fpjson, jsonparser;

 function sync_remote_GET(URL,token:string):string;
 function HTTP_Worker(server,request_type,token,payload:string):string;
 function parse_task_json(s_json:string; out t_size:integer):string;
// function MyWrapText(S :string; MaxCol:integer): string;

   var

g_token,c_url,g_payload:string;

type
  Tworker_proc = class(Tthread)


  protected
  public
  constructor create(CreateSuspended : boolean);

  function get_result_decoy(URL,end_point,token:string):string;


  end;

implementation



constructor Tworker_proc.Create(CreateSuspended : boolean);
begin
inherited Create(CreateSuspended);
    FreeOnTerminate := True;
end;


function Tworker_proc.get_result_decoy(URL,end_point,token:string):string;
var
FPHTTPClient: TFPHTTPClient;
Resultget : string;

begin

FPHTTPClient := TFPHTTPClient.Create(nil);
FPHTTPClient.AllowRedirect := True;
FPHTTPClient.AddHeader('Authorization','Basic '+token);

try
Resultget := FPHTTPClient.Get(URL+end_point);
get_result_decoy := Resultget;

except
on E: exception do
showmessage(E.Message);
end;
FPHTTPClient.Free;

end;




{
function MyWrapText(S :string; MaxCol:integer): string;
var
  P :PChar;
  CharLen, i :integer;
  C :string;
  RightSpace : Integer;
  LastLineEnding : Integer;
begin
  Result := '';
  P := PChar(S);
  LastLineEnding := 0;
  i := 1;
  while P^ <> #0 {i <= Length(S)} do
  begin
    CharLen := UTF8CharacterLength(P);
    C := UTF8Copy(P, 1, 1);
    Result := Result + C;
    if P^ = #10 then
      LastLineEnding := i;
    if (i - LastLineEnding >= MaxCol) then
    begin
      RightSpace := Length((Result)) - RPos(' ', (Result));
      Dec(p, RightSpace);
      Dec(i, RightSpace);
      SetLength(Result, Length(Result) - RightSpace);
      Result := Result + LineEnding;
      LastLineEnding := i;
    end;
    Inc(P, CharLen);
    Inc(i, Charlen);
  end;
end;
  }

function parse_task_json(s_json:string; out t_size:integer):string;
var
Json : TJSONOBJECT;
j_data : TJSONDATA;
tmp : string;
o_pt :string;
ls : Tstringlist;
begin

        try
     //   ls := Tstringlist.create;

         j_data := GetJSON(s_json);
         tmp := j_data.asjson;
         tmp := j_data.formatjson;
         json := TJSONObject(j_data);


        o_pt := json.FindPath('task_output').AsString;
        t_size := length(o_pt);
     //   ls.Add(o_pt);
        result := o_pt;

        finally
      //   ls.Free;
        end;
end;

function HTTP_Worker(server,request_type,token,payload:string):string;
 var
FPHTTPClient: TFPHTTPClient;
Resultget : string;
begin

FPHTTPClient := TFPHTTPClient.Create(nil);
FPHTTPClient.AllowRedirect := True;
FPHTTPClient.AddHeader('Authorization','Basic '+token);
   try
   if request_type = 'GET' then begin
   Resultget := FPHTTPClient.Get(server)
   end else
   Resultget := FPHTTPClient.formpost(server,payload);

   HTTP_WORKER := Resultget;

   except
      on E: exception do
      showmessage(E.Message);
   end;
FPHTTPClient.Free;
end;

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

