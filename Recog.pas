unit Recog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, jpeg, pngimage,
  Dialogs, ExtCtrls, Buttons, ImgList, ExtDlgs, Menus, Math, StdCtrls, Spin;

type
  TRecogForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ScrollBox1: TScrollBox;
    sb_Open: TSpeedButton;
    OpenPictureDialog1: TOpenPictureDialog;
    PopupMenu1: TPopupMenu;
    B_Top: TMenuItem;
    B_Left: TMenuItem;
    B_Right: TMenuItem;
    B_Bottom: TMenuItem;
    Image1: TImage;
    Label1: TLabel;
    Map_Left: TSpinEdit;
    SpeedButton3: TSpeedButton;
    Label2: TLabel;
    Map_Right: TSpinEdit;
    SpeedButton1: TSpeedButton;
    Label3: TLabel;
    Map_Top: TSpinEdit;
    SpeedButton4: TSpeedButton;
    Label4: TLabel;
    Map_Bottom: TSpinEdit;
    SpeedButton2: TSpeedButton;
    Label5: TLabel;
    Map_RowHeight: TSpinEdit;
    Label8: TLabel;
    Map_ColWidth: TSpinEdit;
    Map_Size: TLabel;
    SpeedButton5: TSpeedButton;
    Image2: TImage;
    procedure sb_OpenClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DrawBianJie;
    procedure myDraw;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure B_LeftClick(Sender: TObject);
    procedure B_RightClick(Sender: TObject);
    procedure B_TopClick(Sender: TObject);
    procedure B_BottomClick(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Map_LeftChange(Sender: TObject);
    procedure Map_RightChange(Sender: TObject);
    procedure Map_TopChange(Sender: TObject);
    procedure Map_BottomChange(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Map_RowHeightChange(Sender: TObject);
    procedure Map_ColWidthChange(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RecogForm: TRecogForm;

  PicRows, PicCols: Integer;             // ��������Ĺؿ��ߴ�

  myClickPoint: TPoint;                  // ��갴��ʱ������

implementation

{$R *.dfm}

// ��ʼ����
procedure TRecogForm.FormActivate(Sender: TObject);
begin
  myClickPoint.X := 0;
  myClickPoint.Y := 0;
  Image1.Visible := False;
  Tag := 0;
end;

// ����ͼƬ
procedure TRecogForm.sb_OpenClick(Sender: TObject);
var
  tmpBmp: TBitmap;
begin
  if OpenPictureDialog1.Execute then begin
     try
       tmpBmp := TBitmap.Create;
       Image2.Picture.LoadFromFile(OpenPictureDialog1.FileName);
       tmpBmp.Assign(Image2.Picture.Graphic);
       Image2.Picture.Bitmap := tmpBmp;

       Image1.Width  := Image2.Width;
       Image1.Height := Image2.Height;
       Image1.Visible := True;

       if (Image1.Width < 200) or (Image1.Height < 200) then begin
         Map_Left.Value   := 0;
         Map_Top.Value    := 0;
         Map_Right.Value  := Image1.Width-1;
         Map_Bottom.Value := Image1.Height-1;
       end else begin
         Map_Left.Value   := 50;
         Map_Top.Value    := 50;
         Map_Right.Value  := Image1.Width-50;
         Map_Bottom.Value := Image1.Height-50;
       end;

       Map_Left.MinValue := 0;
       Map_Left.MaxValue := Map_Right.Value-1;
       Map_Top.MinValue := 0;
       Map_Top.MaxValue := Map_Bottom.Value-1;
       Map_Right.MinValue := Map_Left.MinValue+1;
       Map_Right.MaxValue := Image1.Width-1;
       Map_Bottom.MinValue := Map_Top.Value+1;
       Map_Bottom.MaxValue := Image1.Height-1;

       Map_RowHeight.Value := 50;
       Map_ColWidth.Value  := 50;
       PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
       PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
       Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);

       myDraw;
     finally
       FreeAndNil(tmpBmp);
     end;
  end;
end;

// ���ƻ���
procedure TRecogForm.myDraw;
var
  i: Integer;
begin
  if not Image1.Visible then Exit;

  Image1.Canvas.Draw(0, 0, Image2.Picture.Graphic);
  
  DrawBianJie;

  Image1.Canvas.Pen.Width := 1;
  for i := 1 to PicRows do begin
    Image1.Canvas.Pen.Color := clBlack;
    Image1.Canvas.MoveTo(Map_Left.Value, Map_Top.Value + i * Map_RowHeight.Value+1);
    Image1.Canvas.LineTo(Map_Right.Value, Map_Top.Value + i * Map_RowHeight.Value+1);
    Image1.Canvas.Pen.Color := clWhite;
    Image1.Canvas.MoveTo(Map_Left.Value, Map_Top.Value + i * Map_RowHeight.Value);
    Image1.Canvas.LineTo(Map_Right.Value, Map_Top.Value + i * Map_RowHeight.Value);
  end;
  for i := 1 to PicCols do begin
    Image1.Canvas.Pen.Color := clBlack;
    Image1.Canvas.MoveTo(Map_Left.Value + i * Map_ColWidth.Value+1, Map_Top.Value);
    Image1.Canvas.LineTo(Map_Left.Value + i * Map_ColWidth.Value+1, Map_Bottom.Value);
    Image1.Canvas.Pen.Color := clWhite;
    Image1.Canvas.MoveTo(Map_Left.Value + i * Map_ColWidth.Value, Map_Top.Value);
    Image1.Canvas.LineTo(Map_Left.Value + i * Map_ColWidth.Value, Map_Bottom.Value);
  end;
end;

// ���߽�
procedure TRecogForm.DrawBianJie;
var
  R1, R0: TRect;

begin
  R1 := Rect(Map_Left.Value+1, Map_Top.Value+1, Map_Right.Value+1, Map_Bottom.Value+1);
  R0 := Rect(Map_Left.Value,   Map_Top.Value,   Map_Right.Value,   Map_Bottom.Value  );
  Image1.Canvas.Brush.Color := clBlack;
  Image1.Canvas.FrameRect(R1);
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.FrameRect(R0);
end;

// ������߽�
procedure TRecogForm.B_LeftClick(Sender: TObject);
begin
  if myClickPoint.X <= Map_Right.Value then begin
     Map_Left.Value := myClickPoint.X;
     PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
  end
  else begin
     Map_Left.Value := Map_Right.Value;
     Map_Right.Value := myClickPoint.X;
  end;
  myDraw;
end;

// �����ұ߽�
procedure TRecogForm.B_RightClick(Sender: TObject);
begin
  if myClickPoint.X >= Map_Left.Value then begin
     Map_Right.Value := myClickPoint.X;
     PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
  end
  else begin
     Map_Right.Value := Map_Left.Value;
     Map_Left.Value := myClickPoint.X;
  end;
  myDraw;
end;

// �����ϱ߽�
procedure TRecogForm.B_TopClick(Sender: TObject);
begin
  if myClickPoint.Y <= Map_Bottom.Value then begin
     Map_Top.Value := myClickPoint.Y;
     PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
  end
  else begin
     Map_Top.Value := Map_Bottom.Value;
     Map_Bottom.Value :=  myClickPoint.Y;
  end;
  myDraw;
end;

// �����±߽�
procedure TRecogForm.B_BottomClick(Sender: TObject);
begin
  if myClickPoint.Y >= Map_Top.Value then begin
     Map_Bottom.Value := myClickPoint.Y;
     PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
  end
  else begin
     Map_Bottom.Value := Map_Top.Value;
     Map_Top.Value := myClickPoint.Y;
  end;
  myDraw;
end;

// ��갴��
procedure TRecogForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  myClickPoint.X := X;
  myClickPoint.Y := Y;
end;

// ���̧��
procedure TRecogForm.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin

end;

// ����϶� -- ��ѡ���
procedure TRecogForm.Map_LeftChange(Sender: TObject);
begin
  PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
  Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
  myDraw;
end;

procedure TRecogForm.Map_RightChange(Sender: TObject);
begin
  PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
  Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
  myDraw;
end;

procedure TRecogForm.Map_TopChange(Sender: TObject);
begin
  PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
  Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
  myDraw;
end;

procedure TRecogForm.Map_BottomChange(Sender: TObject);
begin
  PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
  Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
  myDraw;
end;

procedure TRecogForm.SpeedButton1Click(Sender: TObject);
begin
  Map_Right.Value := Image1.Width-1;
  Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
  myDraw;
end;

procedure TRecogForm.SpeedButton2Click(Sender: TObject);
begin
  Map_Bottom.Value := Image1.Height-1;
  Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
  myDraw;
end;

procedure TRecogForm.SpeedButton3Click(Sender: TObject);
begin
  Map_Left.Value := 0;
  Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
  myDraw;
end;

procedure TRecogForm.SpeedButton4Click(Sender: TObject);
begin
  Map_Top.Value := 0;
  Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
  myDraw;
end;

procedure TRecogForm.FormCreate(Sender: TObject);
begin
  Caption := '�и�ؿ�ͼ';

  B_Top.Caption := '�ϱ߽�(&T)';
  B_Bottom.Caption := '�±߽�(&B)';
  B_Left.Caption := '��߽�(&L)';
  B_Right.Caption := '�ұ߽�(&R)';

  sb_Open.Hint := '�򿪹ؿ���ͼ';
  SpeedButton5.Hint := '�и�ؿ���ͼ';

  SpeedButton1.Caption := '��';
  SpeedButton1.Caption := '��';
  SpeedButton3.Hint := '�Խ�ͼ�����Ϊ�ؿ���߽�';
  SpeedButton1.Hint := '�Խ�ͼ���ұ�Ϊ�ؿ��ұ߽�';
  SpeedButton4.Hint := '�Խ�ͼ���ϱ�Ϊ�ؿ��ϱ߽�';
  SpeedButton2.Hint := '�Խ�ͼ���±�Ϊ�ؿ��±߽�';

  Label1.Caption := '��߽�:';
  Label2.Caption := '�ұ߽�:';
  Label3.Caption := '�ϱ߽�:';
  Label4.Caption := '�±߽�:';
  Label5.Caption := '�и�:';
  Label8.Caption := '�п�:';
  Map_Size.Caption := '�ؿ��ߴ�:';

  Map_RowHeight.Value := 50;
  Map_ColWidth.Value := 50;
end;

procedure TRecogForm.Map_RowHeightChange(Sender: TObject);
begin
   if Map_RowHeight.Value > 0 then begin
     PicRows := (Map_Bottom.Value-Map_Top.Value) div Map_RowHeight.Value;
     Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
     myDraw;
   end;
end;

procedure TRecogForm.Map_ColWidthChange(Sender: TObject);
begin
   if Map_ColWidth.Value > 0 then begin
     PicCols := (Map_Right.Value-Map_Left.Value) div Map_ColWidth.Value;
     Map_Size.Caption := Format('����: %d, ����: %d', [PicRows+1, PicCols+1]);
     myDraw;
   end;
end;

procedure TRecogForm.SpeedButton5Click(Sender: TObject);
begin
  if Image1.Visible then Tag := 1
  else Tag := 0;
  Close;
end;

end.
