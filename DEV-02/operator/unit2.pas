unit Unit2;

{$mode objfpc}{$H+}

interface

uses

  Interfaces,Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Buttons, Menus, listener, fpjson, jsonparser,
   VirtualTrees, opensslsockets,core;


Type

  Tdecoy_list = Array of String;


Function CreateTdecoy_list(AJSON : TJSONData) : Tdecoy_list;



type
  Tdecoy_data = array of string;

Function CreateTdecoy_data(AJSON : TJSONData) : Tdecoy_data;




type
   TWorker = class(Tthread)

   protected
   procedure execute;override;
   public

   constructor create(CreateSuspended : boolean);

   end;



type

  { TForm2 }

  TForm2 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ImageList1: TImageList;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Timer1: TTimer;
    VirtualStringTree1: TVirtualStringTree;
    VST: TVirtualStringTree;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure PageControl2Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure VirtualStringTree1GetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure VirtualStringTree1GetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: String);
    procedure VSTGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure VSTMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
   Fdecoy_list : Tdecoy_list;
   Fdecoy_data : Tdecoy_data;
  public
    procedure get_connections_list; virtual;
    function get_decoy_data(UUID,Fuser:string):string;

   // Procedure LoadFromJSON(AJSON : TJSONData); virtual;
    Property decoy_list : Tdecoy_list Read Fdecoy_list Write Fdecoy_list;
    Property decoy_data : Tdecoy_data Read Fdecoy_data Write Fdecoy_data;
  end;
  type
  TConnection = class
    FIP: String;
    FHost: String;
    FPort: String;
    FUser: String;
    FPass: String;
    FData: Pointer;
   end;

  // Type Records for active connections
 type
   PTreeDecoy = ^TTreeData2;
   TTreeData2 = record
   UUID : string;
   P_type : string;
   internal_IP : string;
   user :string;
   end;


   // type Records for created Listeners
   type
  PTreeData = ^TTreeData;
  TTreeData = record
    profile_name: String;
    address: String;
    port: String;
    payload_type:string;

  end;

var
  Form2: TForm2;
  lNewTabSheet: TTabSheet;
  wp : Tworker;

implementation

uses
  unit1;

{$R *.lfm}




constructor Tworker.Create(CreateSuspended : boolean);
//var
//WP : Tworker;
begin
inherited Create(CreateSuspended);
    FreeOnTerminate := True;


end;

procedure Tworker.execute;
begin
// showmessage('okay');
sync_remote_GET(c_url+g_payload,g_token);
end;



{ TForm2 }





Function CreateTdecoy_data(AJSON : TJSONData) : Tdecoy_data;

var
  I : integer;

begin
  SetLength(Result,AJSON.Count);
  For I:=0 to AJSON.Count-1 do
    Result[i]:=AJSON.Items[i].AsString;
End;

Function CreateTdecoy_list(AJSON : TJSONData) : Tdecoy_list;

var
  I : integer;

begin
  SetLength(Result,AJSON.Count);
  For I:=0 to AJSON.Count-1 do
    Result[i]:=AJSON.Items[i].AsString;
End;

function extract_pos(i_list:string;ps:integer):string;
var
  t_list : Tstringlist;

begin
  t_list := Tstringlist.Create;

  t_list.Delimiter:=',';
  t_list.DelimitedText:= i_list;

  result := t_list[ps];

  end;



function Tform2.get_decoy_data(UUID,Fuser:string):string;
begin

end;

procedure Tform2.get_connections_list;    // this going to retrieve the connections list, lets decoys
var
rs,proc: string;
i :integer;


jData : TJSONData;
E : TJsonEnum;
Data: PTreeDecoy;
XNode: PVirtualNode;
p_size,d_size : integer;

begin

 // IdOpenSSLSetLibPath(ExtractFilePath(ParamStr(0)));
  proc := 'https://';
  try

 // rs := form2.IdHTTP1.Get(proc+form1.edit1.Text+':'+form1.edit2.Text+'/decoys/list/');

 rs := sync_remote_GET(proc+form1.edit1.Text+':'+form1.edit2.Text+'/decoys/list',Label1.Caption);


 showmessage(rs); // for debug
 ////  JSON Parser to extract connected decoys with info /////////////////
 jData := GetJSON(rs);

 for E in JData do begin
   case E.Key of
     'decoys':     //grab decoy list
    decoy_list:=CreateTdecoy_list(e.Value);


  //   'data':     //grab each decoy data
   // decoy_data := CreateTdecoy_data(e.Value);

   end;
 end;


p_size := length(decoy_list);
//d_size := length(decoy_data);


for i :=0 to p_size -1 do begin

XNode := VST.AddChild(nil);
if  Assigned(Xnode) then begin

 Data := VST.GetNodeData(XNode);

 Data^.UUID:= decoy_list[i];

// Data^.internal_IP:= extract_pos(decoy_data[i],0);
 //Data^.user:=extract_pos(decoy_data[i],1);
 //Data^.P_type:=extract_pos(decoy_data[i],2);

end;
end;

 except
       on E: Exception do
       showmessage(E.message);
  end;




end;



procedure TForm2.BitBtn1Click(Sender: TObject);
begin
  form3.show;
end;

procedure TForm2.BitBtn2Click(Sender: TObject);
begin

end;

procedure TForm2.Button1Click(Sender: TObject);
var
  Data: PTreeData;
  XNode: PVirtualNode;
  Rand: Integer;
  payload : string;
begin



 //  wp := Tworker.create(true);
 ///listeners/create?l_port=3333&l_host=google.com
 c_URL := 'https://'+form1.Edit1.Text+':'+form1.Edit2.text+'/listeners/create?';
  Randomize;
  Rand := Random(99);
  XNode := Virtualstringtree1.AddChild(nil);

  if Virtualstringtree1.AbsoluteIndex(XNode) > -1 then
  begin
    Data := Virtualstringtree1.GetNodeData(Xnode);
    Data^.profile_name := form3.Edit1.Text;
    Data^.address := form3.Edit2.Text;
    Data^.payload_type := form3.ComboBox1.SelText;
    Data^.port := form3.Edit3.Text;
  end;

 // with wp do begin
  // wp := Tworker.create(true);
    wp := Tworker.create(true);

  g_token := label1.Caption;
  g_payload := 'l_port='+Data^.port+'&l_host='+Data^.address;
   wp.Start;
  //wp.execute(c_url+payload,label1.Caption);
 //wp.execute;
  //wp.execute(c_url+payload,label1.Caption)

end;



procedure TForm2.Button2Click(Sender: TObject);

begin

 get_connections_list; // procedure to get connected decoys and it's collected data (OS/IP/Domain)


end;

procedure TForm2.Button3Click(Sender: TObject);
var
  list : Tstringlist;
  Data: PTreeDecoy;
  CellText: String;

  Node: PVirtualNode;
  Column: TColumnIndex;
  TextType: TVSTTextType;
begin
  list := Tstringlist.Create;
  showmessage(Data^.internal_IP);



end;

procedure TForm2.FormCreate(Sender: TObject);
var
  wip : Tworker;
begin

end;

procedure TForm2.MenuItem1Click(Sender: TObject);
begin

end;

procedure TForm2.MenuItem2Click(Sender: TObject);
var
  Node: PVirtualNode;
  Data: PTreeDecoy;
  k: integer;

 // lNewFrame: Tframe1;
  newlabel: TLabel;
  newtab : TTabsheet;
  PageControl : Tpagecontrol;
  newSpeedButton_toolbarFirst: TSpeedButton;


begin
   k := PageControl2.PageCount + 1;

  if VST.SelectedCount = 0 then
  begin
  //  MessageDlgEx('Please select a client first.', mtInformation, [mbOk], [], False, Self);
    Exit;
  end;

   Node := VST.GetFirstSelected;

  try
      while Assigned(Node) do
      begin
        Data := VST.GetNodeData(Node);
       // inbound := true;

      if k <= 5 then
      begin
        lNewTabSheet := PageControl2.AddTabSheet;
       with lNewTabSheet do
          begin
            lNewTabSheet.Name := 'tab' + IntToStr(k);
            lNewTabSheet.Caption := DATA^.user;


          //  newlabel := TLabel.Create(lNewTabSheet);
           // newlabel.Caption:='fuck it';
           // newlabel.Parent:= lNewTabSheet;

          // section, here is will be for getting data and sync it with generated TTY
              {
            TTY := TSynEdit.Create(lNewTabSheet);
            TTY.Tag:=Data^.FUniqueID;
            TTY.Visible:=true;
            TTY.Anchors:=[akleft,akbottom,akright,aktop];

            TTY.Parent:= lNewTabSheet;
            TTY.Width:=816;
            TTY.OnClick:=@Synedit1click;
            TTy.OnGutterClick:=@SynEdit1GutterClick;
            TTY.OnKeyDown := @SynEdit1KeyDown;

               }

          end;

      end;
          {

          here will do fetch of information based on UUID + username (to avoid getting duplicate information)

          }
      //  FTCPServer.SendMessage('TEXT',['invoke'],Data^.FUniqueID);

        Node := VST.GetNextSelected(Node);
      //  Tabsheet2.Caption:= inttostr(Data^.FUniqueID);

     // end;
   end;
  finally
   // fBroadcastMessage.Free;
  end;
end;

procedure TForm2.PageControl2Change(Sender: TObject);
begin

end;



procedure TForm2.Timer1Timer(Sender: TObject);
begin

end;

procedure TForm2.VirtualStringTree1GetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TTreeData);
end;

procedure TForm2.VirtualStringTree1GetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
    Data: PTreeData;
begin
  Data := VirtualStringtree1.GetNodeData(Node);
  case Column of
    0: CellText := Data^.profile_name;
    1: CellText := Data^.address;
    2: CellText := Data^.port;
    3: CellText := Data^.payload_type;
  end;
end;

procedure TForm2.VSTGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
   NodeDataSize := SizeOf(TTreeData2);
end;

procedure TForm2.VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);

  var
    Data: PTreeDecoy;
begin
  Data := VST.GetNodeData(Node);
  case Column of
    0: CellText := Data^.UUID;
    1: CellText := Data^.P_type;
    2: CellText := Data^.internal_IP;
    3: CellText := Data^.user;
  end;
end;

procedure TForm2.VSTMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
  Node: PVirtualNode;
  P: TPoint;
begin
  if Button = mbRight then
  begin
    Node := VST.GetNodeAt(X, Y);
    if (Node <> nil) and VST.Selected[Node] then
    begin
      P.X := X; P.Y := Y;
      P := ClientToScreen(P);
      popupmenu1.PopUp(P.X, P.Y);
    end;
  end;
end;

end.

