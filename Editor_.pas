unit Editor_;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Clipbrd, 
  Dialogs, ExtCtrls, Buttons, ExtDlgs, Math, StdCtrls, Grids, StrUtils,
  Menus, ComCtrls;

type                  
  TMapNode = record      // �ؿ��ڵ�
    Map: TStringList;    // �ؿ� XSB
    Title: string;       // ����
    Author: string;      // ����
    Comment: string;     // �ؿ�������Ϣ
  end;

type
  TEditorForm_ = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    sb_Load: TSpeedButton;
    pl_Wall: TPanel;
    img_Wall: TImage;
    pl_Box: TPanel;
    img_Box: TImage;
    pl_Goal: TPanel;
    img_Goal: TImage;
    pl_Floor: TPanel;
    img_Floor: TImage;
    pl_Player: TPanel;
    img_Player: TImage;
    DrawGrid1: TDrawGrid;
    pl_Select: TPanel;
    img_Select: TImage;
    sb_Save: TSpeedButton;
    sb_Xsb_OK: TSpeedButton;
    sb_Inf: TSpeedButton;
    sb_Clear: TSpeedButton;
    sb_UnDo: TSpeedButton;
    sb_Help: TSpeedButton;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    sb_ReDo: TSpeedButton;
    sb_SaveToFile: TSpeedButton;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    sb_LoadPic: TSpeedButton;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    bt_Skin: TSpeedButton;
    PopupMenu2: TPopupMenu;
    procedure SetSelect;
    procedure img_WallClick(Sender: TObject);
    procedure img_BoxClick(Sender: TObject);
    procedure img_GoalClick(Sender: TObject);
    procedure img_FloorClick(Sender: TObject);
    procedure img_PlayerClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rt: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure DrawGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DrawGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DrawGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure img_SelectClick(Sender: TObject);
    procedure DrawGrid1MouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure DrawGrid1MouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    function MapNormalize: Integer;
    procedure sb_Xsb_OKClick(Sender: TObject);             // ��ͼ��׼�����������򵥱�׼�� -- �����ؿ���ǽ������
    function LoadMapsFromClipboard: boolean;
    procedure sb_LoadClick(Sender: TObject);
    procedure sb_InfClick(Sender: TObject);
    procedure sb_SaveClick(Sender: TObject);
    procedure sb_ClearClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure sb_HelpClick(Sender: TObject);
    procedure sb_UnDoClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure sb_ReDoClick(Sender: TObject);
    procedure sb_SaveToFileClick(Sender: TObject);
    procedure sb_LoadPicClick(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure bt_SkinClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure img_WallMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_BoxMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_GoalMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_FloorMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_PlayerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure img_SelectMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_SaveToFileMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure sb_SaveMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_LoadMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_UnDoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_ReDoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_ClearMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_InfMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_Xsb_OKMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_HelpMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sb_LoadPicMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure bt_SkinMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);  private                     // ��ȡ�ؿ� -- �Ӽ��а���� XSB
    procedure SetUnDoReDo(isReDo: Boolean = false);                             // Set UnDo
    function LurdToXSB(mStr: String): boolean;                                  // �ô𰸵��ƹؿ�
    function isLurd(str: String): boolean;                                      // �Ƿ� Lurd �ַ���
    procedure myCount;                                                          // ��������Ŀ���
  public
    { Public declarations }
  end;

const
  MaxSize = 100;
  XSB: array[0..6] of Char = ( '-', '.', '$', '*', '@', '+', '#' );

  cursorWall  = 1;
  cursorBox   = 2;
  cursorGoal  = 3;
  cursorFloor = 4;
  cursorMan   = 5;

var
  EditorForm_: TEditorForm_;

  MapNode: TMapNode;                     // �ؿ� XSB �������Ϣ
  
  mySelect: Integer;                     // ѡ���Ԫ��
  curCell, manPos: TPoint;               // ��갴��ʱλ�á��˵�λ��
  SelPoint_LT, SelPoint_RB: TPoint;      // ѡ�������

  isDrawing: Boolean;                    // �Ƿ�ʼ����

  CellSize: Integer;                     // ���ӵĳߴ�
  MapBoard: array[1..MaxSize, 1..MaxSize] of Integer;        // ��ǰ��������
  MapBoard_OK: array[0..MaxSize+1, 0..MaxSize+1] of Char;    // ��׼����ĵ�ͼ

  UnDoList, ReDoList: TStringList;

  isSaved: Boolean;                                          // �Ƿ��Ѿ�����
  isMoving: Boolean;                                         // �Ƿ��ƶ������
  isMouseRrghtDown: Boolean;                                 // �Ƿ���������Ҽ�

  isMouseSheel: Boolean;                                     // ʶ��ģ���У����ʹ����껬��΢��

//  myLogFile: Textfile;

implementation

uses
  EditorInf_, Recog_, LoadSkin, EditorHelp;
  
{$R *.dfm}
{$R MyCursor.res}

// ��ʼ����
procedure TEditorForm_.FormActivate(Sender: TObject);
var
  i, j: Integer;
begin
  mySelect := 0;
  SetSelect;
  
  curCell.X := 0;
  curCell.Y := 0;

  for i := 1 to MaxSize do begin
      for j := 1 to MaxSize do begin
          MapBoard[i, j] := 0;
      end;
  end;

end;

// ��Ԫ��ѡ��򡢸ı������ʽ
procedure TEditorForm_.SetSelect;
var
  i: Integer;

begin
  DrawGrid1.PopupMenu := PopupMenu2;
  for i := 0 to 5 do begin
      case i of
      0: begin
           if mySelect = i then begin
              pl_Select.Color := clRed;
              DrawGrid1.Cursor := crDefault;
              DrawGrid1.PopupMenu := PopupMenu1;
           end
           else pl_Select.Color := clInactiveCaption;
         end;
      1: begin
           if mySelect = i then begin
              pl_Wall.Color := clRed;
              DrawGrid1.Cursor := cursorWall;
           end
           else pl_Wall.Color := clInactiveCaption;
         end;
      2: begin
           if mySelect = i then begin
              pl_Box.Color := clRed;
              DrawGrid1.Cursor := cursorBox;
           end
           else pl_Box.Color := clInactiveCaption;
         end;
      3: begin
           if mySelect = i then begin
              pl_Goal.Color := clRed;
              DrawGrid1.Cursor := cursorGoal;
           end
           else pl_Goal.Color := clInactiveCaption;
         end;
      4: begin
           if mySelect = i then begin
              pl_Floor.Color := clRed;
              DrawGrid1.Cursor := cursorFloor;
           end
           else pl_Floor.Color := clInactiveCaption;
         end;
      5: begin
           if mySelect = i then begin
              pl_Player.Color := clRed;
              DrawGrid1.Cursor := cursorMan;
           end
           else pl_Player.Color := clInactiveCaption;
         end;
      end;
  end;
end;

// ѡ��ǽ��
procedure TEditorForm_.img_WallClick(Sender: TObject);
begin
  mySelect := 1;
  SetSelect;
end;

// ѡ������
procedure TEditorForm_.img_BoxClick(Sender: TObject);
begin
  mySelect := 2;
  SetSelect;
end;

// ѡ��Ŀ���
procedure TEditorForm_.img_GoalClick(Sender: TObject);
begin
  mySelect := 3;
  SetSelect;
end;

// ѡ��ذ�
procedure TEditorForm_.img_FloorClick(Sender: TObject);
begin
  mySelect := 4;
  SetSelect;
end;

// ѡ����
procedure TEditorForm_.img_PlayerClick(Sender: TObject);
begin
  mySelect := 5;
  SetSelect;
end;

procedure TEditorForm_.img_SelectClick(Sender: TObject);
begin
  mySelect := 0;
  SetSelect;
end;


procedure TEditorForm_.DrawGrid1DrawCell(Sender: TObject; ACol,
  ARow: Integer; Rt: TRect; State: TGridDrawState);
var
  R, R1, R2: TRect;
  ww, hh, l, t: Integer;
begin
  with Sender as TDrawGrid do begin
    Canvas.CopyMode := SRCCOPY;
    R := Rect(MapBoard[ARow+1, ACol+1] * 60, 0, MapBoard[ARow+1, ACol+1] * 60 + 60, 60);

    // ���ذ�
    if MapBoard[ARow+1, ACol+1] = 0 then begin
       Canvas.CopyRect(Rt, RecogForm_.Image4.Canvas, R);
    end;
    // ��ο�ͼ
    if (RecogForm_.Tag = 1) and (N6.Checked) and (ARow <= PicRows) and (ACol <= PicCols) then begin
       l := (RecogForm_.Map_Left.Value + ACol * RecogForm_.Map_ColWidth.Value) div myScale;
       t := (RecogForm_.Map_Top.Value + ARow * RecogForm_.Map_RowHeight.Value) div myScale;
       R2 := Rect(l, t, l + RecogForm_.Map_ColWidth.Value div myScale, t + RecogForm_.Map_RowHeight.Value div myScale);
       Canvas.CopyRect(Rt, RecogForm_.Image2.Canvas, R2);
    end;

    // ��ͼԪ��
    if (MapBoard[ARow+1, ACol+1] > 0) then begin
       Canvas.CopyRect(Rt, RecogForm_.Image4.Canvas, R);
    end;

    // С�ο�ͼ
    if (RecogForm_.Tag = 1) and (N7.Checked) and (ARow <= PicRows) and (ACol <= PicCols) then begin
       if MapBoard[ARow+1, ACol+1] > 0 then begin
         ww := (Rt.Right-Rt.Left) div 3;
         hh := (Rt.Bottom-Rt.Top) div 3;
         R1 := Rect(Rt.Left + ww, Rt.Top + ww, Rt.Left + ww + ww, Rt.Top + hh + ww);
         l := (RecogForm_.Map_Left.Value + ACol * RecogForm_.Map_ColWidth.Value) div myScale;
         t := (RecogForm_.Map_Top.Value + ARow * RecogForm_.Map_RowHeight.Value) div myScale;
         R2 := Rect(l, t, l + RecogForm_.Map_ColWidth.Value div myScale, t + RecogForm_.Map_RowHeight.Value div myScale);
         Canvas.CopyRect(R1, RecogForm_.Image2.Canvas, R2);
         Canvas.Pen.Color := clBlack;
         Canvas.Brush.Style := bsClear;
         Canvas.Rectangle(R1);
       end;
    end;

    // ������
    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := $00554D45;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(Rt);

    // ��ѡ��� - �������
    if gdSelected in State then begin
       Canvas.Brush.Color := clFuchsia;
       Canvas.FrameRect(Rt);
       StatusBar1.Panels[1].Text := IntToStr(ARow+1);
       StatusBar1.Panels[3].Text := IntToStr(ACol+1);
    end;
  end;
end;

procedure TEditorForm_.FormCreate(Sender: TObject);
begin
  if paramcount = 1 then
     isMouseSheel := AnsiSameText('/m', paramstr(1));

  Panel1.Color := $DBCDBF;
  Panel3.Color := $DBCDBF;
  pl_Wall.Color := $DBCDBF;
  pl_Box.Color := $DBCDBF;
  pl_Goal.Color := $DBCDBF;
  pl_Player.Color := $DBCDBF;
  pl_Floor.Color := $DBCDBF;
  pl_Select.Color := $DBCDBF;

  Caption := '�ؿ��༭��';

  StatusBar1.Panels[0].Text := '��';
  StatusBar1.Panels[2].Text := '��';
  StatusBar1.Panels[4].Text := '����';
  StatusBar1.Panels[6].Text := 'Ŀ��';

  N1.Caption := '����һ��';
  N2.Caption := '����һ��';
  N3.Caption := '����һ��';
  N4.Caption := '����һ��';
  N6.Caption := '�ο�ͼ';
  N7.Caption := 'С�ο�ͼ';

  sb_SaveToFile.Hint := '���浽�ĵ���Ctrl + S��';
  sb_Save.Hint := '���� - ������а塾Ctrl + C��';
  sb_Load.Hint := 'ճ�� - �Ӽ��а���롾Ctrl + V��';
  sb_UnDo.Hint := '������Ctrl + Z��';
  sb_ReDo.Hint := '������Shift + Z��';
  sb_Clear.Hint := '�������';
  sb_Inf.Hint := '��ͼ˵����Ϣ';
  sb_Xsb_OK.Hint := '��ͼ��׼��';
  sb_Help.Hint := '������F1]';
  sb_LoadPic.Hint := '��ͼʶ��';
  bt_Skin.Hint := '����Ƥ����F2��';    

  img_Wall.Hint := '���� -- ��ǽ�ڡ�';
  img_Box.Hint := '���� -- �����ӡ�';
  img_Goal.Hint := '���� -- ��Ŀ��㡻';
  img_Floor.Hint := '���� -- ���ذ塻';
  img_Player.Hint := '���� -- ���ֹ�Ա��';
  img_Select.Hint := '���롰���ģʽ��';

  Screen.Cursors[cursorWall]  := LoadCursor(HInstance, 'CURSOR_WALL');
  Screen.Cursors[cursorBox]   := LoadCursor(HInstance, 'CURSOR_BOX');
  Screen.Cursors[cursorGoal]  := LoadCursor(HInstance, 'CURSOR_GOAL');
  Screen.Cursors[cursorFloor] := LoadCursor(HInstance, 'CURSOR_FLOOR');
  Screen.Cursors[cursorMan]   := LoadCursor(HInstance, 'CURSOR_PLAYER');

  MapNode.Map := TStringList.Create;

  UnDoList := TStringList.Create;
  ReDoList := TStringList.Create;

  manPos.X := 0;
  manPos.Y := 0;
  CellSize := 60;
  DrawGrid1.DefaultColWidth := CellSize;
  DrawGrid1.RowCount := MaxSize;
  DrawGrid1.ColCount := MaxSize;
  isDrawing := false;
  isSaved := True;
  isMoving := False;
  isMouseRrghtDown := false;
  myScale := 1;

  N6.Checked := False;
  N7.Checked := False;

  KeyPreview := true;
end;

procedure TEditorForm_.DrawGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Cell: Integer;
begin
  isMouseRrghtDown := false;
  if Button = mbleft then begin                                                 // ���
    with Sender as TDrawGrid do begin
       MouseToCell(x, y, curCell.X, curCell.Y);
       Inc(curCell.X);
       Inc(curCell.Y);
       Cell := MapBoard[curCell.Y, curCell.X];
       if mySelect in [1, 2, 3, 4, 5] then SetUnDoReDo;
       case mySelect of
         1: Begin           // Wall
            if Cell in [ 4, 5 ] then begin
              manPos.X := 0;
              manPos.Y := 0;
            end;
            MapBoard[curCell.Y, curCell.X] := 6;
            isSaved := False;
         end;
         2: Begin           // Box
            if Cell in [ 4, 5 ] then begin
              manPos.X := 0;
              manPos.Y := 0;
            end;
            if Cell in [ 1, 2, 5] then MapBoard[curCell.Y, curCell.X] := 3
            else MapBoard[curCell.Y, curCell.X] := 2;
            isSaved := False;
         end;
         3: Begin           // Goal
            if Cell in [ 4, 5 ] then begin
              manPos.X := 0;
              manPos.Y := 0;
            end;
            if Cell in [ 1, 2, 5] then MapBoard[curCell.Y, curCell.X] := 3
            else MapBoard[curCell.Y, curCell.X] := 1;
            isSaved := False;
         end;
         4: Begin           // Floor
            if Cell in [ 4, 5 ] then begin
              manPos.X := 0;
              manPos.Y := 0;
            end;
            MapBoard[curCell.Y, curCell.X] := 0;
            isSaved := False;
         end;
         5: Begin           // Player
            if (not (Cell in [ 4, 5 ])) and (manPos.X > 0) and (manPos.Y > 0) then begin
              if MapBoard[manPos.Y, manPos.X] = 4 then MapBoard[manPos.Y, manPos.X] := 0
              else if MapBoard[manPos.Y, manPos.X] = 5 then MapBoard[manPos.Y, manPos.X] := 1;
            end;
            if Cell in [1, 3, 4] then MapBoard[curCell.Y, curCell.X] := 5
            else MapBoard[curCell.Y, curCell.X] := 4;
            manPos.X := curCell.X;
            manPos.Y := curCell.Y;
            isSaved := False;
         end;
         6: Begin           // Select
            SelPoint_LT.X := curCell.X;
            SelPoint_LT.Y := curCell.Y;
            SelPoint_RB.X := curCell.X;
            SelPoint_RB.Y := curCell.Y;
         end;
       end;
       Invalidate;
    end;
    isDrawing := True;
  end else if Button = mbright then begin                                       // �Ҽ�������
    with Sender as TDrawGrid do begin
       MouseToCell(x, y, curCell.X, curCell.Y);
       Inc(curCell.X);
       Inc(curCell.Y);
       Cell := MapBoard[curCell.Y, curCell.X];

       if Cell in [ 4, 5 ] then begin
          manPos.X := 0;
          manPos.Y := 0;
       end;
       MapBoard[curCell.Y, curCell.X] := 0;
       isSaved := False;
       isMouseRrghtDown := True;;

       Invalidate;
    end;
    isDrawing := True;
  end;
end;

procedure TEditorForm_.DrawGrid1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  xx, yy, Cell: Integer;
begin
  isMoving := True;            // �ƶ������
  with Sender as TDrawGrid do begin
    MouseToCell(x, y, xx, yy);
    if (xx >= 0) and (xx < ColCount) and (yy >= 0) and (yy < RowCount) then begin
      if (xx-LeftCol < (Width-24) div CellSize) and (yy-TopRow < (Height-24) div CellSize)then begin
        Row := yy;
        Col := xx;
      end;
    end;
    if isDrawing then begin
       Inc(xx);
       Inc(yy);
       if (xx <> curCell.X) or (yy <> curCell.Y) then begin
         Cell := MapBoard[yy, xx];
         if isMouseRrghtDown then begin
            if Cell in [ 4, 5 ] then begin
              manPos.X := 0;
              manPos.Y := 0;
            end;
            MapBoard[yy, xx] := 0;
            isSaved := False;
         end else begin
           case mySelect of
             1: Begin           // Wall
                if Cell in [ 4, 5 ] then begin
                  manPos.X := 0;
                  manPos.Y := 0;
                end;
                MapBoard[yy, xx] := 6;
                isSaved := False;
             end;
             2: Begin           // Box
                if Cell in [ 4, 5 ] then begin
                  manPos.X := 0;
                  manPos.Y := 0;
                end;
                if Cell in [1, 3, 5] then MapBoard[yy, xx] := 3
                else MapBoard[yy, xx] := 2;
                isSaved := False;
             end;
             3: Begin           // Goal
                if Cell in [2, 3] then MapBoard[yy, xx] := 3
                else if  Cell in [4, 5] then MapBoard[yy, xx] := 5
                else MapBoard[yy, xx] := 1;
                isSaved := False;
             end;
             4: Begin           // Floor
                if Cell in [ 4, 5 ] then begin
                  manPos.X := 0;
                  manPos.Y := 0;
                end;
                MapBoard[yy, xx] := 0;
                isSaved := False;
             end;
             6: Begin           // Select
                SelPoint_LT.X := xx;
                SelPoint_LT.Y := yy;
                SelPoint_RB.X := xx;
                SelPoint_RB.Y := yy;
             end;
           end;
         end;
         curCell.X := xx;
         curCell.Y := yy;
       end;
    end;
  end;
end;

// ��������Ŀ���
procedure TEditorForm_.myCount;
var
  i, j, Boxs, Goals: Integer;
begin
  Boxs := 0;
  Goals := 0;
  for i := 1 to MaxSize do begin
    for j := 1 to MaxSize do begin
      if MapBoard[i, j] in [2, 3] then Inc(Boxs);
      if MapBoard[i, j] in [1, 3, 5] then Inc(Goals);
      if RecogForm_.Tag = 1 then begin
         myMap[i-1, j-1] := XSB[MapBoard[i, j]];
         if myMap[i-1, j-1] in ['@', '+'] then begin
           rg_ManPos.X := manPos.X-1;
           rg_ManPos.Y := manPos.Y-1;
         end;
      end;
    end;
  end;
  StatusBar1.Panels[5].Text := IntToStr(Boxs);
  StatusBar1.Panels[7].Text := IntToStr(Goals);
end;

procedure TEditorForm_.DrawGrid1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  curCell.X := 0;
  curCell.Y := 0;
  isDrawing := false;
  isMouseRrghtDown := false;
  myCount;
end;

procedure TEditorForm_.DrawGrid1MouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssShift in Shift then begin     // ��С
    if CellSize > 20 then begin
      CellSize := CellSize - 2;
      DrawGrid1.DefaultColWidth := CellSize;
      DrawGrid1.DefaultRowHeight := CellSize;
      DrawGrid1.Invalidate;
    end;
  end
  else if ssCtrl in Shift then begin
    DrawGrid1.Perform(WM_HSCROLL,SB_LINEDOWN,0);
    if DrawGrid1.Col < DrawGrid1.LeftCol then DrawGrid1.Col := DrawGrid1.LeftCol;
  end
  else begin
    DrawGrid1.Perform(WM_VSCROLL,SB_LINEDOWN,0);
    if DrawGrid1.Row < DrawGrid1.TopRow then DrawGrid1.Row := DrawGrid1.TopRow;
  end;
  Handled := True;
end;

procedure TEditorForm_.DrawGrid1MouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssShift in Shift then begin     // �Ŵ�
    if CellSize < 60 then begin
      CellSize := CellSize + 2;
      DrawGrid1.DefaultColWidth := CellSize;
      DrawGrid1.DefaultRowHeight := CellSize;
      DrawGrid1.Invalidate;
    end;
  end
  else if ssCtrl in Shift then begin
     DrawGrid1.Perform(WM_HSCROLL,SB_LINEUP,0);
     if DrawGrid1.Col > DrawGrid1.LeftCol then DrawGrid1.Col := DrawGrid1.LeftCol;
  end
  else begin
    DrawGrid1.Perform(WM_VSCROLL,SB_LINEUP,0);
    if DrawGrid1.Row > DrawGrid1.TopRow then DrawGrid1.Row := DrawGrid1.TopRow;
  end;
  Handled := True;
end;

procedure TEditorForm_.FormShow(Sender: TObject);
begin
  DrawGrid1.SetFocus;
end;

// ��ͼ��׼�����������򵥱�׼�� -- �����ؿ���ǽ������
function TEditorForm_.MapNormalize: Integer;
const
  dr4 : array[0..3] of Integer = (  0, 0, -1, 1 );         // ���ڳ��������ҡ��ϡ���
  dc4 : array[0..3] of Integer = ( -1, 1,  0, 0 );
var
  i, j, k, mr, mc, nRen, nPos, p, tail: Integer;
  mr2, mc2, nBox, nDst: Integer;
  pt: array[0..MaxSize*MaxSize] of Integer;
  Mark: array[1..MaxSize, 1..MaxSize] of Boolean;

begin
  mr := manPos.Y;
  mc := manPos.X;
  
  Result := 1;
  if (mr < 0) or (mc < 0) then Exit;           // û�вֹ�Ա

  nRen := 0;
  for i := 1 to MaxSize do begin
    for j := 1 to MaxSize do begin
      if (MapBoard[i, j] < 0) or (MapBoard[i, j] > 6) then MapBoard_OK[i, j] := '-'
      else MapBoard_OK[i, j] := XSB[MapBoard[i, j]];
      if MapBoard_OK[i, j] in [ '@', '+' ] then begin
         mr := i;
         mc := j;
         inc(nRen);
      end;
    end;
  end;

  if nRen <> 1 then Exit;               // �ֹ�Ա <> 1

  // Ϊ���㣬����ʱ��ͼ���ܼ���ǽ�ڿ�
  for i := 0 to MaxSize+1 do begin
    MapBoard_OK[i,         0        ] := '#';
    MapBoard_OK[i,         MaxSize+1] := '#';
    MapBoard_OK[0,         i        ] := '#';
    MapBoard_OK[MaxSize+1, i        ] := '#';
  end;

  // �Ƿ�ɴ���ӱ��
  for i := 1 to MaxSize do begin
    for j := 1 to MaxSize do begin
      Mark[i][j] := false;
    end;
  end;

  nBox := 0;    // ��¼��������Ŀ����
  nDst := 0;

  p := 0; tail := 0;
  Mark[mr, mc] := True;
  pt[0] := (mr shl 16) or mc;
  while (p <= tail) do begin
    nPos := pt[p];
    mr := (nPos shr 16) and $FFFF;
    mc := nPos and $FFFF;;

    // �����ɴ������ڵ���������Ŀ����
    case MapBoard_OK[mr, mc] of
      '$':
        begin
          Inc(nBox);
        end;
      '*':
        begin
          Inc(nBox);
          Inc(nDst);
        end;
      '.', '+':
        begin
          Inc(nDst);
        end;
    end;

    // ���ܱ�̽��������Ƿ�ɴ�
    for k := 0 to 3 do begin
      mr2 := mr + dr4[k];
      mc2 := mc + dc4[k];

      if (MapBoard_OK[mr2, mc2] = '#') or Mark[mr2, mc2] then Continue;

      Result := 3;
      if (mr2 = 1) or (mc2 = 1) or (mr2 = MaxSize) or (mc2 = MaxSize) then Exit;    // δ��ڵĵ�ͼ

      Inc(tail);
      pt[tail] := (mr2 shl 16) or mc2;;   // �µĿɴ����
      Mark[mr2, mc2] := True;             // �ɴ���
    end;
    Inc(p);
  end;

  Result := 2;
  if (nBox <> nDst) or (nBox < 1) or (nDst < 1) then Exit;                // �ɴ������ڵ�������Ŀ���������ȷ

  // ����ؿ�Ԫ��
  for i := 1 to MaxSize do begin
    for j := 1 to MaxSize do begin
      if not Mark[i, j] then begin     // �ɴ�����֮��
        if (MapBoard_OK[i, j] in [ '*', '$', '#' ]) then MapBoard_OK[i, j] := '#'  // ǽ������
        else MapBoard_OK[i, j] := '-';
      end;
    end;
  end;

  // ��׼��
  for i := 1 to MaxSize do begin
    for j := 1 to MaxSize do begin
      if Mark[i, j] then begin  // ̽���ڲ���ЧԪ�صİ˸���λ���Ƿ���԰���ǽ��
        if (MapBoard_OK[i - 1, j] <> '#') and (not Mark[i - 1, j]) then
            MapBoard_OK[i - 1, j] := '#';
        if (MapBoard_OK[i + 1, j] <> '#') and (not Mark[i + 1, j]) then
            MapBoard_OK[i + 1, j] := '#';
        if (MapBoard_OK[i, j - 1] <> '#') and (not Mark[i, j - 1]) then
            MapBoard_OK[i, j - 1] := '#';
        if (MapBoard_OK[i, j + 1] <> '#') and (not Mark[i, j + 1]) then
            MapBoard_OK[i, j + 1] := '#';
        if (MapBoard_OK[i + 1, j - 1] <> '#') and (not Mark[i + 1, j - 1]) then
            MapBoard_OK[i + 1, j - 1] := '#';
        if (MapBoard_OK[i + 1, j + 1] <> '#') and (not Mark[i + 1, j + 1]) then
            MapBoard_OK[i + 1, j + 1] := '#';
        if (MapBoard_OK[i - 1, j - 1] <> '#') and (not Mark[i - 1, j - 1]) then
            MapBoard_OK[i - 1, j - 1] := '#';
        if (MapBoard_OK[i - 1, j + 1] <> '#') and (not Mark[i - 1, j + 1]) then
            MapBoard_OK[i - 1, j + 1] := '#';
      end;
    end;
  end;

  SetUnDoReDo;
  
  // ����༭��ͼ
  for i := 1 to MaxSize do begin
    for j := 1 to MaxSize do begin
      case MapBoard_OK[i, j] of
        '-': MapBoard[i, j] := 0;
        '#': MapBoard[i, j] := 6;
        '.': MapBoard[i, j] := 1;
        '$': MapBoard[i, j] := 2;
        '*': MapBoard[i, j] := 3;
        '@': MapBoard[i, j] := 4;
        '+': MapBoard[i, j] := 5;
      end;
    end;
  end;

  isSaved := False;
  Result := 0;
end;

procedure TEditorForm_.sb_Xsb_OKClick(Sender: TObject);
var
  n: Integer;
begin
  StatusBar1.Panels[8].Text := '';
  
  n := MapNormalize;

  case n of
    0: begin
       DrawGrid1.Invalidate;
       MessageBox(Handle, '��׼���ɹ���', '��Ϣ', MB_ICONINFORMATION + MB_OK);
    end;
    1: begin
       MessageBox(Handle, '�ֹ�Ա������ȷ��', '����', MB_ICONERROR + MB_OK)
    end;
    2: begin
       MessageBox(Handle, '��������Ŀ����������', '����', MB_ICONERROR + MB_OK)
    end;
    3: begin        
       MessageBox(Handle, '��δ��յĵ�ͼ��', '����', MB_ICONERROR + MB_OK)
    end;
  end;
end;

// �ж��Ƿ�Ϊ��Ч�� XSB ��
function isXSB(str: string): boolean;
var
  n, k: Integer;
begin
  result := False;

  n := Length(str);

  if n = 0 then
    exit;

  k := 1;
  // ����Ƿ��ǿ��� -- ���пո�������
  while k <= n do
  begin
    if (str[k] <> #20) and (str[k] <> #8) or (str[k] = '') then
      Break;
    Inc(k);
  end;
  if k > n then
    Exit;

  k := 1;
  while k <= n do
  begin
    if not (str[k] in [' ', '_', '-', '#', '.', '$', '*', '@', '+']) then
      Break;
    Inc(k);
  end;

  result := k > n;
end;

// �ָ��ַ���
function Split(src: string): TStringList;
var
  i: integer;
  str: string;
begin
  result := TStringList.Create;

  src := StringReplace(src, #13, #10, [rfReplaceAll]);
  src := StringReplace(src, #10#10, #10, [rfReplaceAll]);

  repeat
    i := pos(#10, src);
    str := copy(src, 1, i - 1);
    if (str = '') and (i > 0) then
    begin
      result.Add('');
      delete(src, 1, 1);
      continue;
    end;
    if i > 0 then
    begin
      result.Add(str);
      delete(src, 1, i);
    end;
  until i <= 0;
  if src <> '' then
    result.Add(src);
end;

// �Ӽ��а���� XSB
function TEditorForm_.LoadMapsFromClipboard: boolean;
var
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  n, k: Integer;                   // XSB�Ľ�������
  XSB_Text: string;
  data_Text: TStringList;

begin
  Result := False;

  // ��ѯ���������ض���ʽ����������
  if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
     XSB_Text := Clipboard.asText;
     data_Text := Split(XSB_Text);
  end else Exit;

  MapNode.Map.Clear;
  MapNode.Title := '';
  MapNode.Author := '';
  MapNode.Comment := '';

  if isLurd(XSB_Text) then begin
     LurdToXSB(XSB_Text);
  end else begin

    is_XSB := False;
    is_Comment := False;
    k := 0;

    while k < data_Text.Count do begin

      line := data_Text.Strings[k];       // ��ȡһ��
      Inc(k);
      line2 := Trim(line);

      if (not is_Comment) and isXSB(line) then begin       // ����Ƿ�Ϊ XSB ��
        if not is_XSB then begin     // ��ʼ XSB ��

          if MapNode.Map.Count > 0 then Break;

          is_XSB := True;    // ��ʼ�ؿ� XSB ��
          is_Comment := False;
          MapNode.Map.Clear;
          MapNode.Title := '';
          MapNode.Author := '';
          MapNode.Comment := '';
        end;

        MapNode.Map.Add(line);    // �� XSB ��

      end
      else if (not is_Comment) and (AnsiStartsText('title', line2)) then
      begin   // ƥ�� Title������
        n := Pos(':', line2);
        if n > 0 then
           MapNode.Title := trim(Copy(line2, n + 1, MaxInt))
        else
           MapNode.Title := trim(Copy(line2, 6, MaxInt));

        if is_XSB then
           is_XSB := false;      // �����ؿ�SXB�Ľ���
      end
      else if (not is_Comment) and (AnsiStartsText('author', line2)) then
      begin  // ƥ�� Author������
        n := Pos(':', line2);
        if n > 0 then
           MapNode.Author := trim(Copy(line2, n + 1, MaxInt))
        else
           MapNode.Author := trim(Copy(line2, 7, MaxInt));

        if is_XSB then
           is_XSB := false;      // �����ؿ�SXB�Ľ���
      end
      else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then
      begin  // ƥ��"ע��"�����
        is_Comment := False;  // ����"ע��"��
      end
      else if (AnsiStartsText('comment', line2)) then
      begin  //ƥ��"ע��"�鿪ʼ
        if is_XSB then
           is_XSB := false;      // �����ؿ�SXB�Ľ���

        n := Pos(':', line2);
        if n > 0 then
           line := trim(Copy(line2, n + 1, MaxInt))
        else
           line := trim(Copy(line2, 8, MaxInt));

        if Length(line) > 0 then
           MapNode.Comment := line     // ����"ע��"
        else
           is_Comment := True;         // ����"ע��"��
      end
      else if is_Comment then
      begin  // "˵��"��Ϣ
        if Length(MapNode.Comment) > 0 then
           MapNode.Comment := MapNode.Comment + #10 + line
        else
           MapNode.Comment := line;

        if is_XSB then
           is_XSB := false;      // �����ؿ�SXB�Ľ���
      end
      else
      begin
        if is_XSB then
           is_XSB := false;      // �����ؿ�SXB��Ľ���
      end;
    end;

    FreeAndNil(data_Text);
  end;
  
  // ����������һ�� XSB ����
  if MapNode.Map.Count > 0 then Result := true;

end;

procedure TEditorForm_.sb_LoadClick(Sender: TObject);
var
  i, j, nRows, nCols, len: Integer;
  ch: Char;
begin
  if LoadMapsFromClipboard and (MessageBox(Handle, '��ǰ���Ƶ����ݽ������ǣ�ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) = mrOK) then begin
     SetUnDoReDo;
     for i := 1 to MaxSize do begin
         for j := 1 to MaxSize do begin
             MapBoard[i, j] := 0;
         end;
     end;
     nRows := MapNode.Map.Count;
     if nRows > MaxSize then nRows := MaxSize;
     nCols := Length(MapNode.Map[0]);
     for i := 0 to nRows-1 do begin
         len := Length(MapNode.Map[i]);
         if nCols < len then nCols := len;
         if nCols > MaxSize then nCols := MaxSize;
     end;
     for i := 0 to nRows-1 do begin
         for j := 1 to nCols do begin
             len := Length(MapNode.Map[i]);
             if j > len then ch := '-'
             else ch := MapNode.Map[i][j];
             case ch of
                 '#': MapBoard[i+1, j] := 6;
                 '.': MapBoard[i+1, j] := 1;
                 '$': MapBoard[i+1, j] := 2;
                 '*': MapBoard[i+1, j] := 3;
                 '@': begin
                    MapBoard[i+1, j] := 4;
                    manPos.X := j;
                    manPos.Y := i+1;
                 end;
                 '+': begin
                    MapBoard[i+1, j] := 5;
                    manPos.X := j;
                    manPos.Y := i+1;
                 end;
                 else MapBoard[i+1, j] := 0;
             end;
         end;
     end;
     DrawGrid1.Invalidate;
     isSaved := False;
  end;
end;

procedure TEditorForm_.sb_InfClick(Sender: TObject);
begin
  EditorInfForm_.Edit1.Text := MapNode.Title;
  EditorInfForm_.Edit2.Text := MapNode.Author;
  EditorInfForm_.Memo1.Text := MapNode.Comment;
  EditorInfForm_.Tag := 0;
  if (EditorInfForm_.ShowModal = mrOK) and (EditorInfForm_.Tag = 1) then begin
     isSaved := False;
     MapNode.Title := EditorInfForm_.Edit1.Text;
     MapNode.Author := EditorInfForm_.Edit2.Text;
     MapNode.Comment := EditorInfForm_.Memo1.Text;
  end;
end;

// ȡ�ùؿ�XSB��������
function GetXSB: string;
var
  i, j: Integer;
  left, top, right, bottom: Integer;
  flg: Boolean;
begin
  Result := '';

  for i := 1 to MaxSize do begin
    for j := 1 to MaxSize do begin
      if (MapBoard[i, j] < 0) or (MapBoard[i, j] > 6) then MapBoard_OK[i, j] := '-'
      else MapBoard_OK[i, j] := XSB[MapBoard[i, j]];
    end;
  end;
  
  flg := True;
  top := 1;
  while flg and (top <= MaxSize) do begin
      j := 1;
      while j <= MaxSize do begin
          if MapBoard_OK[top, j] <> '-' then begin
             flg := False;
          end;
          inc(j);
      end;
      if flg then inc(top);
  end;
  if flg then Exit;

  flg := True;
  bottom := MaxSize;
  while flg and (bottom >= top) do begin
      j := 1;
      while j <= MaxSize do begin
          if MapBoard_OK[bottom, j] <> '-' then begin
             flg := False;
          end;
          inc(j);
      end;
      if flg then dec(bottom);
  end;

  flg := True;
  left := 1;
  while flg and (left <= MaxSize) do begin
      i := 1;
      while i <= MaxSize do begin
          if MapBoard_OK[i, left] <> '-' then begin
             flg := False;
          end;
          inc(i);
      end;
      if flg then inc(left);
  end;
  
  flg := True;
  right := MaxSize;
  while flg and (right >= left) do begin
      i := 1;
      while i <= MaxSize do begin
          if MapBoard_OK[i, right] <> '-' then begin
             flg := False;
          end;
          inc(i);
      end;
      if flg then dec(right);
  end;

  for i := top to bottom do begin
      Result := Result + #10;
      for j := left to right do begin
        Result := Result + MapBoard_OK[i, j];
      end;
  end;
  Result := Result + #10 + 'Title: ' + MapNode.Title;
  Result := Result + #10 + 'Author: ' + MapNode.Author;

  i := Length(MapNode.Comment);
  flg := False;
  for j := 1 to i do begin
      if not (MapNode.Comment[j] in [ ' ',  #10, #13, #9 ]) then begin
         flg := True;
         Break;
      end;
  end;
  if flg then
     Result := Result + #10 + 'Comment: ' + #10 + MapNode.Comment + #10 + 'Comment_End: ' + #10;

end;

procedure TEditorForm_.sb_SaveClick(Sender: TObject);
begin
  Clipboard.SetTextBuf(PChar(GetXSB));

  isSaved := True;
  StatusBar1.Panels[8].Text := 'XSB �Ѹ��Ƶ����а壡';
end;

procedure TEditorForm_.sb_SaveToFileClick(Sender: TObject);
var
  myFileName, myExtName: string;
  myXSBFile: Textfile;
begin
   if SaveDialog1.Execute then begin

      myFileName := SaveDialog1.FileName;

      myExtName := ExtractFileExt(myFileName);

      if (myExtName = '') or (myExtName = '.') then
          myFileName := changefileext(myFileName, '.xsb');

      if not FileExists(myFileName) or (MessageBox(Handle, PChar(myFileName + #10 + ' �ĵ��Ѿ����ڣ���д����'), '����', MB_ICONWARNING + MB_OKCANCEL) = idOK) then begin
        try
          AssignFile(myXSBFile, myFileName);
          ReWrite(myXSBFile);
          try
            Writeln(myXSBFile, GetXSB);

            isSaved := True;
            StatusBar1.Panels[8].Text := '����ɹ���';
          finally
            Closefile(myXSBFile);
          end;
        except
          StatusBar1.Panels[8].Text := '�������󣬱���ʧ�ܣ�';
        end;
      end;
   end;
end;


procedure TEditorForm_.sb_ClearClick(Sender: TObject);
var
  i, j: Integer;
begin
  if MessageBox(Handle, '��ǰ���Ƶ����ݽ���ȫ��������ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) = mrOK then begin
     SetUnDoReDo;
     for i := 1 to MaxSize do begin
        for j := 1 to MaxSize do begin
            MapBoard[i, j] := 0;
        end;
     end;
     RecogForm_.Tag := 0;
     DrawGrid1.Invalidate;
     isSaved := False;
  end;
end;

procedure TEditorForm_.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F1:                       // F1������
      begin
        sb_Help.Click;
      end;
    VK_F2:                         // F2������Ƥ��
      bt_Skin.Click;
    37:                                                    // Ctrl + ����������
      if ssCtrl in Shift then begin
         N2.Click;
         Key := 0;
      end;
    38:                                                    // Ctrl + ����������
      if ssCtrl in Shift then begin
         N4.Click;
          Key := 0;
      end;
   39:                                                     // Ctrl + ����������
      if ssCtrl in Shift then begin
         N1.Click;
         Key := 0;
      end;
    40:                                                    // Ctrl + ����������
      if ssCtrl in Shift then begin
         N3.Click;
         Key := 0;
      end;
  end;
end;

procedure TEditorForm_.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    45:
      begin                      // -����С
        if CellSize > 20 then begin
          CellSize := CellSize - 2;
          DrawGrid1.DefaultColWidth := CellSize;
          DrawGrid1.DefaultRowHeight := CellSize;
          DrawGrid1.Invalidate;
        end;
      end;
    43:
      begin                      // +���Ŵ�
        if CellSize < 60 then begin
          CellSize := CellSize + 2;
          DrawGrid1.DefaultColWidth := CellSize;
          DrawGrid1.DefaultRowHeight := CellSize;
          DrawGrid1.Invalidate;
        end;
      end;
    27, 42:                      // *����ԭ
      begin
        CellSize := 60;
        DrawGrid1.DefaultColWidth := CellSize;
        DrawGrid1.DefaultRowHeight := CellSize;
        DrawGrid1.Invalidate;
      end;
  end;
end;

procedure TEditorForm_.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  Caption := IntToStr(ord(Key));
  case Key of
    71:                  // G
         N6.Click;
    84:                  // T
         N7.Click;
    90:                 // Ctrl(Shift) + Z�� UnDo��ReDo
      if ssShift in Shift then begin
        sb_ReDo.Click;
      end else if ssCtrl in Shift then begin
        sb_UnDo.Click;
      end;
    83:                 // Ctrl + S�� XSB ���浽�ĵ�
      if ssCtrl in Shift then begin
         sb_SaveToFile.Click;
      end;
    67:                 // Ctrl + C�� XSB ������а�
      if ssCtrl in Shift then begin
        sb_Save.Click;
      end;
    86:                // Ctrl + V�� �Ӽ��а���� XSB
      if ssCtrl in Shift then begin
         sb_Load.Click;
      end;
  end;
  DrawGrid1.Invalidate;
end;

procedure TEditorForm_.sb_HelpClick(Sender: TObject);
begin
  EditorHelpForm.ShowModal;
end;

// Set UnDoReDo
procedure TEditorForm_.SetUnDoReDo(isReDo: Boolean = false);
var
  i, j: Integer;
  right, bottom: Integer;
  flg: Boolean;
  str: string;
begin
  str := '';
  
  flg := True;
  bottom := MaxSize;
  while flg and (bottom > 0) do begin
      j := 1;
      while j <= MaxSize do begin
          if MapBoard[bottom, j] <> 0 then begin
             flg := False;
          end;
          inc(j);
      end;
      if flg then dec(bottom);
  end;

  flg := True;
  right := MaxSize;
  while flg and (right > 0) do begin
      i := 1;
      while i <= MaxSize do begin
          if MapBoard[i, right] <> 0 then begin
             flg := False;
          end;
          inc(i);
      end;
      if flg then dec(right);
  end;

  for i := 1 to bottom do begin
      for j := 1 to right do begin
        str := str + XSB[MapBoard[i, j]];
      end;
      if i < bottom then str := str + #10;
  end;
  if isReDo then ReDoList.Add(str)
  else UnDoList.Add(str);
end;

// Set UnDo��ReDo
procedure SetXSB(str: string);
var
  i, j, nRows, nCols: Integer;
  MyXSB: TStringList;
begin
  for i := 1 to MaxSize do begin
      for j := 1 to MaxSize do begin
          MapBoard[i, j] := 0;
      end;
  end;

  if str = '' then Exit;
  
  MyXSB := TStringList.Create;
  MyXSB := Split(str);
  nRows := MyXSB.Count;
  nCols := Length(MyXSB[0]);
  for i := 0 to nRows-1 do begin
      for j := 1 to nCols do begin
         case MyXSB[i][j] of
           '-': begin
             MapBoard[i+1, j] := 0;
           end;
           '.': begin
             MapBoard[i+1, j] := 1;
           end;
           '$': begin
             MapBoard[i+1, j] := 2;
           end;
           '*': begin
             MapBoard[i+1, j] := 3;
           end;
           '@': begin
             MapBoard[i+1, j] := 4;
             manPos.X := j;
             manPos.Y := i+1;
           end;
           '+': begin
             MapBoard[i+1, j] := 5;
             manPos.X := j;
             manPos.Y := i+1;
           end;
           '#': begin
             MapBoard[i+1, j] := 6;
           end;
         end;
      end;
  end;
  FreeAndNil(MyXSB);
end;

// UnDo
procedure TEditorForm_.sb_UnDoClick(Sender: TObject);
var
  size: Integer;
  s: string;
begin
  size := UnDoList.Count;
  if size > 0 then begin
     SetUnDoReDo(True);
     s := UnDoList[size-1];
     SetXSB(s);
     DrawGrid1.Invalidate;
     UnDoList.Delete(size-1);
  end;
  if UnDoList.Count > 0 then isSaved := False;
  myCount;
end;

// ReDo
procedure TEditorForm_.sb_ReDoClick(Sender: TObject);
var
  size: Integer;
  s: string;
begin
  size := ReDoList.Count;
  if size > 0 then begin
     SetUnDoReDo;
     s := ReDoList[size-1];
     SetXSB(s);
     DrawGrid1.Invalidate;
     ReDoList.Delete(size-1);
  end;
  isSaved := False;
  myCount;  
end;

// ����һ��
procedure TEditorForm_.N1Click(Sender: TObject);
var
  i, j: Integer;
begin
   SetUnDoReDo;
   i := 1;
   while i <= MaxSize do begin
       if MapBoard[i, MaxSize] <> 0 then Break;
       inc(i);
   end;
   if (i > MaxSize) or
      (MessageBox(Handle, '�������ϵ�Ԫ�ػᶪʧ��ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) = mrOK) then begin
      for i := 1 to MaxSize do begin
          for j := MaxSize downto 2 do begin
              MapBoard[i, j] := MapBoard[i, j-1];
          end;
      end;
      for i := 1 to MaxSize do begin
          MapBoard[i, 1] := 0;
      end;
      DrawGrid1.Invalidate;
   end;
   isSaved := False;
end;

// ����һ��
procedure TEditorForm_.N3Click(Sender: TObject);
var
  i, j: Integer;
begin
   SetUnDoReDo;
   i := 1;
   while i <= MaxSize do begin
       if MapBoard[MaxSize, i] <> 0 then Break;
       inc(i);
   end;
   if (i > MaxSize) or
      (MessageBox(Handle, '������ϵ�Ԫ�ػᶪʧ��ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) = mrOK) then begin
      for i := MaxSize downto 2 do begin
          for j := 1 to MaxSize do begin
              MapBoard[i, j] := MapBoard[i-1, j];
          end;
      end;
      for i := 1 to MaxSize do begin
          MapBoard[1, i] := 0;
      end;
      DrawGrid1.Invalidate;
   end;
   isSaved := False;
end;

// ����һ��
procedure TEditorForm_.N2Click(Sender: TObject);
var
  i, j: Integer;
begin
   SetUnDoReDo;
   i := 1;
   while i <= MaxSize do begin
       if MapBoard[i, 1] <> 0 then Break;
       inc(i);
   end;
   if (i > MaxSize) or
      (MessageBox(Handle, '�������ϵ�Ԫ�ػᶪʧ��ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) = mrOK) then begin
      for i := 1 to MaxSize do begin
          for j := 1 to MaxSize-1 do begin
              MapBoard[i, j] := MapBoard[i, j+1];
          end;
      end;
      for i := 1 to MaxSize do begin
          MapBoard[i, MaxSize] := 0;
      end;
      DrawGrid1.Invalidate;
   end;
   isSaved := False;
end;

// ����һ��
procedure TEditorForm_.N4Click(Sender: TObject);
var
  i, j: Integer;
begin
   SetUnDoReDo;
   i := 1;
   while i <= MaxSize do begin
       if MapBoard[1, i] <> 0 then Break;
       inc(i);
   end;
   if (i > MaxSize) or                            
      (MessageBox(Handle, '����ϵ�Ԫ�ػᶪʧ��ȷ����', '����', MB_ICONWARNING + MB_OKCANCEL) = mrOK) then begin
      for i := 1 to MaxSize-1 do begin
          for j := 1 to MaxSize do begin
              MapBoard[i, j] := MapBoard[i+1, j];
          end;
      end;
      for i := 1 to MaxSize do begin
          MapBoard[MaxSize, i] := 0;
      end;
      DrawGrid1.Invalidate;
   end;
   isSaved := False;
end;

procedure TEditorForm_.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  n: Integer;
begin
  if isSaved then CanClose := True
  else begin
     n := MessageBox(Handle, '���µ��޸ģ�������', '����', MB_ICONQUESTION + MB_YESNOCANCEL);
     if n = mrYes then begin

        sb_SaveToFile.Click;
     
        isSaved := True;
        CanClose := True;
     end else if n = mrNo then begin
        isSaved := True;
        CanClose := True;
     end else begin
        CanClose := False;
     end;
  end;
end;

procedure TEditorForm_.FormResize(Sender: TObject);
begin
  if Width < 800 then Width := 800;
  if Height < 560 then  Height := 560;
end;

// �Ƿ� Lurd �ַ���
function TEditorForm_.isLurd(str: String): boolean;
var
  n, k: Integer;
begin
  result := False;

  n := Length(str);

  if n = 0 then exit;    
  
  k := 1;
  while k <= n do begin
     if not (str[k] in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D', ' ', #9 ]) then Break;
     Inc(k);
  end;

  result := k > n;
end;

// �ô𰸵��ƹؿ� - ���Ʒ�����ؿ���̬
function TEditorForm_.LurdToXSB(mStr: String): boolean;
var
  m_tLevel: array[1..MaxSize*2+1, 1..MaxSize*2+1] of Char;
  i, j, k, len, row, col, top, bottom, left, right, row2, col2, box_row, box_col: Integer;
  s: string;
begin
    Result := false;

    try
        for i := 1 to MaxSize*2 do begin
            for j := 1 to MaxSize*2 do begin
                m_tLevel[i][j] := '_';  //��ʱ�ٶ�ȫ��Ϊǽ��ذ�
            end;
        end;

        row := MaxSize; col := MaxSize;  //Ԥ��ֹ�Ա��ʼλ��
        m_tLevel[row][col] := '-';

        top := row; bottom := row; left := col; right := col;  //�ؿ�����
        len := Length(mStr);  //�𰸳���
        for k := len downto 1 do begin
            case mStr[k] of
                'r': begin
                    col2 := col - 1;
                    if (col2 <= 1) or (m_tLevel[row][col2] in [ '$', '*' ]) then Exit
                    else begin
                        if m_tLevel[row][col2] = '_' then begin  //�ֹ�Ա����λ���ǵ�һ�η���
                            m_tLevel[row][col2] := '-';
                        end;
                        col := col2;
                        if left > col then left := col;
                    end;
                end;
                'd': begin
                    row2 := row - 1;
                    if (row2 <= 1) or (m_tLevel[row2][col] in [ '$', '*' ]) then Exit
                    else begin
                        if m_tLevel[row2][col] = '_' then begin  //�ֹ�Ա����λ���ǵ�һ�η���
                            m_tLevel[row2][col] := '-';
                        end;
                        row := row2;
                        if top > row then top := row;
                    end;
                end;
                'l': begin
                    col2 := col + 1;
                    if (col2 > MaxSize * 2) or (m_tLevel[row][col2] in [ '$', '*' ]) then Exit
                    else begin
                        if m_tLevel[row][col2] = '_' then begin  //�ֹ�Ա����λ���ǵ�һ�η���
                            m_tLevel[row][col2] := '-';
                        end;
                        col := col2;
                        if right < col then right := col;
                    end;
                end;
                'u': begin
                    row2 := row + 1;
                    if (row2 > MaxSize * 2) or (m_tLevel[row2][col] in [ '$', '*' ]) then Exit
                    else begin
                        if m_tLevel[row2][col] = '_' then begin  //�ֹ�Ա����λ���ǵ�һ�η���
                            m_tLevel[row2][col] := '-';
                        end;
                        row := row2;
                        if bottom < row then bottom := row;
                    end;
                end;
                'R': begin
                    col2 := col - 1;
                    box_col := col + 1;

                    //���������ì�ܵĸ���
                    if (col2 <= 1) or (box_col > MaxSize * 2) or (m_tLevel[row][col2] in [ '$', '*' ]) or (m_tLevel[row][box_col] = '-') then Exit;

                    if m_tLevel[row][col2] = '_' then begin  //�ֹ�Ա����λ���ǵ�һ�η���
                        m_tLevel[row][col2] := '-';
                    end;

                    if (m_tLevel[row][box_col] in [ '_', '*' ]) then begin  //���ӵ�λ���ǵ�һ�η��ʻ�������Ŀ���λ��
                        m_tLevel[row][box_col] := '.';
                    end else if m_tLevel[row][box_col] = '$' then begin
                        m_tLevel[row][box_col] := '-';
                    end;
                    if m_tLevel[row][col] = '.' then begin  //�����Ƶ��ֹ�Ա��λ��
                        m_tLevel[row][col] := '*';
                    end else begin
                        m_tLevel[row][col] := '$';
                    end;

                    col := col2;  //�ֹ�Ա�Ƶ���λ��

                    if left > col then left := col;  //�����ؿ�����
                    if right < box_col then right := box_col;

                end;
                'D': begin
                    row2 := row - 1;
                    box_row := row + 1;

                    //���������ì�ܵĸ���
                    if (row2 <= 1) or (box_row > MaxSize * 2) or (m_tLevel[row2][col] in [ '$', '*' ]) or (m_tLevel[box_row][col] = '-') then Exit;

                    if m_tLevel[row2][col] = '_' then begin  //�ֹ�Ա����λ���ǵ�һ�η���
                        m_tLevel[row2][col] := '-';
                    end;

                    if (m_tLevel[box_row][col] in [ '_', '*' ]) then begin  //���ӵ�λ���ǵ�һ�η��ʻ�������Ŀ���λ��
                        m_tLevel[box_row][col] := '.';
                    end else if m_tLevel[box_row][col] = '$' then begin
                        m_tLevel[box_row][col] := '-';
                    end;
                    if m_tLevel[row][col] = '.' then begin  //�����Ƶ��ֹ�Ա��λ��
                        m_tLevel[row][col] := '*';
                    end else begin
                        m_tLevel[row][col] := '$';
                    end;

                    row := row2;  //�ֹ�Ա�Ƶ���λ��

                    if top > row then top := row;  //�����ؿ�����
                    if bottom < box_row then bottom := box_row;

                end;
                'L': begin
                    col2 := col + 1;
                    box_col := col - 1;

                    //���������ì�ܵĸ���
                    if (box_col <= 1) or (col2 > MaxSize * 2) or (m_tLevel[row][col2] in [ '$', '*' ]) or (m_tLevel[row][box_col] = '-') then Exit;

                    if (m_tLevel[row][col2] = '_') then begin  //�ֹ�Ա����λ���ǵ�һ�η���
                        m_tLevel[row][col2] := '-';
                    end;

                    if (m_tLevel[row][box_col] in [ '_', '*' ]) then begin  //���ӵ�λ���ǵ�һ�η��ʻ�������Ŀ���λ��
                        m_tLevel[row][box_col] := '.';
                    end else if m_tLevel[row][box_col] = '$' then begin
                        m_tLevel[row][box_col] := '-';
                    end;

                    if m_tLevel[row][col] = '.' then begin //�����Ƶ��ֹ�Ա��λ��
                        m_tLevel[row][col] := '*';
                    end else begin
                        m_tLevel[row][col] := '$';
                    end;

                    col := col2;  //�ֹ�Ա�Ƶ���λ��

                    if right < col then right := col;  //�����ؿ�����
                    if left > box_col then left := box_col;

                end;
                'U': begin
                    row2 := row + 1;
                    box_row := row - 1;

                    //���������ì�ܵĸ���
                    if (box_row <= 1) or (row2 > MaxSize * 2) or (m_tLevel[row2][col] in [ '$', '*' ]) or (m_tLevel[box_row][col] = '-') then Exit;

                    if (m_tLevel[row2][col] = '_') then begin  //�ֹ�Ա����λ���ǵ�һ�η���
                        m_tLevel[row2][col] := '-';
                    end;

                    if (m_tLevel[box_row][col] in [ '_', '*' ]) then begin  //���ӵ�λ���ǵ�һ�η��ʻ�������Ŀ���λ��
                        m_tLevel[box_row][col] := '.';
                    end else if m_tLevel[box_row][col] = '$' then begin
                        m_tLevel[box_row][col] := '-';
                    end;
                    if m_tLevel[row][col] = '.' then begin  //�����Ƶ��ֹ�Ա��λ��
                        m_tLevel[row][col] := '*';
                    end else begin
                        m_tLevel[row][col] := '$';
                    end;

                    row := row2;  //�ֹ�Ա�Ƶ���λ��

                    if bottom < row then bottom := row;  //�����ؿ�����
                    if top > box_row then top := box_row;
                end;
            end;
        end;

        if (right-left < 2) and (bottom-top < 2) then Exit;

        //�ֹ�Ա
        if m_tLevel[row][col] = '.' then begin
            m_tLevel[row][col] := '+';
        end else begin
            m_tLevel[row][col] := '@';
        end;

        //�ؿ���׼��
        for i := top to bottom do begin
            for j := left to right do begin
                if (m_tLevel[i][j] <> '_') and (m_tLevel[i][j] <> '#') then begin
                    if m_tLevel[i-1][j] = '_' then m_tLevel[i-1][j] := '#';
                    if m_tLevel[i+1][j] = '_' then m_tLevel[i+1][j] := '#';
                    if m_tLevel[i][j-1] = '_' then m_tLevel[i][j-1] := '#';
                    if m_tLevel[i][j+1] = '_' then m_tLevel[i][j+1] := '#';
                    if m_tLevel[i+1][j-1] = '_' then m_tLevel[i+1][j-1] := '#';
                    if m_tLevel[i+1][j+1] = '_' then m_tLevel[i+1][j+1] := '#';
                    if m_tLevel[i-1][j-1] = '_' then m_tLevel[i-1][j-1] := '#';
                    if m_tLevel[i-1][j+1] = '_' then m_tLevel[i-1][j+1] := '#';
                end;
            end;
        end;

        // ���عؿ����༭��
        for i := top-1 to bottom+1 do begin
            s := '';
            for j := left-1 to right+1 do begin
                s := s + m_tLevel[i, j];
            end;
            MapNode.Map.Add(s);
        end;

        Result := True;
    Except
    end;
end;


procedure TEditorForm_.sb_LoadPicClick(Sender: TObject);
var
  i, j: Integer;
begin
  old_Left      := RecogForm_.Map_Left.Value;
  old_Top       := RecogForm_.Map_Top.Value;
  old_Right     := RecogForm_.Map_Right.Value;
  old_Bottom    := RecogForm_.Map_Bottom.Value;
  old_RowHeight := RecogForm_.Map_RowHeight.Value;
  old_ColWidth  := RecogForm_.Map_ColWidth.Value;
  old_Tag       := RecogForm_.Tag;

  RecogForm_.Tag := 0;
  RecogForm_.ShowModal;
  if RecogForm_.Tag = 1 then begin

     SetUnDoReDo;

     for i := 0 to 99 do begin
        for j := 0 to 99 do begin
           case myMap[i, j] of
               '#': MapBoard[i+1, j+1] := 6;
               '.': MapBoard[i+1, j+1] := 1;
               '$': MapBoard[i+1, j+1] := 2;
               '*': MapBoard[i+1, j+1] := 3;
               '@': begin
                  MapBoard[i+1, j+1] := 4;
                  manPos.X := j+1;
                  manPos.Y := i+1;
               end;
               '+': begin
                  MapBoard[i+1, j+1] := 5;
                  manPos.X := j+1;
                  manPos.Y := i+1;
               end;
               else MapBoard[i+1, j+1] := 0;
           end;
        end;
     end;
     
     myCount;
     N6.Checked := True;
     N7.Checked := False;
     isSaved := False;
  end;
  DrawGrid1.Invalidate;
end;

procedure TEditorForm_.N6Click(Sender: TObject);
begin
  if RecogForm_.Tag = 1 then begin
     if N6.Checked then begin
        N6.Checked := False;
     end else begin
        N6.Checked := True;
     end;
     DrawGrid1.Invalidate;
  end;
end;

procedure TEditorForm_.N7Click(Sender: TObject);
begin
  if RecogForm_.Tag = 1 then begin
     if N7.Checked then begin
        N7.Checked := False;
     end else begin
        N7.Checked := True;
     end;
     DrawGrid1.Invalidate;
  end;
end;

procedure TEditorForm_.bt_SkinClick(Sender: TObject);
begin
  Recog_.LoadSkin;
  DrawGrid1.Invalidate;
end;

procedure TEditorForm_.img_WallMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := img_Wall.Hint;
end;

procedure TEditorForm_.img_BoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := img_Box.Hint;
end;

procedure TEditorForm_.img_GoalMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := img_Goal.Hint;
end;

procedure TEditorForm_.img_FloorMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := img_Floor.Hint;
end;

procedure TEditorForm_.img_PlayerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := img_Player.Hint;
end;

procedure TEditorForm_.img_SelectMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := img_Select.Hint;
end;

procedure TEditorForm_.sb_SaveToFileMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_SaveToFile.Hint;
end;

procedure TEditorForm_.sb_SaveMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_Save.Hint;
end;

procedure TEditorForm_.sb_LoadMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_Load.Hint;
end;

procedure TEditorForm_.sb_UnDoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_UnDo.Hint;
end;

procedure TEditorForm_.sb_ReDoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_ReDo.Hint;
end;

procedure TEditorForm_.sb_ClearMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_Clear.Hint;
end;

procedure TEditorForm_.sb_InfMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_Inf.Hint;
end;

procedure TEditorForm_.sb_Xsb_OKMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_Xsb_OK.Hint;
end;

procedure TEditorForm_.sb_HelpMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_Help.Hint;
end;

procedure TEditorForm_.sb_LoadPicMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := sb_LoadPic.Hint;
end;

procedure TEditorForm_.bt_SkinMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  StatusBar1.Panels[8].Text := bt_Skin.Hint;
end;

procedure TEditorForm_.FormDestroy(Sender: TObject);
begin
  FreeAndNil(MapNode.Map);
  FreeAndNil(UnDoList);
  FreeAndNil(ReDoList);  
end;

end.
