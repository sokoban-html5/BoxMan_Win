unit Submit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IDHttp;

type
  TMySubmit = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    ComboBox1: TComboBox;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    SubmitCountry, SubmitName, SubmitEmail, SubmitLurd: string;

  end;
  

var
  MySubmit: TMySubmit;


implementation

{$R *.dfm}

procedure TMySubmit.FormCreate(Sender: TObject);
begin
  Caption := '�ύ������';
  Label1.Caption := '����/����:';
  Label2.Caption := '����:';
  Button1.Caption := 'ȡ��(&C)';
  Button2.Caption := 'ȷ��(&O)';
  ComboBox1.Items[1] := '�й�';
  SubmitLurd := '';
end;

procedure TMySubmit.FormShow(Sender: TObject);
var
  i, size: Integer;

begin
  size := ListBox1.Items.Count;

  for i := 0 to size-1 do begin
      if SubmitCountry = ListBox1.Items[i] then begin
         ComboBox1.ItemIndex := i;
         Break;
      end;
  end;
  if ComboBox1.ItemIndex < 0 then ComboBox1.ItemIndex := 1;
  Edit1.Text := SubmitName;
  Edit2.Text := SubmitEmail;
end;

// Post ����
function MyPost: string;
var
  IdHttp : TIdHTTP;
  Url : string;                   // �����ַ
  ResponseStream : TStringStream; // ������Ϣ
  ResponseStr : string;
  RequestList : TStringList;      // ������Ϣ
//  RequestStream : TStringStream;

begin
  // ����IDHTTP�ؼ�
  IdHttp := TIdHTTP.Create(nil);

  // TStringStream�������ڱ�����Ӧ��Ϣ
  ResponseStream := TStringStream.Create('');

//  RequestStream := TStringStream.Create('');
  RequestList := TStringList.Create;

  try
    Url := 'http://sokoban.cn/submit_result.php';
    
    try
      // ���б�ķ�ʽ�ύ����
      RequestList.Add('nickname=' + MySubmit.SubmitName);
      RequestList.Add('country=' + MySubmit.SubmitCountry);
      RequestList.Add('email=' + MySubmit.SubmitEmail);
      RequestList.Add('lurd=' + MySubmit.SubmitLurd);
      IdHttp.Post(Url, RequestList, ResponseStream);

      // �����ķ�ʽ�ύ����
//      RequestStream.WriteString('nickname=' + MySubmit.SubmitName);
//      RequestStream.WriteString('country=' + MySubmit.SubmitCountry);
//      RequestStream.WriteString('email=' + MySubmit.SubmitEmail);
//      RequestStream.WriteString('lurd=' + MySubmit.SubmitLurd);
//      IdHttp.Post(Url, RequestStream, ResponseStream);

    except
//      on e : Exception do
//      begin
//        ShowMessage(e.Message);
//      end;
    end;

    // ��ȡ��ҳ���ص���Ϣ
    ResponseStr := ResponseStream.DataString;
    
    // ��ҳ�еĴ�������ʱ����Ҫ����UTF8����
//    ResponseStr := UTF8Decode(ResponseStr);
  finally
    if IdHttp <> nil then FreeAndNil(IdHttp);
    if RequestList <> nil then FreeAndNil(RequestList);
    if ResponseStream <> nil then FreeAndNil(ResponseStream);
  end;

  Result := ResponseStr;
end;

procedure TMySubmit.Button2Click(Sender: TObject);
var
  inf: string;
begin
  SubmitName  := Edit1.Text;
  SubmitEmail := Edit2.Text;

  inf := AnsiLowerCase(MyPost);

  if Pos('correct (for ', inf) > 0 then Caption := '�ύ�ɹ���'
  else if Pos('not correct', inf) > 0 then Caption := '�𰸲���ȷ��'
  else if Pos('competition has ended', inf) > 0 then Caption := '�����ѹ��ڣ����ע��һ�ڣ�'
  else if Pos('not begin yet', inf) > 0 then Caption := '������δ��ʼ�������ĵȴ���'
  else if Pos('name cannot be empty', inf) > 0 then Caption := '�������ܿ��ţ�'
  else Caption := 'δ֪�����'
end;

procedure TMySubmit.ComboBox1Change(Sender: TObject);
begin
  SubmitCountry := ListBox1.Items[ComboBox1.ItemIndex];
end;

end.
