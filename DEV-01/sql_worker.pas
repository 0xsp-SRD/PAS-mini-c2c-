unit SQL_Worker;

{$mode ObjFPC}{$H+}

interface

uses
  Classes,cthreads, SysUtils,sqlite3conn, sqldb, db,base64;
 type

  TSQL = Class(Tthread)


  SQLite3Connection: TSQLite3Connection;
  SQLTransaction : TSQLTransaction;
  SQL_Query : TSQLQuery;
  protected
 // procedure execute; virtual;
 public
   constructor Create;
   procedure connect;
   procedure add_task(UUID,task_name,task_data:string);
   procedure check_creds(username:string;password:string; out isvalid:boolean; out token:string);
   procedure isdecoy(UUID:string; out isvalid:string);

   end;

implementation
constructor TSQL.create;

begin

   SQLite3Connection := TSQLite3Connection.Create(nil);
   SQLTransaction := TSQLTransaction.Create(nil);
   SQL_Query := TSQLQuery.Create(nil);
   connect;


end;

procedure TSQL.connect;
var
  tmp : string;
begin

  SQLite3Connection.DatabaseName:=getcurrentdir+'/database/mydb.db';
  try
  SQLite3Connection.Open;
  writeln('[+] Successfully connected ');
   except
       on E: ESQLDatabaseError do
           writeln(E.Message);
   end;

  end;

procedure TSQL.check_creds(username:string;password:string; out isvalid:boolean; out token:string);
var
sql,usr,pwd :string;
count: integer;
begin

isvalid := false;
  if SQLite3Connection.Connected then begin
     //database assignment
     SQL_query.DataBase:= SQLite3Connection;
     SQL_query.Transaction:= SQLtransaction;
     SQLtransaction.DataBase :=  SQLite3Connection;

     sql := 'SELECT * FROM users ';
     sql += 'WHERE username ='+'"'+username+'" ';
     sql += 'AND password ='+'"'+password+'"';

     SQL_query.SQL.Text := sql;
     //Count := 0;
           try
               SQL_query.Open;
           //  dbSQLQuery.First;
            //   while not dbSQLQuery.EOF do begin
             //      Inc(Count);
                   usr := SQL_query.FieldByName('username').AsString;
                   pwd :=  SQL_query.FieldByName('password').AsString;

               if ( trim(username) = usr) AND ( trim(password) = pwd) then begin
               isvalid := true;
               token := EncodeStringBase64(usr+':'+pwd);

          //   dbSQLQuery.Next;
            //   end;
               SQL_query.Close;

            end;
            except
               on E: ESQLDatabaseError do begin
                   writeln(E.Message);

           end;

            end;

  end;

end;

procedure TSQL.isdecoy(UUID:string; out isvalid:string);
var
   task,query :string;
   count:integer;
begin
if SQLite3Connection.Connected then begin
     //database assignment
     SQL_query.DataBase:= SQLite3Connection;
     SQL_query.Transaction:= SQLtransaction;
     SQLtransaction.DataBase :=  SQLite3Connection;
           // Create query
           Query := 'SELECT UUID FROM decoys WHERE UUID = '+'"'+UUID+'"';

           // Query the database
           SQL_query.SQL.Text := Query; Count := 0;
           try
               SQL_query.Open;
               SQL_query.First;
               while not SQL_query.EOF do begin
                   Inc(Count);
                  // task := dbSQLQuery.FieldByName('res_body').AsString;
                   UUID :=   SQL_query.FieldByName('UUID').AsString;

                  isvalid := UUID;

                  SQL_query.Next;
               end;
               SQL_query.Close;
           except
               on E: ESQLDatabaseError do begin
                   writeln(E.Message);
               end;
           end;

end;
end;
procedure TSQL.add_task(UUID,task_name,task_data:string);
var
   sql,task_status :string;
   task_id : integer;
begin
 Randomize;
 task_status := 'PENDING';
 task_id := random(100) + 10000;

 Sql := 'INSERT INTO tasks (UUID,task_name,task_data,task_status,task_id) ';
 Sql += 'VALUES ("' + UUID+'","' + task_name+ '","'+ task_data+'","'+ task_status+'","'+ inttostr(task_id)+'")';

 try
    SQL_query.DataBase:= SQLite3Connection;
    SQL_query.Transaction:= SQLtransaction;
    SQLtransaction.DataBase :=  SQLite3Connection;
    SQL_query.SQL.Text := Sql;
    SQL_query.ExecSQL;
    SQLtransaction.Commit;
  except
    on E: ESQLDatabaseError do
     writeln(E.Message);

  end;
end;

end.

