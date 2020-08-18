unit OpenFile;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, LogFile,
  Dialogs, StdCtrls, ExtCtrls, FileCtrl, Registry, Buttons;

type
  TMyOpenFile = class(TForm)
    FileListBox1: TFileListBox;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Panel3: TPanel;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    DriveComboBox1: TDriveComboBox;
    DirectoryListBox1: TDirectoryListBox;
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MyOpenFile: TMyOpenFile;

implementation

{$R *.dfm}

// UtF-8�ļ���ȡ����
//function LoadUTFFile(const FileName: string): string;
//var
//  MemStream: TMemoryStream;
//  S, HeaderStr:string;
//
//begin
//  Result:='';
//
//  if not FileExists(FileName) then Exit;
//  MemStream := TMemoryStream.Create;
//  try
//    MemStream.LoadFromFile(FileName);
//
//    SetLength(HeaderStr, 3);
//    MemStream.Read(HeaderStr[1], 3);
//    if HeaderStr = #$EF#$BB#$BF then
//    begin
//      SetLength(S, MemStream.Size - 3);
//      MemStream.Read(S[1], MemStream.Size - 3);
//    end else
//    begin
//      SetLength(S, MemStream.Size);
//      MemStream.Read(S[1], MemStream.Size);
//    end;
//
//    Result := Utf8ToAnsi(S);
//  finally
//    MemStream.Free;
//  end;
//end;

// Unicode�ļ���ȡ����
//function LoadUnicodeFile(const FileName: string): string;
//var
//  MemStream: TMemoryStream;
//  FlagStr: String;
//  WStr: WideString;
//
//begin
//  Result := '';
//
//  if not FileExists(FileName) then Exit;
//  MemStream := TMemoryStream.Create;
//  try
//    MemStream.LoadFromFile(FileName);
//
//    SetLength(FlagStr, 2);
//    MemStream.Read(FlagStr[1], 2);
//
//    if FlagStr = #$FF#$FE then
//    begin
//      SetLength(WStr, (MemStream.Size-2) div 2);
//      MemStream.Read(WStr[1], MemStream.Size - 2);
//    end else
//    begin
//      SetLength(WStr, MemStream.Size div 2);
//      MemStream.Read(WStr[1], MemStream.Size);
//    end;
//    
//    Result := AnsiString(WStr);
//  finally
//    MemStream.Free;
//  end;
//end;

procedure TMyOpenFile.FormCreate(Sender: TObject);
begin
  Caption := '�򿪹ؿ��ĵ�';
  Button1.Caption := '��(&O)';
  Button2.Caption := 'ȡ��';
  CheckBox1.Caption := '���ؿ��д𰸣���ͬʱ����';
end;

procedure TMyOpenFile.FileListBox1DblClick(Sender: TObject);
begin
  Button1.Click;
end;

procedure TMyOpenFile.FormShow(Sender: TObject);
begin
  CheckBox1.Checked := False;
  FileListBox1.Update;
end;

// ͨ��ע���ȡ�á��ҵ��ĵ����͡����桱�ļ���
function GetShellFolders(strDir: string): string;
const
  regPath = '\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders';
var
  Reg: TRegistry;
  strFolders: string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(regPath, false) then begin
      strFolders := Reg.ReadString(strDir);
    end;
  finally
    Reg.Free;
  end;
  result := strFolders;
end;
      
// ��ȡ�����桱�ļ���
function GetDeskeptPath: string;
begin
  Result := GetShellFolders('Desktop'); //��ȡ�������ļ��е�·��
end;
      
// ��ȡ���ҵ��ĵ����ļ���
function GetMyDoumentpath: string;
begin
  Result := GetShellFolders('Personal'); //�ҵ��ĵ�
end;

procedure TMyOpenFile.DirectoryListBox1Change(Sender: TObject);
begin
  DriveComboBox1.Drive := DirectoryListBox1.Directory[1];
  FileListBox1.Update;
end;

procedure TMyOpenFile.SpeedButton1Click(Sender: TObject);
begin
  DirectoryListBox1.Directory := GetMyDoumentpath;
end;

procedure TMyOpenFile.SpeedButton2Click(Sender: TObject);
begin
  DirectoryListBox1.Directory := GetDeskeptPath;
end;

end.
