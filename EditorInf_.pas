unit EditorInf_;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TEditorInfForm_ = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure Edit1Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditorInfForm_: TEditorInfForm_;

implementation

{$R *.dfm}

procedure TEditorInfForm_.Edit1Change(Sender: TObject);
begin
  EditorInfForm_.Tag := 1;
end;

procedure TEditorInfForm_.Button2Click(Sender: TObject);
begin
  EditorInfForm_.Tag := 0;
end;

procedure TEditorInfForm_.FormCreate(Sender: TObject);
begin
  Caption := '�ؿ�����';

  Label1.Caption := '���⣺';
  Label2.Caption := '���ߣ�';
  Label3.Caption := '˵����';

  Button1.Caption := 'ȷ��(&O)';
  Button2.Caption := 'ȡ��(&C)';
end;

end.
