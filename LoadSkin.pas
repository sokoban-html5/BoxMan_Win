unit LoadSkin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, StdCtrls, ExtCtrls, StrUtils;

type
  TLoadSkinForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Image1: TImage;
    ListBox1: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SkinFileName: string;

    procedure LoadDefaultSkin();                       // Ĭ�ϵļ�Ƥ��
    function  LoadSkin(FileName:string):boolean;       // ��������Զ����Ƥ��
    
  end;

var
  LoadSkinForm: TLoadSkinForm;

  // �ֳ�Ƥ��
  WallPic, FloorPic, GoalPic, ManPic, ManGoalPic, BoxPic, BoxGoalPic: TBitmap;
  WallPic_lurd, WallPic_lr, WallPic_l, WallPic_r, WallPic_ud, WallPic_u, WallPic_d, WallPic_lu, WallPic_ld, WallPic_ru, WallPic_rd, WallPic_lur, WallPic_ldr, WallPic_uld, WallPic_urd, WallPic_top: TBitmap;        // �޷�ǽ��
  FloorPic2, GoalPic2, ManPic2, ManGoalPic2, BoxPic2, BoxGoalPic2: TBitmap;  // ����ͼԪ
  MaskPic: TBitmap;  // ѡ��Ԫ����ͼ

  SkinSize      : Integer;            // Ƥ��Ԫ�سߴ�
  LineColor     : TColor;             // ������ɫ
  isFloorLine   : Boolean;            // �ذ��Ƿ���
  isGoalLine    : Boolean;            // Ŀ����Ƿ���
  isManLine     : Boolean;            // ���Ƿ���
  isManGoalLine : Boolean;            // ����Ŀ����Ƿ���
  isBoxLine     : Boolean;            // �����Ƿ���
  isBoxGoalLine : Boolean;            // ������Ŀ����Ƿ���
  
  isSeamless  : Boolean;              // �Ƿ��޷�ǽ��

implementation

uses
  LogFile;

var
  R: TRect;


{$R *.dfm}

// ����ָ��Ŀ¼�µ��ļ�
procedure FindPathFiles(const APath: string; AFiles: TStrings; const APropty: String = '*.*'; IsAddPath: Boolean = False);
var
  FS: TSearchRec;
  FPath: String;
  AddPath: string;
begin
  FPath := IncludeTrailingPathDelimiter(APath);
  AddPath := IfThen(IsAddPath, FPath, '');
  if FindFirst(FPath + APropty, faAnyFile, FS) = 0 then
  begin
    repeat
    if ((FS.Attr and faDirectory) <> faDirectory) then
       AFiles.Add(AddPath + FS.Name);
    until FindNext(FS) <> 0;
    SysUtils.FindClose(FS);
  end;
end;

// ȡ�� Skins �ļ����µ� .bmp ��ʽ�ĵ��б�
procedure TLoadSkinForm.FormShow(Sender: TObject);
begin
   // ÿ����ʾ����ʱ����Ҫ�����б�����ʼ��
   ListBox1.Items.Clear;
   FindPathFiles(ExtractFilePath(Application.ExeName) + 'Skins\', ListBox1.Items, '*.bmp', false);
   Image1.Canvas.Brush.Color := clBlack;
   Image1.Canvas.FillRect(R);
   Button2.Enabled := False;  // ��δѡ��Ƥ���ĵ��� OK ��ť��Ч
   SkinFileName := '';
   Label4.Caption := '';   // ��ǰѡ�е�ͼƬ�ĵ��Ĳ���
end;

procedure TLoadSkinForm.FormCreate(Sender: TObject);
begin
  Caption := '����Ƥ��';
  Label1.Caption := 'Ƥ���б�';
  Label2.Caption := 'Ԥ����';
  Label3.Caption := '˵����Ƥ������8��Ԫ�񣬷��������У�ÿ��4�񣬷ֱ�Ϊ���ذ塢�ˡ����ӡ�ǽ�ڼ�Ŀ��㡢����Ŀ��㡢������Ŀ��㡢ǽ����չ������ǽ����չ��Ϊ�޷�ǽ��׼���ģ��������ϸ���ͬ���ɡ�Ԫ��ߴ����ڣ�20-200������֮�䡣�ذ�����Ͻ����ص���ɫ��Ϊ�����ߵ���ɫ��';
  Button1.Caption := 'ȡ��(&C)';
  Button2.Caption := 'ȷ��(&O)';

  // ��������ʱ�ĳ�ʼ��
  R := Rect(0, 0, Image1.Width, Image1.Height);

  // ����Ƥ������
  FloorPic       :=TBitmap.Create;
  GoalPic        :=TBitmap.Create;
  ManPic         :=TBitmap.Create;
  ManGoalPic     :=TBitmap.Create;
  BoxPic         :=TBitmap.Create;
  BoxGoalPic     :=TBitmap.Create;

  FloorPic2      :=TBitmap.Create;
  GoalPic2       :=TBitmap.Create;
  ManPic2        :=TBitmap.Create;
  ManGoalPic2    :=TBitmap.Create;
  BoxPic2        :=TBitmap.Create;
  BoxGoalPic2    :=TBitmap.Create;

  WallPic        :=TBitmap.Create;
  WallPic_lurd   :=TBitmap.Create;

  WallPic_lr     :=TBitmap.Create;
  WallPic_l      :=TBitmap.Create;
  WallPic_r      :=TBitmap.Create;

  WallPic_ud     :=TBitmap.Create;
  WallPic_u      :=TBitmap.Create;
  WallPic_d      :=TBitmap.Create;

  WallPic_lu     :=TBitmap.Create;
  WallPic_ld     :=TBitmap.Create;
  WallPic_ru     :=TBitmap.Create;
  WallPic_rd     :=TBitmap.Create;

  WallPic_lur    :=TBitmap.Create;
  WallPic_ldr    :=TBitmap.Create;
  WallPic_uld    :=TBitmap.Create;
  WallPic_urd    :=TBitmap.Create;
  
  WallPic_top    :=TBitmap.Create;

  // ����Ƥ��
  if not LoadSkin(AppPath + 'Skins\' + curSkinFileName) then begin
     LoadDefaultSkin();         // ʹ��Ĭ�ϵļ�Ƥ��
  end;
end;

procedure TLoadSkinForm.ListBox1Click(Sender: TObject);
var
  pic: TBitmap;
  w, h, size: Integer;
  
begin
  if ListBox1.ItemIndex >=0 then begin
    try
        pic := TBitmap.Create;

        SkinFileName := ListBox1.Items[ListBox1.ItemIndex];

        pic.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Skins\' + SkinFileName);

        Image1.Canvas.StretchDraw(R, pic);
    
        w := pic.Width;
        h := pic.Height;
        size := w div 4;

        if (w <> h * 2) or ((w mod 4) <> 0) or (w < 80) or (w > 800 ) then begin
            Button2.Enabled := False;  // Ƥ���ĵ���ʽ������Ҫ�� OK ��ť��Ч
            Label4.Caption := 'Ԫ��ߴ�: ' + IntToStr(size) + '����';
        end
        else begin
            Button2.Enabled := True;  // Ƥ���ĵ���ʽ��ȷ�� OK ��ť��Ч
            Label4.Caption := 'Ԫ��ߴ�: ' + IntToStr(size) + '����';
        end;
        
        FreeAndNil(pic);
    except
      Button2.Enabled := False;  // Ƥ���ĵ����� OK ��ť��Ч
      Label4.Caption := ' ';
    end;
  end;
end;

// Ĭ��Ƥ���������Ǽ����򵥵ļ���ͼ��
procedure TLoadSkinForm.LoadDefaultSkin();
begin
  SkinSize   := 50;
  isSeamless := False;
  LineColor  := clInactiveCaptionText;  // ������ɫ
  isFloorLine   := true;            // �ذ��Ƿ���
  isGoalLine    := true;            // Ŀ����Ƿ���
  isManLine     := true;            // ���Ƿ���
  isManGoalLine := true;            // ����Ŀ����Ƿ���
  isBoxLine     := true;            // �����Ƿ���
  isBoxGoalLine := true;            // ������Ŀ����Ƿ���

  // �ذ�
  FloorPic.Width   := SkinSize;
  FloorPic.Height  := SkinSize;
  FloorPic.Canvas.Brush.Color := clBlack;
  FloorPic.Canvas.FillRect(Rect(0, 0, SkinSize, SkinSize));

  // Ŀ���
  GoalPic.Width   := SkinSize;
  GoalPic.Height  := SkinSize;
  GoalPic.Canvas.Brush.Color := clBlack;
  GoalPic.Canvas.FillRect(Rect(0, 0, SkinSize, SkinSize));
  GoalPic.Canvas.Brush.Color := $959A18;
  GoalPic.Canvas.Ellipse(12, 12, SkinSize-12, SkinSize-12);

  // ���
  ManPic.Width   := SkinSize;
  ManPic.Height  := SkinSize;
  ManPic.Canvas.Brush.Color := clBlack;
  ManPic.Canvas.FillRect(Rect(0, 0, SkinSize, SkinSize));
  ManPic.Canvas.Brush.Color := $000198;
  ManPic.Canvas.Ellipse(5, 5, SkinSize-5, SkinSize-5);

  // ��ҡ�Ŀ���
  ManGoalPic.Width   := SkinSize;
  ManGoalPic.Height  := SkinSize;
  ManGoalPic.Canvas.Brush.Color := clBlack;
  ManGoalPic.Canvas.FillRect(Rect(0, 0, SkinSize, SkinSize));
  ManGoalPic.Canvas.Brush.Color := $000198;
  ManGoalPic.Canvas.Ellipse(5, 5, SkinSize-5, SkinSize-5);
  ManGoalPic.Canvas.Brush.Color := $959A18;
  ManGoalPic.Canvas.Ellipse(12, 12, SkinSize-12, SkinSize-12);

  // ����
  BoxPic.Width   := SkinSize;
  BoxPic.Height  := SkinSize;
  BoxPic.Canvas.Brush.Color := clBlack;
  BoxPic.Canvas.FillRect(Rect(0, 0, SkinSize, SkinSize));
  BoxPic.Canvas.Brush.Color:=$378CCF;
  BoxPic.Canvas.FillRect(Rect(1, 1, SkinSize-1, SkinSize-1));

  // ���ӡ�Ŀ���
  BoxGoalPic.Width   := SkinSize;
  BoxGoalPic.Height  := SkinSize;
  BoxGoalPic.Canvas.Brush.Color := clBlack;
  BoxGoalPic.Canvas.FillRect(Rect(0, 0, SkinSize, SkinSize));
  BoxGoalPic.Canvas.Brush.Color := $959A18;
  BoxGoalPic.Canvas.FillRect(Rect(1, 1, SkinSize-1, SkinSize-1));

  // ǽ��
  WallPic.Width   := SkinSize;
  WallPic.Height  := SkinSize;
  WallPic.Canvas.Brush.Color := $73655F;
  WallPic.Canvas.FillRect(Rect(0, 0, SkinSize, SkinSize));
  
end;

// ͼԪ���ȵ���
procedure BrightnessChange(const SrcBmp, DestBmp: TBitmap; ValueChange: integer);
var
  i, j: integer;
  SrcRGB, DestRGB: pRGBTriple;
  
begin
  SrcBmp.PixelFormat   :=   pf24Bit;
  DestBmp.PixelFormat   :=   pf24Bit;
  for i := 0 to SrcBmp.Height - 1 do
  begin
    SrcRGB := SrcBmp.ScanLine[i];
    DestRGB := DestBmp.ScanLine[i];
    for j := 0 to SrcBmp.Width - 1 do
    begin
      if ValueChange > 0 then
      begin
        DestRGB.rgbtRed := Min(255, SrcRGB.rgbtRed + ValueChange);
        DestRGB.rgbtGreen := Min(255, SrcRGB.rgbtGreen + ValueChange);
        DestRGB.rgbtBlue := Min(255, SrcRGB.rgbtBlue + ValueChange);
      end else begin
        DestRGB.rgbtRed := Max(0, SrcRGB.rgbtRed + ValueChange);
        DestRGB.rgbtGreen := Max(0, SrcRGB.rgbtGreen + ValueChange);
        DestRGB.rgbtBlue := Max(0, SrcRGB.rgbtBlue + ValueChange);
      end;
      Inc(SrcRGB);
      Inc(DestRGB);
    end;
  end;
end;

// ����Ƥ��
function TLoadSkinForm.LoadSkin(FileName:string):boolean;
var
  pic: TBitmap;
  w, h, size, s_4, i: Integer;
  R1, R2: TRect;
  c1, c2: TColor;

begin
  result := false;
  
  if not FileExists(FileName) then begin
     exit;
  end;

  try
    pic := TBitmap.Create;

    pic.LoadFromFile(FileName);

    w := pic.Width;
    h := pic.Height;

    if (w <> h * 2) or ((w mod 4) <> 0) or (w < 80) or (w > 800 ) then begin
       Exit;
    end;

    size := w div 4;

    R2 := Rect(0, 0, size, size);

    // Floor
    R1 := Rect(0, 0, size, size);
    FloorPic.Width := size;
    FloorPic.Height := size;
    FloorPic.Canvas.CopyMode := SRCCOPY;
    FloorPic.Canvas.CopyRect(R2, pic.Canvas, R1);

    c1            := FloorPic.Canvas.Pixels[1, 1];    // ȡ�ذ�ͼԪ��[1, 1]���ص���ɫ��Ϊ�Ƿ񻭸��ߵıȽ���ɫ
    LineColor     := FloorPic.Canvas.Pixels[0, 0];    // ȡ�ذ�ͼԪ��[0, 0]���ص���ɫ��Ϊ������ɫ
    isFloorLine   := LineColor <> c1;
    c2            := FloorPic.Canvas.Pixels[1, 0];    // ��������ȡ�ذ�ͼԪ�����ص���ɫ��ΪĿ��㡢�ˡ�����Ŀ��㡢���ӡ�������Ŀ���ͼԪ�Ƿ񻭸��ߵıȽ���ɫ
    isGoalLine    := c1 <> c2;                        // Ŀ����Ƿ���
    c2            := FloorPic.Canvas.Pixels[2, 0];
    isManLine     := c1 <> c2;                        // ���Ƿ���
    c2            := FloorPic.Canvas.Pixels[3, 0];
    isManGoalLine := c1 <> c2;                        // ����Ŀ����Ƿ���
    c2            := FloorPic.Canvas.Pixels[4, 0];
    isBoxLine     := c1 <> c2;                        // �����Ƿ���
    c2            := FloorPic.Canvas.Pixels[5, 0];
    isBoxGoalLine := c1 <> c2            ;            // ������Ŀ����Ƿ���

    // Goal
    R1 := Rect(0, size, size, size*2);
    GoalPic.Width := size;
    GoalPic.Height := size;
    GoalPic.Canvas.CopyMode := SRCCOPY;
    GoalPic.Canvas.CopyRect(R2, pic.Canvas, R1);

    // Player
    R1 := Rect(size, 0, size*2, size);
    ManPic.Width := size;
    ManPic.Height := size;
    ManPic.Canvas.CopyMode := SRCCOPY;
    ManPic.Canvas.CopyRect(R2, pic.Canvas, R1);

    // PlayerGoal
    R1 := Rect(size, size, size*2, size*2);
    ManGoalPic.Width := size;
    ManGoalPic.Height := size;
    ManGoalPic.Canvas.CopyMode := SRCCOPY;
    ManGoalPic.Canvas.CopyRect(R2, pic.Canvas, R1);

    // Box
    R1 := Rect(size*2, 0, size*3, size);
    BoxPic.Width := size;
    BoxPic.Height := size;
    BoxPic.Canvas.CopyMode := SRCCOPY;
    BoxPic.Canvas.CopyRect(R2, pic.Canvas, R1);

    // BoaGoal
    R1 := Rect(size*2, size, size*3, size*2);
    BoxGoalPic.Width := size;
    BoxGoalPic.Height := size;
    BoxGoalPic.Canvas.CopyMode := SRCCOPY;
    BoxGoalPic.Canvas.CopyRect(R2, pic.Canvas, R1);

    // ����ͼԪ
    FloorPic2.Width := size;
    FloorPic2.Height := size;
    GoalPic2.Width := size;
    GoalPic2.Height := size;
    ManPic2.Width := size;
    ManPic2.Height := size;
    ManGoalPic2.Width := size;
    ManGoalPic2.Height := size;
    BoxPic2.Width := size;
    BoxPic2.Height := size;
    BoxGoalPic2.Width := size;
    BoxGoalPic2.Height := size;
    BrightnessChange(FloorPic, FloorPic2, -10);
    BrightnessChange(GoalPic, GoalPic2, -10);
    BrightnessChange(ManPic, ManPic2, -10);
    BrightnessChange(ManGoalPic, ManGoalPic2, -10);
    BrightnessChange(BoxPic, BoxPic2, -10);
    BrightnessChange(BoxGoalPic, BoxGoalPic2, -10);

    // Wall
    R1 := Rect(size*3, 0, size*4, size);
    WallPic.Width := size;
    WallPic.Height := size;
    WallPic.Canvas.CopyMode := SRCCOPY;
    WallPic.Canvas.CopyRect(R2, pic.Canvas, R1);

    // Wall_lurd
    R1 := Rect(size*3, size, size*4, size*2);
    WallPic_lurd.Width := size;
    WallPic_lurd.Height := size;
    WallPic_lurd.Canvas.CopyMode := SRCCOPY;
    WallPic_lurd.Canvas.CopyRect(R2, pic.Canvas, R1);

    // ����Ϊƴ���޷�ǽ��
    s_4  := size div 4;

    isSeamless := False;

    // ���Ƥ���е�����ǽ��Ԫ�񣬿��Ƿ�ʹ�����޷�ǽ��
    // ���Ƚϵ�һ�еİ����ж�Ӧ�����ص㣬��������ͬ�����ص㣬����Ϊʹ�����޷�ǽ��
    for i := 0 to size div 2 do begin
        c1 := WallPic.Canvas.Pixels[i, 0];
        c2 := WallPic_lurd.Canvas.Pixels[i, 0];

        if c1 <> c2 then begin
           isSeamless := True;
           Break;
        end;

    end;

    // ��Ƥ��ʹ�����޷�ǽ��
    if isSeamless then begin
       // ˮƽ -- �ߴ�
       WallPic_lr.Width := size;
       WallPic_lr.Height := size;
       WallPic_l.Width := size;
       WallPic_l.Height := size;
       WallPic_r.Width := size;
       WallPic_r.Height := size;

       // ��ֱ -- �ߴ�
       WallPic_ud.Width := size;
       WallPic_ud.Height := size;
       WallPic_u.Width := size;
       WallPic_u.Height := size;
       WallPic_d.Width := size;
       WallPic_d.Height := size;

       // �Ľ� -- �ߴ�
       WallPic_lu.Width := size;
       WallPic_lu.Height := size;
       WallPic_ld.Width := size;
       WallPic_ld.Height := size;
       WallPic_ru.Width := size;
       WallPic_ru.Height := size;
       WallPic_rd.Width := size;
       WallPic_rd.Height := size;

       // �ı� -- �ߴ�
       WallPic_lur.Width := size;
       WallPic_lur.Height := size;
       WallPic_ldr.Width := size;
       WallPic_ldr.Height := size;
       WallPic_uld.Width := size;
       WallPic_uld.Height := size;
       WallPic_urd.Width := size;
       WallPic_urd.Height := size;

       // �� -- �ߴ�
       WallPic_top.Width := size;
       WallPic_top.Height := size;

       // ˮƽ����ֱ -- Ԥ��ͼ
       WallPic_lr.Canvas.Draw(0, 0, WallPic);
       WallPic_l.Canvas.Draw(0, 0, WallPic);
       WallPic_r.Canvas.Draw(0, 0, WallPic);
       WallPic_ud.Canvas.Draw(0, 0, WallPic);
       WallPic_u.Canvas.Draw(0, 0, WallPic);
       WallPic_d.Canvas.Draw(0, 0, WallPic);

       // �ı� -- Ԥ��ͼ
       WallPic_lur.Canvas.Draw(0, 0, WallPic_lurd);
       WallPic_ldr.Canvas.Draw(0, 0, WallPic_lurd);
       WallPic_uld.Canvas.Draw(0, 0, WallPic_lurd);
       WallPic_urd.Canvas.Draw(0, 0, WallPic_lurd);

       // �� -- Ԥ��ͼ
       WallPic_top.Canvas.Draw(0, 0, WallPic_lurd);

       // ƴ���޷�ǽ��Ԫ��
       // ˮƽ����� 3 ��
       R1 := Rect(s_4, 0, s_4 * 2, size);
       R2 := Rect(0, 0, s_4, size);
       WallPic_lr.Canvas.CopyMode := SRCCOPY;
       WallPic_lr.Canvas.CopyRect(R2, WallPic.Canvas, R1);
       WallPic_l.Canvas.CopyMode := SRCCOPY;
       WallPic_l.Canvas.CopyRect(R2, WallPic.Canvas, R1);
       R2 := Rect(size - s_4, 0, size, size);
       WallPic_lr.Canvas.CopyMode := SRCCOPY;
       WallPic_lr.Canvas.CopyRect(R2, WallPic.Canvas, R1);
       WallPic_r.Canvas.CopyMode := SRCCOPY;
       WallPic_r.Canvas.CopyRect(R2, WallPic.Canvas, R1);

       // ��ֱ����� 3 ��
       R1 := Rect(0, s_4, size, s_4 * 2);
       R2 := Rect(0, 0, size, s_4);
       WallPic_ud.Canvas.CopyMode := SRCCOPY;
       WallPic_ud.Canvas.CopyRect(R2, WallPic.Canvas, R1);
       WallPic_u.Canvas.CopyMode := SRCCOPY;
       WallPic_u.Canvas.CopyRect(R2, WallPic.Canvas, R1);
       R2 := Rect(0, size - s_4, size, size);
       WallPic_ud.Canvas.CopyMode := SRCCOPY;
       WallPic_ud.Canvas.CopyRect(R2, WallPic.Canvas, R1);
       WallPic_d.Canvas.CopyMode := SRCCOPY;
       WallPic_d.Canvas.CopyRect(R2, WallPic.Canvas, R1);

       // �ı�
       WallPic_uld.Canvas.CopyMode := SRCCOPY;
       R2 := Rect(size - s_4, 0, size, size);
       WallPic_uld.Canvas.CopyRect(R2, WallPic_ud.Canvas, R2);

       WallPic_urd.Canvas.CopyMode := SRCCOPY;
       R2 := Rect(0, 0, s_4, size);
       WallPic_urd.Canvas.CopyRect(R2, WallPic_ud.Canvas, R2);

       WallPic_lur.Canvas.CopyMode := SRCCOPY;
       R2 := Rect(0, size - s_4, size, size);
       WallPic_lur.Canvas.CopyRect(R2, WallPic_lr.Canvas, R2);

       WallPic_ldr.Canvas.CopyMode := SRCCOPY;
       R2 := Rect(0, 0, size, s_4);
       WallPic_ldr.Canvas.CopyRect(R2, WallPic_lr.Canvas, R2);

       // �Ľ� -- Ԥ��ͼ
       WallPic_lu.Canvas.Draw(0, 0, WallPic_lur);
       WallPic_ld.Canvas.Draw(0, 0, WallPic_ldr);
       WallPic_ru.Canvas.Draw(0, 0, WallPic_lur);
       WallPic_rd.Canvas.Draw(0, 0, WallPic_ldr);

       // �Ľ�
       WallPic_lu.Canvas.CopyMode := SRCCOPY;
       R2 := Rect(size - s_4, 0, size, size);
       WallPic_lu.Canvas.CopyRect(R2, WallPic_ud.Canvas, R2);
       R1 := Rect(size - s_4, size - s_4, size, size);
       WallPic_lu.Canvas.CopyRect(R1, WallPic.Canvas, R1);

       WallPic_ru.Canvas.CopyMode := SRCCOPY;
       R2 := Rect(0, 0, s_4, size);
       WallPic_ru.Canvas.CopyRect(R2, WallPic_ud.Canvas, R2);
       R1 := Rect(0, size - s_4, s_4, size);
       WallPic_ru.Canvas.CopyRect(R1, WallPic.Canvas, R1);

       WallPic_ld.Canvas.CopyMode := SRCCOPY;
       R2 := Rect(size - s_4, 0, size, size);
       WallPic_ld.Canvas.CopyRect(R2, WallPic_ud.Canvas, R2);
       R1 := Rect(size - s_4, 0, size, s_4);
       WallPic_ld.Canvas.CopyRect(R1, WallPic.Canvas, R1);

       WallPic_rd.Canvas.CopyMode := SRCCOPY;
       R2 := Rect(0, 0, s_4, size);
       WallPic_rd.Canvas.CopyRect(R2, WallPic_ud.Canvas, R2);
       R1 := Rect(0, 0, s_4, s_4);
       WallPic_rd.Canvas.CopyRect(R1, WallPic.Canvas, R1);

       // ��
       WallPic_top.Canvas.CopyMode := SRCCOPY;
       R1 := Rect(s_4, s_4, s_4 * 2, s_4 * 2);
       R2 := Rect(0, 0, s_4, s_4);
       WallPic_top.Canvas.CopyRect(R2, WallPic_ud.Canvas, R1);
       R2 := Rect(0, size - s_4, s_4, size);
       WallPic_top.Canvas.CopyRect(R2, WallPic_ud.Canvas, R1);
       R2 := Rect(size - s_4, 0, size, s_4);
       WallPic_top.Canvas.CopyRect(R2, WallPic_ud.Canvas, R1);
       R2 := Rect(size - s_4, size - s_4, size, size);
       WallPic_top.Canvas.CopyRect(R2, WallPic_ud.Canvas, R1);

    end;

    FreeAndNil(pic);
  except
    exit;
  end;

  SkinSize := size;

  Result := true;
end;

procedure TLoadSkinForm.FormDestroy(Sender: TObject);
begin
  // �ͷ��ڴ�
  FreeAndNil(FloorPic);
  FreeAndNil(GoalPic);
  FreeAndNil(ManPic);
  FreeAndNil(ManGoalPic);
  FreeAndNil(BoxPic);
  FreeAndNil(BoxGoalPic);

  FreeAndNil(FloorPic2);
  FreeAndNil(GoalPic2);
  FreeAndNil(ManPic2);
  FreeAndNil(ManGoalPic2);
  FreeAndNil(BoxPic2);
  FreeAndNil(BoxGoalPic2);

  FreeAndNil(WallPic);
  FreeAndNil(WallPic_lurd);

  FreeAndNil(WallPic_lr);
  FreeAndNil(WallPic_l);
  FreeAndNil(WallPic_r);

  FreeAndNil(WallPic_ud);
  FreeAndNil(WallPic_u);
  FreeAndNil(WallPic_d);

  FreeAndNil(WallPic_lu);
  FreeAndNil(WallPic_ld);
  FreeAndNil(WallPic_ru);
  FreeAndNil(WallPic_rd);

  FreeAndNil(WallPic_lur);
  FreeAndNil(WallPic_ldr);
  FreeAndNil(WallPic_uld);
  FreeAndNil(WallPic_urd);

  FreeAndNil(WallPic_top);

end;

procedure TLoadSkinForm.ListBox1DblClick(Sender: TObject);
begin
  if ListBox1.ItemIndex >=0 then begin
     ListBox1Click(Self);
     Button2.Click;
  end;
end;

end.
