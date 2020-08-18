unit TrialUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, ComCtrls, AppEvnts, PathFinder, StdCtrls;

type
  TTrialForm = class(TForm)
    pl_Tools: TPanel;
    bt_UnDo: TSpeedButton;
    bt_ReDo: TSpeedButton;
    bt_OddEven: TSpeedButton;
    bt_GoThrough: TSpeedButton;
    bt_Exit: TSpeedButton;
    pl_Ground: TPanel;
    map_Image: TImage;
    StatusBar1: TStatusBar;
    ApplicationEvents1: TApplicationEvents;
    SpeedButton1: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure bt_ExitMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bt_ExitClick(Sender: TObject);
    
    function  GetWall(r, c: Integer): Integer;
    procedure DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);
    procedure DrawMap();
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    
    map_Board: array[0..9999] of Char;             // ��������ͼ

    isBK: boolean;             // �Ƿ�����ģʽ
    isGoThrough: boolean;      // ��Խ�Ƿ���
    isOddEven: Boolean;        // �Ƿ���ʾ��ż��Ч

    mapRows, mapCols, manPos: Integer;

    myPathFinder: TPathFinder;

  end;

const
  minWindowsWidth = 600;                            // ���򴰿���С�ߴ�����
  minWindowsHeight = 400;

var
  TrialForm: TTrialForm;

  IsManAccessibleTips, IsBoxAccessibleTips: Boolean;
  CellSize: Integer;

implementation

uses
  LurdAction, LoadSkin;

{$R *.dfm}

procedure TTrialForm.FormCreate(Sender: TObject);
begin
  Caption := '������';
  bt_Exit.Caption := '����';
  bt_GoThrough.Caption := '��Խ';
  bt_OddEven.Caption := '��ż';

  bt_Exit.Hint := '���ر༭: Esc';
  bt_GoThrough.Hint := '��Խ����: G';
  bt_OddEven.Hint := '��ż��λ: E';

  StatusBar1.Panels[0].Text := '�ƶ�';
  StatusBar1.Panels[2].Text := '�ƶ�';
  StatusBar1.Panels[4].Text := '���';

  KeyPreview := true;
end;

procedure TTrialForm.bt_ExitMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  StatusBar1.Panels[7].Text := bt_Exit.Hint;
end;

procedure TTrialForm.bt_ExitClick(Sender: TObject);
begin
  Close;
end;

// �����޷�ǽ��ͼԪ
function TTrialForm.GetWall(r, c: Integer): Integer;
var
  pos: Integer;
begin
  result := 0;

  pos := r * mapCols + c;

  if (c > 0) and (map_Board[r * mapCols + c - 1] = '#') then
    result := result or 1;  // ����ǽ��
  if (r > 0) and (map_Board[(r - 1) * mapCols + c] = '#') then
    result := result or 2;  // ����ǽ��
  if (c < mapCols - 1) and (map_Board[r * mapCols + c + 1] = '#') then
    result := result or 4;  // ����ǽ��
  if (r < mapRows - 1) and (map_Board[(r + 1) * mapCols + c] = '#') then
    result := result or 8;  // ����ǽ��

  if ((result = 3) or (result = 7) or (result = 11) or (result = 15)) and (c > 0) and (r > 0) and (map_Board[pos - mapCols - 1] = '#') then
    result := result or 16;  // ��Ҫ��ǽ��
end;

// �Ƚ�ͼԪ���һ������ɫ��ذ����ɫ�Ƿ���ͬ����ȷ���Ƿ񻭸���
procedure TTrialForm.DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);
begin
  if isLine then
  begin
    cs.Pen.Color := LineColor;
    cs.MoveTo(x1, y1);
    cs.LineTo(x1 + CellSize, y1);
    cs.MoveTo(x1, y1);
    cs.LineTo(x1, y1 + CellSize);
  end;
end;

// �ػ���ͼ
procedure TTrialForm.DrawMap();
var
  i, j, k, dx, dy, x1, y1, x2, y2, x3, y3, x4, y4, pos, t1, t2, man_Pos_: integer;
  R, R2: TRect;

begin

  // �����ʽ
  if IsManAccessibleTips or IsBoxAccessibleTips then map_Image.Cursor := crDrag
  else map_Image.Cursor := crDefault;

  map_Image.Visible := false;

  for i := 0 to mapRows - 1 do
  begin
    for j := 0 to mapCols - 1 do
    begin
      pos := i * mapCols + j;    // ��ͼ�У������ӡ�����ʵλ��

      x1 := j * CellSize;        // x1, y1 �ǵ�ͼԪ�صĻ������� -- ��ת���
      y1 := i * CellSize;

      R := Rect(x1, y1, x1 + CellSize, y1 + CellSize);        // ��ͼ���ӵĻ��ƾ���

      map_Image.Canvas.CopyMode := SRCCOPY;
      case map_Board[pos] of
        '#':
          if isSeamless then
          begin    // �޷�ǽ��
            k := GetWall(i, j);
            case (k and $F) of
              1:
                map_Image.Canvas.StretchDraw(R, WallPic_l);     // ����
              2:
                map_Image.Canvas.StretchDraw(R, WallPic_u);     // ����
              3:
                map_Image.Canvas.StretchDraw(R, WallPic_lu);    // ����
              4:
                map_Image.Canvas.StretchDraw(R, WallPic_r);     // ����
              5:
                map_Image.Canvas.StretchDraw(R, WallPic_lr);    // ����
              6:
                map_Image.Canvas.StretchDraw(R, WallPic_ru);    // �ҡ���
              7:
                map_Image.Canvas.StretchDraw(R, WallPic_lur);   // ���ϡ���
              8:
                map_Image.Canvas.StretchDraw(R, WallPic_d);     // ����
              9:
                map_Image.Canvas.StretchDraw(R, WallPic_ld);    // ����
              10:
                map_Image.Canvas.StretchDraw(R, WallPic_ud);    // �ϡ���
              11:
                map_Image.Canvas.StretchDraw(R, WallPic_uld);   // ���ϡ���
              12:
                map_Image.Canvas.StretchDraw(R, WallPic_rd);    // �ҡ���
              13:
                map_Image.Canvas.StretchDraw(R, WallPic_ldr);   // ���ҡ���
              14:
                map_Image.Canvas.StretchDraw(R, WallPic_urd);   // �ϡ��ҡ���
              15:
                map_Image.Canvas.StretchDraw(R, WallPic_lurd);  // �ķ���ȫ��
            else
              map_Image.Canvas.StretchDraw(R, WallPic);
            end;
            if k > 15 then
            begin     // ��Ҫ����ǽ�Ķ��� -- �������Ŀ顱ǽ��
              dx := R.Left - CellSize div 2;
              dy := R.Top - CellSize div 2;
              map_Image.Canvas.StretchDraw(Rect(dx, dy, dx + CellSize, dy + CellSize), WallPic_top);
            end;
          end
          else
          begin                 // ��ǽ��
            map_Image.Canvas.StretchDraw(R, WallPic);
          end;
        '-':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, FloorPic2)
            else map_Image.Canvas.StretchDraw(R, FloorPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isFloorLine);  // ��������
          end;
        '.':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, GoalPic2)
            else map_Image.Canvas.StretchDraw(R, GoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isGoalLine);   // ��������
          end;
        '$':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxPic2)
            else map_Image.Canvas.StretchDraw(R, BoxPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxLine);    // ��������
          end;
        '*':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, BoxGoalPic2)
            else map_Image.Canvas.StretchDraw(R, BoxGoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isBoxGoalLine); // ��������
          end;
        '@':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManPic2)
            else map_Image.Canvas.StretchDraw(R, ManPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManLine);    // ��������
          end;
        '+':
          begin
            if isOddEven and ((i + j) mod 2 = 1) then map_Image.Canvas.StretchDraw(R, ManGoalPic2)
            else map_Image.Canvas.StretchDraw(R, ManGoalPic);
            if not isOddEven then DrawLine(map_Image.Canvas, x1, y1, isManGoalLine); // ��������
          end;
      else
        if isBK then
           map_Image.Canvas.Brush.Color := clBlack
        else
           map_Image.Canvas.Brush.Color := clInactiveCaptionText;
          
        map_Image.Canvas.FillRect(R);
      end;

      // �Ƿ�����ģʽ��
      if isBK then
      begin

        if IsManAccessibleTips then
        begin   // ��ʾ�˵Ŀɴ���ʾ
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isManReachableByThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2));
          end
          else if myPathFinder.isManReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end
          else if myPathFinder.isBoxOfThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // ��ʾ���ӵĿɴ���ʾ
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isBoxReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
      end
      else                                                                      // ����
      begin
        if IsManAccessibleTips then
        begin   // ��ʾ�˵Ŀɴ���ʾ
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isManReachableByThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2));
          end
          else if myPathFinder.isManReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end
          else if myPathFinder.isBoxOfThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // ��ʾ���ӵĿɴ���ʾ
          t1 := CellSize div 6;
          if t1 < 4 then t1 := 4;
          t2 := t1 - 1;
          if myPathFinder.isBoxReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t1, y1 + CellSize div 2 - t1, x1 + CellSize div 2 + t1, y1 + CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + CellSize div 2 - t2, y1 + CellSize div 2 - t2, x1 + CellSize div 2 + t2, y1 + CellSize div 2 + t2);
          end;
        end;
      end;
    end;
  end;

  map_Image.Visible := true;

//  ShowStatusBar();
end;

procedure TTrialForm.FormShow(Sender: TObject);
begin
  DrawMap;
end;

procedure TTrialForm.SpeedButton1Click(Sender: TObject);
begin
  DrawMap;
end;

end.
