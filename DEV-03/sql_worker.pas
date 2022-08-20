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
   procedure add_task(UUID,task_name,task_data,task_id:string);
   procedure get_task(UUID:string;out task_data,task_status,task_id:string);
   procedure update_task(UUID,task_id,task_status:string);
   procedure check_creds(username:string;password:string; out isvalid:boolean; out token:string);
   procedure isdecoy(UUID:string; out isvalid:string);   // will check if the connected decoy is already created by teamserver operator, if yes then okay
   function all_decoys:Tstrings; // the data output will be array of strings, return the value of all grabbed strings from db and push it into API

   procedure get_decoy_result(UUID,task_id:string;out task_output:string);  // this will get the results only
   procedure insert_task_result(UUID,task_id,task_body:string);

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




procedure TSQL.update_task(UUID,task_id,task_status:string);
var
  SQl :string;
begin
   if SQLite3Connection.Connected then begin
     //database assignment
     SQL_query.DataBase:= SQLite3Connection;
     SQL_query.Transaction:= SQLtransaction;
     SQLtransaction.DataBase :=  SQLite3Connection;

     SQL := 'UPDATE tasks SET task_status = :task_status WHERE task_id = :task_id AND UUID = :UUID';
    // SQL += 'SET task_status ='+'"'+task_status+'"';
    // SQL += ' WHERE task_id = '+'"'+task_id+'"';

     try
     SQL_query.SQL.text := SQl;

     sql_query.Params.ParamByName('task_status').AsString:= task_status;
     sql_query.Params.ParamByName('task_id').AsString:= task_id;
     sql_query.Params.ParamByName('UUID').AsString:= uuid;

     sql_query.ExecSQL;
     SQLtransaction.Commit;




    // sql_query.Open;

    //  task_data := SQL_query.FieldByName('task_data').AsString;
     // task_status := SQL_query.FieldByName('task_status').AsString;

   //   sql_query.Close;

        except
               on E: ESQLDatabaseError do begin
                   writeln(E.Message);

               end;

end;

   end;

end;

procedure TSQL.get_task(UUID:string;out task_data,task_status,task_id:string);
var
  SQL :string;

begin
    if SQLite3Connection.Connected then begin
     //database assignment
     SQL_query.DataBase:= SQLite3Connection;
     SQL_query.Transaction:= SQLtransaction;
     SQLtransaction.DataBase :=  SQLite3Connection;

     SQL := 'SELECT * from tasks WHERE UUID = :UUID AND task_status = "PENDING" ';
   //  SQL += 'WHERE UUID = '+'"'+uuid+'"';
    // SQL += 'AND task_status = "PENDING" ';


     SQL_query.SQL.text := SQl;
     SQL_QUERY.Params.ParamByName('UUID').asstring := UUID;

    end;
    try
     sql_query.Open;
     sql_query.First;

      task_data := SQL_query.FieldByName('task_data').AsString;
      task_status := SQL_query.FieldByName('task_status').AsString;
      task_id := SQL_query.FieldByName('task_id').AsString;
      sql_query.Close;

        except
               on E: ESQLDatabaseError do begin
                   writeln(E.Message);

    end;

end;

end;


procedure TSQL.get_decoy_result(UUID,task_id:string; out task_output:string);
var
SQL : string;
str_list : Tstrings;
//count : integer;
begin
 if SQLite3Connection.Connected then begin
 // writeln('connected');
     //database assignment
     SQL_query.DataBase:= SQLite3Connection;
     SQL_query.Transaction:= SQLtransaction;
     SQLtransaction.DataBase :=  SQLite3Connection;

  SQL := 'SELECT * FROM decoy_task_results WHERE profile_UUID = :UUID AND task_id = :task_id';


      SQL_query.SQL.Text := sql;
      sql_query.Params.ParamByName('UUID').asstring := UUID;
      sql_query.Params.ParamByName('task_id').AsString:= task_id;


    // str_list := Tstringlist.Create;

       try


          SQL_query.Open;
          SQL_query.First;
       while not SQL_query.Eof do
         begin

       task_output := SQL_query.FieldByName('task_output').AsString;

       SQL_query.Next;
         end;


        except
               on E: ESQLDatabaseError do begin
                   writeln(E.Message);
end;


       end;
       sql_query.Close;
   end;



end;

function TSQL.all_decoys:Tstrings;
var
  SQL : string;
  agent_UUID : string;
  str_list : Tstrings;
  count : integer;
begin

   if SQLite3Connection.Connected then begin
     //database assignment
     SQL_query.DataBase:= SQLite3Connection;
     SQL_query.Transaction:= SQLtransaction;
     SQLtransaction.DataBase :=  SQLite3Connection;

     SQL := ' SELECT * FROM decoys ';

      SQL_query.SQL.Text := sql; count := 0;

     str_list := Tstringlist.Create;

       try
       SQL_query.Open;
       SQL_query.First;


    while not SQL_query.EOF do begin
   Inc(Count);


         agent_uuid := SQL_query.FieldByName('UUID').AsString;

         str_list.Add(agent_uuid);
           SQL_query.Next;
         writeln(agent_uuid);

         result := str_list;
         end;

         sql_query.Close;
        except
               on E: ESQLDatabaseError do begin
                   writeln(E.Message);
end;
       end;

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

     sql := 'SELECT * FROM users WHERE username = :username AND password = :password';
    // sql += 'WHERE username ='+'"'+username+'" ';
    // sql += 'AND password ='+'"'+password+'"';

     SQL_query.SQL.Text := sql;
     sql_query.Params.ParamByName('username').AsString:= username;
     sql_query.Params.ParamByName('password').AsString:= password;

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
           Query := 'SELECT UUID FROM decoys WHERE UUID = :UUID';

           // Query the database
           SQL_query.SQL.Text := Query; Count := 0;
           sql_query.Params.ParamByName('UUID').AsString:= UUID;
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


procedure TSQL.insert_task_result(UUID,task_id,task_body:string);
var
   sql :string;
begin
   sql :='INSERT INTO decoy_task_results (profile_UUID,task_id,task_output) values (:UUID,:task_id,:task_body)';

//   sql +='VALUES ("' +UUID+'","'+task_id+'","'+task_body+'")'; // this vulnerable to SQL injection
  try
    SQL_query.DataBase:= SQLite3Connection;
    SQL_query.Transaction:= SQLtransaction;
    SQLtransaction.DataBase :=  SQLite3Connection;
    SQL_query.SQL.Text := Sql;

    sql_query.Params.ParamByName('UUID').AsString:= UUID;
    SQL_QUERY.Params.ParamByName('task_id').AsString:= task_id;
    sql_query.Params.ParamByName('task_body').AsString:=task_body;

    SQL_query.ExecSQL;

    SQLtransaction.Commit;
  except
    on E: ESQLDatabaseError do
     writeln(E.Message);

  end;



end;

procedure TSQL.add_task(UUID,task_name,task_data,task_id:string);
var
   sql,task_status :string;

begin

 task_status := 'PENDING';


 Sql := 'INSERT INTO tasks (UUID,task_name,task_data,task_status,task_id) values (:UUID,:task_name,:task_data,:task_status,:task_id) ';
 //Sql += 'VALUES ("' + UUID+'","' + task_name+ '","'+ task_data+'","'+ task_status+'","'+ task_id+'")';      // possible SQL injection, must be fixed

 try
    SQL_query.DataBase:= SQLite3Connection;
    SQL_query.Transaction:= SQLtransaction;
    SQLtransaction.DataBase :=  SQLite3Connection;
    SQL_query.SQL.Text := Sql;

    sql_query.Params.ParamByName('UUID').AsString:= UUID;
    sql_query.Params.ParamByName('task_name').AsString:= task_name;
    sql_query.Params.ParamByName('task_data').AsString:= task_data;
    sql_query.Params.ParamByName('task_status').AsString:= task_status;
    sql_query.Params.ParamByName('task_id').AsString:= task_id;



    SQL_query.ExecSQL;
    SQLtransaction.Commit;
  except
    on E: ESQLDatabaseError do
     writeln(E.Message);

  end;
end;

end.

