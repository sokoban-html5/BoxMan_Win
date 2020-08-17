unit BrowseLevels;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, ImgList, Math, CommCtrl, Menus;

type
  TBrowseForm = class(TForm)
    ListView1: TListView;
    ImageList1: TImageList;
    ImageList0: TImageList;
    procedure ListView1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListView1AdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure ListView1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }

    Map_Icon: TBitmap;       // �ؿ�ͼ��
    focused_Icon: TBitmap;   // ͼ��ѡ���

  end;

var
  BrowseForm: TBrowseForm;
  Size_Icon, Solved_Count: Integer;      // ͼ��ߴ磬�н�ؿ���
  myTitle: string;

implementation

uses
  LoadMap, LoadSkin, inf;

{$R *.dfm}

procedure TBrowseForm.ListView1DblClick(Sender: TObject);
begin
  if ListView1.ItemIndex >= 0 then begin
     Tag := 0;
     Close;
  end else Caption := myTitle;
end;

procedure TBrowseForm.FormShow(Sender: TObject);
var
  i: integer;
  mapNode: PMapNode;
  
begin
  ListView1.Items.Clear;

  Solved_Count := 0;
  for i := 0 to MapList.Count-1 do begin   // ��ӿ� item
      ListView1.Items.add;
      mapNode := MapList[i];
      if mapNode.Solved then inc(Solved_Count);
  end;
  myTitle := '��� [���: ' + IntToStr(Solved_Count) + '/' + IntToStr(MapList.Count) + ']';
  Caption := myTitle;
end;

procedure TBrowseForm.FormCreate(Sender: TObject);
begin
  Caption := '���';

  ListView1.DoubleBuffered := true;    // ����˫���棬��ֹ���������о�ûɶ��

  Size_Icon := 150;                    // ͼ��ߴ�

  Map_Icon := TBitmap.Create;
  Map_Icon.Width := ImageList1.Width;
  Map_Icon.Height := ImageList1.Height;

  focused_Icon := TBitmap.Create;
  focused_Icon.Width := ImageList0.Width;
  focused_Icon.Height := ImageList0.Height;
  ImageList0.Draw(focused_Icon.Canvas, 0, 0, 0, true);

  SendMessage(ListView1.Handle, LVM_SETICONSPACING, 0, MakeLong(Size_Icon + 10, Size_Icon + 20)); // �趨icon�ļ��

end;

// ��ͼ��
procedure DrawIcon(cv: TCanvas; mapNode: PMapNode);
var
  i, j, x_Size, y_Size, cell_Size, x, y: Integer;
  R: TRect;
  ch: Char;

begin
  x_Size := Size_Icon div mapNode.Cols;
  y_Size := Size_Icon div mapNode.Rows;
  cell_Size := Min(x_Size, y_Size);
  x := (Size_Icon - cell_Size * mapNode.Cols) div 2;
  y := (Size_Icon - cell_Size * mapNode.Rows) div 2;

  for i := 0 to mapNode.Rows-1 do begin
      for j := 1 to mapNode.Cols do begin
          R := Rect((j-1) * cell_Size + x, i * cell_Size + y, j * cell_Size + x, (i+1) * cell_Size + y);
          ch := mapNode.Map[i][j];
          case ch of
              '#': begin
                   cv.StretchDraw(R, WallPic);
              end;
              '-': begin
                   cv.StretchDraw(R, FloorPic);
              end;
              '.': begin
                   cv.StretchDraw(R, GoalPic);
              end;
              '$': begin
                   cv.StretchDraw(R, BoxPic);
              end;
              '*': begin
                   cv.StretchDraw(R, BoxGoalPic);
              end;
              '@': begin
                   cv.StretchDraw(R, ManPic);
              end;
              '+': begin
                   cv.StretchDraw(R, ManGoalPic);
              end;
              else begin
                   cv.Brush.Color := clWhite;
                   cv.FillRect(R);
              end;
          end;
      end;
  end;
end;

procedure TBrowseForm.ListView1AdvancedCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var
  R: TRect;    // R Ϊ���ָ��ǵķ�Χ
  s: string;
  mapNode: PMapNode;

begin
  mapNode := MapList[Item.index];
  R := Item.DisplayRect(drBounds);
  with ListView1.Canvas do begin
    // �������
    if cdsSelected in State then begin
       StretchDraw(r, focused_Icon);
    end;

    // ��ͼ��
    Map_Icon.Canvas.Brush.Color := clWhite;
    Map_Icon.Canvas.FillRect(Rect(0, 0, Size_Icon, Size_Icon));
    DrawIcon(Map_Icon.Canvas, mapNode);
    Draw(r.Left + 5, r.top + 5, Map_Icon);

    // ������
    r.top := r.top + Size_Icon + 3;
    r.Bottom := r.Bottom - 3;    
    r.left := r.left + 3;
    r.right := r.right - 3;
    SetBkMode(Handle, TRANSPARENT);                // �趨����Ϊ͸��
    if mapNode.Title = '' then s := 'Level ' + IntToStr(Item.index+1)
    else s := mapNode.Title;
    if mapNode.Solved then begin                   
       Sender.Canvas.Brush.Color := $009500;       // ��ɫ��ʶ�ѽ�ؿ�
    end else begin
       Sender.Canvas.Brush.Color := clWhite;
    end;
    FillRect(r);
    DrawText(Handle, PChar(s), Length(s), r, DT_WORDBREAK or DT_CENTER);
  end;
  
  with Sender.Canvas do
    if Assigned(Font.OnChange) then Font.OnChange(Font);
end;

procedure TBrowseForm.ListView1Click(Sender: TObject);
var
  mapNode: PMapNode;
  
begin
  if ListView1.ItemIndex >= 0 then begin
     mapNode := MapList[ListView1.ItemIndex];
     Caption := myTitle + ' - ' + mapNode.Title + ',  ����: ' + mapNode.Author;      // �õ���Ӧ���ݵ�ǰ��ַ
  end else Caption := myTitle;;
end;

procedure TBrowseForm.FormResize(Sender: TObject);
begin
  ListView1.Repaint;
end;

// �ؿ���ϸ����
procedure TBrowseForm.ListView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  mapNode: PMapNode;
  i, size: Integer;

begin
  case Button of
    mbleft:
      begin

      end;
    mbright:
      begin    // �һ� -- ָ�Ҽ�
         if ListView1.ItemIndex >= 0 then begin
            mapNode := MapList[ListView1.ItemIndex];
            InfForm.Memo1.Lines.Clear;
            size := mapNode.Map.Count;
            for i :=0 to size-1 do begin
                InfForm.Memo1.Lines.Add(mapNode.Map[i]);
            end;
            InfForm.Memo1.Lines.Add('Title: ' + mapNode.Title);
            InfForm.Memo1.Lines.Add('Author: ' + mapNode.Author);
            if Trim(mapNode.Comment) <> '' then begin
               InfForm.Memo1.Lines.Add('Comment: ');
               InfForm.Memo1.Lines.Add(mapNode.Comment);
               InfForm.Memo1.Lines.Add('Comment_End: ');
            end;
            InfForm.ShowModal;
         end;
      end;
  end;
end;

end.
