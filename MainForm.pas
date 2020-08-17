unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Forms, Inifiles, Controls,
  Contnrs, Registry, ComCtrls, ExtCtrls, ImgList, StdCtrls, Buttons, Dialogs,
  ShellAPI, Menus, Clipbrd, Math;

type
  TSetting = record       // ����������Ŀ
    myTop: integer;            // �ϴ��˳�ʱ�����ڵ�λ�ü���С
    myLeft: integer;
    myWidth: integer;
    myHeight: integer;
    bwTop: integer;            // �Ϲؿ�������ڵ�λ�ü���С�ļ���
    bwLeft: integer;
    bwWidth: integer;
    bwHeight: integer;
    bwStyle: integer;            // �ؿ������ʽ
    mySpeed: integer;            // ��ǰ�ƶ��ٶ�
    bwBKColor: integer;            // �ؿ��������ı���ɫ
    MapFileName: string;             // ��ǰ�ؿ����ĵ���
    SkinFileName: string;             // ��ǰƤ���ĵ���
    isGoThrough: boolean;            // ��Խ�Ƿ���
    isIM: boolean;            // ˲���Ƿ���
    isBK: boolean;            // �Ƿ�����ģʽ
    isSameGoal: boolean;            // ����ʱ��ʹ������Ŀ��λ
    isJijing: boolean;            // ����Ŀ��λ
    isJijing_BK: boolean;            // ����Ŀ��λ -- ����
    isXSB_Saved: boolean;            // ���Ӽ��а嵼��� XSB �Ƿ񱣴����
    isLurd_Saved: boolean;            // �ƹؿ��Ķ����Ƿ񱣴����
    isOddEven: Boolean;            // �Ƿ���ʾ��ż��Ч
    LaterList: TStringList;           // ����ƹ��Ĺؿ���
    SubmitCountry: string;             // �ύ--���һ����
    SubmitName: string;             // �ύ--����
    SubmitEmail: string;             // �ύ--����
  end;

type                  // ��ǰ��ͼ��Ϣ
  TMapState = record
    CurrentLevel: integer;    // ��ǰ�ؿ����
    ManPosition: integer;    // ���Ƴ�ʼ״̬���˵�λ��
    MapSize: integer;    // ��ͼ�ߴ�
    CellSize: integer;    // ����ͼʱ����ǰ�ĵ�Ԫ��ߴ�

  end;

type
  Tmain = class(TForm)
    pl_Ground: TPanel;
    StatusBar1: TStatusBar;
    map_Image: TImage;
    pl_Main: TPanel;
    pl_Side: TPanel;
    pl_Tools: TPanel;
    ImageList1: TImageList;
    PageControl: TPageControl;
    Tab_Solution: TTabSheet;
    Tab_Snapshot: TTabSheet;
    bt_Pre: TSpeedButton;
    bt_Open: TSpeedButton;
    bt_Next: TSpeedButton;
    bt_UnDo: TSpeedButton;
    bt_ReDo: TSpeedButton;
    bt_IM: TSpeedButton;
    bt_BK: TSpeedButton;
    bt_OddEven: TSpeedButton;
    dlgOpen1: TOpenDialog;
    bt_Skin: TSpeedButton;
    List_Solution: TListBox;
    List_State: TListBox;
    bt_GoThrough: TSpeedButton;
    bt_View: TSpeedButton;
    pnl_Trun: TPanel;
    pnl_Speed: TPanel;
    tsList_Inf: TTabSheet;
    mmo_Inf: TMemo;
    dlgSave1: TSaveDialog;
    pmBoardBK: TPopupMenu;
    pmGoal: TMenuItem;
    pmJijing: TMenuItem;
    pmSolution: TPopupMenu;
    so_Lurd: TMenuItem;
    so_XSB_Lurd: TMenuItem;
    so_XSB_Lurd_File: TMenuItem;
    so_XSB_LurdAll: TMenuItem;
    so_XSB_LurdAll_File: TMenuItem;
    so_Delete: TMenuItem;
    so_DeleteAll: TMenuItem;
    pmState: TPopupMenu;
    sa_Lurd: TMenuItem;
    sa_Lurd_BK: TMenuItem;
    sa_XSB_Lurd: TMenuItem;
    sa_XSB_Lurd_File: TMenuItem;
    sa_Delete: TMenuItem;
    sa_DeleteAll: TMenuItem;
    bt_Lately: TSpeedButton;
    pm_Later: TPopupMenu;
    pm_Home: TMenuItem;
    Panel1: TPanel;
    bt_Act: TSpeedButton;
    bt_Save: TSpeedButton;
    N1: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bt_OddEvenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure bt_OddEvenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure map_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ContentClick(Sender: TObject);              // ����
    procedure Restart(is_BK: Boolean);                    // �ؿ����¿�ʼ
    procedure bt_PreClick(Sender: TObject);               // ��һ��
    procedure bt_NextClick(Sender: TObject);              // ��һ��
    procedure bt_UnDoClick(Sender: TObject);              // UnDo ��ť
    procedure bt_ReDoClick(Sender: TObject);              // ReDo ��ť
    procedure bt_GoThroughClick(Sender: TObject);         // ��Խ����
    procedure bt_IMClick(Sender: TObject);                // ˲�ƿ���
    procedure bt_BKClick(Sender: TObject);                // ����ģʽ
    procedure SetButton();                                // ���ð�ť״̬
    procedure bt_OpenClick(Sender: TObject);              // �򿪹ؿ��ĵ�
    procedure bt_SkinClick(Sender: TObject);              // ѡ��Ƥ��
    function GetWall(r, c: Integer): Integer;            // ���㻭��ͼʱ��ʹ���ǿ�ǽ��ͼԪ
    function GetCur(x, y: Integer): string;              // ������
    procedure DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);      // ������
    procedure MyDraw();
    procedure pnl_TrunMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pnl_SpeedMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure bt_ViewClick(Sender: TObject);
    procedure bt_ActClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure List_SolutionDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure List_SolutionMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
    procedure pmGoalClick(Sender: TObject);
    procedure pmJijingClick(Sender: TObject);
    procedure List_SolutionDblClick(Sender: TObject);
    procedure List_StateDblClick(Sender: TObject);
    procedure sa_LurdClick(Sender: TObject);
    procedure sa_Lurd_BKClick(Sender: TObject);
    procedure sa_XSB_LurdClick(Sender: TObject);
    procedure sa_XSB_Lurd_FileClick(Sender: TObject);
    procedure sa_DeleteClick(Sender: TObject);
    procedure sa_DeleteAllClick(Sender: TObject);
    procedure so_LurdClick(Sender: TObject);
    procedure so_XSB_LurdClick(Sender: TObject);
    procedure so_XSB_LurdAllClick(Sender: TObject);
    procedure so_XSB_Lurd_FileClick(Sender: TObject);
    procedure so_XSB_LurdAll_FileClick(Sender: TObject);
    procedure so_DeleteClick(Sender: TObject);
    procedure so_DeleteAllClick(Sender: TObject);
    procedure StatusBar1DblClick(Sender: TObject);
    procedure StatusBar1Resize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure bt_LatelyClick(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rt: TRect);
    procedure bt_SaveClick(Sender: TObject);
    procedure pm_HomeClick(Sender: TObject);
    procedure N1Click(Sender: TObject);

  private
    // ��ǰ��ͼ����
    curMap: TMapState;                         // ��ǰ�ĵ�ͼ����
    MoveTimes, PushTimes: integer;             // �������Ʋ���
    MoveTimes_BK, PushTimes_BK: integer;       // �������Ʋ���
    IsMoving: boolean;                         // �Ƿ������ƶ�
    IsClick: boolean;                          // �Ƿ��������
    IsManAccessibleTips: boolean;              // �Ƿ���ʾ�˵����ƿɴ���ʾ
    IsManAccessibleTips_BK: boolean;           // �Ƿ���ʾ�˵����ƿɴ���ʾ
    IsBoxAccessibleTips: boolean;              // �Ƿ���ʾ���ӵ����ƿɴ���ʾ
    IsBoxAccessibleTips_BK: boolean;           // �Ƿ���ʾ���ӵ����ƿɴ���ʾ

    map_Board_OG: array[0..9999] of integer;   // ԭʼ��ͼ
    map_Board_BK: array[0..9999] of integer;   // ���Ƶ�ͼ
    map_Board: array[0..9999] of integer;      // ���Ƶ�ͼ
    BoxNumber: integer;                        // ������
    GoalNumber: integer;                       // Ŀ�����
    ManPos: integer;                           // �˵�λ�� -- ����
    ManPos_BK: integer;                        // �˵�λ�� -- ����
    OldBoxPos: integer;                        // ����������ӵ�λ�� -- ����
    OldBoxPos_BK: integer;                     // ����������ӵ�λ�� -- ����

    LastSteps: Integer;                                // �������һ�ε���ǰ�Ĳ���

    // ��ͼ
    function LoadMap(MapIndex: integer): boolean;      // ���عؿ�
    procedure InitlizeMap();                           // ��ͼ��ʼ��
    procedure NewMapSize();                            // ���¼����ͼ�ߴ�
    procedure DrawMap();                               // ����ͼ

    // �������ӵ��ƶ�
    function IsComplete(): boolean;                    // �Ƿ���� - ����
    function IsComplete_BK(): boolean;                 // �Ƿ���� - ����
    function IsMeets(ch: Char): Boolean;               // �Ƿ��������
    procedure ReDo(Steps: Integer);                    // ����һ�� - ����
    procedure UnDo(Steps: Integer);                    // ����һ�� - ����
    procedure ReDo_BK(Steps: Integer);                 // ����һ�� - ����
    procedure UnDo_BK(Steps: Integer);                 // ����һ�� - ����
    procedure GameDelay();                             // ��ʱ

    // ��ȡ������Ϣ
    procedure LoadSttings();
    procedure SaveSttings();
    procedure ShowStatusBar();                        // ˢ�µײ�״̬��
    procedure SetMapTrun();                           // ���µ�ͼ��ת״̬

    function GetStep(is_BK: Boolean): Integer;        // �������� reDo �����ڵ� -- ÿ��һ������Ϊһ������
    function GetStep2(is_BK: Boolean): Integer;       // �������� unDo �����ڵ� -- ÿ��һ������Ϊһ������
    function SaveXSBToFile(): Boolean;                // ����ؿ� XSB ���ĵ�
    function SaveSolution(n: Integer): Boolean;       // ������
    function SaveState(): Boolean;                    // ����״̬
    function LoadState(): Boolean;                    // ����״̬
    function LoadSolution(): Boolean;                 // ���ش�
    function GetStateFromDB(index: Integer; var x: Integer; var y: Integer; var str1: string; var str2: string): Boolean;    // �Ӵ𰸿����һ��״̬
    function GetSolutionFromDB(index: Integer; var str: string): Boolean;                                                    // �Ӵ𰸿����һ����
    procedure MenuItemClick(Sender: TObject);

  public
    mySettings: TSetting;                             // �������������

  end;

const
  minWindowsWidth = 600;                                        // ���򴰿���С�ߴ�����
  minWindowsHeight = 400;
  DelayTimes: array[0..4] of dword = (5, 110, 275, 550, 1000);     // ��Ϸ��ʱ -- �ٶȿ���

  MapTrun: array[0..7] of string = ('0ת', '1ת', '2ת', '3ת', '4ת', '5ת', '6ת', '7ת');
  SpeedInf: array[0..4] of string = ('���', '�Ͽ�', '����', '����', '����');
  AppName = 'BoxMan';
  AppVer = ' V1.2';

var
  main: Tmain;
  tmpTrun: integer;
  SoltionList: Tlist;     // ���б���
  StateList: Tlist;       // ״̬�б���
  AotoRedo: Boolean;      // �Զ����ȫ�� RedoList �е�ȫ������
  isYanshi: Boolean;      // �Ƿ�������ʾ�� -- �ո�����˸�����Ƶ�

  MapDir: array[0..7, 0..6] of Integer = (
    (1, 2, 4, 8, 3, 7, 11),    // 0 ת
    (2, 4, 8, 1, 6, 7, 14),    // 1
    (4, 8, 1, 2, 12, 13, 14),  // 2
    (8, 1, 2, 4, 9, 13, 11),   // 3
    (4, 2, 1, 8, 6, 7, 14),    // 4
    (8, 4, 2, 1, 12, 13, 14),  // 5
    (1, 8, 4, 2, 9, 13, 11),   // 6
    (2, 1, 8, 4, 3, 7, 11));   // 7

    ActDir: array[0..7, 0..7] of Char = (  // ���� 8 ��λ��ת֮ n ת�Ļ�������
            ('l', 'u', 'r', 'd', 'L', 'U', 'R', 'D'),
            ('d', 'l', 'u', 'r', 'D', 'L', 'U', 'R'),
            ('r', 'd', 'l', 'u', 'R', 'D', 'L', 'U'),
            ('u', 'r', 'd', 'l', 'U', 'R', 'D', 'L'),
            ('r', 'u', 'l', 'd', 'R', 'U', 'L', 'D'),
            ('d', 'r', 'u', 'l', 'D', 'R', 'U', 'L'),
            ('l', 'd', 'r', 'u', 'L', 'D', 'R', 'U'),
            ('u', 'l', 'd', 'r', 'U', 'L', 'D', 'R'));


  // Ϊʹ���ֻ����һ������ı���
  lsHandle: THandle;
  PreInstanceWindow: HWnd;
  lsPjt, lsAppName: string;

implementation

uses
  DateUtils, LogFile, MyInf, Submit, IDHttp, superobject,
  LoadSkin, PathFinder, LoadMap, LurdAction, BrowseLevels, DateModule, CRC_32, Actions;

var
  myPathFinder: TPathFinder;

  gotoLeft, gotoPos, gotoWidth: Integer;   // ״̬�����ұ�һ������缰���
  keyPressing: Boolean;                    // �Ƿ��а�������

{$R *.DFM}

// ����������Ϣ
procedure Tmain.LoadSttings();
var
  IniFile: TIniFile;
  i: Integer;
  s: string;

begin
  
  IniFile := TIniFile.Create(AppPath + AppName + '.ini');

  try

    mySettings.myTop := IniFile.ReadInteger('Settings', 'Top', 100);      // �ϴ��˳�ʱ�����ڵ�λ�ü���С
    mySettings.myLeft := IniFile.ReadInteger('Settings', 'Left', 100);
    mySettings.myWidth := IniFile.ReadInteger('Settings', 'Width', 800);
    mySettings.myHeight := IniFile.ReadInteger('Settings', 'Height', 600);
    mySettings.bwTop := IniFile.ReadInteger('Settings', 'bwTop', 100);      // �ؿ�������ڵ�λ�ü���С�ļ���
    mySettings.bwLeft := IniFile.ReadInteger('Settings', 'bwLeft', 100);
    mySettings.bwWidth := IniFile.ReadInteger('Settings', 'bwWidth', 800);
    mySettings.bwHeight := IniFile.ReadInteger('Settings', 'bwHeight', 600);
    mySettings.bwStyle := IniFile.ReadInteger('Settings', 'bwStyle', 0);
    mySettings.SubmitCountry := IniFile.ReadString('Settings', 'SubmitCountry', 'CN'); // �ύ--���һ����
    mySettings.SubmitName := IniFile.ReadString('Settings', 'SubmitName', '');         // �ύ--����
    mySettings.SubmitEmail := IniFile.ReadString('Settings', 'SubmitEmail', '');       // �ύ--����
    mySettings.mySpeed := IniFile.ReadInteger('Settings', '�ٶ�', 2);        // Ĭ���ƶ��ٶ�
    mySettings.bwBKColor := IniFile.ReadInteger('Settings', '�������ɫ', clWhite);        // Ĭ�Ϲؿ�������汳��ɫ
    mySettings.isGoThrough := IniFile.ReadBool('Settings', '��Խ', true);    // ��Խ����
    mySettings.isIM := IniFile.ReadBool('Settings', '˲��', false);    // ˲�ƿ���
    mySettings.isSameGoal := IniFile.ReadBool('Settings', '����Ŀ��λ', false);  // ����ʱ��ʹ������Ŀ��λ
    mySettings.SkinFileName := IniFile.ReadString('Settings', 'Ƥ��', '');       // ��ǰƤ���ĵ���
    mySettings.MapFileName := IniFile.ReadString('Settings', '�ؿ��ĵ�', '');       // ��ǰ�ؿ��ĵ���
    curMap.CurrentLevel := IniFile.ReadInteger('Settings', '�ؿ����', 1);        // �ϴ��ƵĹؿ����
    tmpTrun := IniFile.ReadInteger('Settings', '�ؿ���ת', 0);        // �ϴ��ƵĹؿ���ת

    mySettings.LaterList := TStringList.Create;
    for i := 0 to 9 do begin
        s := IniFile.ReadString('Settings', 'Later_' + IntToStr(i), '');
        if s <> '' then mySettings.LaterList.Add(s);       // ����ƹ��Ĺؿ���
    end;

    // Ĭ�ϵ�������
    mySettings.isBK := False;                   // �Ƿ�����ģʽ
    mySettings.isXSB_Saved := True;                    // ���Ӽ��а嵼��� XSB �Ƿ񱣴����
    mySettings.isLurd_Saved := True;                    // �ƹؿ��Ķ����Ƿ񱣴����
    mySettings.isJijing := False;                   // ����Ŀ��λ
    mySettings.isJijing_BK := False;                   // ����Ŀ��λ -- ����
    pmGoal.Checked := mySettings.isSameGoal;   // �̶���Ŀ��λ
    if (mySettings.myWidth < minWindowsWidth) then
      mySettings.myWidth := minWindowsWidth;
    if (mySettings.myHeight < minWindowsHeight) then
      mySettings.myHeight := minWindowsHeight;
    if (mySettings.myWidth > SCREEN.WIDTH) then
      mySettings.myWidth := SCREEN.WIDTH;
    if (mySettings.myHeight > SCREEN.HEIGHT) then
      mySettings.myHeight := SCREEN.HEIGHT;
    if (mySettings.myTop < 0) or (mySettings.myTop > SCREEN.WIDTH) then
      mySettings.myTop := 0;
    if (mySettings.myLeft < 0) or (mySettings.myLeft > SCREEN.HEIGHT) then
      mySettings.myLeft := 0;
    if (mySettings.mySpeed < 0) or (mySettings.mySpeed > 4) then
      mySettings.mySpeed := 2;      // Ĭ���ƶ��ٶ�
    if (tmpTrun < 0) or (tmpTrun > 7) then
      tmpTrun := 0;      // �ؿ���ת
  finally
    FreeAndNil(IniFile);
  end;

end;

// ����������Ϣ
procedure Tmain.SaveSttings();
var
  IniFile: TIniFile;
  fn: string;
  i, n: Integer;

begin
  IniFile := TIniFile.Create(AppPath + AppName + '.ini');

  fn := mySettings.MapFileName;
  n := Pos(AppPath, fn);
  if n > 0 then Delete(fn, 1, Length(AppPath));

  try
    IniFile.WriteInteger('Settings', 'Top', Top);                           // �˳�ʱ�����ڵ�λ�ü���С
    IniFile.WriteInteger('Settings', 'Left', Left);
    IniFile.WriteInteger('Settings', 'Width', Width);
    IniFile.WriteInteger('Settings', 'Height', Height);
    IniFile.WriteInteger('Settings', 'bwTop', BrowseForm.Top);                           // �ؿ�������ڵ�λ�ü���С�ļ���
    IniFile.WriteInteger('Settings', 'bwLeft', BrowseForm.Left);
    IniFile.WriteInteger('Settings', 'bwWidth', BrowseForm.Width);
    IniFile.WriteInteger('Settings', 'bwHeight', BrowseForm.Height);
    IniFile.WriteString('Settings', 'SubmitCountry', mySettings.SubmitCountry);   // ���һ����
    IniFile.WriteString('Settings', 'SubmitName', mySettings.SubmitName);         // ����
    IniFile.WriteString('Settings', 'SubmitEmail', mySettings.SubmitEmail);       // ����
    IniFile.WriteInteger('Settings', '�ٶ�', mySettings.mySpeed);           // �ƶ��ٶ�
    IniFile.WriteInteger('Settings', '�������ɫ', mySettings.bwBKColor);   // �ؿ�������汳��ɫ
    IniFile.WriteBool('Settings', '��Խ', mySettings.isGoThrough);          // ��Խ����
    IniFile.WriteBool('Settings', '˲��', mySettings.isIM);                 // ˲�ƿ���
    IniFile.WriteBool('Settings', '����Ŀ��λ', mySettings.isSameGoal);     // ����ʱ��ʹ������Ŀ��λ
    IniFile.WriteString('Settings', 'Ƥ��', mySettings.SkinFileName);       // ��ǰƤ���ĵ���
    IniFile.WriteString('Settings', '�ؿ��ĵ�', fn);                        // ��ǰ�ؿ��ĵ��� -- ��Ӧ�ؿ��ĵ��������ͬһĿ¼�µ����
    IniFile.WriteInteger('Settings', '�ؿ����', curMap.CurrentLevel);      // ��ǰ�ؿ����
    if curMapNode = nil then
      IniFile.WriteInteger('Settings', '�ؿ���ת', 0)                       // ��ǰ�ؿ���ת
    else
      IniFile.WriteInteger('Settings', '�ؿ���ת', curMapNode.Trun);

    n := mySettings.LaterList.Count;
    for i := 0 to n-1 do begin
        IniFile.WriteString('Settings', 'Later_' + IntToStr(i), mySettings.LaterList.Strings[i]);    // ����ƹ��Ĺؿ���
    end;

  finally
    FreeAndNil(IniFile);
  end;
end;

// ��ȡ���ĵ���������ָ����ŵĵ�ͼ
function Tmain.LoadMap(MapIndex: integer): boolean;
var
  i, j, CurCell: integer;
  ch: Char;
  s: string;

begin
  result := false;

  curMapNode := nil;

  if (MapIndex < 1) or (MapIndex > MapList.Count) then
    MapIndex := 1;

  curMapNode := MapList.Items[MapIndex - 1];

  if (MapList.Count <= 0) or (curMapNode.Rows <= 0) then
    Exit;

  curMap.CurrentLevel := MapIndex;

  for i := 0 to curMapNode.Rows - 1 do
  begin    // ��ѭ��
    for j := 1 to curMapNode.Cols do
    begin    // ��ѭ��
      ch := curMapNode.Map[i][j];
      case ch of
        '_':
          CurCell := EmptyCell;
        '#':
          CurCell := WallCell;
        '.':
          CurCell := GoalCell;
        '$':
          CurCell := BoxCell;
        '*':
          CurCell := BoxGoalCell;
        '@':
          CurCell := ManCell;
        '+':
          CurCell := ManGoalCell;
      else
        CurCell := FloorCell;
      end;
      map_Board_OG[i * curMapNode.Cols + j - 1] := CurCell;
    end;
  end;

  curMap.MapSize := curMapNode.Cols * curMapNode.Rows;

  mmo_Inf.Lines.Clear;
  mmo_Inf.Lines.Add('����:');
  mmo_Inf.Lines.Add('-----');
  mmo_Inf.Lines.Add(curMapNode.Title);
  mmo_Inf.Lines.Add('');
  mmo_Inf.Lines.Add('');
  mmo_Inf.Lines.Add('����:');
  mmo_Inf.Lines.Add('-----');
  mmo_Inf.Lines.Add(curMapNode.Author);
  
  s := StringReplace(curMapNode.Comment, #10, '', [rfReplaceAll]);
  s := StringReplace(s, #13, '', [rfReplaceAll]);
  s := StringReplace(s, #9, '', [rfReplaceAll]);
  if Trim(s) <> '' then begin
     mmo_Inf.Lines.Add('');
     mmo_Inf.Lines.Add('');
     mmo_Inf.Lines.Add('˵��:');
     mmo_Inf.Lines.Add('-----');
     mmo_Inf.Lines.Add(curMapNode.Comment);
  end;
  myPathFinder.PathFinder(curMapNode.Cols, curMapNode.Rows);

  result := true;
end;

// �����ͼ�µ�ͼƬ��ʾ�ĳߴ�
procedure Tmain.NewMapSize();
var
  w, h: integer;
begin
  if curMapNode = nil then
    exit;
  
  // �����ͼ��Ԫ��Ĵ�С
  if (curMapNode.Cols > 2) and (curMapNode.Rows > 2) then
  begin
    if curMapNode.Trun mod 2 = 0 then
    begin
      w := pl_Ground.Width div curMapNode.Cols;
      h := pl_Ground.Height div curMapNode.Rows;
    end
    else
    begin
      h := pl_Ground.Width div curMapNode.Rows;
      w := pl_Ground.Height div curMapNode.Cols;
    end;

    if w < h then
      curMap.CellSize := w
    else
      curMap.CellSize := h;
  end;
  if curMap.CellSize > SkinSize then
    curMap.CellSize := SkinSize;
  if curMap.CellSize < 10 then
    curMap.CellSize := 10;

  // ȷ����ͼ�ĳߴ�
  map_Image.Picture := nil;       // ���Ǳ���ģ����򣬵�ͼ���ܸı�ߴ�
  if curMapNode.Trun mod 2 = 0 then
  begin
    map_Image.Width := curMapNode.Cols * curMap.CellSize;
    map_Image.Height := curMapNode.Rows * curMap.CellSize;
  end
  else
  begin
    map_Image.Height := curMapNode.Cols * curMap.CellSize;
    map_Image.Width := curMapNode.Rows * curMap.CellSize;
  end;
  map_Image.Left := (pl_Ground.Width - map_Image.Width) div 2;
  map_Image.Top := (pl_Ground.Height - map_Image.Height) div 2;
end;

// �ؿ���ʼ��
procedure Tmain.InitlizeMap();
var
  i: integer;
begin
  // ǰ��׼��
  UnDoPos := 0;
  ReDoPos := 0;
  UnDoPos_BK := 0;
  ReDoPos_BK := 0;
  MoveTimes := 0;
  PushTimes := 0;
  MoveTimes_BK := 0;
  PushTimes_BK := 0;
  IsMoving := false;           // ����������...
  IsClick  := false;           // �Ƿ��������
  isYanshi := False;
  BoxNumber := 0;
  GoalNumber := 0;
  ManPos_BK := -1;              // �˵�λ�� -- ����
  ManPos_BK_0 := -1;            // �˵�λ�� -- ���� -- ����
  LastSteps := -1;              // �������һ�ε���ǰ�Ĳ���
  IsManAccessibleTips := false;           // �Ƿ���ʾ�˵����ƿɴ���ʾ
  IsManAccessibleTips_BK := false;           // �Ƿ���ʾ�˵����ƿɴ���ʾ
  IsBoxAccessibleTips := false;           // �Ƿ���ʾ���ӵ����ƿɴ���ʾ
  IsBoxAccessibleTips_BK := false;           // �Ƿ���ʾ���ӵ����ƿɴ���ʾ
  mySettings.isLurd_Saved := True;            // �ƹؿ��Ķ����Ƿ񱣴����
  AotoRedo := False;

  for i := 0 to curMap.MapSize - 1 do begin
    map_Board[i] := map_Board_OG[i];

    case map_Board_OG[i] of
      GoalCell:
        begin
          Inc(GoalNumber);
          map_Board_BK[i] := BoxCell;
        end;
      ManCell:
        begin
          ManPos := i;
          map_Board_BK[i] := FloorCell;
        end;
      ManGoalCell:
        begin
          Inc(GoalNumber);
          ManPos := i;
          map_Board_BK[i] := BoxCell;
        end;
      BoxCell:
        begin
          Inc(BoxNumber);
          map_Board_BK[i] := GoalCell;
        end;
      BoxGoalCell:
        begin
          Inc(BoxNumber);
          Inc(GoalNumber);
          map_Board_BK[i] := BoxGoalCell;
        end;
    else
      begin
        map_Board_BK[i] := map_Board_OG[i];
      end;
    end;
  end;

  curMap.ManPosition := ManPos;              // ��ͼ���˵�ԭʼλ�ã���������״̬ʱ���Դ���ʾ
  mySettings.isBK := False;                  // Ĭ������ģʽ
  OldBoxPos := -1;                     // ����������ӵ�λ�� -- ����
  OldBoxPos_BK := -1;                     // ����������ӵ�λ�� -- ����


  NewMapSize();    // ����ȷ�� Image ��С
  DrawMap();       // ����ͼ
  SetButton();     // ���ð�ť״̬

  LoadState();     // ����״̬
  LoadSolution();  // ���ش�
  curMapNode.Solved := (SoltionList.Count > 0);

  if mySettings.isXSB_Saved then
    Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']'
  else
    Caption := AppName + AppVer + ' - ���а� ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';

  ShowStatusBar();   // ����״̬��
  myPathFinder.setThroughable(mySettings.isGoThrough);    // ��Խ����

  if curMapNode.Cols > 0 then
    StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos div curMapNode.Cols + 1) + ' ]';       // ���
end;

// �����޷�ǽ��ͼԪ
function Tmain.GetWall(r, c: Integer): Integer;
var
  pos: Integer;
begin
  result := 0;

  pos := r * curMapNode.Cols + c;

  if (c > 0) and (map_Board[r * curMapNode.Cols + c - 1] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 0];  // ����ǽ��
  if (r > 0) and (map_Board[(r - 1) * curMapNode.Cols + c] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 1];  // ����ǽ��
  if (c < curMapNode.Cols - 1) and (map_Board[r * curMapNode.Cols + c + 1] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 2];  // ����ǽ��
  if (r < curMapNode.Rows - 1) and (map_Board[(r + 1) * curMapNode.Cols + c] = WallCell) then
    result := result or MapDir[curMapNode.Trun, 3];  // ����ǽ��

  if ((result = MapDir[curMapNode.Trun, 4]) or (result = MapDir[curMapNode.Trun, 5]) or (result = MapDir[curMapNode.Trun, 6]) or (result = 15)) and (c > 0) and (r > 0) and (map_Board[pos - curMapNode.Cols - 1] = WallCell) then
    result := result or 16;  // ��Ҫ��ǽ��
end;

// �Ƚ�ͼԪ���һ������ɫ��ذ����ɫ�Ƿ���ͬ����ȷ���Ƿ񻭸���
procedure Tmain.DrawLine(cs: TCanvas; x1, y1: Integer; isLine: boolean);
begin
  if isLine then
  begin
    cs.Pen.Color := LineColor;
    cs.MoveTo(x1, y1);
    cs.LineTo(x1 + curMap.CellSize, y1);
    cs.MoveTo(x1, y1);
    cs.LineTo(x1, y1 + curMap.CellSize);
  end;
end;

// �ػ���ͼ
procedure Tmain.DrawMap();
var
  i, j, k, dx, dy, myCell, x1, y1, pos, t1, t2, i2, j2: integer;
  R, R2: TRect;
    
begin
  if curMapNode = nil then
    exit;

  map_Image.Visible := false;

  for i := 0 to curMapNode.Rows - 1 do
  begin
    for j := 0 to curMapNode.Cols - 1 do
    begin
      // 0-7, 1-6, 2-5, 3-4, ��Ϊת��
      case (curMapNode.Trun) of  // ���� i2, j2 ģ��ͼԪ�ص���ת������������ô����ת����ʵ���ϵ�ͼʼ�ղ��� -- ����ͼ����ת��Ϊ�Ӿ�����
      1:
        begin
          j2 := curMapNode.Rows - 1 - i;
          i2 := j;
        end;
      2:
        begin
          j2 := curMapNode.Cols - 1 - j;
          i2 := curMapNode.Rows - 1 - i;
        end;
      3:
        begin
          j2 := i;
          i2 := curMapNode.Cols - 1 - j;
        end;
      4:
        begin
          j2 := curMapNode.Cols - 1 - j;
          i2 := i;
        end;
      5:
        begin
          j2 := curMapNode.Rows - 1 - i;
          i2 := curMapNode.Cols - 1 - j;
        end;
      6:
        begin
          j2 := j;
          i2 := curMapNode.Rows - 1 - i;
        end;
      7:
        begin
          j2 := i;
          i2 := j;
        end;
      else
        begin
          j2 := j;
          i2 := i;
        end;
      end;

      pos := i * curMapNode.Cols + j;    // ��ͼ�У������ӡ�����ʵλ��

      x1 := j2 * curMap.CellSize;        // x1, y1 �ǵ�ͼԪ�صĻ������� -- ��ת���
      y1 := i2 * curMap.CellSize;

      R := Rect(x1, y1, x1 + curMap.CellSize, y1 + curMap.CellSize);        // ��ͼ���ӵĻ��ƾ���

      if mySettings.isBK then
      begin            // ����
        myCell := map_Board_BK[pos];
        if mySettings.isJijing_BK then
        begin  // ����Ŀ��λ
          case map_Board[pos] of
            BoxCell, BoxGoalCell:
              case myCell of
                FloorCell:
                  myCell := GoalCell;
                BoxCell:
                  myCell := BoxGoalCell;
                ManCell:
                  myCell := ManGoalCell;
              end;
          else
            case myCell of
              GoalCell:
                myCell := FloorCell;
              BoxGoalCell:
                myCell := BoxCell;
              ManGoalCell:
                myCell := ManCell;
            end;
          end;
        end
        else if mySettings.isSameGoal then
        begin  // �̶���Ŀ��λ
          case map_Board_OG[pos] of
            GoalCell, BoxGoalCell, ManGoalCell:
              case myCell of
                FloorCell:
                  myCell := GoalCell;
                BoxCell:
                  myCell := BoxGoalCell;
                ManCell:
                  myCell := ManGoalCell;
              end;
            FloorCell, BoxCell, ManCell:
              case myCell of
                GoalCell:
                  myCell := FloorCell;
                BoxGoalCell:
                  myCell := BoxCell;
                ManGoalCell:
                  myCell := ManCell;
              end;
          end;
        end;
      end
      else
      begin
        myCell := map_Board[pos];             // ����
        if mySettings.isJijing then
        begin     // ����Ŀ��λ
          case map_Board_BK[pos] of
            BoxCell, BoxGoalCell:
              case myCell of
                FloorCell:
                  myCell := GoalCell;
                BoxCell:
                  myCell := BoxGoalCell;
                ManCell:
                  myCell := ManGoalCell;
              end;
          else
            case myCell of
              GoalCell:
                myCell := FloorCell;
              BoxGoalCell:
                myCell := BoxCell;
              ManGoalCell:
                myCell := ManCell;
            end;
          end;
        end;
      end;

      case myCell of
        WallCell:
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
              case (curMapNode.Trun) of
                1, 4:
                  begin
                    dx := R.Left + curMap.CellSize div 2;
                    dy := R.Top - curMap.CellSize div 2;
                  end;
                2, 5:
                  begin
                    dx := R.Left + curMap.CellSize div 2;
                    dy := R.Top + curMap.CellSize div 2;
                  end;
                3, 6:
                  begin
                    dx := R.Left - curMap.CellSize div 2;
                    dy := R.Top + curMap.CellSize div 2;
                  end;
              else
                begin
                  dx := R.Left - curMap.CellSize div 2;
                  dy := R.Top - curMap.CellSize div 2;
                end;
              end;
              map_Image.Canvas.StretchDraw(Rect(dx, dy, dx + curMap.CellSize, dy + curMap.CellSize), WallPic_top);
            end;
          end
          else
          begin                 // ��ǽ��
            map_Image.Canvas.StretchDraw(R, WallPic);
          end;
        FloorCell:
          begin
            map_Image.Canvas.StretchDraw(R, FloorPic);
            DrawLine(map_Image.Canvas, x1, y1, isFloorLine);  // ��������
          end;
        GoalCell:
          begin
            map_Image.Canvas.StretchDraw(R, GoalPic);
            DrawLine(map_Image.Canvas, x1, y1, isGoalLine);   // ��������
          end;
        BoxCell:
          begin
            map_Image.Canvas.StretchDraw(R, BoxPic);
            DrawLine(map_Image.Canvas, x1, y1, isBoxLine);    // ��������
          end;
        BoxGoalCell:
          begin
            map_Image.Canvas.StretchDraw(R, BoxGoalPic);
            DrawLine(map_Image.Canvas, x1, y1, isBoxGoalLine); // ��������
          end;
        ManCell:
          begin
            map_Image.Canvas.StretchDraw(R, ManPic);
            DrawLine(map_Image.Canvas, x1, y1, isManLine);    // ��������
          end;
        ManGoalCell:
          begin
            map_Image.Canvas.StretchDraw(R, ManGoalPic);
            DrawLine(map_Image.Canvas, x1, y1, isManGoalLine); // ��������
          end;
      else
        if mySettings.isBK then
          map_Image.Canvas.Brush.Color := clBlack
        else
          map_Image.Canvas.Brush.Color := clInactiveCaptionText;
        map_Image.Canvas.FillRect(R);
      end;

      // ������ģʽ���£���ʾ�˵����Ƴ�ʼλ��
      if mySettings.isBK then
      begin
        map_Image.Canvas.Brush.Color := clBlack;
        map_Image.Canvas.Font.Name := '΢���ź�';
        map_Image.Canvas.Font.Size := 16;
        map_Image.Canvas.Font.Color := clWhite;
        map_Image.Canvas.Font.Style := [fsBold];
        if mySettings.isJijing_BK then
          map_Image.Canvas.TextOut(0, 0, '����ģʽ - ����')
        else
          map_Image.Canvas.TextOut(0, 0, '����ģʽ');

        if (curMap.ManPosition = i2 * curMapNode.Cols + j2) then
        begin
          map_Image.Canvas.Brush.Color := clRed;  // clFuchsia

          dx := curMap.CellSize div 5;

          for k := 1 to 2 do
          begin
            R2 := Rect(x1 + dx * k, y1 + dx * k, x1 + curMap.CellSize - dx * k, y1 + curMap.CellSize - dx * k);
            map_Image.Canvas.DrawFocusRect(R2);
          end;

        end;
        if IsManAccessibleTips_BK then
        begin   // ��ʾ�˵Ŀɴ���ʾ
          t1 := curMap.CellSize div 6;
          t2 := t1 - 1;
          if myPathFinder.isManReachableByThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2));
          end
          else if myPathFinder.isManReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end
          else if myPathFinder.isBoxOfThrough_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips_BK then
        begin   // ��ʾ���ӵĿɴ���ʾ
          t1 := curMap.CellSize div 6;
          t2 := t1 - 1;
          if myPathFinder.isBoxReachable_BK(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
      end
      else
      begin
        if mySettings.isJijing then
        begin    // ����
          map_Image.Canvas.Brush.Color := clBlack;
          map_Image.Canvas.Font.Name := '΢���ź�';
          map_Image.Canvas.Font.Size := 16;
          map_Image.Canvas.Font.Color := clWhite;
          map_Image.Canvas.Font.Style := [fsBold];
          map_Image.Canvas.TextOut(0, 0, '����');
        end;

        if IsManAccessibleTips then
        begin   // ��ʾ�˵Ŀɴ���ʾ
          t1 := curMap.CellSize div 6;
          t2 := t1 - 1;
          if myPathFinder.isManReachableByThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1));
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.FillRect(Rect(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2));
          end
          else if myPathFinder.isManReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end
          else if myPathFinder.isBoxOfThrough(pos) then
          begin
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
        if IsBoxAccessibleTips then
        begin   // ��ʾ���ӵĿɴ���ʾ
          t1 := curMap.CellSize div 6;
          t2 := t1 - 1;
          if myPathFinder.isBoxReachable(pos) then
          begin
            map_Image.Canvas.Brush.Color := clBlack;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t1, y1 + curMap.CellSize div 2 - t1, x1 + curMap.CellSize div 2 + t1, y1 + curMap.CellSize div 2 + t1);
            map_Image.Canvas.Brush.Color := clWhite;
            map_Image.Canvas.Ellipse(x1 + curMap.CellSize div 2 - t2, y1 + curMap.CellSize div 2 - t2, x1 + curMap.CellSize div 2 + t2, y1 + curMap.CellSize div 2 + t2);
          end;
        end;
      end;

      // ��ż����ʾ
      if mySettings.isOddEven and ((i2 + j2) mod 2 = 1) and ((myCell = FloorCell) or (myCell = GoalCell) or (myCell = ManCell) or (myCell = ManGoalCell)) then
      begin
        map_Image.Canvas.Brush.Color := clWhite;

        dx := curMap.CellSize div 5;

        for k := 0 to 2 do
        begin
          R2 := Rect(x1 + dx * k, y1 + dx * k, x1 + curMap.CellSize - dx * k, y1 + curMap.CellSize - dx * k);
          map_Image.Canvas.DrawFocusRect(R2);
        end;
      end;
    end;
  end;

  map_Image.Visible := true;
  ShowStatusBar();
end;

procedure Tmain.FormCreate(Sender: TObject);
var
  res: TResourceStream;

begin
//  LogFileInit('');

  bt_View.Caption      := 'ѡ��';
  bt_GoThrough.Caption := '��Խ';
  bt_IM.Caption        := '˲��';
  bt_BK.Caption        := '����';
  bt_OddEven.Caption   := '��ż';
  bt_Skin.Caption      := '����';
  bt_Act.Caption       := '�����༭';
  bt_Save.Caption      := '״̬�浵';

  bt_Open.Hint         := '���ĵ�: Ctrl + O';
  bt_Lately.Hint       := '����򿪵��ĵ�';
  bt_Pre.Hint          := '��һ��: PgUp';
  bt_Next.Hint         := '��һ��: PgDn';
  bt_UnDo.Hint         := '����: Z';
  bt_ReDo.Hint         := '����: X';
  bt_View.Hint         := 'ѡ��ؿ�: F3';
  bt_GoThrough.Hint    := '��Խ����: G';
  bt_IM.Hint           := '˲�ƿ���: I';
  bt_BK.Hint           := '����ģʽ: B';
  bt_OddEven.Hint      := '��ż��λ: E';
  bt_Skin.Hint         := '����Ƥ��: F2';
  bt_Act.Hint          := '�����༭: F4';
  bt_Save.Hint         := '�����ֳ�: Ctrl + S';
  pnl_Trun.Hint        := '��ת�ؿ�: *��/����������';
  pnl_Speed.Hint       := '�ı���Ϸ�ٶ�:  +��-����������';

  StatusBar1.Panels[0].Text := '�ƶ�';
  StatusBar1.Panels[4].Text := '���';

  PageControl.Pages[0].Caption := '��';
  PageControl.Pages[1].Caption := '״̬';
  PageControl.Pages[2].Caption := '����';
  
  pmSolution.Items[0].Caption := '�ύ������';
  pmSolution.Items[1].Caption := 'Lurd �����а�';
  pmSolution.Items[2].Caption := 'XSB + Lurd �����а�';
  pmSolution.Items[3].Caption := 'XSB + Lurd ���ĵ�';
  pmSolution.Items[4].Caption := 'XSB + Lurd_All �����а�';
  pmSolution.Items[5].Caption := 'XSB + Lurd_All ���ĵ�';
  pmSolution.Items[6].Caption := 'ɾ��';
  pmSolution.Items[7].Caption := 'ɾ��ȫ��';

  pmState.Items[0].Caption := '���� Lurd �����а�';
  pmState.Items[1].Caption := '���� Lurd �����а�';
  pmState.Items[2].Caption := 'XSB + Lurd �����а�';
  pmState.Items[3].Caption := 'XSB + Lurd ���ĵ�';
  pmState.Items[4].Caption := 'ɾ��';
  pmState.Items[5].Caption := 'ɾ��ȫ��';

  pmBoardBK.Items[0].Caption := '�̶���Ŀ��λ';
  pmBoardBK.Items[1].Caption := '����Ŀ��λ';
  pmBoardBK.Items[2].Caption := '���¿�ʼ   Esc';

  // һЩ��ԭʼ��Ĭ������
  mySettings.myTop := 100;      // �ϴ��˳�ʱ�����ڵ�λ�ü���С
  mySettings.myLeft := 100;
  mySettings.myWidth := 800;
  mySettings.myHeight := 600;
  mySettings.bwTop := 100;      // �ؿ�������ڵ�λ�ü���С�ļ���
  mySettings.bwLeft := 100;
  mySettings.bwWidth := 800;
  mySettings.bwHeight := 600;
  mySettings.mySpeed := 2;        // Ĭ���ƶ��ٶ�
  mySettings.isGoThrough := true;    // ��Խ����

  AppPath := ExtractFilePath(Application.ExeName);

  // ���Ӵ����ݿ�
  try
    // ���𰸿��ļ��Ƿ���ڣ��������ڣ������Դ���е�������
    if not FileExists(AppPath + '\BoxMan.dat') then begin
       res := TResourceStream.Create(HInstance, 'DATA', 'MDB');
       res.SaveToFile(AppPath + '\BoxMan.dat');
       res.Free;
    end;
    DataModule1.ADOConnection1.Close;
    DataModule1.ADOConnection1.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=BoxMan.dat;Persist Security Info=False;Jet OLEDB:Database Password=boxman2019;';
    DataModule1.ADOConnection1.LoginPrompt := False;
    DataModule1.ADOConnection1.Open;
  except
    DataModule1.ADOConnection1.Close;
    MessageBox(handle, '�𰸿��ĵ�����' + #10 + '���򽫲��ܱ���𰸺�״̬��', '����', MB_ICONERROR or MB_OK);
//      application.Terminate;
  end;

  // ���򴰿���С�ߴ�����
  Constraints.MinHeight := minWindowsHeight;
  Constraints.MinWidth := minWindowsWidth;

  // undo��redo ָ���ʼ��
  UnDoPos := 0;
  ReDoPos := 0;
  UnDoPos_BK := 0;
  ReDoPos_BK := 0;

  LoadSttings();    // ����������

  Caption := AppName + AppVer;

  curSkinFileName := mySettings.SkinFileName;      // ��ǰƤ��

  // �ָ��ϴ��˳�ʱ�����ڵ�λ�ü���С
  Top := mySettings.myTop;
  Left := mySettings.myLeft;
  Width := mySettings.myWidth;
  Height := mySettings.myHeight;

  myPathFinder := TPathFinder.Create;             // ̽·��

  MapList := TList.Create;                    // ��ͼ�б�
  SoltionList := TList.Create;                    // ���б�
  StateList := TList.Create;                    // ״̬�б�

  // ���ص�ͼ
  if (not FileExists(mySettings.MapFileName)) or (not LoadMaps(mySettings.MapFileName)) then  // �ϴεĹؿ����ĵ�
  begin
    if Trim(mySettings.MapFileName) <> '' then
       StatusBar1.Panels[7].Text := '�ؿ����ĵ�����ʧ�� - ' + mySettings.MapFileName;
//    MessageBox(handle, PChar('û���ҵ��ؿ����ĵ� - ' + mySettings.MapFileName), '����', MB_ICONERROR or MB_OK);
  end;

  if (MapList <> nil) and (MapList.Count > 0) then
  begin
    if (curMap.CurrentLevel < 1) and (curMap.CurrentLevel > MapList.Count) then
      curMap.CurrentLevel := 1;

    curMapNode := MapList.Items[curMap.CurrentLevel - 1];
    curMapNode.Trun := tmpTrun;

    if LoadMap(curMap.CurrentLevel) then
      InitlizeMap();

    pnl_Trun.Caption := MapTrun[curMapNode.Trun];
  end;

  SetButton();             // ���ð�ť״̬
  pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];

  KeyPreview := true;
  keyPressing := False;

end;

// ���ð�ť״̬
procedure Tmain.SetButton();
begin
  if mySettings.isGoThrough then
  begin
    bt_GoThrough.Font.Color := clBlack;
    bt_GoThrough.Font.Style := bt_IM.Font.Style + [fsBold];
    bt_GoThrough.Down := True;
  end
  else
  begin
    bt_GoThrough.Font.Color := clGray;
    bt_GoThrough.Font.Style := bt_IM.Font.Style - [fsBold];
    bt_GoThrough.Down := False;
  end;

  if mySettings.isIM then
  begin
    bt_IM.Font.Color := clBlack;
    bt_IM.Font.Style := bt_IM.Font.Style + [fsBold];
    bt_IM.Down := True;
  end
  else
  begin
    bt_IM.Font.Color := clGray;
    bt_IM.Font.Style := bt_IM.Font.Style - [fsBold];
    bt_IM.Down := False;
  end;

//  StatusBar1.Panels[7].Text := '';
  if mySettings.isBK then
  begin
    pl_Ground.Color := clBlack;
    bt_BK.Font.Color := clBlack;
    bt_BK.Font.Style := bt_BK.Font.Style + [fsBold];
    bt_BK.Down := True;
    if ManPos_BK < 0 then
    begin
      StatusBar1.Panels[7].Text := '����ָ�����˵Ŀ�ʼλ�á�������';
    end;
  end
  else
  begin
    pl_Ground.Color := clInactiveCaptionText;
    bt_BK.Font.Color := clGray;
    bt_BK.Font.Style := bt_BK.Font.Style - [fsBold];
    bt_BK.Down := False;
  end;
end;

// �رճ���
procedure Tmain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ReDoPos := 0;
  ReDoPos_BK := 0;

  SaveSttings();               // ����������

  FreeAndNil(mySettings.LaterList);

  IsMoving := false;

  FreeAndNil(BrowseForm.Map_Icon);

  FreeAndNil(MapList);         // ��ͼ�б�
  FreeAndNil(SoltionList);     // ���б�
  FreeAndNil(StateList);       // ״̬�б�

//  LogFileClose();
end;

// �Ƿ���� -- ����
function Tmain.IsComplete(): Boolean;
var
  i: integer;
begin
  result := true;

  for i := 1 to curMap.MapSize do
  begin
    if (map_Board[i] = BoxCell) or (map_Board[i] = GoalCell) then
    begin
      result := false;
      Exit;
    end;
  end;
end;

// �Ƿ���� -- ����
function Tmain.IsComplete_BK(): Boolean;
var
  i: integer;

begin
  result := true;

  for i := 1 to curMap.MapSize do
  begin
    if (map_Board_BK[i] = BoxCell) or (map_Board_BK[i] = GoalCell) then
    begin
      result := false;
      Exit;
    end;
  end;
end;

// �Ƿ��������
function Tmain.IsMeets(ch: Char): Boolean;
var
  i, len, n: integer;
  flg: Boolean;
begin
  Result := False;

  if (MoveTimes_BK < 1) or (ch in [ 'l', 'r', 'u', 'd' ]) then
    Exit;        // û�����ƶ���ʱ������������

  for i := 1 to curMap.MapSize do
  begin
    if ((map_Board[i] = BoxCell) or (map_Board[i] = BoxGoalCell)) and (map_Board_BK[i] <> BoxCell) and (map_Board_BK[i] <> BoxGoalCell) then
    begin
      Exit;
    end;
  end;

  flg := True;
  if (ManPos <> ManPos_BK) then
  begin
    flg := myPathFinder.manTo2(false, -1, -1, ManPos div curMapNode.Cols, ManPos mod curMapNode.Cols, ManPos_BK div curMapNode.Cols, ManPos_BK mod curMapNode.Cols);
  end;

  if flg then
  begin
    Result := True;
     
//     if isBK then bt_BK.Click;    // �л������ƽ���

    // �������ƴ��У�ǰ�����õĿ��ƶ���
    n := 1;
    while n <= UnDoPos_BK do begin
      if UndoList_BK[n] in [ 'L', 'R', 'U', 'D' ] then Break;
      inc(n);
    end;

    ReDoPos := 0;
    for i := n to UnDoPos_BK do
    begin
      if ReDoPos = MaxLenPath then Exit;

      Inc(ReDoPos);
      case UndoList_BK[i] of
        'l':
          RedoList[ReDoPos] := 'r';
        'r':
          RedoList[ReDoPos] := 'l';
        'u':
          RedoList[ReDoPos] := 'd';
        'd':
          RedoList[ReDoPos] := 'u';
        'L':
          RedoList[ReDoPos] := 'R';
        'R':
          RedoList[ReDoPos] := 'L';
        'U':
          RedoList[ReDoPos] := 'D';
        'D':
          RedoList[ReDoPos] := 'U';
      end

    end;

    len := myPathFinder.manTo(false, map_Board, ManPos, ManPos_BK);
    for i := 1 to len do
    begin
      if ReDoPos = MaxLenPath then
        Exit;
      Inc(ReDoPos);
      RedoList[ReDoPos] := ManPath[i];
    end;
  end;
end;

// �����¼�
procedure Tmain.FormKeyPress(Sender: TObject; var Key: Char);
begin
//  StatusBar1.Panels[7].Text := IntToStr(ord(Key));
  case Ord(Key) of
    45:
      begin                      // -������
        if mySettings.mySpeed < 4 then
          Inc(mySettings.mySpeed);
      end;
    43:
      begin                      // +������
        if mySettings.mySpeed > 0 then
          Dec(mySettings.mySpeed);
      end;
    27:                         // ESC���ؿ�ʼ
      begin
        isYanshi := False;
        if not IsClick then IsClick := True;
        Restart(mySettings.isBK);   
      end;
    8:                            // �˸������������
      begin
        isYanshi := True;
        if mySettings.isBK then begin
          if IsMoving then IsClick := True
          else UnDo_BK(UnDoPos_BK);
        end else begin
          if IsMoving then IsClick := True
          else UnDo(UnDoPos);
        end;
      end;
    32:                          // �ո����������β
      begin
        isYanshi := True;
        if mySettings.isBK then begin
          if IsMoving then IsClick := True
          else ReDo_BK(ReDoPos_BK);
        end else begin
          if IsMoving then IsClick := True
          else ReDo(ReDoPos);
        end;
      end;
    122, 90:                 // z������
      begin
        if isYanshi then begin
           isYanshi := False;
           if not IsClick then IsClick := True;
        end else bt_UnDo.Click;
      end;
    120, 88:                 // x������
      begin
        if isYanshi then begin
           isYanshi := False;
           if not IsClick then IsClick := True;
        end else bt_ReDo.Click;
      end;
    97, 65:                        // a������һ��
      begin
        if isYanshi then begin
           isYanshi := False;
           if not IsClick then IsClick := True;
        end else begin
           if mySettings.isBK then
             UnDo_BK(1)
            else
             UnDo(1);
            end;
      end;
    115, 83:                       // s������һ��
      begin
        if isYanshi then begin
           isYanshi := False;
           if not IsClick then IsClick := True;
        end else begin
           if mySettings.isBK then
              ReDo_BK(1)
           else
              ReDo(1);
           end;
      end;
    15:                   // Ctrl + o���򿪹ؿ��ĵ�
      begin
        if isYanshi then begin
           isYanshi := False;
           if not IsClick then IsClick := True;
        end else bt_Open.Click;
      end;
    42:
      begin
        curMapNode.Trun := 0;        // �� 0 ת
        SetMapTrun;
      end;
    47:
      begin
        if curMapNode.Trun < 7 then
          inc(curMapNode.Trun)
        else
          curMapNode.Trun := 0; // �� 0 ת
        SetMapTrun;
      end;
    105, 73:
      bt_IM.Click;            // i��˲��
    98, 66:
      bt_BK.Click;            // b������ģʽ
  end;
end;

// F5 -- ����
//procedure MyTest();
//var
//  i, size: Integer;
//  MapNode : PMapNode;                   // �ؿ��ڵ�
//
//begin
//  LogFileInit(AppPath);    // ��ʼ�� Log �ļ�
//  MapNode := curMapNode;
//
//  size := MapList.Count;
//  for i := 0 to size-1 do begin
//      curMapNode := MapList[i];
//      Write(myLogFile, GetXsb());
//      Write(myLogFile, #10);
//  end;
//
//  curMapNode := MapNode;
//  LogFileClose();              // �ر� Log �ļ�
//  showmessage('OK');
//end;

// ���ڼ��̵��������Ұ��������ݹؿ��ĵ�ǰ��ת״̬ת�������ַ�
function getTrun_Act(n: Integer; act: Char): Char;
begin
  Result := ' ';
  case act of
     'l': Result := ActDir[n, 0];
     'u': Result := ActDir[n, 1];
     'r': Result := ActDir[n, 2];
     'd': Result := ActDir[n, 3];
     'L': Result := ActDir[n, 4];
     'U': Result := ActDir[n, 5];
     'R': Result := ActDir[n, 6];
     'D': Result := ActDir[n, 7];
  end;
end;

// ���̰���
procedure Tmain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i, myCell: Integer;
  mNode: PMapNode;
  s: string;
  flg: Boolean;

begin
//  StatusBar1.Panels[7].Text := IntToStr(ord(Key));
  case Key of
    VK_LEFT:
      if not IsMoving then
      begin
        if mySettings.isBK and (ManPos_BK < 0) then Exit;
        isYanshi := False;
        if mySettings.isBK then
        begin
          ReDoPos_BK := 1;
          if Shift = [ssCtrl] then
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'L')
          else
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'l');
          ReDo_BK(ReDoPos_BK)
        end
        else
        begin
          ReDoPos := 1;
          RedoList[ReDoPos] := getTrun_Act(curMapNode.Trun, 'l');
          ReDo(ReDoPos);
        end;
      end;
    VK_RIGHT:
      if not IsMoving then
      begin
        if mySettings.isBK and (ManPos_BK < 0) then
          Exit;
        isYanshi := False;
        if mySettings.isBK then
        begin
          ReDoPos_BK := 1;
          if Shift = [ssCtrl] then
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'R')
          else
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'r');
          ReDo_BK(ReDoPos_BK)
        end
        else
        begin
          ReDoPos := 1;
          RedoList[ReDoPos] := getTrun_Act(curMapNode.Trun, 'r');
          ReDo(ReDoPos);
        end;
      end;
    VK_UP:
      if not IsMoving then
      begin
        if mySettings.isBK and (ManPos_BK < 0) then
          Exit;
        isYanshi := False;
        if mySettings.isBK then
        begin
          ReDoPos_BK := 1;
          if Shift = [ssCtrl] then
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'U')
          else
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'u');
          ReDo_BK(ReDoPos_BK)
        end
        else
        begin
          ReDoPos := 1;
          RedoList[ReDoPos] := getTrun_Act(curMapNode.Trun, 'u');
          ReDo(ReDoPos);
        end;
      end;
    VK_DOWN:
      if not IsMoving then
      begin
        if mySettings.isBK and (ManPos_BK < 0) then
          Exit;
        isYanshi := False;
        if mySettings.isBK then
        begin
          ReDoPos_BK := 1;
          if Shift = [ssCtrl] then
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'D')
          else
            RedoList_BK[ReDoPos_BK] := getTrun_Act(curMapNode.Trun, 'd');
          ReDo_BK(ReDoPos_BK)
        end
        else
        begin
          ReDoPos := 1;
          RedoList[ReDoPos] := getTrun_Act(curMapNode.Trun, 'd');
          ReDo(ReDoPos);
        end;
      end;
    VK_F1:                         // F1������
      begin
        ShellExecute(Application.handle, nil, PChar(AppPath + 'BoxManHelp.txt'), nil, nil, SW_SHOWNORMAL);
        ContentClick(Self);
      end;
    VK_F2:                         // F2������Ƥ��
      bt_Skin.Click;
    VK_F3:                         // F3������ؿ�
      bt_View.Click;
    VK_F4:                         // F4�������༭
      bt_Act.Click;
//    VK_F5:                         // F5������
//      MyTest();
    69:                     // E�� ��ż��Ч��
      bt_OddEvenMouseDown(Self, mbLeft, [], -1, -1);      
    VK_PRIOR:               // Page Up����  ��һ��
      begin
        if not keyPressing then begin
           keyPressing := true;
           if Shift = [ssCtrl] then begin
              s := 'ǰ��û���ҵ�δ��ؿ�!';
              if curMap.CurrentLevel > 1 then
              begin
                i := curMap.CurrentLevel;
                while i > 1 do
                begin
                  Dec(i);
                  mNode := MapList.Items[i - 1];
                  if not mNode.Solved then
                    Break;
                end;

                if (i > 0) and (not mNode.Solved) then
                begin
                  if LoadMap(i) then
                  begin
                    InitlizeMap();
                    SetMapTrun();
                  end;
                  s := '��һ��δ��ؿ���';
                end;
              end;
              StatusBar1.Panels[7].Text := s;
           end else bt_Pre.Click;
        end;
      end;
    VK_NEXT:                // Page Domw������һ��
      begin
        if not keyPressing then begin
           keyPressing := true;
           if Shift = [ssCtrl] then begin
              s := '����û���ҵ�δ��ؿ�!';
              if curMap.CurrentLevel <= MapList.Count then
              begin
                i := curMap.CurrentLevel;
                while i < MapList.Count do
                begin
                  inc(i);
                  mNode := MapList.Items[i - 1];
                  if not mNode.Solved then
                    Break;
                end;

                if (i <= MapList.Count) and (not mNode.Solved) then
                begin
                  if LoadMap(i) then
                  begin
                    InitlizeMap();
                    SetMapTrun();
                  end;
                  s := '��һ��δ��ؿ���';
                end;
              end;
              StatusBar1.Panels[7].Text := s;
           end else bt_Next.Click;
        end;
      end;
    VK_HOME:    // Home������
      begin
        isYanshi := False;
        if not IsClick then IsClick := True;
        pm_Home.Click;
      end;
    VK_END:    // End����β
      begin
        isYanshi := False;
        if not IsClick then IsClick := True;
        flg := AotoRedo;
        AotoRedo := True;
        if mySettings.isBK then ReDo_BK(ReDoPos_BK)
        else ReDo(ReDoPos);
        StatusBar1.Panels[7].Text := '����β��';
        AotoRedo := flg;
      end;
    83:                // Ctrl + S
      if (not keyPressing) and (Shift = [ssCtrl]) then begin
        isYanshi := False;
        keyPressing := true;
        bt_Save.Click;
      end;
    81:                // Ctrl + Q�� �˳�
      if (not keyPressing) and (Shift = [ssCtrl]) then
      begin
        isYanshi := False;
        keyPressing := true;
        Close();
      end;
    71:                // Ctrl + G�� �̶���Ŀ��λ
      if (not keyPressing) and (Shift = [ssCtrl]) then begin
         keyPressing := true;
         pmGoal.Click;
      end;
    74:                // Ctrl + J�� ����Ŀ��λ
      if (not keyPressing) and (Shift = [ssCtrl]) then begin
         keyPressing := true;
         pmJijing.Click;
      end;
    76:                // Ctrl + L�� �Ӽ��а���� Lurd
      if (not keyPressing) and (Shift = [ssCtrl]) then begin
        keyPressing := true;
        isYanshi := False;
        if LoadLurdFromClipboard(mySettings.isBK) then begin
          StatusBar1.Panels[7].Text := '�Ӽ��а���� Lurd��';
          if mySettings.isBK and (ManPos_BK_0_2 >= 0) then begin   // �����˵�λ��
            myCell := map_Board_OG[ManPos_BK_0_2];
            if (myCell = FloorCell) or (myCell = GoalCell) then begin
              for i := 0 to curMap.MapSize - 1 do begin
                if map_Board_OG[i] = BoxCell then
                  map_Board_BK[i] := GoalCell
                else if map_Board_OG[i] = GoalCell then
                  map_Board_BK[i] := BoxCell
                else if map_Board_OG[i] = ManCell then
                  map_Board_BK[i] := FloorCell
                else if map_Board_OG[i] = ManGoalCell then
                  map_Board_BK[i] := GoalCell
                else
                  map_Board_BK[i] := map_Board_OG[i];
              end;
              ManPos_BK_0 := ManPos_BK_0_2;
              ManPos_BK := ManPos_BK_0_2;
              if map_Board_BK[ManPos_BK] = FloorCell then
                map_Board_BK[ManPos_BK] := ManCell
              else
                map_Board_BK[ManPos_BK] := ManGoalCell;
              UnDoPos_BK := 0;
              MoveTimes_BK := 0;
              PushTimes_BK := 0;
              IsMoving := false;            // ����������...
              LastSteps := -1;              // �������һ�ε���ǰ�Ĳ���
              IsManAccessibleTips_BK := false;           // �Ƿ���ʾ�˵����ƿɴ���ʾ
              IsBoxAccessibleTips_BK := false;           // �Ƿ���ʾ���ӵ����ƿɴ���ʾ
              mySettings.isLurd_Saved := True;            // �ƹؿ��Ķ����Ƿ񱣴����
              DrawMap();         // ����ͼ
              SetButton();       // ���ð�ť״̬
              ShowStatusBar();   // ����״̬��
              StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos_BK mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos_BK div curMapNode.Cols + 1) + ' ]';       // ���
            end;
          end;
          if mySettings.isBK then begin
            if ManPos_BK >= 0 then ReDo_BK(ReDoPos_BK);
          end else ReDo(ReDoPos);
        end;
      end;
    77:                // Ctrl + M�� Lurd ������а�
      if (not keyPressing) and (Shift = [ssCtrl]) then begin
        keyPressing := true;
        isYanshi := False;
        if LurdToClipboard(ManPos_BK_0 mod curMapNode.Cols, ManPos_BK_0 div curMapNode.Cols) then
          StatusBar1.Panels[7].Text := 'Lurd ������а壡';
      end;
    67:                 // Ctrl + C�� XSB ������а�
      if (not keyPressing) and (Shift = [ssCtrl]) then
      begin
        keyPressing := true;
        XSBToClipboard();
        StatusBar1.Panels[7].Text := '�ؿ� XSB ������а壡';
      end;
    86:                // Ctrl + V�� �Ӽ��а���� XSB
      if (not keyPressing) and (Shift = [ssCtrl]) then begin
        keyPressing := true;
        isYanshi := False;
        if not mySettings.isXSB_Saved then
        begin    // ���µ�XSB��δ����
          i := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴浼��Ĺؿ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
          if i = idyes then begin
            SaveXSBToFile();
          end else if i = idno then begin
            mySettings.isXSB_Saved := False;
          end else Exit;
        end;

        if not mySettings.isLurd_Saved then
        begin    // ���µĶ�����δ����
          i := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴����µ��ƶ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
          if i = idyes then begin
            mySettings.isLurd_Saved := True;
            SaveState();          // ����״̬�����ݿ�
          end else if i = idno then begin
            mySettings.isLurd_Saved := True;
            StatusBar1.Panels[7].Text := '������������';
          end else exit;
        end;

        if LoadMapsFromClipboard() then begin               // ���а嵼�� XSB
          if (MapList <> nil) and (MapList.Count > 0) then begin   // ����������Ч�ؿ����Զ��򿪵�һ���ؿ�
            if LoadMap(1) then begin
              curMapNode.Trun := 0;    // Ĭ�Ϲؿ��� 0 ת
              SetMapTrun();
              InitlizeMap();
              mySettings.isXSB_Saved := False;              // ���Ӽ��а嵼��� XSB �Ƿ񱣴����
              mySettings.isLurd_Saved := True;              // �ƹؿ��Ķ����Ƿ񱣴����
              Caption := AppName + AppVer + ' - ���а� ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
              StatusBar1.Panels[7].Text := '�Ӽ��а���عؿ� XSB �ɹ���';
            end;
          end;
        end
        else StatusBar1.Panels[7].Text := '�Ӽ��а���عؿ� XSB ʧ�ܣ�';
      end;
  end;
end;

// ����̧��
procedure Tmain.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    69:
      bt_OddEvenMouseUp(Self, mbLeft, [], -1, -1);       // E�� ��ż��Ч��
  end;
  keyPressing := false;
end;

// �ؿ����¿�ʼ
procedure Tmain.Restart(is_BK: Boolean);
var
  i: integer;
begin
  if is_BK then
  begin
    if UnDoPos_BK > 0 then begin
      if ReDoPos_BK + UnDoPos_BK > MaxLenPath then
        ReDoPos_BK := 0;
      for i := UnDoPos_BK downto 1 do begin
        Inc(ReDoPos_BK);
        RedoList_BK[ReDoPos_BK] := UndoList_BK[i];
      end;
    end;
    UnDoPos_BK := 0;
      
      // ǰ��׼��
    MoveTimes_BK := 0;
    PushTimes_BK := 0;
    ManPos_BK := ManPos_BK_0;     // �˵�λ�� -- ����
    LastSteps := -1;              // �������һ�ε���ǰ�Ĳ���
    IsManAccessibleTips_BK := false;           // �Ƿ���ʾ�˵����ƿɴ���ʾ
    IsBoxAccessibleTips_BK := false;           // �Ƿ���ʾ���ӵ����ƿɴ���ʾ

    for i := 0 to curMap.MapSize - 1 do begin
      case map_Board_OG[i] of
        GoalCell:
          begin
            map_Board_BK[i] := BoxCell;
          end;
        ManCell:
          begin
            map_Board_BK[i] := FloorCell;
          end;
        ManGoalCell:
          begin
            map_Board_BK[i] := GoalCell;
          end;
        BoxCell:
          begin
            map_Board_BK[i] := GoalCell;
          end;
        BoxGoalCell:
          begin
            map_Board_BK[i] := BoxGoalCell;
          end;
      else
        begin
          map_Board_BK[i] := map_Board_OG[i];
        end;
      end;
    end;

    if ManPos_BK >= 0 then begin
      if map_Board_BK[ManPos_BK] = FloorCell then
        map_Board_BK[ManPos_BK] := ManCell
      else
        map_Board_BK[ManPos_BK] := ManGoalCell;
    end;

    OldBoxPos_BK := -1;                     // ����������ӵ�λ�� -- ����

    DrawMap();       // ����ͼ
    SetButton();     // ���ð�ť״̬

    ShowStatusBar();   // ����״̬��

    if curMapNode.Cols > 0 then
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos_BK mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos_BK div curMapNode.Cols + 1) + ' ]';       // ���
  end
  else
  begin
    if UnDoPos > 0 then begin
      if ReDoPos + UnDoPos > MaxLenPath then
        ReDoPos := 0;
      for i := UnDoPos downto 1 do begin
        Inc(ReDoPos);
        RedoList[ReDoPos] := UndoList[i];
      end;
    end;
    UnDoPos := 0;

    // ǰ��׼��
    MoveTimes := 0;
    PushTimes := 0;
    IsMoving := false;           // ����������...
    IsClick := false;
    LastSteps := -1;              // �������һ�ε���ǰ�Ĳ���
    IsManAccessibleTips := false;           // �Ƿ���ʾ�˵����ƿɴ���ʾ
    IsBoxAccessibleTips := false;           // �Ƿ���ʾ���ӵ����ƿɴ���ʾ

    for i := 0 to curMap.MapSize - 1 do
    begin
      map_Board[i] := map_Board_OG[i];
    end;

    OldBoxPos := -1;                     // ����������ӵ�λ�� -- ����
    ManPos := curMap.ManPosition;

    DrawMap();       // ����ͼ
    SetButton();     // ���ð�ť״̬

    ShowStatusBar();   // ����״̬��

    if curMapNode.Cols > 0 then
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos div curMapNode.Cols + 1) + ' ]';       // ���
  end;

  StatusBar1.Panels[7].Text := '���¿�ʼ��';

  if mySettings.isXSB_Saved then
    Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']'
  else
    Caption := AppName + AppVer + ' - ���а� ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
end;

// �������ڴ�С
procedure Tmain.FormResize(Sender: TObject);
begin
  NewMapSize();
  DrawMap();        // ����ͼ
end;

// ˢ��״̬�� - �ƶ������ƶ���
procedure Tmain.ShowStatusBar();
begin
  if mySettings.isBK then
  begin
    StatusBar1.Panels[1].Text := inttostr(MoveTimes_BK);
    StatusBar1.Panels[2].Text := '����';
    StatusBar1.Panels[3].Text := inttostr(PushTimes_BK);
  end
  else
  begin
    StatusBar1.Panels[1].Text := inttostr(MoveTimes);
    StatusBar1.Panels[2].Text := '�ƶ�';
    StatusBar1.Panels[3].Text := inttostr(PushTimes);
  end;
//  StatusBar1.Panels[7].Text := ' ';
end;

// ������
function Tmain.GetCur(x, y: Integer): string;
var
  k: Integer;
begin

  k := x div 26 + 64;

  if (k > 64) then
    Result := chr(k);

  Result := chr(x mod 26 + 65) + IntToStr(y + 1);
end;

// ��ͼ�ϵ���
procedure Tmain.map_ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MapClickPos: TPoint;
  myCell, pos, x2, y2, k: Integer;

//  dStart, dEnd: TDateTime;     // ����

begin
  if curMap.CellSize = 0 then Exit;
  
  IsClick := true;

  x2 := X div curMap.CellSize;
  y2 := Y div curMap.CellSize;

  case curMapNode.Trun of // �ѵ����λ�ã�ת����ͼ����ʵ���� -- ���Ӿ�����ת��Ϊ��ͼ����
    1:
      begin
        MapClickPos.X := y2;
        MapClickPos.Y := curMapNode.Rows - 1 - x2;
      end;
    2:
      begin
        MapClickPos.X := curMapNode.Cols - 1 - x2;
        MapClickPos.Y := curMapNode.Rows - 1 - y2;
      end;
    3:
      begin
        MapClickPos.X := curMapNode.Cols - 1 - y2;
        MapClickPos.Y := x2;
      end;
    4:
      begin
        MapClickPos.X := curMapNode.Cols - 1 - x2;
        MapClickPos.Y := y2;
      end;
    5:
      begin
        MapClickPos.X := curMapNode.Cols - 1 - y2;
        MapClickPos.Y := curMapNode.Rows - 1 - x2;
      end;
    6:
      begin
        MapClickPos.X := x2;
        MapClickPos.Y := curMapNode.Rows - 1 - y2;
      end;
    7:
      begin
        MapClickPos.X := y2;
        MapClickPos.Y := x2;
      end;
  else
    begin
      MapClickPos.X := x2;
      MapClickPos.Y := y2;
    end;
  end;

  StatusBar1.Panels[5].Text := ' ' + GetCur(x2, y2) + ' - [ ' + IntToStr(x2 + 1) + ', ' + IntToStr(y2 + 1) + ' ]';       // ���

  // �������ͼԪλ��
  pos := MapClickPos.y * curMapNode.Cols + MapClickPos.x;
  if mySettings.isBK then
    myCell := map_Board_BK[pos]
  else
    myCell := map_Board[pos];

  case Button of
    mbleft:
      begin    // ���� -- ָ���
        case myCell of
          FloorCell, GoalCell:
            begin            // �����ذ�
              if mySettings.isBK then
              begin                                            // ����
                if IsBoxAccessibleTips_BK then
                begin                      // �����ӿɴ���ʾʱ
                         // �ӵ��λ���Ƿ�ɴ����
                  if not myPathFinder.isBoxReachable_BK(pos) then
                    IsBoxAccessibleTips_BK := False
                  else
                  begin
                    IsBoxAccessibleTips_BK := False;
                    ReDoPos_BK := myPathFinder.boxTo(mySettings.isBK, OldBoxPos_BK, pos, ManPos_BK);
                    if ReDoPos_BK > 0 then
                    begin
                      for k := 1 to ReDoPos_BK do
                        RedoList_BK[k] := BoxPath[ReDoPos_BK - k + 1];
                      mySettings.isLurd_Saved := False;             // �����µĶ���
                      IsClick := false;
                      ReDo_BK(ReDoPos_BK);
                    end;
                  end;
                end
                else
                begin
                  if (ManPos_BK < 0) or (PushTimes_BK <= 0) then
                  begin                      // �����У������˵Ķ�λ
                    IsManAccessibleTips_BK := False;
                    IsBoxAccessibleTips_BK := False;
                    if ManPos_BK >= 0 then
                    begin
                      if map_Board_BK[ManPos_BK] = ManCell then
                        map_Board_BK[ManPos_BK] := FloorCell
                      else
                        map_Board_BK[ManPos_BK] := GoalCell;
                    end;
                    ManPos_BK := MapClickPos.y * curMapNode.Cols + MapClickPos.x;
                    ManPos_BK_0 := ManPos_BK;
                    if map_Board_BK[ManPos_BK] = FloorCell then
                      map_Board_BK[ManPos_BK] := ManCell
                    else
                      map_Board_BK[ManPos_BK] := ManGoalCell;
                  end
                  else
                  begin
                    IsManAccessibleTips_BK := False;
                    IsBoxAccessibleTips_BK := False;
                    ReDoPos_BK := myPathFinder.manTo(mySettings.isBK, map_Board_BK, ManPos_BK, pos);   // �����˿ɴ�
                    if ReDoPos_BK > 0 then
                    begin
                      for k := 1 to ReDoPos_BK do
                        RedoList_BK[k] := ManPath[k];
                      IsClick := false;
                      ReDo_BK(ReDoPos_BK);
                    end;
                  end;
                end;
              end
              else
              begin                                                // ����
                if IsBoxAccessibleTips then
                begin                          // �����ӿɴ���ʾʱ
                        // �ӵ��λ���Ƿ�ɴ����
                  if not myPathFinder.isBoxReachable(pos) then
                    IsBoxAccessibleTips := False
                  else
                  begin
                    IsBoxAccessibleTips := False;
                    ReDoPos := myPathFinder.boxTo(mySettings.isBK, OldBoxPos, pos, ManPos);
                    if ReDoPos > 0 then
                    begin
                      for k := 1 to ReDoPos do
                        RedoList[k] := BoxPath[ReDoPos - k + 1];
                      LastSteps := UnDoPos;              // �������һ�ε���ǰ�Ĳ���
                      mySettings.isLurd_Saved := False;             // �����µĶ���
                      IsClick := false;
                      ReDo(ReDoPos);
                    end;
                  end;
                end
                else
                begin
                  IsManAccessibleTips := False;
                  IsBoxAccessibleTips := False;
                  ReDoPos := myPathFinder.manTo(mySettings.isBK, map_Board, ManPos, pos);               // �����˿ɴ�
                  if ReDoPos > 0 then
                  begin
                    LastSteps := UnDoPos;              // �������һ�ε���ǰ�Ĳ���
                    for k := 1 to ReDoPos do
                      RedoList[k] := ManPath[k];
                    IsClick := false;
                    ReDo(ReDoPos);
                  end;
                end;
              end;
            end;
          ManCell, ManGoalCell:
            begin           // ������
              if mySettings.isBK then
              begin                                            // ����
                if IsBoxAccessibleTips_BK and myPathFinder.isBoxReachable_BK(ManPos_BK) then
                begin  // �����ӿɴ���ʾʱ
                  IsBoxAccessibleTips_BK := False;
                  ReDoPos_BK := myPathFinder.boxTo(mySettings.isBK, OldBoxPos_BK, pos, ManPos_BK);
                  if ReDoPos_BK > 0 then
                  begin
                    for k := 1 to ReDoPos_BK do
                      RedoList_BK[k] := BoxPath[ReDoPos_BK - k + 1];
                    mySettings.isLurd_Saved := False;             // �����µĶ���
                    IsClick := false;
                    ReDo_BK(ReDoPos_BK);
                  end;
                end
                else if IsManAccessibleTips_BK then
                  IsManAccessibleTips_BK := False  // ����ʾ�˵Ŀɴ���ʾʱ���ֵ������
                else
                begin
                  myPathFinder.manReachable(mySettings.isBK, map_Board_BK, ManPos_BK);            // �����˿ɴ�
                  IsManAccessibleTips_BK := True;
                  IsBoxAccessibleTips_BK := False;
                end;
              end
              else
              begin                                                // ����
                if IsBoxAccessibleTips and myPathFinder.isBoxReachable(ManPos) then
                begin   // �����ӿɴ���ʾʱ
                  IsBoxAccessibleTips := False;
                  ReDoPos := myPathFinder.boxTo(mySettings.isBK, OldBoxPos, pos, ManPos);
                  if ReDoPos > 0 then
                  begin
                    for k := 1 to ReDoPos do
                      RedoList[k] := BoxPath[ReDoPos - k + 1];
                    LastSteps := UnDoPos;              // �������һ�ε���ǰ�Ĳ���
                    mySettings.isLurd_Saved := False;             // �����µĶ���
                    IsClick := false;
                    ReDo(ReDoPos);
                  end;
                end
                else if IsManAccessibleTips then
                  IsManAccessibleTips := False        // ����ʾ�˵Ŀɴ���ʾʱ���ֵ������
                else
                begin
                  myPathFinder.manReachable(mySettings.isBK, map_Board, ManPos);                  // �����˿ɴ�
                  IsManAccessibleTips := True;
                  IsBoxAccessibleTips := False;
                end;
              end;
            end;
          BoxCell, BoxGoalCell:
            begin           // ��������
              if mySettings.isBK then
              begin                                            // ����
                if ManPos_BK < 0 then
                begin
                  IsClick := false;
                  Exit;
                end
                else
                begin
                  if IsBoxAccessibleTips_BK and (OldBoxPos_BK = pos) then
                    IsBoxAccessibleTips_BK := False
                  else
                  begin
                    IsBoxAccessibleTips_BK := True;
                    IsManAccessibleTips_BK := False;
                    myPathFinder.FindBlock(map_Board_BK, pos);                       // ���ݱ���������ӣ�������
                    myPathFinder.boxReachable(mySettings.isBK, pos, ManPos_BK);                 // �������ӿɴ�
                    OldBoxPos_BK := pos;
                  end;
                end;
              end
              else
              begin                                                // ����
                if IsBoxAccessibleTips and (OldBoxPos = pos) then
                  IsBoxAccessibleTips := False
                else
                begin
                  IsBoxAccessibleTips := True;
                  IsManAccessibleTips := False;
                  myPathFinder.FindBlock(map_Board, pos);                              // ���ݱ���������ӣ�������
                  myPathFinder.boxReachable(mySettings.isBK, pos, ManPos);                        // �������ӿɴ�
                  OldBoxPos := pos;
                end;
              end;
            end;
        else
          begin                            // ȡ���ɴ���ʾ
            if mySettings.isBK then
            begin
              IsManAccessibleTips_BK := False;
              IsBoxAccessibleTips_BK := False;
            end
            else
            begin
              IsManAccessibleTips := False;
              IsBoxAccessibleTips := False;
            end;
          end;
        end;
      end;
    mbright:
      begin    // �һ� -- ָ�Ҽ�

      end;
  end;

  DrawMap();
end;

// ��Ϸ��ʱ
procedure Tmain.GameDelay();
var
  CurTime: dword;
  ch1, ch2: Char;
  
begin
  if isYanshi then begin
    if mySettings.isIM then begin
       if mySettings.isBK then begin
          if (UnDoPos_BK <= 0) or (UnDoPos_BK > MaxLenPath) then ch1 := ' '
          else ch1 := UndoList_BK[UnDoPos_BK];
          if (ReDoPos_BK <= 0) or (ReDoPos_BK > MaxLenPath) then ch2 := ' '
          else ch2 := RedoList_BK[ReDoPos_BK];
       end else begin
          if (UnDoPos <= 0) or (UnDoPos > MaxLenPath) then ch1 := ' '
          else ch1 := UndoList[UnDoPos];
          if (ReDoPos <= 0) or (ReDoPos > MaxLenPath) then ch2 := ' '
          else ch2 := RedoList[ReDoPos];
       end;
       if (ch1 in [ 'l', 'r', 'u' ,'d' ]) and (ch2 in [ 'l', 'r', 'u' ,'d'] ) or
          (ch1 in [ 'L', 'R', 'U' ,'D' ]) and (ch2 in [ 'L', 'R', 'U' ,'D' ]) then Exit;
          
       DrawMap();
       StatusBar1.Repaint;
    end;
  end else begin
    if mySettings.isIM then
      exit;        // ˲�ƴ�ʱ
  end;

  CurTime := GetTickCount;  // ��ʱ

  while (GetTickCount - CurTime) < DelayTimes[mySettings.mySpeed] do
    Application.ProcessMessages;
end;

procedure Tmain.ContentClick(Sender: TObject);
begin   // ����
//  Application.HelpFile := ChangeFileExt(Application.ExeName, '.HLP');
//  Application.HelpCommand(HELP_FINDER, 0);
end;

// ����״̬
function Tmain.SaveState(): Boolean;
var
  i, ActCRC, ActCRC_BK, x, y, size: Integer;
  actNode: ^TStateNode;
  act, act_BK: string;
begin
  Result := False;

  if (PushTimes = 0) and (PushTimes_BK = 0) then
    Exit;     // û���ƶ�����ʱ���������洦��

  if MoveTimes > 0 then
    ActCRC := Calcu_CRC_32_2(@UndoList, MoveTimes)
  else
    ActCRC := -1;

  if MoveTimes_BK > 0 then
    ActCRC_BK := Calcu_CRC_32_2(@UndoList_BK, MoveTimes_BK)
  else
    ActCRC_BK := -1;

  if ManPos_BK_0 < 0 then
  begin
    x := -1;
    y := -1;
  end
  else
  begin
    x := ManPos_BK_0 mod curMapNode.Cols;
    y := ManPos_BK_0 div curMapNode.Cols;
  end;

   // ����
  i := 0;
  size := StateList.Count;
  while i < size do
  begin
    actNode := StateList[i];
    if (actNode.CRC32 = ActCRC) and (actNode.Moves = MoveTimes) and (actNode.Pushs = PushTimes) and (actNode.CRC32_BK = ActCRC_BK) and (actNode.Moves_BK = MoveTimes_BK) and (actNode.Pushs_BK = PushTimes_BK) and (actNode.Man_X = x) and (actNode.Man_Y = y) then
      Break;
    inc(i);
  end;
  actNode := nil;

  if i = size then
  begin           // ���ظ�
    if UnDoPos < MaxLenPath then
      UndoList[UnDoPos + 1] := #0;
    act := PChar(@UndoList);

    if UnDoPos_BK < MaxLenPath then
      UndoList_BK[UnDoPos_BK + 1] := #0;
    act_BK := PChar(@UndoList_BK);

    New(actNode);
    actNode.id := -1;
    actNode.DateTime := Now;
    actNode.Moves := MoveTimes;
    actNode.Pushs := PushTimes;
    actNode.CRC32 := ActCRC;
    actNode.Moves_BK := MoveTimes_BK;
    actNode.Pushs_BK := PushTimes_BK;
    actNode.CRC32_BK := ActCRC_BK;
    actNode.Man_X := x;
    actNode.Man_Y := y;

      // ����״̬�����ݿ�
    try
      DataModule1.ADOQuery1.Close;
      DataModule1.ADOQuery1.SQL.Clear;
      DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_State';
      DataModule1.ADOQuery1.Open;

         // ׷��״̬
      with DataModule1.ADOQuery1 do
      begin

        Append;   // ���

        FieldByName('XSB_CRC32').AsInteger := curMapNode.CRC32;
        FieldByName('XSB_CRC_TrunNum').AsInteger := curMapNode.CRC_Num;
        FieldByName('Goals').AsInteger := curMapNode.Goals;
        FieldByName('Act_CRC32').AsInteger := actNode.CRC32;
        FieldByName('Act_CRC32_BK').AsInteger := actNode.CRC32_BK;
        FieldByName('Moves').AsInteger := actNode.Moves;
        FieldByName('Pushs').AsInteger := actNode.Pushs;
        FieldByName('Moves_BK').AsInteger := actNode.Moves_BK;
        FieldByName('Pushs_BK').AsInteger := actNode.Pushs_BK;
        FieldByName('Man_X').AsInteger := actNode.Man_X;
        FieldByName('Man_Y').AsInteger := actNode.Man_Y;
        FieldByName('Act_Text').AsString := act;
        FieldByName('Act_Text_BK').AsString := act_BK;
        FieldByName('Act_DateTime').AsDateTime := actNode.DateTime;

        Post;    // �ύ

      end;

      actNode.id := DataModule1.ADOQuery1.FieldByName('ID').AsInteger;
      DataModule1.ADOQuery1.Close;

      StateList.Insert(0, actNode);

      // ��ǰ״̬���뵽�б����ǰ��
      List_State.Items.Insert(0, IntToStr(actNode.Pushs) + '/' + IntToStr(actNode.Moves) + #10 + ' [' + IntToStr(actNode.Man_X) + ',' + IntToStr(actNode.Man_Y) + ']' + IntToStr(actNode.Pushs_BK) + '/' + IntToStr(actNode.Moves_BK) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime));

      StatusBar1.Panels[7].Text := '״̬�ѱ��棡';
    except
      FreeAndNil(actNode);
      StatusBar1.Panels[7].Text := '����״̬ʱ��������';
      Exit;
    end;
  end else begin        // ���ظ�
    try
      DataModule1.ADOQuery1.Close;
      DataModule1.ADOQuery1.SQL.Clear;
      DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_State';
      DataModule1.ADOQuery1.Open;

      with DataModule1.ADOQuery1 do begin

        Edit;    // �޸�

        FieldByName('Act_DateTime').AsDateTime := actNode.DateTime;

        Post;    // �ύ

      end;

      DataModule1.ADOQuery1.Close;
         
         // ����״̬�б���Ŀ�Ĵ��� -- ��ǰ״̬�ᵽ��ǰ��
      if i > 0 then begin
        actNode := StateList.Items[i];
        actNode.DateTime := Now;
        StateList.Move(i, 0);
        List_State.Items.Move(i, 0);
        List_State.Items[0] := IntToStr(actNode.Pushs) + '/' + IntToStr(actNode.Moves) + #10 + ' [' + IntToStr(actNode.Man_X) + ',' + IntToStr(actNode.Man_Y) + ']' + IntToStr(actNode.Pushs_BK) + '/' + IntToStr(actNode.Moves_BK) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime);
      end;

      StatusBar1.Panels[7].Text := '״̬���ظ����ѵ����洢����';
    except
      StatusBar1.Panels[7].Text := '״̬���ظ��������洢����ʱ��������';
      Exit;
    end;
  end;

  actNode := nil;
  PageControl.ActivePageIndex := 1;
  List_State.Selected[0] := True;
  List_State.SetFocus;
  mySettings.isLurd_Saved := True;
  Result := True;
end;

// ����״̬
function Tmain.LoadState(): Boolean;
var
  actNode: ^TStateNode;
begin
  Result := False;

  StateList.Clear;
  List_State.Clear;

  // ����״̬�����ݿ�
  try
    DataModule1.ADOQuery1.Close;
    DataModule1.ADOQuery1.SQL.Clear;
    DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_State where XSB_CRC32 = ' + IntToStr(curMapNode.CRC32) + ' and XSB_CRC_TrunNum = ' + IntToStr(curMapNode.CRC_Num) + ' and Goals = ' + IntToStr(curMapNode.Goals) + ' order by Act_DateTime desc';
    DataModule1.ADOQuery1.Open;
    DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;

     // ׷��״̬
    with DataModule1.DataSource1.DataSet do
    begin
      First;

      while not Eof do
      begin
        New(actNode);
        actNode.id := FieldByName('ID').AsInteger;
        actNode.DateTime := FieldByName('Act_DateTime').AsDateTime;
        actNode.Moves := FieldByName('Moves').AsInteger;
        actNode.Pushs := FieldByName('Pushs').AsInteger;
        actNode.CRC32 := FieldByName('Act_CRC32').AsInteger;
        actNode.Moves_BK := FieldByName('Moves_BK').AsInteger;
        actNode.Pushs_BK := FieldByName('Pushs_BK').AsInteger;
        actNode.CRC32_BK := FieldByName('Act_CRC32_BK').AsInteger;
        actNode.Man_X := FieldByName('Man_X').AsInteger;
        actNode.Man_Y := FieldByName('Man_Y').AsInteger;

        StateList.Add(actNode);
        List_State.Items.Add(IntToStr(actNode.Pushs) + '/' + IntToStr(actNode.Moves) + #10 + ' [' + IntToStr(actNode.Man_X) + ',' + IntToStr(actNode.Man_Y) + ']' + IntToStr(actNode.Pushs_BK) + '/' + IntToStr(actNode.Moves_BK) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', actNode.DateTime));

        Next;
      end;

    end;

    DataModule1.ADOQuery1.Close;
  except
    FreeAndNil(actNode);
    Exit;
  end;

  actNode := nil;
  Result := True;
end;

// ������ - n=1�����ƹ��أ�n=2��������ϻ����ƹ���
function Tmain.SaveSolution(n: Integer): Boolean;
var
  sol: string;
  i, size, solCRC, k, m, p: Integer;
  solNode: ^TSoltionNode;
  
begin
  Result := False;

  // ����� CRC
  if n = 1 then begin      // ���ƹ���
     solCRC := Calcu_CRC_32_2(@UndoList, MoveTimes);
     m := MoveTimes;
     p := PushTimes;
  end else begin           // ���ƹ��ػ��������
     // ������ϻ����ƹ���ʱ�����Ѿ�����������
     // ����һ�� ManPath ��������صļ���
     for i := 1 to UnDoPos do begin
         ManPath[i] := UndoList[i];
     end;
     k := UnDoPos;
     for i := ReDoPos downto 1 do begin
         inc(k);
         ManPath[k] := RedoList[i];
     end;
     if k < MaxLenPath then ManPath[k+1] := #0;
     solCRC := Calcu_CRC_32_2(@ManPath, k);
     m := k;
     p := PushTimes;
     for i := 1 to ReDoPos do begin
         if RedoList[i] in [ 'L', 'R', 'U', 'D' ] then Inc(p);
     end;
  end;

  // ����
  i := 0;
  size := SoltionList.Count;
  while i < size do
  begin
    solNode := SoltionList[i];
    if (solNode.CRC32 = solCRC) and (solNode.Moves = m) and (solNode.Pushs = p) then
      Break;
    inc(i);
  end;
  solNode := nil;

  // ���ظ����ڱ�����𰸿�
  if i = size then
  begin
    if n = 1 then begin      // ���ƹ���
       if UnDoPos < MaxLenPath then UndoList[UnDoPos + 1] := #0;
       sol := PChar(@UndoList);
    end else begin           // ���ƹ��ػ��������
       sol := PChar(@ManPath);
    end;
    New(solNode);
    solNode.id := -1;
    solNode.DateTime := Now;
    solNode.Moves := m;
    solNode.Pushs := p;
    solNode.CRC32 := solCRC;

      // ���浽���ݿ�
    try
      DataModule1.ADOQuery1.Close;
      DataModule1.ADOQuery1.SQL.Clear;
      DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_Solution';
      DataModule1.ADOQuery1.Open;

      with DataModule1.ADOQuery1 do
      begin

        Append;    // �޸�

        FieldByName('XSB_CRC32').AsInteger := curMapNode.CRC32;
        FieldByName('XSB_CRC_TrunNum').AsInteger := curMapNode.CRC_Num;
        FieldByName('Goals').AsInteger := curMapNode.Goals;
        FieldByName('Sol_CRC32').AsInteger := solNode.CRC32;
        FieldByName('Moves').AsInteger := solNode.Moves;
        FieldByName('Pushs').AsInteger := solNode.Pushs;
        FieldByName('Sol_Text').AsString := sol;
        FieldByName('Sol_DateTime').AsDateTime := solNode.DateTime;

        Post;    // �ύ

      end;

      solNode.id := DataModule1.ADOQuery1.FieldByName('ID').AsInteger;
      DataModule1.ADOQuery1.Close;

      SoltionList.Add(solNode);
      List_Solution.Items.Add(IntToStr(p) + '/' + IntToStr(m) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', solNode.DateTime));
    except
      FreeAndNil(solNode);
      exit;
    end;

    Result := True;
  end;

  mySettings.isLurd_Saved := True;
  PageControl.ActivePageIndex := 0;
  if i < size then List_Solution.Selected[i] := True
  else List_Solution.Selected[List_Solution.Count - 1] := True;
  List_Solution.SetFocus;
  solNode := nil;
end;

// ���ش�
function Tmain.LoadSolution(): Boolean;
var
  solNode: ^TSoltionNode;
  str: string;

begin
  Result := False;

  SoltionList.Clear;
  List_Solution.Clear;

  // ����״̬�����ݿ�
  try
    DataModule1.ADOQuery1.Close;
    DataModule1.ADOQuery1.SQL.Clear;
    DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(curMapNode.CRC32) + ' and Goals = ' + IntToStr(curMapNode.Goals) + ' order by Moves, Pushs';
    DataModule1.ADOQuery1.Open;
    DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;

     // ׷��״̬
    with DataModule1.DataSource1.DataSet do
    begin
      First;

      while not Eof do begin
        New(solNode);
        solNode.id := FieldByName('ID').AsInteger;
        solNode.DateTime := FieldByName('Sol_DateTime').AsDateTime;
        solNode.Moves := FieldByName('Moves').AsInteger;
        solNode.Pushs := FieldByName('Pushs').AsInteger;
        solNode.CRC32 := FieldByName('Sol_CRC32').AsInteger;
        str           := FieldByName('Sol_Text').AsString;

        // ����֤
        if isSolution(curMapNode, PChar(str)) then begin
           SoltionList.Add(solNode);
           List_Solution.Items.Add(IntToStr(solNode.Pushs) + '/' + IntToStr(solNode.Moves) + #10 + FormatDateTime(' yyyy-mm-dd hh:nn', solNode.DateTime));
        end;
        
        Next;
      end;

    end;

    DataModule1.ADOQuery1.Close;
  except
    FreeAndNil(solNode);
    Exit;
  end;

  solNode := nil;
  Result := True;
end;

// ����һ�� -- ����
procedure Tmain.ReDo(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
  isPush, isOK, isMeet, IsCompleted: Boolean;

begin
  IsMoving := True;                                                       // �ƶ���...
  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;
  StatusBar1.Panels[7].Text := '';

  isMeet := False;
  IsCompleted := False;

  while (Steps > 0) and (ReDoPos > 0) and (UnDoPos < MaxLenPath) do begin

    if IsClick then begin
       IsClick := false;
       Break;
    end;

    ch := RedoList[ReDoPos];
    Dec(ReDoPos);

    Dec(Steps);

    pos1 := -1;
    pos2 := -1;
    case ch of
      'l', 'L':
        begin
          pos1 := ManPos - 1;
          pos2 := ManPos - 2;
          ch := 'l';
        end;
      'r', 'R':
        begin
          pos1 := ManPos + 1;
          pos2 := ManPos + 2;
          ch := 'r';
        end;
      'u', 'U':
        begin
          pos1 := ManPos - curMapNode.Cols;
          pos2 := ManPos - curMapNode.Cols * 2;
          ch := 'u';
        end;
      'd', 'D':
        begin
          pos1 := ManPos + curMapNode.Cols;
          pos2 := ManPos + curMapNode.Cols * 2;
          ch := 'd';
        end;
    end;

    isPush := false;       // ��Ĭ�Ϸ��ƶ�
    isOK := (pos1 >= 0) and (pos1 < curMap.MapSize);                       // ����λ��

        // �����ذ壬�����ƶ��˼��ɣ����������ӣ���Ҫͬʱ�ƶ����Ӻ��ˣ����������˴���ֱ�ӽ������ε��ƶ�
    if isOK and (map_Board[pos1] = FloorCell) then
      map_Board[pos1] := ManCell          // ��һ���ǵذ�
    else if isOK and (map_Board[pos1] = GoalCell) then
      map_Board[pos1] := ManGoalCell  // ��һ����Ŀ���
    else if isOK and (map_Board[pos1] = BoxCell) then
    begin                            // ��һ��������
      isOK := (pos2 >= 0) and (pos2 < curMap.MapSize);                      // ����λ��
      if isOK and (map_Board[pos2] = FloorCell) then
        map_Board[pos2] := BoxCell
      else if isOK and (map_Board[pos2] = GoalCell) then
        map_Board[pos2] := BoxGoalCell
      else
        Break;                              // �������󣬽���
      map_Board[pos1] := ManCell;
      isPush := true;                                                      // �ƶ���־
    end
    else if isOK and (map_Board[pos1] = BoxGoalCell) then
    begin                    // ��һ����������Ŀ���
      isOK := (pos2 >= 0) and (pos2 < curMap.MapSize);                      // ����λ��
      if isOK and (map_Board[pos2] = FloorCell) then
        map_Board[pos2] := BoxCell
      else if isOK and (map_Board[pos2] = GoalCell) then
        map_Board[pos2] := BoxGoalCell
      else
        Break;                              // �������󣬽���
      map_Board[pos1] := ManGoalCell;
      isPush := true;                                                      // �ƶ���־
    end
    else
      Break;                                 // �������󣬽���

    // �ָ���ԭ����λ��
    if map_Board[ManPos] = ManCell then
      map_Board[ManPos] := FloorCell
    else
      map_Board[ManPos] := GoalCell;

    if isPush then
    begin
      ch := Char(Ord(ch) - 32);                                // ��ɴ�д -- �ƶ�
      Inc(PushTimes);                                                      // �ƶ�����
    end;
    Inc(MoveTimes);                                                         // �ƶ�����

    Inc(UnDoPos);
    UndoList[UnDoPos] := ch;
    ManPos := pos1;                                                         // �˵���λ��

    if (not mySettings.isIM) and (not AotoRedo) then DrawMap();                                  // ���µ�ͼ��ʾ
    ShowStatusBar();
    StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos div curMapNode.Cols) + 1) + ' ]';       // ���

    if (Steps > 0) and (not AotoRedo) then GameDelay();                                          // ��ʱ

    if isPush and (PushTimes > 0) and (not AotoRedo) then begin                          // ��سɹ�
      if IsComplete() then
      begin
        IsCompleted := True;
        Break;
      end
      else if IsMeets(ch) then
      begin                  // �������
        isMeet := True;
        Break;
      end;
    end;
  end;

  if mySettings.isIM or AotoRedo then DrawMap();                                  // ���µ�ͼ��ʾ

  IsMoving := False;
  StatusBar1.Repaint;

  if IsCompleted then begin
    ReDoPos := 0;

    // �Զ�����һ�´�
    SaveSolution(1);          // ���ƹ���

    mySettings.isLurd_Saved := True;
    curMapNode.Solved := True;

    ShowMyInfo('���ƹ��أ�', '��ϲ');

  end else if isMeet then begin
    // �Զ�����һ�´�
    SaveSolution(2);          // �������
    ShowMyInfo('������ϣ�', '��ϲ');
  end else StatusBar1.Panels[7].Text := '';
end;

// ����һ�� -- ����
procedure Tmain.UnDo(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
begin
  IsMoving := True;                                                       // �ƶ���...
  IsBoxAccessibleTips := False;
  IsManAccessibleTips := False;
  StatusBar1.Panels[7].Text := '';

  while (Steps > 0) and (UnDoPos > 0) and (ReDoPos < MaxLenPath) do begin

    if IsClick then begin
       IsClick := false;
       Break;
    end;

    ch := UndoList[UnDoPos];
    Dec(UnDoPos);

    Dec(Steps);

    pos1 := -1;
    pos2 := -1;
    case ch of
      'l', 'L':
        begin
          pos1 := ManPos - 1;
          pos2 := ManPos + 1;
        end;
      'r', 'R':
        begin
          pos1 := ManPos + 1;
          pos2 := ManPos - 1;
        end;
      'u', 'U':
        begin
          pos1 := ManPos - curMapNode.Cols;
          pos2 := ManPos + curMapNode.Cols;
        end;
      'd', 'D':
        begin
          pos1 := ManPos + curMapNode.Cols;
          pos2 := ManPos - curMapNode.Cols;
        end;
    end;

    // UnDo ������������
    // �˵��˻�
    if map_Board[pos2] = FloorCell then
      map_Board[pos2] := ManCell
    else
      map_Board[pos2] := ManGoalCell;
    Dec(MoveTimes);                                                         // �ƶ�����

    // ����Ƿ�������ӵ��˻�
    if ch in ['L', 'R', 'U', 'D'] then
    begin
      Dec(PushTimes);                                                      // �ƶ�����
      if (map_Board[pos1] = BoxCell) then
        map_Board[pos1] := FloorCell
      else
        map_Board[pos1] := GoalCell;
      if (map_Board[ManPos] = ManCell) then
        map_Board[ManPos] := BoxCell
      else
        map_Board[ManPos] := BoxGoalCell;
    end
    else
    begin
      if (map_Board[ManPos] = ManCell) then
        map_Board[ManPos] := FloorCell
      else
        map_Board[ManPos] := GoalCell;
    end;

    inc(ReDoPos);
    RedoList[ReDoPos] := ch;
    ManPos := pos2;                                                         // �˵���λ��

    if (not mySettings.isIM)  and (not AotoRedo) then DrawMap();                                  // ���µ�ͼ��ʾ
    ShowStatusBar();
    StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos div curMapNode.Cols) + 1) + ' ]';       // ���

    if (Steps > 0) and (not AotoRedo) then GameDelay();                                          // ��ʱ

  end;

  if mySettings.isIM or AotoRedo then DrawMap();                                  // ���µ�ͼ��ʾ

  StatusBar1.Panels[7].Text := '';
  StatusBar1.Repaint;
  IsMoving := False;
end;

// ����һ�� -- ����
procedure Tmain.ReDo_BK(Steps: Integer);
var
  ch: Char;
  i, len, pos1, pos2, n: Integer;
  isOK, isMeet, IsCompleted: Boolean;
begin
  IsMoving := True;                                                       // �ƶ���...
  IsBoxAccessibleTips_BK := False;
  IsManAccessibleTips_BK := False;
  StatusBar1.Panels[7].Text := '';

  isMeet := False;
  IsCompleted := False;

  while (Steps > 0) and (ReDoPos_BK > 0) and (UnDoPos_BK < MaxLenPath) do begin

    if IsClick then begin
       IsClick := false;
       Break;
    end;

    ch := RedoList_BK[ReDoPos_BK];
    Dec(ReDoPos_BK);

    Dec(Steps);

    pos1 := -1;
    pos2 := -1;
    isOK := False;
    case ch of
      'l', 'L':
        begin
          isOK := (ManPos_BK mod curMapNode.Cols) > 0;
          pos1 := ManPos_BK - 1;
          pos2 := ManPos_BK + 1;
        end;
      'r', 'R':
        begin
          isOK := (ManPos_BK mod curMapNode.Cols) < curMapNode.Cols - 1;
          pos1 := ManPos_BK + 1;
          pos2 := ManPos_BK - 1;
        end;
      'u', 'U':
        begin
          isOK := (ManPos_BK div curMapNode.Cols) > 0;
          pos1 := ManPos_BK - curMapNode.Cols;
          pos2 := ManPos_BK + curMapNode.Cols;
        end;
      'd', 'D':
        begin
          isOK := (ManPos_BK div curMapNode.Cols) < curMapNode.Rows - 1;
          pos1 := ManPos_BK + curMapNode.Cols;
          pos2 := ManPos_BK - curMapNode.Cols;
        end;
    end;

    if isOK then
    begin
      if ch in [ 'L', 'R', 'U', 'D' ] then
      begin
        if (map_Board_BK[pos2] <> BoxCell) and (map_Board_BK[pos2] <> BoxGoalCell) or (map_Board_BK[pos1] <> FloorCell) and (map_Board_BK[pos1] <> GoalCell) then
          Break;    // ��������

        if (map_Board_BK[pos1] = FloorCell) then
          map_Board_BK[pos1] := ManCell          // ��һ���ǵذ�
        else if (map_Board_BK[pos1] = GoalCell) then
          map_Board_BK[pos1] := ManGoalCell;  // ��һ����Ŀ���
        if map_Board_BK[ManPos_BK] = ManCell then
          map_Board_BK[ManPos_BK] := BoxCell
        else
          map_Board_BK[ManPos_BK] := BoxGoalCell;
        if map_Board_BK[pos2] = BoxCell then
          map_Board_BK[pos2] := FloorCell
        else
          map_Board_BK[pos2] := GoalCell;
        Inc(PushTimes_BK);                                                     // �ƶ�����
      end
      else
      begin
                // �˵�λ
        if (map_Board_BK[pos1] = FloorCell) then
          map_Board_BK[pos1] := ManCell          // ��һ���ǵذ�
        else if (map_Board_BK[pos1] = GoalCell) then
          map_Board_BK[pos1] := ManGoalCell  // ��һ����Ŀ���
        else
          Break;                                                                     // ��������
        if map_Board_BK[ManPos_BK] = ManCell then
          map_Board_BK[ManPos_BK] := FloorCell
        else
          map_Board_BK[ManPos_BK] := GoalCell;
      end;

      Inc(MoveTimes_BK);                                                       // �ƶ�����

      Inc(UnDoPos_BK);
      UndoList_BK[UnDoPos_BK] := ch;
      ManPos_BK := pos1;                                                       // �˵���λ��

      if (not mySettings.isIM) and (not AotoRedo) then DrawMap();                                   // ���µ�ͼ��ʾ
      ShowStatusBar();
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos_BK mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos_BK div curMapNode.Cols) + 1) + ' ]';       // ���

      if (Steps > 0) and (not AotoRedo) then GameDelay();                                      // ��ʱ

      if (PushTimes_BK > 0) and (not AotoRedo) then begin                          // ��سɹ�
        if IsComplete_BK() then
        begin
          IsCompleted := True;
          Break;
        end
        else if IsMeets(ch) then
        begin                       // �������
          isMeet := True;
          Break;
        end;
      end;
    end;
  end;

  if mySettings.isIM or AotoRedo then DrawMap();                                  // ���µ�ͼ��ʾ

  IsMoving := False;
  StatusBar1.Repaint;

  if IsCompleted then begin

    ReDoPos_BK := 0;

    // ���ƴ�ת�浽����
    Restart(false);           // ���Ƶ�ͼ��λ
    ReDoPos := 0;

    // �������ƴ��У�ǰ�����õĿ��ƶ���
    n := 1;
    while n <= UnDoPos_BK do begin
      if UndoList_BK[n] in [ 'L', 'R', 'U', 'D' ] then Break;
      inc(n);
    end;


    for i := n to UnDoPos_BK do
    begin
      Inc(ReDoPos);
      case UndoList_BK[i] of
        'l':
          RedoList[ReDoPos] := 'r';
        'r':
          RedoList[ReDoPos] := 'l';
        'u':
          RedoList[ReDoPos] := 'd';
        'd':
          RedoList[ReDoPos] := 'u';
        'L':
          RedoList[ReDoPos] := 'R';
        'R':
          RedoList[ReDoPos] := 'L';
        'U':
          RedoList[ReDoPos] := 'D';
        'D':
          RedoList[ReDoPos] := 'U';
      end
    end;

    isOK := True;
    if ManPos <> ManPos_BK then
    begin
      len := myPathFinder.manTo(false, map_Board, ManPos, ManPos_BK);
      for i := len downto 1 do
      begin
        if ReDoPos = MaxLenPath then
        begin
          isOK := False;
          ReDoPos := 0;
          Break;
        end;
        Inc(ReDoPos);
        RedoList[ReDoPos] := ManPath[i];
      end;
    end;

    if isOK then begin
      // �Զ�����һ�´�
      SaveSolution(2);          // ���ƹ���
      ShowMyInfo('���ƹ��أ�', '��ϲ');
    end else
      ShowMyInfo('���ƹ��أ�' + #10 + '�𰸹���������ʧ�ܣ�', '��ϲ');

  end
  else if isMeet then begin
    // �Զ�����һ�´�
    SaveSolution(2);          // �������
    ShowMyInfo('������ϣ�', '��ϲ');
  end else StatusBar1.Panels[7].Text := '';
end;

// ����һ�� -- ����
procedure Tmain.UnDo_BK(Steps: Integer);
var
  ch: Char;
  pos1, pos2: Integer;
  isPush: Boolean;
begin
  IsMoving := True;                                                       // �ƶ���...
  IsBoxAccessibleTips_BK := False;
  IsManAccessibleTips_BK := False;
  StatusBar1.Panels[7].Text := '';

  while (Steps > 0) and (UnDoPos_BK > 0) and (ReDoPos_BK < MaxLenPath) do begin

    if IsClick then begin
       IsClick := false;
       Break;
    end;

    ch := UndoList_BK[UnDoPos_BK];
    Dec(UnDoPos_BK);

    Dec(Steps);

    isPush := False;

    pos1 := -1;
    pos2 := -1;
    case ch of
      'l', 'L':
        begin
          pos1 := ManPos_BK + 1;
          pos2 := ManPos_BK + 2;
          isPush := (ch = 'L');
        end;
      'r', 'R':
        begin
          pos1 := ManPos_BK - 1;
          pos2 := ManPos_BK - 2;
          isPush := (ch = 'R');
        end;
      'u', 'U':
        begin
          pos1 := ManPos_BK + curMapNode.Cols;
          pos2 := ManPos_BK + curMapNode.Cols * 2;
          isPush := (ch = 'U');
        end;
      'd', 'D':
        begin
          pos1 := ManPos_BK - curMapNode.Cols;
          pos2 := ManPos_BK - curMapNode.Cols * 2;
          isPush := (ch = 'D');
        end;
    end;

    // UnDo ������������
    // ����Ƿ�������ӵ��˻�
    if isPush then
    begin
      Dec(PushTimes_BK);                                                   // �ƶ�����
      if (map_Board_BK[pos2] = FloorCell) then
        map_Board_BK[pos2] := BoxCell
      else
        map_Board_BK[pos2] := BoxGoalCell;
      if map_Board_BK[pos1] = BoxCell then
        map_Board_BK[pos1] := ManCell
      else
        map_Board_BK[pos1] := ManGoalCell;
    end
    else
    begin
      if (map_Board_BK[pos1] = FloorCell) then
        map_Board_BK[pos1] := ManCell
      else
        map_Board_BK[pos1] := ManGoalCell;
    end;

        // �˵��˻�
    if (map_Board_BK[ManPos_BK] = ManCell) then
      map_Board_BK[ManPos_BK] := FloorCell
    else
      map_Board_BK[ManPos_BK] := GoalCell;
    Dec(MoveTimes_BK);                                                      // �ƶ�����

    Inc(ReDoPos_BK);
    RedoList_BK[ReDoPos_BK] := ch;
    ManPos_BK := pos1;                                                      // �˵���λ��

    if (not mySettings.isIM) and (not AotoRedo) then DrawMap();                                  // ���µ�ͼ��ʾ
    ShowStatusBar();
    StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr((ManPos_BK mod curMapNode.Cols) + 1) + ', ' + IntToStr((ManPos_BK div curMapNode.Cols) + 1) + ' ]';       // ���

    if (Steps > 0) and (not AotoRedo) then GameDelay();                                          // ��ʱ

  end;

  if mySettings.isIM or AotoRedo then DrawMap();                                  // ���µ�ͼ��ʾ

  StatusBar1.Panels[7].Text := '';
  StatusBar1.Repaint;
  IsMoving := False;
end;

// ��һ��
procedure Tmain.bt_PreClick(Sender: TObject);
var
  bt: LongWord;
begin
  if curMap.CurrentLevel > 1 then
  begin
    if not mySettings.isLurd_Saved then
    begin    // ���µĶ�����δ����
      bt := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴����µ��ƶ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
      if bt = idyes then begin
         SaveState();          // ����״̬�����ݿ�
      end else if bt = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '������������';
      end else exit;
    end;

    Dec(curMap.CurrentLevel);
    if LoadMap(curMap.CurrentLevel) then
    begin
      InitlizeMap();
      SetMapTrun();
    end;
  end
  else
    StatusBar1.Panels[7].Text := 'ǰ��û����!';
end;

// ��һ��
procedure Tmain.bt_NextClick(Sender: TObject);
var
  bt: LongWord;
begin
  if curMap.CurrentLevel < MapList.Count then
  begin
    if not mySettings.isLurd_Saved then
    begin    // ���µĶ�����δ����
      bt := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴����µ��ƶ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
      if bt = idyes then begin
         SaveState();          // ����״̬�����ݿ�
      end else if bt = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '������������';
      end else exit;
    end;
    Inc(curMap.CurrentLevel);
    if LoadMap(curMap.CurrentLevel) then
    begin
      InitlizeMap();
      SetMapTrun();
    end;
  end
  else
    StatusBar1.Panels[7].Text := '����û����!';
end;

// UnDo ��ť
procedure Tmain.bt_UnDoClick(Sender: TObject);
begin
  if mySettings.isBK then
  begin
    UnDo_BK(GetStep(mySettings.isBK));
  end
  else
  begin
    if (LastSteps < 0) or (LastSteps > UnDoPos) then
      UnDo(GetStep2(mySettings.isBK))
    else
      UnDo(UnDoPos - LastSteps);
    LastSteps := -1;              // �������һ�ε���ǰ�Ĳ���
  end;
end;

// ReDo��ť
procedure Tmain.bt_ReDoClick(Sender: TObject);
begin
  if mySettings.isBK then
    ReDo_BK(GetStep2(mySettings.isBK))
  else
    ReDo(GetStep(mySettings.isBK));
end;

// ��Խ����
procedure Tmain.bt_GoThroughClick(Sender: TObject);
begin
  mySettings.isGoThrough := not mySettings.isGoThrough;
  myPathFinder.setThroughable(mySettings.isGoThrough);
  SetButton();             // ���ð�ť״̬
end;

// ˲�ƿ���
procedure Tmain.bt_IMClick(Sender: TObject);
begin
  mySettings.isIM := not mySettings.isIM;
  SetButton();             // ���ð�ť״̬
end;

// ����ģʽ����
procedure Tmain.bt_BKClick(Sender: TObject);
begin
  IsClick := True;
  isYanshi := false;
  StatusBar1.Panels[7].Text := '';
  mySettings.isBK := not mySettings.isBK;
  DrawMap();
  SetButton();             // ���ð�ť״̬
  if curMapNode.Cols > 0 then
  begin
    if mySettings.isBK then
    begin
      if ManPos_BK < 0 then
        StatusBar1.Panels[5].Text := ' '
      else
        StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos_BK mod curMapNode.Cols, ManPos_BK div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos_BK mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos_BK div curMapNode.Cols + 1) + ' ]'       // ���
    end
    else
      StatusBar1.Panels[5].Text := ' ' + GetCur(ManPos mod curMapNode.Cols, ManPos div curMapNode.Cols) + ' - [ ' + IntToStr(ManPos mod curMapNode.Cols + 1) + ', ' + IntToStr(ManPos div curMapNode.Cols + 1) + ' ]';       // ���
  end;
end;

// ���عؿ��ĵ��Ի���
procedure Tmain.bt_OpenClick(Sender: TObject);
var
  bt: LongWord;
  i, size: Integer;

begin
  if not mySettings.isXSB_Saved then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴浼��Ĺؿ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then
    begin
      SaveXSBToFile();
    end
    else if bt = idno then
    begin
    end
    else
      Exit;
  end;

  if not mySettings.isLurd_Saved then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴����µ��ƶ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then begin
       SaveState();          // ����״̬�����ݿ�
    end else if bt = idno then begin
       mySettings.isLurd_Saved := True;
       StatusBar1.Panels[7].Text := '������������';
    end else exit;
  end;

  if (ExtractFilePath(mySettings.MapFileName) <> '') then
    dlgOpen1.InitialDir := ExtractFilePath(mySettings.MapFileName)
  else
    dlgOpen1.InitialDir := AppPath;

  dlgOpen1.FileName := '';
  if dlgOpen1.Execute then
  begin
    if LoadMaps(dlgOpen1.FileName) then
    begin
      if MapList.Count > 0 then
      begin   // ����������Ч�ؿ����Զ��򿪵�һ���ؿ�
        mySettings.MapFileName := dlgOpen1.FileName;
        mySettings.LaterList.Insert(0, mySettings.MapFileName);
        size := mySettings.LaterList.Count;
        i := 1;
        while i < size do begin
            if mySettings.LaterList[i] = mySettings.MapFileName then begin
               mySettings.LaterList.Delete(i);
               Break;
            end else inc(i);
        end;
        if mySettings.LaterList.Count > 10 then mySettings.LaterList.Delete(10);

        mySettings.isXSB_Saved := True;
        if LoadMap(1) then
        begin
          curMapNode.Trun := 0;    // Ĭ�Ϲؿ��� 0 ת
          SetMapTrun();
          InitlizeMap();
        end;
      end;
      StatusBar1.Panels[7].Text := '';
    end else StatusBar1.Panels[7].Text := '�ؿ����ĵ�����ʧ�� - ' + dlgOpen1.FileName;
  end;
end;

// ͸��ͼ����
procedure Tmain.MyDraw();
var
  bf: BLENDFUNCTION;
  desBmp, srcBmp: TBitmap;
  rgn: HRGN;
begin
  with bf do
  begin
    BlendOp := AC_SRC_OVER;
    BlendFlags := 0;
    AlphaFormat := 0;
    SourceConstantAlpha := 240;    // ͸���ȣ�0~255
  end;

  desBmp := TBitmap.Create;
  srcBmp := TBitmap.Create;

  try
    srcBmp.Assign(map_Image.Picture.Bitmap);

    desBmp.Width := srcBmp.Width;
    desBmp.Height := srcBmp.Height;

    Windows.AlphaBlend(desBmp.Canvas.Handle, 0, 0, desBmp.Width, desBmp.Height, srcBmp.Canvas.Handle, 0, 0, srcBmp.Width, srcBmp.Height, bf);

    rgn := CreateEllipticRgn(50, 50, 200, 200);    // ����һ��Բ������
    SelectClipRgn(srcBmp.Canvas.Handle, rgn);
    srcBmp.Canvas.Draw(0, 0, desBmp);

    map_Image.Picture.Bitmap.Assign(nil);
    map_Image.Picture.Bitmap.Assign(srcBmp);
  finally
    FreeAndNil(desBmp);
    FreeAndNil(srcBmp);
  end;
end;

// ����Ƥ���Ի���
procedure Tmain.bt_SkinClick(Sender: TObject);
begin
  if LoadSkinForm.ShowModal = mrOK then
  begin
    mySettings.SkinFileName := LoadSkinForm.SkinFileName;
    if not LoadSkinForm.LoadSkin(AppPath + 'Skins\' + mySettings.SkinFileName) then
    begin
      LoadSkinForm.LoadDefaultSkin();         // ʹ��Ĭ�ϵļ�Ƥ��
    end;
    DrawMap();
  end;
end;

// ��ʾ��ż��Ч
procedure Tmain.bt_OddEvenMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mySettings.isOddEven := true;
  DrawMap();
end;

// �ر���ż��Ч
procedure Tmain.bt_OddEvenMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  mySettings.isOddEven := false;
  DrawMap();
end;

procedure Tmain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(myPathFinder);
end;

// �������� reDo �����ڵ� -- ÿ��һ������Ϊһ������
function Tmain.GetStep(is_BK: Boolean): Integer;
var
  i, j, k, n, len: Integer;
  mAct: Char;
  boxRC: array[0..1] of Integer;
  flg: Boolean;
begin
  if is_BK then
    len := UnDoPos_BK
  else
    len := ReDoPos;

  if GoalNumber = 1 then
  begin
    result := len;
    exit;
  end;

  i := 0;
  j := 0;

  boxRC[0] := 1000;
  boxRC[1] := 1000;

    // Ѱ�Ҷ����ڵ�
  n := 0;  // Ӧ��ͣ�ڵڼ���������
  flg := false;

  k := len;
  while k > 0 do
  begin

    if is_BK then
      mAct := UndoList_BK[k]
    else
      mAct := RedoList[k];

    Dec(k);

    case (mAct) of
      'l':
        Dec(j);      // ����
      'u':
        Dec(i);      // ����
      'r':
        Inc(j);      // ����
      'd':
        Inc(i);      // ����
      'L':
        begin        // ����
          Dec(j);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��

          boxRC[0] := i;
          boxRC[1] := j - 1;
        end;
      'U':
        begin        // ����
          Dec(i);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��

          boxRC[0] := i - 1;
          boxRC[1] := j;
        end;
      'R':
        begin        // ����
          Inc(j);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��

          boxRC[0] := i;
          boxRC[1] := j + 1;
        end;
      'D':
        begin        // ����
          Inc(i);

          if (boxRC[0] <> i) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��

          boxRC[0] := i + 1;
          boxRC[1] := j;
        end;
    end;
  end;
  if flg then
    result := len - n  // ���һ�����������ƣ���ǰ�����ƵĶ���ʱ
  else
    result := len;  // ʣ���ȫ������
end;

// �������� unDo �����ڵ� -- ÿ��һ������Ϊһ������
function Tmain.GetStep2(is_BK: Boolean): Integer;
var
  i, j, k, n, len: Integer;
  mAct: Char;
  boxRC: array[0..1] of Integer;
  flg: Boolean;
begin
  if is_BK then
    len := ReDoPos_BK
  else
    len := UnDoPos;

  if GoalNumber = 1 then
  begin
    result := len;
    exit;
  end;

  i := 0;
  j := 0;

  boxRC[0] := 1000;
  boxRC[1] := 1000;

    // Ѱ�Ҷ����ڵ�
  n := 0;  // Ӧ��ͣ�ڵڼ���������
  flg := false;

  k := len;
  while k > 0 do
  begin

    if is_BK then
      mAct := RedoList_BK[k]
    else
      mAct := UndoList[k];

    Dec(k);

    case (mAct) of
      'l':
        Dec(j);      // ����
      'u':
        Dec(i);      // ����
      'r':
        Inc(j);      // ����
      'd':
        Inc(i);      // ����
      'L':
        begin        // ����
          if (boxRC[0] <> i) or (boxRC[1] <> j + 1) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��
          boxRC[0] := i;
          boxRC[1] := j;
          Dec(j);
        end;
      'U':
        begin        // ����
          if (boxRC[0] <> i + 1) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��
          boxRC[0] := i;
          boxRC[1] := j;
          Dec(i);
        end;
      'R':
        begin        // ����
          if (boxRC[0] <> i) or (boxRC[1] <> j - 1) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��
          boxRC[0] := i;
          boxRC[1] := j;
          Inc(j);
        end;
      'D':
        begin        // ����
          if (boxRC[0] <> i - 1) or (boxRC[1] <> j) then
          begin
            if flg then
              break;   // �ڶ�������
            flg := true;         // ��һ������
          end;
          n := k;                  // ��һ�����ӵ����λ��
          boxRC[0] := i;
          boxRC[1] := j;
          Inc(i);
        end;
    end;
  end;
  if flg then
    result := len - n  // ���һ�����������ƣ���ǰ�����ƵĶ���ʱ
  else
    result := len;
end;

procedure Tmain.pnl_TrunMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
    if (curMapNode = nil) or (curMapNode.Map.Count = 0) then Exit;
    
    case Button of
      mbleft:
        begin     // ���� -- ָ���
          if curMapNode.Trun < 7 then
            inc(curMapNode.Trun)
          else
            curMapNode.Trun := 0;    // �� 0 ת
        end;
      mbright:
        begin    // �һ� -- ָ�Ҽ�
          if curMapNode.Trun > 0 then
            dec(curMapNode.Trun)
          else
            curMapNode.Trun := 7;    // �� 0 ת
        end;
    end;
    SetMapTrun();
    curMapNode.Trun := curMapNode.Trun;
end;

procedure Tmain.SetMapTrun();
begin
  pnl_Trun.Caption := MapTrun[curMapNode.Trun];
  NewMapSize();
  DrawMap();       // ����ͼ
end;

procedure Tmain.pnl_SpeedMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  case Button of
    mbleft:
      begin     // ���� -- ָ���
        if mySettings.mySpeed > 0 then
          dec(mySettings.mySpeed)
      end;
    mbright:
      begin    // �һ� -- ָ�Ҽ�
        if mySettings.mySpeed < 4 then
          inc(mySettings.mySpeed)
      end;
  end;
  pnl_Speed.Caption := SpeedInf[mySettings.mySpeed];
end;

// ����ؿ� XSB ���ĵ�
function Tmain.SaveXSBToFile(): Boolean;
var
  myXSBFile: Textfile;
  myFileName, myExtName: string;
  i, j, size: Integer;
  mapNode: PMapNode;               // �ؿ��ڵ�

begin
  Result := False;
  StatusBar1.Panels[7].Text := '';

  if (ExtractFilePath(mySettings.MapFileName) <> '') then
    dlgSave1.InitialDir := ExtractFilePath(mySettings.MapFileName)
  else
    dlgSave1.InitialDir := AppPath;

  dlgSave1.FileName := '';
  if dlgSave1.Execute then
  begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
      myFileName := changefileext(myFileName, '.xsb');

    AssignFile(myXSBFile, myFileName);
    ReWrite(myXSBFile);

    for i := 0 to MapList.Count - 1 do
    begin
      mapNode := MapList.Items[i];

      Writeln(myXSBFile, '');
      for j := 0 to mapNode.Map.Count - 1 do
      begin
        Writeln(myXSBFile, mapNode.Map[j]);
      end;
      if Trim(mapNode.Title) <> '' then
        Writeln(myXSBFile, 'Title: ' + mapNode.Title);
      if Trim(mapNode.Author) <> '' then
        Writeln(myXSBFile, 'Author: ' + mapNode.Author);
      if Trim(mapNode.Comment) <> '' then
      begin
        Writeln(myXSBFile, 'Comment: ');
        Writeln(myXSBFile, mapNode.Comment);
        Writeln(myXSBFile, 'Comment_end: ');
      end;
    end;

    Closefile(myXSBFile);

    mySettings.MapFileName := myFileName;
    mySettings.isXSB_Saved := True;            // ���Ӽ��а嵼��� XSB �Ƿ񱣴����

    mySettings.LaterList.Insert(0, mySettings.MapFileName);
    size := mySettings.LaterList.Count;
    i := 1;
    while i < size do begin
        if mySettings.LaterList[i] = mySettings.MapFileName then begin
           mySettings.LaterList.Delete(i);
           break;
        end else inc(i);
    end;
    if mySettings.LaterList.Count > 10 then mySettings.LaterList.Delete(10);

    Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
    Result := True;
  end;
end;

procedure Tmain.bt_ViewClick(Sender: TObject);
begin
  BrowseForm.Tag := -1;        // ˫�� item ʱ����ֵΪ 0
  BrowseForm.BK_Color := mySettings.bwBKColor;
  BrowseForm.ShowModal;
  mySettings.bwBKColor := BrowseForm.BK_Color;
  if BrowseForm.Tag < 0 then Exit;

  isYanshi := False;
  curMap.CurrentLevel := BrowseForm.ListView1.ItemIndex + 1;
  if LoadMap(curMap.CurrentLevel) then begin
    InitlizeMap();
    SetMapTrun();
  end;

end;

procedure Tmain.bt_ActClick(Sender: TObject);
var
  i, RepTimes, n: Integer;
  ch: Char;

begin
  // �������� -- �Ƿ����ơ�Ĭ��·��
  ActionForm.isBK := mySettings.isBK;
  if (ExtractFilePath(mySettings.MapFileName) <> '') then
    ActionForm.MyPath := ExtractFilePath(mySettings.MapFileName)
  else
    ActionForm.MyPath := AppPath;
    
  ActionForm.ExePath := AppPath;

  isYanshi := False;
  
  ActionForm.ShowModal;

  if ActionForm.Tag = 1 then begin
  
     RepTimes := ActionForm.Rep_Times.Value;          // �ظ�����

     // ����ʱ����Ҫ�����˵ĳ�ʼλ��
     if not ActionForm.Run_CurPos.Checked then begin  // �ӵ�ǰ��ִ��
        if mySettings.isBK then begin
           if ManPos_BK < 0 then begin
              if (ActionForm.M_X < 0) or (ActionForm.M_Y < 0) or (ActionForm.M_X >= curMapNode.Cols) or (ActionForm.M_Y >= curMapNode.Rows) or
                 (not (map_Board_BK[ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X] in [ FloorCell, GoalCell ])) then begin
                 MessageBox(handle, '�˵ĳ�ʼλ�ò���ȷ��', '����', MB_ICONERROR or MB_OK);
                 Exit;
              end;

              // ��λ�÷����� 
              ManPos_BK := ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X;
              ManPos_BK_0 := ManPos_BK;
              if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
              else map_Board_BK[ManPos_BK] := ManGoalCell;
           end;
        end;
     end else begin
        Restart(mySettings.isBK);
        if mySettings.isBK then begin
        
           if (ActionForm.M_X < 0) or (ActionForm.M_Y < 0) or (ActionForm.M_X >= curMapNode.Cols) or (ActionForm.M_Y >= curMapNode.Rows) or
              (not (map_Board_BK[ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X] in [ FloorCell, GoalCell, ManCell, ManGoalCell ])) then begin

              if ManPos_BK < 0 then begin
                 MessageBox(handle, '�˵ĳ�ʼλ�ò���ȷ��', '����', MB_ICONERROR or MB_OK);
                 Exit;
              end;
           end;

           // ���ص��˵�λ����ȷ��������ԭ�����˵�λ��
           if ManPos_BK >= 0 then begin
              if map_Board_BK[ManPos_BK] = ManCell then map_Board_BK[ManPos_BK] := FloorCell
              else map_Board_BK[ManPos_BK] := GoalCell;
           end;

           // ��λ�÷�����
           ManPos_BK := ActionForm.M_Y * curMapNode.Cols + ActionForm.M_X;
           ManPos_BK_0 := ManPos_BK;
           if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
           else map_Board_BK[ManPos_BK] := ManGoalCell;
        end;
     end;

     GetLurd(ActionForm.Act, mySettings.isBK);

     // ���ֳ���תת�� redo �еĶ���
     if ActionForm.Run_CurTru.Checked then begin
        if mySettings.isBK then begin
           for i := 1 to ReDoPos_BK do begin
               ch := RedoList_BK[i];
               case ch of
                 'l': ch := ActDir[curMapNode.Trun, 0];
                 'u': ch := ActDir[curMapNode.Trun, 1];
                 'r': ch := ActDir[curMapNode.Trun, 2];
                 'd': ch := ActDir[curMapNode.Trun, 3];
                 'L': ch := ActDir[curMapNode.Trun, 4];
                 'U': ch := ActDir[curMapNode.Trun, 5];
                 'R': ch := ActDir[curMapNode.Trun, 6];
                 'D': ch := ActDir[curMapNode.Trun, 7];
               end;
               RedoList_BK[i] := ch;
           end;
        end else begin
           for i := 1 to ReDoPos do begin
               ch := RedoList[i];
               case ch of
                 'l': ch := ActDir[curMapNode.Trun, 0];
                 'u': ch := ActDir[curMapNode.Trun, 1];
                 'r': ch := ActDir[curMapNode.Trun, 2];
                 'd': ch := ActDir[curMapNode.Trun, 3];
                 'L': ch := ActDir[curMapNode.Trun, 4];
                 'U': ch := ActDir[curMapNode.Trun, 5];
                 'R': ch := ActDir[curMapNode.Trun, 6];
                 'D': ch := ActDir[curMapNode.Trun, 7];
               end;
               RedoList[i] := ch;
           end;
        end;
     end;

     if mySettings.isBK then begin
        n := ReDoPos_BK;
     end else begin
        n := ReDoPos;
     end;
     // ִ�д���
     for i := 1 to RepTimes do begin
         if mySettings.isBK then begin
            ReDoPos_BK := n;
            ReDo_BK(ReDoPos_BK);
         end else begin
            ReDoPos := n;
            ReDo(ReDoPos);
         end;
     end;
     if mySettings.isBK then begin
        ReDoPos_BK := 0;
     end else begin
        ReDoPos := 0;
     end;
  end;
end;

procedure Tmain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  bt: LongWord;
begin
  CanClose := True;
  if not IsClick then IsClick := True;

  if not mySettings.isXSB_Saved then
  begin    // ���µ�XSB��δ����
    bt := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴浼��Ĺؿ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then
    begin
      SaveXSBToFile();
    end
    else if bt = idno then
    begin
      mySettings.isXSB_Saved := True;
    end
    else
      CanClose := False;
  end;

  if CanClose and (not mySettings.isLurd_Saved) then
  begin    // ���µĶ�����δ����
    bt := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴����µ��ƶ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
    if bt = idyes then
    begin
      mySettings.isLurd_Saved := True;
      SaveState();          // ����״̬�����ݿ�
    end
    else if bt = idno then
    begin
      mySettings.isLurd_Saved := True;
    end
    else
      CanClose := False;
  end;

end;

procedure Tmain.List_SolutionDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  lpstr: PChar;
  c: integer;
begin
  with Control as TListBox do
  begin
    Canvas.FillRect(Rect);
    c := length(items[Index]);
    lpstr := PChar(Items[Index]);
    drawtext(Canvas.Handle, lpstr, c, Rect, DT_WORDBREAK);
  end;
end;

procedure Tmain.List_SolutionMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
var
  lpstr: PChar;
  c, h: integer;
  tc: TRect;
begin

  with Control as TListBox do
  begin
    c := length(items[Index]);
    lpstr := PChar(Items[Index]);
    tc := clientrect;
    h := drawtext(Canvas.Handle, lpstr, c, tc, DT_CALCRECT or DT_WORDBREAK);
  end;

  Height := h + 4;
end;

// ����Ŀ��λ�л�
procedure Tmain.pmGoalClick(Sender: TObject);
begin
  mySettings.isSameGoal := not mySettings.isSameGoal;
  if mySettings.isSameGoal then
    pmGoal.Checked := True
  else
    pmGoal.Checked := False;
  DrawMap();                                  // ���µ�ͼ��ʾ
  ShowStatusBar();
end;

// ����Ŀ��λ�л�
procedure Tmain.pmJijingClick(Sender: TObject);
begin
  if mySettings.isBK then
    mySettings.isJijing_BK := not mySettings.isJijing_BK
  else
    mySettings.isJijing := not mySettings.isJijing;

  DrawMap();                                  // ���µ�ͼ��ʾ
  ShowStatusBar();
end;

// ˫�����б���ش�
procedure Tmain.List_SolutionDblClick(Sender: TObject);
var
  s: string;
  i, len: Integer;

begin
    StatusBar1.Panels[7].Text := '';
    StatusBar1.Repaint;

    if not mySettings.isLurd_Saved then
    begin    // ���µĶ�����δ����
      i := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴����µ��ƶ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
         SaveState();          // ����״̬�����ݿ�
         PageControl.ActivePageIndex := 0;
      end else if i = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '������������';
      end else exit;
    end;
    
    if GetSolutionFromDB(List_Solution.ItemIndex, s) then begin

       len := Length(s);

       if len > 0 then begin
           Restart(False);

           // ���������Ƶ� RedoList
           ReDoPos := 0;
           for i := len downto 1 do begin
               if ReDoPos = MaxLenPath then Exit;
               inc(ReDoPos);
               RedoList[ReDoPos] := s[i];
           end;
       end;
       StatusBar1.Panels[7].Text := '�������룡';
       StatusBar1.Repaint;
    end;
end;

procedure Tmain.List_StateDblClick(Sender: TObject);
var
  s1, s2: string;
  i, len, x, y, id, n: Integer;
  actNode: ^TStateNode;

begin
    StatusBar1.Panels[7].Text := '';
    StatusBar1.Repaint;

    n := List_State.ItemIndex;

    if not mySettings.isLurd_Saved then
    begin    // ���µĶ�����δ����
      i := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴����µ��ƶ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
      if i = idyes then begin
         actNode := StateList[n];
         id := actNode.id;
         SaveState();          // ����״̬�����ݿ�
         len := StateList.Count;
         for x := 0 to len-1 do begin
             actNode := StateList[x];
             if id = actNode.id then begin
                n := x;
                List_State.Selected[n] := True;
             end;
         end;
      end else if i = idno then begin
         mySettings.isLurd_Saved := True;
         StatusBar1.Panels[7].Text := '������������';
      end else exit;
    end;

    if GetStateFromDB(n, x, y, s1, s2) then begin
  
       Restart(False);                 // �ؿ���λ
       Restart(True);                  // �ؿ���λ

       len := Length(s1);

       // ״̬���� RedoList
       if len > 0 then begin
           ReDoPos := 0;
           for i := len downto 1 do begin
               if ReDoPos = MaxLenPath then Exit;
               inc(ReDoPos);
               RedoList[ReDoPos] := s1[i];
           end;
               
           AotoRedo := True;
           ReDo(len);
           AotoRedo := False;
       end;

       len := Length(s2);

       // ״̬���� RedoList_BK
       if (len > 0) and (x > 0) and (y > 0) then begin

           if ManPos_BK >= 0 then begin
              if map_Board_BK[ManPos_BK] = ManCell then map_Board_BK[ManPos_BK] := FloorCell
              else map_Board_BK[ManPos_BK] := GoalCell;
           end;

           ManPos_BK := y * curMapNode.Cols + x;

           if map_Board_BK[ManPos_BK] = FloorCell then map_Board_BK[ManPos_BK] := ManCell
           else if map_Board_BK[ManPos_BK] = GoalCell then map_Board_BK[ManPos_BK] := ManGoalCell
           else Exit;

           ManPos_BK_0 := ManPos_BK;
               
           ReDoPos_BK := 0;
           for i := len downto 1 do begin
               if ReDoPos_BK = MaxLenPath then Exit;
               inc(ReDoPos_BK);
               RedoList_BK[ReDoPos_BK] := s2[i];
           end;

           AotoRedo := True;
           ReDo_BK(len);
           AotoRedo := False;
       end;
       StatusBar1.Panels[7].Text := '״̬�����룡';
       StatusBar1.Repaint;
    end;
end;

// �Ӵ𰸿����һ��״̬
function Tmain.GetStateFromDB(index: Integer; var x: Integer; var y: Integer; var str1: string; var str2: string): Boolean;
var
  actNode: ^TStateNode;
  
begin

  Result := False;

  if index < 0 then Exit;

  try
  
    actNode := StateList[index];

    DataModule1.ADOQuery1.Close;
    DataModule1.ADOQuery1.SQL.Text := 'select Act_Text, Act_Text_BK, Man_X, Man_Y from Tab_State where id = ' + IntToStr(actNode.id);
    DataModule1.ADOQuery1.Open;
    DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;                           

    actNode := nil;

    with DataModule1.DataSource1.DataSet do begin
        First;

        if not Eof then begin
           str1 := FieldByName('Act_Text').AsString;     // ��ȡ״̬
           str2 := FieldByName('Act_Text_BK').AsString;
           x    := FieldByName('Man_X').AsInteger;
           y    := FieldByName('Man_Y').AsInteger;
        end;
    end;
  except
  end;

  DataModule1.ADOQuery1.Close;
  Result := True;
end;

// �Ӵ𰸿����һ����
function Tmain.GetSolutionFromDB(index: Integer; var str: string): Boolean;
var
  solNode: ^TSoltionNode;

begin
    Result := False;

    if index < 0 then Exit;

    try       // ���ش�
    
      solNode := SoltionList[index];

      DataModule1.ADOQuery1.Close;
      DataModule1.ADOQuery1.SQL.Text := 'select Sol_Text from Tab_Solution where id = ' + IntToStr(solNode.id);
      DataModule1.ADOQuery1.Open;
      DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;

      solNode := nil;

      with DataModule1.DataSource1.DataSet do begin
          First;

          if not Eof then begin
             str := FieldByName('Sol_Text').AsString;     // ��ȡ��
          end;
      end;
    Except
    end;

    DataModule1.ADOQuery1.Close;
    Result := True;
end;

// ״̬ -- ���� Lurd �����а�
procedure Tmain.sa_LurdClick(Sender: TObject);
var
  s1, s2: string;
  len, x, y: Integer;
  
begin
   if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      len := Length(s1);
      if len > 0 then begin
         Clipboard.SetTextBuf(PChar(s1));
         StatusBar1.Panels[7].Text := '���� Lurd �����а壡';
      end else StatusBar1.Panels[7].Text := '�������� Lurd ʧ�ܣ�';
   end;
end;

// ״̬ -- ���� Lurd �����а�
procedure Tmain.sa_Lurd_BKClick(Sender: TObject);
var
  s1, s2: string;
  len, x, y: Integer;

begin
   if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      len := Length(s2);
      if (len > 0) and (x > 0) and (y > 0) then begin
         Clipboard.SetTextBuf(PChar('[' + IntToStr(x) + ', ' + IntToStr(y) + ']' + s2));
         StatusBar1.Panels[7].Text := '���� Lurd �����а壡';
      end else StatusBar1.Panels[7].Text := '�������� Lurd ʧ�ܣ�';
   end;
end;

// ״̬ -- XSB + Lurd �����а�
procedure Tmain.sa_XSB_LurdClick(Sender: TObject);
var
  s, s1, s2: string;
  len, x, y: Integer;

begin
   if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      s := GetXSB();
      
      len := Length(s1);
      if len > 0 then s := s + s1;

      len := Length(s2);
      if (len > 0) and (x > 0) and (y > 0) then Clipboard.SetTextBuf(PChar(s+#10+'[' + IntToStr(x) + ', ' + IntToStr(y) + ']' + s2))
      else Clipboard.SetTextBuf(PChar(s));

      StatusBar1.Panels[7].Text := 'XSB + Lurd �����а壡';
   end;
end;

// ״̬ -- XSB + Lurd ���ĵ�
procedure Tmain.sa_XSB_Lurd_FileClick(Sender: TObject);
var
  myXSBFile: Textfile;
  myFileName, myExtName, s1, s2: string;
  x, y, len: Integer;

begin
  dlgSave1.InitialDir := AppPath;
  dlgSave1.FileName := '';

  if dlgSave1.Execute then begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
      myFileName := changefileext(myFileName, '.txt');

    AssignFile(myXSBFile, myFileName);
    ReWrite(myXSBFile);

    Write(myXSBFile, GetXSB());

    if GetStateFromDB(List_State.ItemIndex, x, y, s1, s2) then begin
      
      len := Length(s1);
      if len > 0 then Write(myXSBFile, s1 + #10);

      len := Length(s2);
      if (len > 0) and (x > 0) and (y > 0) then Write(myXSBFile, PChar('[' + IntToStr(x) + ', ' + IntToStr(y) + ']' + s2 + #10));

      StatusBar1.Panels[7].Text := 'XSB + Lurd ���ĵ���';
    end;

    Closefile(myXSBFile);
  end;
end;

// ״̬ -- ɾ��һ��
procedure Tmain.sa_DeleteClick(Sender: TObject);
var
  actNode: ^TStateNode;

begin
  if List_State.ItemIndex < 0 then Exit;

  if MessageBox(Handle, '����!' + #10 + 'ɾ��ѡ�е�״̬��ȷ����', AppName, MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

  try
  
    actNode := StateList[List_State.ItemIndex];

    DataModule1.ADOQuery1.Close;
    DataModule1.ADOQuery1.SQL.Clear;
    DataModule1.ADOQuery1.SQL.Text := 'delete from Tab_State where id = ' + IntToStr(actNode.id);
    DataModule1.ADOQuery1.ExecSQL;

    actNode := nil;

    StateList.Delete(List_State.ItemIndex);
    List_State.Items.Delete(List_State.ItemIndex);
  except
  end;
end;

// ״̬ -- ɾ��ȫ��
procedure Tmain.sa_DeleteAllClick(Sender: TObject);
var
  i, len: Integer;
  actNode: ^TStateNode;
  s: string;
  
begin
  if MessageBox(Handle, '����!' + #10 + 'ɾ��ȫ����״̬��ȷ����', AppName, MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

  len := List_State.Count;

  try
    for i := 0 to len-1 do begin
        actNode := StateList[i];
        if i = 0 then s := IntToStr(actNode.id)
        else s := s + ', ' + IntToStr(actNode.id);
    end;
    actNode := nil;
    
    DataModule1.ADOQuery1.Close;
    DataModule1.ADOQuery1.SQL.Clear;
    DataModule1.ADOQuery1.SQL.Text := 'delete from Tab_State where id in (' + s + ')';
    DataModule1.ADOQuery1.ExecSQL;

    StateList.Clear;
    List_State.Clear;
  except
  end;
end;

// �� -- Lurd �����а�
procedure Tmain.so_LurdClick(Sender: TObject);
var
  s1: string;
  len: Integer;

begin
   if GetSolutionFromDB(List_Solution.ItemIndex, s1) then begin
      len := Length(s1);
      if len > 0 then begin
         Clipboard.SetTextBuf(PChar(s1));
         StatusBar1.Panels[7].Text := 'Lurd �����а壡';
      end else StatusBar1.Panels[7].Text := '���� Lurd ʧ�ܣ�';
   end;
end;

// �� -- XSB + Lurd �����а�
procedure Tmain.so_XSB_LurdClick(Sender: TObject);
var
  s, s1: string;
  len: Integer;
  solNode: ^TSoltionNode;

begin
   if GetSolutionFromDB(List_Solution.ItemIndex, s1) then begin
      s := GetXSB();

      len := Length(s1);
      if len > 0 then begin
         solNode := SoltionList.items[List_Solution.ItemIndex];
         Clipboard.SetTextBuf(PChar(s + 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10));
         StatusBar1.Panels[7].Text := 'XSB + Lurd �����а壡';
         solNode := nil;
      end else StatusBar1.Panels[7].Text := 'XSB + Lurd �����а�ʧ�ܣ�';
   end;
end;

// �� -- XSB + Lurd_All �����а�
procedure Tmain.so_XSB_LurdAllClick(Sender: TObject);
var
  s, s1, ss: string;
  i, len, len0: Integer;
  solNode: ^TSoltionNode;

begin
   s := GetXSB();
   ss := '';

   len0 := List_Solution.Count;
   for i := 0 to len0-1 do begin
       if GetSolutionFromDB(i, s1) then begin
          len := Length(s1);
          if len > 0 then begin
             solNode := SoltionList.items[i];
             ss := ss + 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10;
          end;
       end;
   end;

   Clipboard.SetTextBuf(PChar(s + ss));
   StatusBar1.Panels[7].Text := 'XSB + Lurd_All �����а壡';
   solNode := nil;
end;

// �� -- XSB + Lurd ���ĵ�
procedure Tmain.so_XSB_Lurd_FileClick(Sender: TObject);
var
  myXSBFile: Textfile;
  myFileName, myExtName, s1: string;
  len: Integer;
  solNode: ^TSoltionNode;

begin
  dlgSave1.InitialDir := AppPath;
  dlgSave1.FileName := '';

  if dlgSave1.Execute then begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
        myFileName := changefileext(myFileName, '.txt');

    if GetSolutionFromDB(List_Solution.ItemIndex, s1) then begin

      len := Length(s1);
      
      if len > 0 then begin
         AssignFile(myXSBFile, myFileName);
         ReWrite(myXSBFile);

         Write(myXSBFile, GetXSB());

         solNode := SoltionList.items[List_Solution.ItemIndex];
         Write(myXSBFile, 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10);
         StatusBar1.Panels[7].Text := 'XSB + Lurd ���ĵ���';
         Closefile(myXSBFile);
         solNode := nil;
      end else StatusBar1.Panels[7].Text := '���� XSB + Lurd ���ĵ�ʧ�ܣ�';
    end;
  end;
end;

procedure Tmain.so_XSB_LurdAll_FileClick(Sender: TObject);
var
  myXSBFile: Textfile;
  myFileName, myExtName, s1: string;
  i, len, len0: Integer;
  solNode: ^TSoltionNode;

begin
  dlgSave1.InitialDir := AppPath;
  dlgSave1.FileName := '';

  if dlgSave1.Execute then begin
    myFileName := dlgSave1.FileName;

    myExtName := ExtractFileExt(myFileName);

    if (myExtName = '') or (myExtName = '.') then
       myFileName := changefileext(myFileName, '.txt');

    AssignFile(myXSBFile, myFileName);
    ReWrite(myXSBFile);

    Write(myXSBFile, GetXSB());

    len0 := List_Solution.Count;
    for i := 0 to len0-1 do begin
       if GetSolutionFromDB(i, s1) then begin
          len := Length(s1);
          if len > 0 then begin
             solNode := SoltionList.items[i];
             Write(myXSBFile, 'Solution (Moves: ' + IntToStr(solNode.Moves) + ', Pushs: ' + IntToStr(solNode.Pushs) + '): ' + s1 + #10);
          end;
       end;
    end;

    solNode := nil;
    StatusBar1.Panels[7].Text := 'XSB + Lurd_All ���ĵ���';
    Closefile(myXSBFile);
  end;
end;

// �� -- ɾ��һ��
procedure Tmain.so_DeleteClick(Sender: TObject);
var
  solNode: ^TSoltionNode;

begin
  if List_Solution.ItemIndex < 0 then Exit;

  if MessageBox(Handle, '����!' + #10 + 'ɾ��ѡ�еĴ𰸣�ȷ����', AppName, MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

  try

    solNode := SoltionList[List_Solution.ItemIndex];

    DataModule1.ADOQuery1.Close;
    DataModule1.ADOQuery1.SQL.Clear;
    DataModule1.ADOQuery1.SQL.Text := 'delete from Tab_Solution where id = ' + IntToStr(solNode.id);
    DataModule1.ADOQuery1.ExecSQL;

    solNode := nil;

    SoltionList.Delete(List_Solution.ItemIndex);
    List_Solution.Items.Delete(List_Solution.ItemIndex);
  except
  end;
end;

// �� -- ɾ��ȫ��
procedure Tmain.so_DeleteAllClick(Sender: TObject);
var
  i, len: Integer;
  solNode: ^TSoltionNode;
  s: string;
  
begin

  if MessageBox(Handle, '����!' + #10 + 'ɾ��ȫ���Ĵ𰸣�ȷ����', AppName, MB_ICONWARNING + MB_OKCANCEL) <> idOK then Exit;

  len := List_Solution.Count;

  try
    for i := 0 to len-1 do begin
        solNode := SoltionList[i];
        if i = 0 then s := IntToStr(solNode.id)
        else s := s + ', ' + IntToStr(solNode.id);
    end;
    solNode := nil;
    
    DataModule1.ADOQuery1.Close;
    DataModule1.ADOQuery1.SQL.Clear;
    DataModule1.ADOQuery1.SQL.Text := 'delete from Tab_Solution where id in (' + s + ')';
    DataModule1.ADOQuery1.ExecSQL;

    SoltionList.Clear;
    List_Solution.Clear;
  except
  end;
end;

// ˫��״̬�����ұߵ�һ�� -- ��������
procedure Tmain.StatusBar1DblClick(Sender: TObject);
var
  mpt: TPoint;
  len: Integer;
  per: Double;

begin
  if IsMoving then begin
     IsClick := True;
     if isYanshi then isYanshi := false;
     Exit;
  end;

  mpt := Mouse.CursorPos;
  mpt := StatusBar1.ScreenToClient(mpt);

  AotoRedo := True;
  if mpt.x <= gotoLeft then begin
     if mySettings.isBK then UnDo_BK(UnDoPos_BK)
     else UnDo(UnDoPos);
  end else if mpt.x >= gotoLeft + gotoWidth then begin
     if mySettings.isBK then ReDo_BK(ReDoPos_BK)
     else ReDo(ReDoPos);
  end else begin
     per := (mpt.x - gotoLeft) / gotoWidth;        // goto ��λ��
     if mySettings.isBK then begin
        len := UnDoPos_BK + ReDoPos_BK;
        gotoPos := Trunc(len * per);
        if gotoPos < UnDoPos_BK then UnDo_BK(UnDoPos_BK-gotoPos)
        else if gotoPos > UnDoPos_BK then ReDo_BK(gotoPos-UnDoPos_BK);
     end else begin
        len := UnDoPos + ReDoPos;
        gotoPos := Trunc(len * per);
        if gotoPos < UnDoPos then UnDo(UnDoPos-gotoPos)
        else if gotoPos > UnDoPos then ReDo(gotoPos-UnDoPos);
     end;
  end;

  AotoRedo := False;
end;

// ״̬�� - ��Ϣ������
procedure Tmain.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rt: TRect);
var
  pos, len: Integer;
  per: Double;
  R1, R0: TRect;

begin
  if Panel.Index = 7 then begin
     per := 0.0;
     
     if mySettings.isBK then begin
        len := UnDoPos_BK + ReDoPos_BK;
        if len > 0 then per := UnDoPos_BK / len;
     end else begin
        len := UnDoPos + ReDoPos;
        if len > 0 then per := UnDoPos / len;
     end;

     if len > 0 then begin
         pos := Trunc(gotoWidth * per);
         R0 := Rect(gotoLeft, Rt.Top, gotoWidth + gotoLeft, Rt.Bottom);
         R1 := Rect(gotoLeft, Rt.Top, pos + gotoLeft, Rt.Bottom);
         StatusBar.Canvas.Brush.Color := clMoneyGreen;        // ��ɫ
         StatusBar.Canvas.FillRect(R0);
         StatusBar.Canvas.Brush.Color := clTeal;              // ��ɫ
         StatusBar.Canvas.FillRect(R1);
     end;

     if mySettings.isBK and (UnDoPos_BK > 0) or (not mySettings.isBK) and (UnDoPos > 0) then begin
        StatusBar.Canvas.Brush.Color := clTeal;               // ��ɫ
     end else begin
        StatusBar.Canvas.Brush.Color := clMoneyGreen;         // ��ɫ
     end;
     StatusBar.Canvas.Font.Color  := clBlack;                 // ������ɫ
     StatusBar.Canvas.TextOut(Rt.Left, Rt.Top, Panel.Text);
  end;
end;

procedure Tmain.StatusBar1Resize(Sender: TObject);
var
  j: integer;
  
begin
  gotoLeft := 0;
  for j := 0 to StatusBar1.Panels.Count - 2 do begin
      gotoLeft := gotoLeft + StatusBar1.Panels[j].Width;
  end;

  gotoLeft := gotoLeft;
  gotoWidth := StatusBar1.Width - gotoLeft - 20;
end;

procedure Tmain.FormShow(Sender: TObject);
begin
  // �ؿ�������ڵ�λ�ü���С
  BrowseForm.Top := mySettings.bwTop;
  BrowseForm.Left := mySettings.bwLeft;
  BrowseForm.Width := mySettings.bwWidth;
  BrowseForm.Height := mySettings.bwHeight;
end;

procedure Tmain.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  bt_UnDo.Click;          // z������
  Handled := True;
end;

procedure Tmain.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  bt_ReDo.Click;          // x������
  Handled := True;
end;

// GET ����
function MyGetMatch: string;
var
  IdHttp : TIdHTTP;
  Url : string;                   // �����ַ
  ResponseStream : TStringStream; // ������Ϣ
  ResponseStr : string;
  
begin
  // ����IDHTTP�ؼ�
  IdHttp := TIdHTTP.Create(nil);

  // TStringStream�������ڱ�����Ӧ��Ϣ
  ResponseStream := TStringStream.Create('');

  try
    // �����ַ
    Url := 'http://sokoban.ws/api/competition/';
    try
      IdHttp.Get(Url, ResponseStream);
    except
//      on e : Exception do
//      begin
//        ShowMessage(e.Message);
//      end;
    end;

    // ��ȡ��ҳ���ص���Ϣ
    ResponseStr := ResponseStream.DataString;

    // ��ҳ�еĴ�������ʱ����Ҫ����UTF8����
    ResponseStr := UTF8Decode(ResponseStr);

  finally
    IdHttp.Free;
    ResponseStream.Free;
  end;

  Result := ResponseStr;
end;

// ��Ӧ����򿪵Ĺؿ����ĵ��˵���ĵ����¼�
procedure Tmain.MenuItemClick(Sender: TObject);
var
  fn: string;
  i, size: Integer;
  // ���� Json
  jRet, jLevel: ISuperObject;
  strBegin, strEnd, strLevel, level, author, title, str: string;
  id: integer;

begin
  fn := TmenuItem(sender).caption;
  fn := StringReplace(fn, '&', '', [rfReplaceAll]);
  if fn = '��ȡ�����ؿ�(Z)' then begin
     if not mySettings.isXSB_Saved then
     begin    // ���µ�XSB��δ����
        i := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴浼��Ĺؿ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
        if i = idyes then begin
          SaveXSBToFile();
        end else if i = idno then begin
          mySettings.isXSB_Saved := False;
        end else Exit;
     end;

     if not mySettings.isLurd_Saved then
     begin    // ���µĶ�����δ����
        i := MessageBox(Handle, '����!' + #10 + '�Ƿ񱣴����µ��ƶ���', AppName, MB_ICONWARNING + MB_YESNOCANCEL);
        if i = idyes then begin
          mySettings.isLurd_Saved := True;
          SaveState();          // ����״̬�����ݿ�
        end else if i = idno then begin
          mySettings.isLurd_Saved := True;
          StatusBar1.Panels[7].Text := '������������';
        end else exit;
     end;

     jRet := SO(MyGetMatch);
     if (jRet.O['id'] <> nil) then begin
        str := #10;
        
        id := jRet.O['id'].AsInteger;

        strBegin := jRet.O['begin'].AsString;
        strEnd := jRet.O['end'].AsString;

        if (jRet.O['main'] <> nil) then begin
            strLevel := jRet.O['main'].AsString;
            jLevel := SO(strLevel);
            title := jLevel.O['title'].AsString;
            author := jLevel.O['author'].AsString;
            level := jLevel.O['level'].AsString;
            level := StringReplace(level, '|', #10, [rfReplaceAll]);
            str := str + level + #10 + 'Title: ' + title + #10 + 'Author' + author + #10#10;
        end;
      
        if (jRet.O['extra'] <> nil) then begin
            strLevel := jRet.O['extra'].AsString;
            jLevel := SO(strLevel);
            title := jLevel.O['title'].AsString;
            author := jLevel.O['author'].AsString;
            level := jLevel.O['level'].AsString;
            level := StringReplace(level, '|', #10, [rfReplaceAll]);
            str := str + level + #10 + 'Title: ' + title + #10 + 'Author' + author + #10;
        end;

        Clipboard.SetTextBuf(PChar(str));

        if LoadMapsFromClipboard() then begin               // ���а嵼�� XSB
          if (MapList <> nil) and (MapList.Count > 0) then begin   // ����������Ч�ؿ����Զ��򿪵�һ���ؿ�
            if LoadMap(1) then begin
              curMapNode.Trun := 0;    // Ĭ�Ϲؿ��� 0 ת
              SetMapTrun();
              InitlizeMap();
              mySettings.isXSB_Saved := False;              // ���Ӽ��а嵼��� XSB �Ƿ񱣴����
              mySettings.isLurd_Saved := True;              // �ƹؿ��Ķ����Ƿ񱣴����
              Caption := AppName + AppVer + ' - �����ؿ� ~ [' + inttostr(curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
              StatusBar1.Panels[7].Text := '��' + inttostr(id) + '�ڱ�����' + strBegin + ' �� ' + strEnd;
            end;
          end;
        end
        else StatusBar1.Panels[7].Text := '��ȡ�����ؿ�ʧ�ܣ�';

     end else StatusBar1.Panels[7].Text := 'û����ȡ�������ؿ���';
  end
  else begin
    if LoadMaps(fn) then
    begin
      if MapList.Count > 0 then
      begin
        mySettings.MapFileName := fn;
        size := mySettings.LaterList.Count;
        i := 0;
        while i < size do begin
          if fn = mySettings.LaterList[i] then Break;
          Inc(i);
        end;
        if i < size then mySettings.LaterList.Move(i, 0)
        else mySettings.LaterList.Insert(0, fn);

        mySettings.isXSB_Saved := True;
        if LoadMap(1) then
        begin
          curMapNode.Trun := 0;    // Ĭ�Ϲؿ��� 0 ת
          SetMapTrun();
          InitlizeMap();
        end;
      end;
      StatusBar1.Panels[7].Text := '';
    end
    else begin
      StatusBar1.Panels[7].Text := '�ؿ����ĵ�����ʧ�� - ' + fn;
    end;
  end;
end;

// ����򿪵Ĺؿ����ĵ� -- �Զ����ɲ˵���
procedure Tmain.bt_LatelyClick(Sender: TObject);
var
  i, size: Integer;
  ItemL1: TMenuItem;

begin
  size := mySettings.LaterList.Count;

  if size = 0 then Exit;

  pm_Later.Items.Clear;
  for i := 0 to size-1 do begin
      ItemL1 := TMenuItem.Create(Nil);
      ItemL1.Caption := mySettings.LaterList[i];
      ItemL1.OnClick := MenuItemClick;
      pm_Later.Items.Add(ItemL1);
  end;
  ItemL1 := TMenuItem.Create(Nil);
  ItemL1.Caption := '��ȡ�����ؿ�';
  ItemL1.OnClick := MenuItemClick;
  pm_Later.Items.Add(ItemL1);

  SetCursorPos(Left + 45, Top + 55);
  mouse_event(MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
  mouse_event(MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
end;

procedure Tmain.bt_SaveClick(Sender: TObject);
begin
  if mySettings.isXSB_Saved then begin
    SaveState();                                   // ����״̬�����ݿ�
  end else begin
    if SaveXSBToFile() then SaveState();           // ����ؿ� XSB ���ĵ���״̬�����ݿ�
  end;
end;

procedure Tmain.pm_HomeClick(Sender: TObject);
begin
  Restart(mySettings.isBK);
end;

procedure Tmain.N1Click(Sender: TObject);
var
   len: Integer;
   
begin
   if GetSolutionFromDB(List_Solution.ItemIndex, MySubmit.SubmitLurd) then begin   // �ύ--Lurd
      len := Length(MySubmit.SubmitLurd);
      if len > 0 then begin
          MySubmit.SubmitCountry := mySettings.SubmitCountry;       // �ύ--���һ����
          MySubmit.SubmitName    := mySettings.SubmitName;          // �ύ--����
          MySubmit.SubmitEmail   := mySettings.SubmitEmail;         // �ύ--����
          if MySubmit.ShowModal = mrOK then begin
             mySettings.SubmitCountry := MySubmit.SubmitCountry;       // �ύ--���һ����
             mySettings.SubmitName    := MySubmit.SubmitName;          // �ύ--����
             mySettings.SubmitEmail   := MySubmit.SubmitEmail;         // �ύ--����
             StatusBar1.Panels[7].Text := MySubmit.Caption;            // �ύ���
          end;
      end else StatusBar1.Panels[7].Text := '���ش�ʧ�ܣ�';
   end else StatusBar1.Panels[7].Text := '����ѡ����Ҫ�ύ�Ĵ𰸣�';
end;

initialization
  lsPjt := 'yuweng_BoxMan';
  lsHandle := CreateMutex(nil, true, PChar(lsPjt));
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    lsAppName := Application.Title;
    Application.ShowMainForm := false;
    Application.Title := 'de_yuweng_BoxMan';
    PreInstanceWindow := findWindow(nil, PChar(lsAppName));
    if PreInstanceWindow <> 0 then
    begin
      if IsIconic(PreInstanceWindow) then
        showWindow(PreInstanceWindow, SW_RESTORE)
      else
        SetForegroundWindow(PreInstanceWindow);
    end;
    Application.Terminate;
  end
  else
    Application.Title := 'yuweng_BoxMan';

finalization
  if lsHandle <> 0 then
    closeHandle(lsHandle);

end.

