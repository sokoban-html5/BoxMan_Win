unit LoadMapUnit;    // �ؿ��ı�������Ԫ

interface

uses
  windows, classes, StrUtils, SysUtils, Clipbrd, Math, CRC_32, SQLiteTable3;

type
  TLoadMapThread = class(TThread)         // ����������ȫ���ؿ��ĺ�̨�߳�
  protected
    procedure Execute; override;
  public
  end;

type
  TLoadAnsThread = class(TThread)         // ����𰸵ĺ�̨�߳�
  protected
    procedure UpdateCaption;
    procedure Execute; override;
  public
  end;

type                  // �ؿ��ڵ� -- �ؿ����еĸ����ؿ�
  TMapNode = record
    Map_Thin: string;           // ���ؿ� XSB
    Map: TStringList;           // �ؿ� XSB
    Rows, Cols: integer;        // �ؿ��ߴ�
    Boxs: integer;              // ������
    Goals: integer;             // Ŀ����
    Trun: integer;              // �ؿ���ת�Ǽ�
    Title: string;              // ����
    Author: string;             // ����
    Comment: string;            // �ؿ�������Ϣ
    CRC32: integer;             // CRC32
    CRC_Num: integer;           // ����ǰ��ͼΪ 0 ת����С CRC λ�ڵڼ�ת��
    Solved: Boolean;            // �Ƿ��ɴ�
    isEligible: Boolean;        // �Ƿ�ϸ�Ĺؿ�XSB
    Num: integer;               // �ؿ���� -- �������ĵ����һ���ؿ�ʱʹ��
  end;

  PMapNode = ^TMapNode;         // �ؿ��ڵ�ָ��

function LoadMapsFromTextList(data_Text: TStringList; isAns: Boolean): boolean;                   // ���عؿ� -- �� TStringList �У�isAns -- �Ƿ���ش�

procedure QuicklyLoadMap(data_Text: TStringList; number: Integer; var curMap: PMapNode);  // Ѹ�ٵļ���ָ����� number �Ĺؿ�

function GetMapNumber(data_Text: TStringList): Integer;              // ȡ�ùؿ���

function FindClipbrd(num: Integer): Integer;                         // �ڹؿ��б��У����Ҽ��а��еĹؿ��������ҵ�����ţ�û�ҵ��򷵻� -1

function MapNormalize(var mapNode: PMapNode): Boolean;               // ��ͼ��׼�����������򵥱�׼�� -- �����ؿ���ǽ�����ͣ���׼��׼�� -- �������ؿ���ǽ�����ͣ�ͬʱ���� CRC ��

function isSolution(mapNode: PMapNode; sol: PChar): Boolean;         // ����֤

procedure MyStringListFree(var _StringList_: TStringList);           // �ͷ� TStringList ���ڴ�

procedure MyListClear(var _List_: TList);                            // ��չؿ��б�

function GetXSB(mapNpde: PMapNode): string;                          // ȡ�ùؿ� XSB

function GetXSB_2(): string;                                        // ȡ���ֳ� XSB

procedure XSBToClipboard();                                         // XSB ������а�

procedure XSBToClipboard_2();                                       // �ֳ� XSB ������а�

procedure Split(src: string; var myList: TStringList);              // �ָ��ַ���

var
  isStopThread: Boolean;                   // �Ƿ���ֹ��̨�߳�
  isStopThread_Ans: Boolean;               // �Ƿ���ֹ��̨�߳�
  ManPos_BK_0: integer;                    // �˵�λ�� -- ���ƣ�����Ѿ�ָ����λ��
  ManPos_BK_0_2: integer;                  // �˵�λ�� -- ���ƣ�����������λ��

  sMoves, sPushs: integer;                 // ��֤��ʱ����¼�ƶ������ƶ���

  sumSolution: Integer;                    // �ɹ�����Ĵ𰸸���

  MapCount: Integer;                       // �Ѿ����������Ĺؿ���
  MapList: TList;                          // �ؿ��б�
  MapArray: array[0..99, 0..99] of Char;   // ��׼���ùؿ�����
  Mark: array[0..99, 0..99] of Boolean;    // ��׼���ñ�־����
  curMapNode: PMapNode;                    // ��ǰ�ؿ��ڵ�

  tmp_Board: array[0..9999] of integer;    // ��ʱ��ͼ

  // ��׼���ùؿ�����
  aMap0: array[0..99, 0..99] of Char;
  aMap1: array[0..99, 0..99] of Char;
  aMap2: array[0..99, 0..99] of Char;
  aMap3: array[0..99, 0..99] of Char;
  aMap4: array[0..99, 0..99] of Char;
  aMap5: array[0..99, 0..99] of Char;
  aMap6: array[0..99, 0..99] of Char;
  aMap7: array[0..99, 0..99] of Char;

  xbsChar: array[0..7] of Char = ( '_', '#', '-', '.', '$', '*', '@', '+' );

implementation

uses
  MainForm, LogFile, OpenFile;

const
  EmptyCell = 0;
  WallCell = 1;
  FloorCell = 2;
  GoalCell = 3;
  BoxCell = 4;
  BoxGoalCell = 5;
  ManCell = 6;
  ManGoalCell = 7;

  // ���ڳ��������ҡ��ϡ���
  dr4 : array[0..3] of Integer = (  0, 0, -1, 1 );
  dc4 : array[0..3] of Integer = ( -1, 1,  0, 0 );

var
  pt: array[0..9999] of Integer;        // �ڡ��ؿ���׼�������У���������������С�

// �ͷ� TStringList ���ڴ�
procedure MyStringListFree(var _StringList_: TStringList);
begin
  if Assigned(_StringList_) then begin
     _StringList_.Clear;
     _StringList_.Free;
     _StringList_ := nil;
  end;
end;

// ��չؿ��б�TList���ͣ�
procedure MyListClear(var _List_: TList);
var
  i, len: Integer;
begin
  if not Assigned(_List_) then exit;

  if Assigned(_List_) then begin
    len := _List_.Count;
    for i := len-1 downto 0 do begin
        if Assigned(PMapNode(_List_.Items[i])) then begin
           MyStringListFree(PMapNode(_List_.Items[i]).Map);
           Dispose(PMapNode(_List_.Items[i]));
           _List_.Items[i] := nil;
        end;
    end;
    _List_.Clear;
  end;
end;

// ȡ���Ӵ������ֵ�λ��
function LastPos(const SubStr, Str: ansistring): Integer;
var
  Idx: Integer;
begin
  Result := 0;
  Idx := StrUtils.PosEx(SubStr, Str);
  if Idx = 0 then Exit;
  while Idx > 0 do begin
    Result := Idx;
    Idx := StrUtils.PosEx(SubStr, Str, Idx + 1);
  end;
end;

// �ж��Ƿ�Ϊ��Ч�� Lurd ��
function isLurd(str: String; is_BK: Boolean = False): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;    
  
  k := 1;
  while k <= n do begin
     if not (str[k] in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D', ' ', #9 ]) then Break;
     k := k+1;
  end;

  result := k > n;
end;

// �ж��Ƿ�Ϊ��Ч�� Lurd ��
function isLurd_2(str: String): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;    
  
  k := 1;
  while k <= n do begin
     if not (str[k] in [ 'l', 'u', 'r', 'd', 'L', 'U', 'R', 'D', ',', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ' ', '[', ']', ' ', #9 ]) then Break;
     k := k+1;
  end;

  result := k > n;
end;

// �ж��Ƿ�Ϊ��Ч�� XSB ��
function isXSB(str: string): boolean;
var
  n, k: Integer;
begin
  result := False;

  n := Length(str);

  if n = 0 then exit;

  k := 1;
  // ����Ƿ��ǿ��� -- ���пո�������
  while k <= n do begin
    if (str[k] <> #20) and (str[k] <> #9) or (str[k] = '') then Break;
    k := k+1;
  end;
  if k > n then Exit;

  k := 1;
  while k <= n do begin
    if not (str[k] in [ #9, ' ', '_', '-', '#', '.', '$', '*', '@', '+']) then Break;
    k := k+1;
  end;

  result := k > n;
end;

// ����֤
function isSolution(mapNode: PMapNode; sol: PChar): Boolean;
var
  i, j, len, mpos, pos1, pos2, okNum, size, Rows, Cols: Integer;
  isPush: Boolean;
  ch: Char;
begin
  Result := False;

  // ��ʱ��ͼ��λ
  mpos := -1;
  Rows := mapNode.Rows;
  Cols := mapNode.Cols;
  size := Rows * Cols;
  for i := 0 to Rows - 1 do begin
    for j := 1 to Cols do begin
      ch := mapNode.Map[i][j];
      case ch of
        '#':
          tmp_Board[i * Cols + j] := WallCell;
        '-':
          tmp_Board[i * Cols + j] := FloorCell;
        '.':
          tmp_Board[i * Cols + j] := GoalCell;
        '$':
          tmp_Board[i * Cols + j] := BoxCell;
        '*':
          tmp_Board[i * Cols + j] := BoxGoalCell;
        '@':
          tmp_Board[i * Cols + j] := ManCell;
        '+':
          tmp_Board[i * Cols + j] := ManGoalCell;
      else
        tmp_Board[i * Cols + j] := EmptyCell;
      end;

      if ch in ['@', '+'] then mpos := i * Cols + j;
    end;
  end;

  if mpos < 0 then Exit;
  
  sPushs := 0;
  sMoves := 0;

  // ����֤
  len := Length(sol);
  for i := 0 to len - 1 do begin
    pos1 := -1;
    pos2 := -1;
    ch := sol[i];
    // ���ؿ���ת�任�����ַ�
//    case ch of
//       'l': ch := ActDir[mapNode.Trun, 0];
//       'u': ch := ActDir[mapNode.Trun, 1];
//       'r': ch := ActDir[mapNode.Trun, 2];
//       'd': ch := ActDir[mapNode.Trun, 3];
//       'L': ch := ActDir[mapNode.Trun, 4];
//       'U': ch := ActDir[mapNode.Trun, 5];
//       'R': ch := ActDir[mapNode.Trun, 6];
//       'D': ch := ActDir[mapNode.Trun, 7];
//    end;
    case ch of
      'l', 'L':
        begin
          pos1 := mpos - 1;
          pos2 := mpos - 2;
        end;
      'r', 'R':
        begin
          pos1 := mpos + 1;
          pos2 := mpos + 2;
        end;
      'u', 'U':
        begin
          pos1 := mpos - mapNode.Cols;
          pos2 := mpos - mapNode.Cols * 2;
        end;
      'd', 'D':
        begin
          pos1 := mpos + mapNode.Cols;
          pos2 := mpos + mapNode.Cols * 2;
        end;
    end;

    if (pos1 < 0) or (pos1 >= size) then   // pos1 ����
       Exit;

    isPush := False;
    if tmp_Board[pos1] = FloorCell then begin
       tmp_Board[pos1] := ManCell;
    end else if tmp_Board[pos1] = GoalCell then begin
       tmp_Board[pos1] := ManGoalCell;
    end else if tmp_Board[pos1] = BoxCell then begin
       if (pos2 < 0) or (pos2 >= size) then // pos2 ����
          Exit;

       if tmp_Board[pos2] = FloorCell then begin
          tmp_Board[pos2] := BoxCell;
       end else if tmp_Board[pos2] = GoalCell then begin
          tmp_Board[pos2] := BoxGoalCell;
       end else Exit;                       // ����

       tmp_Board[pos1] := ManCell;

       isPush := True;
    end else if tmp_Board[pos1] = BoxGoalCell then begin
       if (pos2 < 0) or (pos2 >= size) then // pos2 ����
          Exit;
          
       if tmp_Board[pos2] = FloorCell then begin
          tmp_Board[pos2] := BoxCell;
       end else if tmp_Board[pos2] = GoalCell then begin
          tmp_Board[pos2] := BoxGoalCell;
       end else Exit;                       // ����

       tmp_Board[pos1] := ManGoalCell;

       isPush := True;
    end else Exit;;                        // ����

    if tmp_Board[mpos] = ManCell then
      tmp_Board[mpos] := FloorCell
    else
      tmp_Board[mpos] := GoalCell;

    if isPush then sPushs := sPushs+1;
    sMoves := sMoves+1;

    mpos := pos1;

    okNum := 0;
    for j := 0 to size - 1 do begin
      if (tmp_Board[j] = BoxGoalCell) then
        okNum := okNum+1;

      if okNum = mapNode.Boxs then begin                     // �ܹ���أ�Ϊ��Ч��
        Result := True;
        Exit;
      end;
    end;
  end;

  Result := False;
end;

// �����µĹؿ��ڵ�
procedure NewMapNode(var mpList: TList);
var
  mapNode: PMapNode;               // �ؿ��ڵ�
begin
  New(mapNode);
  mapNode.Map := TStringList.Create;

  mapNode.Map_Thin := '';
  mapNode.Rows := 0;
  mapNode.Cols := 0;
  mapNode.Trun := 0;
  mapNode.Title := '';
  mapNode.Author := '';
  mapNode.Comment := '';
  mapNode.CRC32 := -1;
  mapNode.CRC_Num := -1;
  mapNode.Solved := false;

  mpList.Add(mapNode);          // ����ؿ����б�
  mapNode := nil;
end;

// ԭʼ XSB ������а�
procedure XSBToClipboard();
begin
  if Assigned(curMapNode) and (curMapNode.Map.Count > 0) then
  begin
    Clipboard.SetTextBuf(PChar(GetXSB(curMapNode)));
  end;
end;

// �ֳ� XSB ������а�
procedure XSBToClipboard_2();
begin
  if Assigned(curMapNode) and (curMapNode.Map.Count > 0) then
  begin
    Clipboard.SetTextBuf(PChar(GetXSB_2()));
  end;
end;

// ����ʱ�������ִ𰸣�����𰸿�
procedure SetSolved(mapNode: PMapNode; var Solitions: TStringList);
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  i, l, solCRC: Integer;
  is_Solved: Boolean;
begin
  is_Solved := false;
  mapNode.Solved := false;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    if sldb.TableExists('Tab_Solution') then begin
      // ���������˴𰸣�����֤�𰸲��������
      if Solitions.Count > 0 then begin
        l := Solitions.Count;
        for i := l - 1 downto 0 do begin
          if isSolution(mapNode, PChar(Solitions[i])) then begin       // �Դ𰸽�����֤
            // ����𰸵����ݿ�
            sSQL := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Boxs);
            sltb := slDb.GetTable(sSQL);

            try
              solCRC := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
              sltb.MoveFirst;
              while not sltb.EOF do begin
                if (sltb.FieldAsInteger(sltb.FieldIndex['Sol_CRC32']) = solCRC) and (sltb.FieldAsInteger(sltb.FieldIndex['Moves']) = sMoves) and (sltb.FieldAsInteger(sltb.FieldIndex['Pushs']) = sPushs) then
                  Break;
                    
                sltb.Next;
              end;

              // û���ظ��𰸣�����ӵ��𰸿�
              if sltb.EOF then begin
                 sldb.BeginTransaction;

                 sSQL := 'INSERT INTO Tab_Solution (XSB_CRC32, XSB_CRC_TrunNum, Goals, Sol_CRC32, Moves, Pushs, Sol_Text, XSB_Text, Sol_DateTime) ' +
                         'VALUES (' +
                         IntToStr(mapNode.CRC32) + ', ' +
                         IntToStr(mapNode.CRC_Num) + ', ' +
                         IntToStr(mapNode.Boxs) + ', ' +
                         IntToStr(solCRC) + ', ' +
                         IntToStr(sMoves) + ', ' +
                         IntToStr(sPushs) + ', ''' +
                         Solitions[i] + ''', ''' +
                         mapNode.Map_Thin + ''', ''' +
                         FormatDateTime(' yyyy-mm-dd hh:nn', now) + ''');';

                 sldb.ExecSQL(sSQL);

                 sldb.Commit;
                 sumSolution := sumSolution + 1;           // �ɹ�����Ĵ𰸸���
              end;
            finally
              sltb.free;
            end;
          end else begin
            Solitions.Delete(i);
          end;
        end;
        is_Solved := True;
        Solitions.Clear;
      end;

      if is_Solved then mapNode.Solved := is_Solved
      else begin
        // ���ݿ����Ƿ��н�
        sSQL := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Boxs);
        sltb := slDb.GetTable(sSQL);
        try
          mapNode.Solved := sltb.Count > 0;
        finally
          sltb.Free;
        end;
      end;
    end;
  finally
    sldb.free;
  end;
end;

// �������𰸿�
procedure SetSolved_2(mapNode: PMapNode; var Solitions: TStringList);
var
  sldb: TSQLiteDatabase;
  sltb: TSQLIteTable;
  sSQL: String;
  i, l, solCRC: Integer;
  is_Solved: Boolean;
begin
  is_Solved := false;
  mapNode.Solved := false;

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    if sldb.TableExists('Tab_Solution') then begin
      // ���������˴𰸣�����֤�𰸲��������
      if Solitions.Count > 0 then begin
        l := Solitions.Count;
        for i := l - 1 downto 0 do begin
          if isSolution(mapNode, PChar(Solitions[i])) then begin       // �Դ𰸽�����֤
            // ����𰸵����ݿ�
            sSQL := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Boxs);
            sltb := slDb.GetTable(sSQL);

            try
              solCRC := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
              sltb.MoveFirst;
              while not sltb.EOF do begin
                if (sltb.FieldAsInteger(sltb.FieldIndex['Sol_CRC32']) = solCRC) and (sltb.FieldAsInteger(sltb.FieldIndex['Moves']) = sMoves) and (sltb.FieldAsInteger(sltb.FieldIndex['Pushs']) = sPushs) then
                  Break;
                    
                sltb.Next;
              end;

              // û���ظ��𰸣�����ӵ��𰸿�
              if sltb.EOF then begin
                 sldb.BeginTransaction;

                 sSQL := 'INSERT INTO Tab_Solution (XSB_CRC32, XSB_CRC_TrunNum, Goals, Sol_CRC32, Moves, Pushs, Sol_Text, XSB_Text, Sol_DateTime) ' +
                         'VALUES (' +
                         IntToStr(mapNode.CRC32) + ', ' +
                         IntToStr(mapNode.CRC_Num) + ', ' +
                         IntToStr(mapNode.Boxs) + ', ' +
                         IntToStr(solCRC) + ', ' +
                         IntToStr(sMoves) + ', ' +
                         IntToStr(sPushs) + ', ''' +
                         Solitions[i] + ''', ''' +
                         mapNode.Map_Thin + ''', ''' +
                         FormatDateTime(' yyyy-mm-dd hh:nn', now) + ''');';

                 sldb.ExecSQL(sSQL);

                 sldb.Commit;
                 sumSolution := sumSolution + 1;           // �ɹ�����Ĵ𰸸���
              end;
            finally
              sltb.free;
            end;
          end else begin
            Solitions.Delete(i);
          end;
        end;
        is_Solved := True;
        Solitions.Clear;
      end;

      if is_Solved then mapNode.Solved := is_Solved
      else begin
        // ���ݿ����Ƿ��н�
        sSQL := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Boxs);
        sltb := slDb.GetTable(sSQL);
        try
          mapNode.Solved := sltb.Count > 0;
        finally
          sltb.Free;
        end;
      end;
    end;
  finally
    sldb.free;
  end;
end;

// Ѹ�ټ���ָ����ŵĹؿ�
procedure QuicklyLoadMap(data_Text: TStringList; number: Integer; var curMap: PMapNode);
var
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  n, k, len, num: Integer;         // XSB�Ľ�������
begin
  curMap.Map := TStringList.Create;

  try
    curMap.Map_Thin := '';
    curMap.Rows := 0;
    curMap.Cols := 0;
    curMap.Trun := 0;
    curMap.Title := '';
    curMap.Author := '';
    curMap.Comment := '';
    curMap.CRC32 := -1;
    curMap.CRC_Num := -1;
    curMap.Solved := false;
    curMap.isEligible := True;      // Ĭ���Ǻϸ�Ĺؿ� XSB
    curMap.Num := 0;

    is_XSB := False;
    is_Comment := False;

    len := data_Text.Count;
    k := 0;
    num := 0;
    while (k < len) do begin
      line  := data_Text.Strings[k];
      line2 := Trim(line);
      k := k+1;

      if (not is_Comment) and isXSB(line) then begin       // ����Ƿ�Ϊ XSB ��
        if not is_XSB then begin     // ��ʼ XSB ��

          if (curMap.Rows > 2) or (num = 0) then
             num := num+1;     // �����ĵ� num �� XSB ��

          if num > number then  Break;

          is_XSB := True;    // ��ʼ�ؿ� XSB ��
          is_Comment := False;
          curMap.Map.Clear;
          curMap.Rows := 0;
          curMap.Num := num;
        end;

        if num = number then begin
           curMap.Map.Add(line);      // �� XSB ��
        end;
        curMap.Rows := curMap.Rows+1;

      end
      else if (not is_Comment) and (AnsiStartsText('title', line2)) and (curMap.Title = '') then begin   // ƥ�� Title������
        if num = number then begin
           n := Pos(':', line2);
           if n > 0 then
              curMap.Title := trim(Copy(line2, n + 1, MaxInt))
           else
              curMap.Title := trim(Copy(line2, 6, MaxInt));
        end;

        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
      end
      else if (not is_Comment) and (AnsiStartsText('author', line2)) and (curMap.Author = '') then begin  // ƥ�� Author������
        if num = number then begin
           n := Pos(':', line2);
           if n > 0 then
             curMap.Author := trim(Copy(line2, n + 1, MaxInt))
           else
             curMap.Author := trim(Copy(line2, 7, MaxInt));
        end;

        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
      end
      else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // ƥ��"ע��"�����
        is_Comment := False;   // ����"ע��"��
      end
      else if AnsiStartsText('comment', line2) and (curMap.Comment = '') then begin  //ƥ��"ע��"�鿪ʼ
        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
        n := Pos(':', line2);
        if n > 0 then
          line := trim(Copy(line2, n + 1, MaxInt))
        else
          line := trim(Copy(line2, 8, MaxInt));

        if Length(line) > 0 then begin
          if num = number then
            curMap.Comment := line;     // ����"ע��"
        end
        else
          is_Comment := True;          // ����"ע��"��
      end
      else if is_Comment then begin  // "˵��"��Ϣ
        if num = number then begin
          if Length(curMap.Comment) > 0 then
            curMap.Comment := curMap.Comment + #10 + line
          else
            curMap.Comment := line;
        end;
      end
      else begin
        if is_XSB then is_XSB := false;      // �����ؿ�SXB��Ľ���
      end;
    end;

    // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
    if (curMap.Rows > 2) then begin
       MapNormalize(curMap);
    end else begin
      curMap.Map.Clear;
      curMap.Rows := 0;
    end;
  except
    curMap.Map.Clear;
    curMap.Rows := 0;
  end;
end;

// ȡ�ð����Ĺؿ�����
function GetMapNumber(data_Text: TStringList): Integer;
var
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  n, k, len, Rows: Integer;        // XSB�Ľ�������
begin
  Result := 0;

  Rows := 0;

  try

    is_XSB := False;
    is_Comment := False;

    len := data_Text.Count;
    k := 0;
    while (k < len) do begin
      line  := data_Text.Strings[k];
      line2 := Trim(line);
      k := k+1;

      if (not is_Comment) and isXSB(line) then begin       // ����Ƿ�Ϊ XSB ��
        if not is_XSB then begin     // ��ʼ XSB ��

          if (Rows > 2) or (Result = 0) then
             Result := Result+1;     // �����ĵ� num �� XSB ��

          if Result >= MaxInt then begin
             Break;
          end;

          is_XSB := True;    // ��ʼ�ؿ� XSB ��
          is_Comment := False;
          Rows := 0;
        end;

        Rows := Rows+1;

      end
      else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // ƥ��"ע��"�����
        is_Comment := False;   // ����"ע��"��
      end
      else if AnsiStartsText('comment', line2) then begin  //ƥ��"ע��"�鿪ʼ
        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
        n := Pos(':', line2);
        if n > 0 then
          line := trim(Copy(line2, n + 1, MaxInt))
        else
          line := trim(Copy(line2, 8, MaxInt));

        if Length(line) <= 0 then is_Comment := True;          // ����"ע��"��
      end
      else if is_Comment then begin  // "˵��"��Ϣ
      end
      else begin
        if is_XSB then is_XSB := false;      // �����ؿ�SXB��Ľ���
      end;
    end;

  finally
    // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
    if (Rows < 3) then begin
       Result := Result - 1;
    end;
  end;
end;

// �ָ��ַ���
procedure Split(src: string; var myList: TStringList);
var
  i: integer;
  str: string;
begin
  src := StringReplace(src, #13, #10, [rfReplaceAll]);
//  i := 1;
//  while i > 0 do begin
     src := StringReplace(src, #10#10, #10, [rfReplaceAll]);
//     i := pos(#10#10, src);
//  end;

  repeat
    i := pos(#10, src);
    str := copy(src, 1, i - 1);
    if (str = '') and (i > 0) then
    begin
      myList.Add('');
      delete(src, 1, 1);
      continue;
    end;
    if i > 0 then
    begin
      myList.Add(str);
      delete(src, 1, i);
    end;
  until i <= 0;
  if src <> '' then
    myList.Add(src);
end;

// ���� TStringList �еĹؿ���Ϣ
function LoadMapsFromTextList(data_Text: TStringList; isAns: Boolean): boolean;
var
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Solution: Boolean;            // �Ƿ����
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  num, n, k, len: Integer;              // XSB�Ľ�������
  mapNode: PMapNode;               // �������ĵ�ǰ�ؿ��ڵ�ָ��
  mapSolution: TStringList;        // �ؿ���
  tmpList: TList;
begin
  Result := False;

  if (not Assigned(data_Text)) or (data_Text.Count <= 0) then Exit;

  MyListClear(MapList);
  tmpList := TList.Create;                    // ��ʱ�ؿ��б�

  try
    mapSolution := TStringList.Create;

    try

      NewMapNode(tmpList);                // �ȴ���һ���ؿ��ڵ�
      mapNode := tmpList.Items[0];        // ָ�����´����Ľڵ�
      mapNode.isEligible := True;         // Ĭ���Ǻϸ�Ĺؿ�XSB
      is_XSB := False;
      is_Comment := False;
      is_Solution := False;

      sumSolution := 0;
      k := 0;
      len := data_Text.Count;
      while k < len do begin

        line := data_Text.Strings[k];     // ��ȡһ��
        k := k+1;
        line2 := Trim(line);

        if (not is_Comment) and isXSB(line) then begin       // ����Ƿ�Ϊ XSB ��
          if not is_XSB then begin     // ��ʼ XSB ��

            if mapNode.Map.Count > 2 then begin   // ǰ���н������Ĺؿ� XSB����ѵ�ǰ�ؿ�����ؿ����б�
              // ���ؿ��ı�׼��������CRC��
              if MapNormalize(mapNode) then begin
                 if isAns then SetSolved(mapNode, mapSolution);
              end;

              NewMapNode(tmpList);                                  // ����һ���µĹؿ��ڵ�
              num := tmpList.Count - 1;
              mapNode := tmpList.Items[num];                        // ָ�����´����Ľڵ�
              mapNode.isEligible := True;                           // Ĭ���Ǻϸ�Ĺؿ�XSB
            end
            else mapNode.Map.Clear;

            is_XSB := True;    // ��ʼ�ؿ� XSB ��
            is_Comment := False;
            is_Solution := False;
            mapNode.Rows := 0;
            mapNode.Cols := 0;
            mapNode.Title := '';
            mapNode.Author := '';
            mapNode.Comment := '';
          end;

          mapNode.Map.Add(line);    // �� XSB ��

        end
        else if (not is_Comment) and (AnsiStartsText('title', line2)) and (mapNode.Title = '') then begin   // ƥ�� Title������
          n := Pos(':', line2);
          if n > 0 then
            mapNode.Title := trim(Copy(line2, n + 1, MaxInt))
          else
            mapNode.Title := trim(Copy(line2, 6, MaxInt));

          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
        end
        else if (not is_Comment) and (AnsiStartsText('author', line2)) and (mapNode.Author = '') then begin  // ƥ�� Author������
          n := Pos(':', line2);
          if n > 0 then
            mapNode.Author := trim(Copy(line2, n + 1, MaxInt))
          else
            mapNode.Author := trim(Copy(line2, 7, MaxInt));

          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
        end
        else if (not is_Comment) and (isAns) and (AnsiStartsText('solution', line2)) then begin  // ƥ�� Solution����
          n := LastPos(':', line2);
          if n = 0 then
            n := Pos(')', line2);

          if n > 0 then
            line := trim(Copy(line2, n + 1, MaxInt))
          else
            line := trim(Copy(line2, 9, MaxInt));

          if Length(line) > 0 then
            mapSolution.Add(line)
          else
            mapSolution.Add('');

          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
          is_Solution := true;                 // ��ʼ�𰸽���
        end
        else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // ƥ��"ע��"�����
          is_Comment := False;   // ����"ע��"��
        end
        else if AnsiStartsText('comment', line2) and (mapNode.Comment = '') then begin  //ƥ��"ע��"�鿪ʼ
          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���

          n := Pos(':', line2);
          if n > 0 then
            line := trim(Copy(line2, n + 1, MaxInt))
          else
            line := trim(Copy(line2, 8, MaxInt));

          if Length(line) > 0 then
            mapNode.Comment := line     // ����"ע��"
          else
            is_Comment := True;         // ��ʼ"ע��"��
        end
        else if is_Comment then begin  // "˵��"��Ϣ
          if Length(mapNode.Comment) > 0 then
            mapNode.Comment := mapNode.Comment + #10 + line
          else
            mapNode.Comment := line;
        end
        else if is_Solution then begin  // ����
          line2 := StringReplace(line2, #9, '', [rfReplaceAll]);
          line2 := StringReplace(line2, ' ', '', [rfReplaceAll]);
          if isLurd(line2) then begin
             n := mapSolution.Count - 1;
             mapSolution[n] := mapSolution[n] + line2;
          end;
        end
        else begin
          if is_XSB then is_XSB := false;      // �����ؿ�SXB��Ľ���
        end;
      end;

      Result := True;
    finally
      // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
      num := tmpList.Count - 1;
      if num >= 0 then begin
         mapNode := tmpList.Items[num];
         if mapNode.Map.Count < 3 then begin
            MyStringListFree(mapNode.Map);
            tmpList.Delete(num);
            Dispose(mapNode);
         end else begin
           if MapNormalize(mapNode) then begin
              if isAns then SetSolved(mapNode, mapSolution);
           end;
         end;
      end else if Assigned(mapNode) then begin
         if mapNode.Map.Count > 0 then begin
            MyStringListFree(mapNode.Map);
         end;
         Dispose(mapNode);
      end;
      mapNode := nil;

      MyStringListFree(mapSolution);
    end;
  finally
    if Assigned(tmpList) then begin
       if tmpList.Count > 0 then begin
          MapList := tmpList;
       end else begin
          MyListClear(tmpList);
       end;
       tmpList := nil;
    end;
  end;
end;

// �� TStringList �е����
//procedure TLoadMapThread2.Execute;

// ��ͼ��׼�����������򵥱�׼�� -- �����ؿ���ǽ�����ͣ���׼��׼�� -- �������ؿ���ǽ�����ͣ�ͬʱ���� CRC ��
function MapNormalize(var mapNode: PMapNode): Boolean;
var
  i, j, k, t, mr, mc, Rows, Cols, nLen, nRen, nRows, nCols, p, tail, pos: Integer;
  ch: Char;
  mr2, mc2, left, top, right, bottom, nBox, nDst, mTop, mLeft, mBottom, mRight: Integer;
  s1: string;
  key8: array[0..7] of Integer;
begin
  Result := False;

  mr := -1;
  mc := -1;
  nRen := 0;
  Rows := mapNode.Map.Count;
  Cols := 0;
  for i := 0 to Rows - 1 do begin
    nLen := Length(mapNode.Map[i]);
    if Cols < nLen then
      Cols := nLen;
  end;

  mapNode.Rows := Rows;
  mapNode.Cols := Cols;

  if (Rows >= 100) or (Cols >= 100) then begin
    mapNode.Rows := 100;
    mapNode.Cols := 100;
    mapNode.isEligible := False;        // ���ϸ�Ĺؿ�XSB
    Exit;
  end;

  for i := 0 to Rows - 1 do begin
    nLen := Length(mapNode.Map[i]);
    for j := 0 to Cols - 1 do
    begin
      if j < nLen then
        ch := mapNode.Map[i][j + 1]
      else
        ch := '-';

      case (ch) of
        '#', '.', '$', '*':
          begin
            MapArray[i, j] := ch;
          end;
        '@', '+':
          begin
            MapArray[i, j] := ch;
            nRen := nRen+1;
            mr := i;
            mc := j;
          end;
      else
        MapArray[i, j] := '-';
      end;

    end;
  end;

  if nRen <> 1 then begin  // �ֹ�Ա <> 1
    mapNode.isEligible := False;        // ���ϸ�Ĺؿ�XSB
    Exit;
  end;

  for i := 0 to Rows - 1 do begin
    for j := 0 to Cols - 1 do
    begin
      Mark[i][j] := false;
    end;
  end;

  left := mc;
  top := mr;
  right := mc;
  bottom := mr;
  nBox := 0;
  nDst := 0;

  p := 0; tail := 0;
  pos := (mc shl 16) or mr;
  pt[0] := pos;
  Mark[mr][mc] := true;
  while p <= tail do begin // �����Mark[][]Ϊ true �ģ�Ϊǽ��
    mr := pt[p] and $00FF;
    mc := pt[p] shr 16;

    case MapArray[mr, mc] of
      '$':
        begin
          nBox := nBox+1;
        end;
      '*':
        begin
          nBox := nBox+1;
          nDst := nDst+1;
        end;
      '.', '+':
        begin
          nDst := nDst+1;
        end;
    end;
    for k := 0 to 3 do begin   // �ֹ�Ա���ĸ�������
      mr2 := mr + dr4[k];
      mc2 := mc + dc4[k];
      if (mr2 < 0) or (mr2 >= Rows) or (mc2 < 0) or (mc2 >= Cols) or    // ����
         (Mark[mr2, mc2]) or (MapArray[mr2, mc2] = '#') then            // �ѷ��ʻ�����ǽ
          continue;

      // ��������
      if left > mc2 then
        left := mc2;
      if top > mr2 then
        top := mr2;
      if right < mc2 then
        right := mc2;
      if bottom < mr2 then
        bottom := mr2;

      Mark[mr2][mc2] := true;  //���Ϊ�ѷ���
      pos := (mc2 shl 16) or mr2;
      tail := tail+1;
      pt[tail] := pos;
    end;
    p := p+1;
  end;

  mapNode.Boxs  := nBox;
  mapNode.Goals := nDst;

  if (nBox <> nDst) or (nBox < 1) or (nDst < 1) then begin  // �ɴ������ڵ�������Ŀ���������ȷ
    mapNode.isEligible := False;        // ���ϸ�Ĺؿ�XSB
    exit;
  end;

  // ��׼����ĳߴ磨��ת��
  nRows := bottom - top + 1 + 2;
  nCols := right - left + 1 + 2;

  // ����ؿ�Ԫ��
  for i := 0 to Rows - 1 do begin
    for j := 0 to Cols - 1 do
    begin
      ch := MapArray[i, j];
      if (Mark[i, j]) then
      begin  // ǽ��
        if not (ch in ['-', '.', '$', '*', '@', '+']) then
        begin  //��ЧԪ��
          ch := '-';
          MapArray[i, j] := ch;
        end;
      end
      else
      begin  // ǽ������
        if (ch = '*') or (ch = '$') then
        begin
          ch := '#';
          MapArray[i, j] := ch;
        end
        else if not (ch in ['#', '_']) then
        begin  // ��ЧԪ��
          ch := '_';
          MapArray[i, j] := ch;
        end;
      end;
      if (i >= top) and (i <= bottom) and (j >= left) and (j <= right) then
      begin  // ����������Χ��
        if Mark[i, j] then
          aMap0[i - top + 1, j - left + 1] := ch  // ��׼���ؿ�����ЧԪ�أ���ʱ�ճ����ܣ�
        else
          aMap0[i - top + 1, j - left + 1] := '_';
      end;
    end;
  end;

  // �ؿ���С��
  mTop := 0;
  mLeft := 0;
  mBottom := Rows - 1;
  mRight := Cols - 1;
  for k := 0 to Rows - 1 do begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do
      t := t+1;

    if t = Cols then
      mTop := mTop+1
    else
      break;
  end;
  for k := Rows - 1 downto mTop + 1 do begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do
      t := t+1;
    if t = Cols then
      mBottom := mBottom-1
    else
      break;
  end;
  if mBottom - mTop < 2 then Exit;

  for k := 0 to Cols - 1 do begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do
      t := t+1;
    if t > mBottom then
      mLeft := mLeft+1
    else
      break;
  end;
  for k := Cols - 1 downto mLeft + 1 do begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do
      t := t+1;
    if t > mBottom then
      mRight := mRight-1
    else
      break;
  end;
  if mRight - mLeft < 2 then Exit;

  // �ؿ�ԭò�������򵥱�׼��������ǽ�����ͣ�
  mapNode.Map.Clear;
  for i := mTop to mBottom do begin
    s1 := '';  // ���ֹؿ�ԭò����ǽ�����Ͳ��ֲ�������
    for j := mLeft to mRight do
    begin
      s1 := s1 + MapArray[i, j];
    end;
    mapNode.Map.Add(s1);
  end;
  mapNode.Rows := mapNode.Map.Count;
  mapNode.Cols := Length(mapNode.Map[0]);

  // ��׼���ؿ���������� '_'
  for i := 0 to nRows - 1 do begin
    for j := 0 to nCols - 1 do begin
      if (i = 0) or (j = 0) or (i = nRows - 1) or (j = nCols - 1) then
        aMap0[i, j] := '_';
    end;
  end;

  // ��׼��
  for i := 1 to nRows - 2 do begin
    for j := 1 to nCols - 2 do begin
      if (aMap0[i, j] <> '_') and (aMap0[i, j] <> '#') then begin  // ̽���ڲ���ЧԪ�صİ˸���λ���Ƿ���԰���ǽ��
        if (aMap0[i - 1, j] = '_') then
          aMap0[i - 1, j] := '#';
        if (aMap0[i + 1, j] = '_') then
          aMap0[i + 1, j] := '#';
        if (aMap0[i, j - 1] = '_') then
          aMap0[i, j - 1] := '#';
        if (aMap0[i, j + 1] = '_') then
          aMap0[i, j + 1] := '#';
        if (aMap0[i + 1, j - 1] = '_') then
          aMap0[i + 1, j - 1] := '#';
        if (aMap0[i + 1, j + 1] = '_') then
          aMap0[i + 1, j + 1] := '#';
        if (aMap0[i - 1, j - 1] = '_') then
          aMap0[i - 1, j - 1] := '#';
        if (aMap0[i - 1, j + 1] = '_') then
          aMap0[i - 1, j + 1] := '#';
      end;
    end;
  end;

  mapNode.Map_Thin := '';

  // ��׼����İ�ת���ؿ���˳ʱ����ת���õ���0ת��1ת��2ת��3ת����4תΪ0ת�����Ҿ���4ת��˳ʱ����ת���õ���4ת��5ת��6ת��7ת��
  for i := 0 to nRows - 1 do begin
    for j := 0 to nCols - 1 do begin
      mapNode.Map_Thin := mapNode.Map_Thin + aMap0[i, j];
      aMap1[j, nRows - 1 - i] := aMap0[i, j];
      aMap2[nRows - 1 - i, nCols - 1 - j] := aMap0[i, j];
      aMap3[nCols - 1 - j, i] := aMap0[i, j];
      aMap4[i, nCols - 1 - j] := aMap0[i, j];
      aMap5[nCols - 1 - j, nRows - 1 - i] := aMap0[i, j];
      aMap6[nRows - 1 - i, j] := aMap0[i, j];
      aMap7[j, i] := aMap0[i, j];
    end;
    if i < nRows - 1 then mapNode.Map_Thin := mapNode.Map_Thin + #10;
  end;

  // ����
//  Writeln(myLogFile, '333');
//  for j := 0 to mapNode.Map.Count-1 do begin
//    Writeln(myLogFile, mapNode.Map[j]);
//  end;
//  Writeln(myLogFile, Inttostr(mapNode.Rows));
//  Writeln(myLogFile, Inttostr(mapNode.Cols));
//  Writeln(myLogFile, '');
//  Writeln(myLogFile, '444');
//  for i := 0 to nRows-1 do begin
//    for j := 0 to nCols-1 do begin
//      Write(myLogFile, aMap0[i, j]);
//    end;
//    Write(myLogFile, #10);
//  end;

  // �ڼ�ת�� CRC ��С
  key8[1] := Calcu_CRC_32(@aMap1, nCols, nRows);
  key8[2] := Calcu_CRC_32(@aMap2, nRows, nCols);
  key8[3] := Calcu_CRC_32(@aMap3, nCols, nRows);
  key8[4] := Calcu_CRC_32(@aMap4, nRows, nCols);
  key8[5] := Calcu_CRC_32(@aMap5, nCols, nRows);
  key8[6] := Calcu_CRC_32(@aMap6, nRows, nCols);
  key8[7] := Calcu_CRC_32(@aMap7, nCols, nRows);
  mapNode.CRC32 := Calcu_CRC_32(@aMap0, nRows, nCols);        // ��׼��׼����Ĺؿ� -- û��ǽ������
  mapNode.CRC_Num := 0;

  // ����
//  Writeln(myLogFile, '======================');
//  Writeln(myLogFile, inttostr(mapNode.CRC32));
//  Writeln(myLogFile, inttostr(key8[1]));
//  Writeln(myLogFile, inttostr(key8[2]));
//  Writeln(myLogFile, inttostr(key8[3]));
//  Writeln(myLogFile, inttostr(key8[4]));
//  Writeln(myLogFile, inttostr(key8[5]));
//  Writeln(myLogFile, inttostr(key8[6]));
//  Writeln(myLogFile, inttostr(key8[7]));


  for i := 1 to 7 do begin
    if mapNode.CRC32 > key8[i] then
    begin
      mapNode.CRC32 := key8[i];
      mapNode.CRC_Num := i;
    end;
  end;

  mapNode.Num := 0;       // �����Խ��ڹؿ�Ԥ��ʱ����ʶ�Ƿ��������н⡱���
  
  Result := True;
end;

// ȡ�ùؿ� XSB
function GetXSB(mapNpde: PMapNode): string;
var
  i: Integer;
begin
  Result := #10;

  if mapNpde.Map.Count > 0 then begin
    for i := 0 to mapNpde.Map.Count - 1 do begin
      Result := Result + mapNpde.Map.Strings[i] + #10;
    end;
    if Trim(mapNpde.Title) <> '' then
      Result := Result + 'Title: ' + mapNpde.Title + #10;
    if Trim(mapNpde.Author) <> '' then
      Result := Result + 'Author: ' + mapNpde.Author + #10;
    if Trim(mapNpde.Comment) <> '' then begin
      Result := Result + 'Comment: ' + mapNpde.Comment + #10;
      Result := Result + 'Comment_end: ' + #10;
    end;
    Result := Result + #10;
  end;
end;

// ȡ���ֳ� XSB
function GetXSB_2(): string;
var
  i, j, myCell, pos: Integer;

begin
  Result := #10;

  if (not Assigned(curMapNode)) then Exit;

  if curMapNode.Map.Count > 0 then begin
    for i := 0 to curMapNode.Rows - 1 do begin
      for j := 0 to curMapNode.Cols - 1 do begin
        pos := i * curMapNode.Cols + j;
        if main.mySettings.isBK then begin                // ����
           if main.mySettings.isJijing then begin              // ����Ŀ��λ
              if main.map_Board[pos] in [BoxCell, BoxGoalCell] then begin
                 if main.map_Board_BK[pos] = BoxCell then myCell := BoxGoalCell
                 else if main.map_Board_BK[pos] = ManCell then myCell := ManGoalCell
                 else if main.map_Board_BK[pos] = FloorCell then myCell := GoalCell
                 else myCell := main.map_Board_BK[pos];
              end else begin
                 if main.map_Board_BK[pos] = BoxGoalCell then myCell := BoxCell
                 else if main.map_Board_BK[pos] = ManGoalCell then myCell := ManCell
                 else if main.map_Board_BK[pos] = GoalCell then myCell := FloorCell
                 else myCell := main.map_Board_BK[pos];
              end;
           end else if main.mySettings.isSameGoal then begin   // �̶�Ŀ��λ
              if main.map_Board_OG[pos] in [GoalCell, BoxGoalCell, ManGoalCell] then begin
                 if main.map_Board_BK[pos] = BoxCell then myCell := BoxGoalCell
                 else if main.map_Board_BK[pos] = ManCell then myCell := ManGoalCell
                 else if main.map_Board_BK[pos] = FloorCell then myCell := GoalCell
                 else myCell := main.map_Board_BK[pos];
              end else begin
                 if main.map_Board_BK[pos] = BoxGoalCell then myCell := BoxCell
                 else if main.map_Board_BK[pos] = ManGoalCell then myCell := ManCell
                 else if main.map_Board_BK[pos] = GoalCell then myCell := FloorCell
                 else myCell := main.map_Board_BK[pos];
              end;
           end else begin
              myCell := main.map_Board_BK[pos];
           end;
        end else begin
           if main.mySettings.isJijing then begin              // ����Ŀ��λ
              if main.map_Board_BK[pos] in [BoxGoalCell, BoxCell] then begin
                 if main.map_Board[pos] = BoxCell then myCell := BoxGoalCell
                 else if main.map_Board[pos] = ManCell then myCell := ManGoalCell
                 else if main.map_Board[pos] = FloorCell then myCell := GoalCell
                 else myCell := main.map_Board[pos];
              end else begin
                 if main.map_Board[pos] = BoxGoalCell then myCell := BoxCell
                 else if main.map_Board[pos] = ManGoalCell then myCell := ManCell
                 else if main.map_Board[pos] = GoalCell then myCell := FloorCell
                 else myCell := main.map_Board[pos];
              end;
           end else begin
              myCell := main.map_Board[pos];
           end;
        end;
        Result := Result + xbsChar[myCell];
      end;
      Result := Result + #10;
    end;
  end;
end;

// �ں�̨�߳��м��ص�ͼ�ĵ�
procedure TLoadMapThread.Execute;
var
  FileName: string;
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  num, n, k: Integer;              // XSB�Ľ�������
  mapNode: PMapNode;               // �������ĵ�ǰ�ؿ��ڵ�ָ��
  mapSolution: TStringList;        // �ؿ���
  tmpMapList: TList;               // ��ʱ�ؿ��б�
  txtLines: Integer;

begin
  FreeOnTerminate := True;

  main.bt_View.Enabled := False;
  
  isStopThread := False;

  MyListClear(MapList);

  FileName := main.mySettings.MapFileName;

  if Pos(':', FileName) = 0 then FileName := AppPath + FileName;
  if FileExists(FileName) then begin

    MapCount := 1;
    
    tmpMapList := TList.Create;             // �ؿ��б�

    try
      txtLines := main.txtList.Count;         // �ı�����

      mapSolution := TStringList.Create;

      try
        NewMapNode(tmpMapList);              // �ȴ���һ���ؿ��ڵ�
        mapNode := tmpMapList.Items[0];      // ָ�����´����Ľڵ�
        mapNode.isEligible := True;          // Ĭ���Ǻϸ�Ĺؿ�XSB
        is_XSB := False;
        is_Comment := False;

        k := 0;
        while (k < txtLines) and (not isStopThread) do begin
          line  := main.txtList.Strings[k];
          line2 := Trim(line);

          if (not is_Comment) and isXSB(line) then begin       // ����Ƿ�Ϊ XSB ��
            if not is_XSB then begin       // ��ʼ XSB ��

              if mapNode.Map.Count > 2 then begin   // ǰ���н������Ĺؿ� XSB����ѵ�ǰ�ؿ�����ؿ����б�

                MapCount := MapCount + 1;

                MapNormalize(mapNode);         // ���ؿ��ı�׼��������CRC��

                NewMapNode(tmpMapList);                      // ����һ���µĹؿ��ڵ�
                num := tmpMapList.Count - 1;
                mapNode := tmpMapList.Items[num];            // ָ�����´����Ľڵ�
                mapNode.isEligible := True;               // Ĭ���Ǻϸ�Ĺؿ�XSB

              end else mapNode.Map.Clear;

              is_XSB := True;    // ��ʼ�ؿ� XSB ��
              is_Comment := False;
              mapNode.Rows := 0;
              mapNode.Cols := 0;
              mapNode.Title := '';
              mapNode.Author := '';
              mapNode.Comment := '';
            end;

            mapNode.Map.Add(line);    // �� XSB ��

          end
          else if (not is_Comment) and (AnsiStartsText('title', line2)) and (mapNode.Title = '') then begin   // ƥ�� Title������
            n := Pos(':', line2);
            if n > 0 then
              mapNode.Title := trim(Copy(line2, n + 1, MaxInt))
            else
              mapNode.Title := trim(Copy(line2, 6, MaxInt));

            if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
          end
          else if (not is_Comment) and (AnsiStartsText('author', line2)) and (mapNode.Author = '') then begin  // ƥ�� Author������
            n := Pos(':', line2);
            if n > 0 then
              mapNode.Author := trim(Copy(line2, n + 1, MaxInt))
            else
              mapNode.Author := trim(Copy(line2, 7, MaxInt));

            if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
          end
          else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // ƥ��"ע��"�����
            is_Comment := False; // ����"ע��"��
          end
          else if AnsiStartsText('comment', line2) and (mapNode.Comment = '') then begin  //ƥ��"ע��"�鿪ʼ
            if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
            n := Pos(':', line2);
            if n > 0 then
              line := trim(Copy(line2, n + 1, MaxInt))
            else
              line := trim(Copy(line2, 8, MaxInt));
            if Length(line) > 0 then
              mapNode.Comment := line     // ����"ע��"
            else
              is_Comment := True;     // ��ʼ"ע��"��
          end
          else if is_Comment then begin  // "˵��"��Ϣ
            if Length(mapNode.Comment) > 0 then
              mapNode.Comment := mapNode.Comment + #10 + line
            else
              mapNode.Comment := line;
          end
          else begin
            if is_XSB then is_XSB := false;      // �����ؿ�SXB��Ľ���
          end;
          k := k+1;
        end;

      finally
        // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
        num := tmpMapList.Count - 1;
        if num >= 0 then begin
           mapNode := tmpMapList.Items[num];
           if mapNode.Map.Count < 3 then begin
              MyStringListFree(mapNode.Map);
              tmpMapList.Delete(num);
              Dispose(mapNode);
           end else begin
             MapNormalize(mapNode);
           end;
        end else if Assigned(mapNode) then begin
           if mapNode.Map.Count > 0 then begin
              MyStringListFree(mapNode.Map);
           end;
           Dispose(mapNode);
        end;
        mapNode := nil;

        MyStringListFree(mapSolution);
      end;
    finally
      if Assigned(tmpMapList) then begin
         if tmpMapList.Count > 0 then begin
            MapList := tmpMapList;
         end else begin
            MyListClear(tmpMapList);
         end;
         tmpMapList := nil;
      end;
    end;
  end;
  
  isStopThread := True;
  main.bt_View.Enabled := True;
end;

// ���������ڱ���
procedure TLoadAnsThread.UpdateCaption;
begin
  try
    MyOpenFile.Label1.Caption := '������� ' + IntToStr(sumSolution) + ' ��';
  except
  end;
end;

// ����𰸵ĺ�̨�߳�
procedure TLoadAnsThread.Execute;
var
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Solution: Boolean;            // �Ƿ����
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  num, n, k: Integer;              // XSB�Ľ�������
  mapNode: PMapNode;               // �������ĵ�ǰ�ؿ��ڵ�ָ��
  mapSolution: TStringList;        // �ؿ���
  data_Text: TStringList;          // �ı���
begin
  FreeOnTerminate := True;

  isStopThread_Ans := False;
  
  data_Text := TStringList.Create;          // �ı���

  try

    data_Text.LoadFromFile(MyOpenFile.FileListBox1.FileName);    // �ı���

    mapSolution := TStringList.Create;      // �𰸻���

    try

      New(mapNode);                         // �ؿ��ڵ�

      try
        // �ڵ�Ĭ��ֵ
        mapNode.Map_Thin := '';
        mapNode.Rows := 0;
        mapNode.Cols := 0;
        mapNode.Trun := 0;
        mapNode.Title := '';
        mapNode.Author := '';
        mapNode.Comment := '';
        mapNode.CRC32 := -1;
        mapNode.CRC_Num := -1;
        mapNode.Solved := false;
        mapNode.isEligible := True;

        mapNode.Map := TStringList.Create;    // ��ͼ��
      
        try
          is_XSB := False;
          is_Comment := False;
          is_Solution := False;


          num := 0;
          sumSolution := 0;
          k := 0;
          while (k < data_Text.Count) and (not isStopThread_Ans) do begin

            line := data_Text.Strings[k];     // ��ȡһ��
            k := k+1;
            line2 := Trim(line);

            if (not is_Comment) and isXSB(line) then begin       // ����Ƿ�Ϊ XSB ��
              if not is_XSB then begin     // ��ʼ XSB ��

                if mapNode.Map.Count > 2 then begin   // ǰ���н������Ĺؿ� XSB����ѵ�ǰ�ؿ�����ؿ����б�

                  MyOpenFile.Caption := '����� ~ �ؿ���' + IntToStr(num);

                  // ���ؿ��ı�׼��������CRC��
                  if MapNormalize(mapNode) then begin
                     num := num + 1;
                     SetSolved_2(mapNode, mapSolution);
                  end;
                end;

                mapNode.Map.Clear;

                is_XSB := True;    // ��ʼ�ؿ� XSB ��
                is_Comment := False;
                is_Solution := False;
                mapNode.Rows := 0;
                mapNode.Cols := 0;
                mapNode.Title := '';
                mapNode.Author := '';
                mapNode.Comment := '';
              end;

              mapNode.Map.Add(line);    // �� XSB ��

            end
            else if (not is_Comment) and (AnsiStartsText('solution', line2)) then begin  // ƥ�� Solution����
              n := LastPos(':', line2);
              if n = 0 then
                n := Pos(')', line2);

              if n > 0 then
                line := trim(Copy(line2, n + 1, MaxInt))
              else
                line := trim(Copy(line2, 9, MaxInt));

              if Length(line) > 0 then
                mapSolution.Add(line)
              else
                mapSolution.Add('');

              if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
              is_Solution := true;                 // ��ʼ�𰸽���
            end
            else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // ƥ��"ע��"�����
              is_Comment := False;   // ����"ע��"��
            end
            else if AnsiStartsText('comment', line2) and (mapNode.Comment = '') then begin  //ƥ��"ע��"�鿪ʼ
              if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���

              n := Pos(':', line2);
              if n > 0 then
                line := trim(Copy(line2, n + 1, MaxInt))
              else
                line := trim(Copy(line2, 8, MaxInt));

              if Length(line) <= 0 then is_Comment := True;         // ��ʼ"ע��"��
            end
            else if is_Solution then begin  // ����
              line2 := StringReplace(line2, #9, '', [rfReplaceAll]);
              line2 := StringReplace(line2, ' ', '', [rfReplaceAll]);
              if isLurd(line2) then begin
                 n := mapSolution.Count - 1;
                 mapSolution[n] := mapSolution[n] + line2;
              end;
            end
            else if is_Comment then begin  // "˵��"��Ϣ
            end
            else begin
              if is_XSB then is_XSB := false;      // �����ؿ�SXB��Ľ���
            end;
          end;
        finally
          if (mapNode.Map.Count > 2) and (not isStopThread_Ans) then begin
            if MapNormalize(mapNode) then begin
               SetSolved_2(mapNode, mapSolution);
            end;
          end;
          MyStringListFree(mapNode.Map);
        end;
      finally
        Dispose(mapNode);
        mapNode := nil;
      end;
    finally
      MyStringListFree(mapSolution);
    end;
  finally
    MyStringListFree(data_Text);
  end;

  synchronize(UpdateCaption);     // ������������ʾ
  isStopThread_Ans := True;
end;

function FindClipbrd(num: Integer): Integer;                                       // �ڹؿ��б��У����Ҽ��а��еĹؿ��������ҵ�����ţ�û�ҵ��򷵻� -1
var
  mapNode: PMapNode;
  str: string;
  i, len: Integer;
begin
  Result := -1;

  len := MapList.Count;
  if len = 0 then Exit;

  New(mapNode);

  try
    mapNode.Map := TStringList.Create;
    try
      mapNode.Map_Thin := '';
      mapNode.Rows := 0;
      mapNode.Cols := 0;
      mapNode.Trun := 0;
      mapNode.Title := '';
      mapNode.Author := '';
      mapNode.Comment := '';
      mapNode.CRC32 := -1;
      mapNode.CRC_Num := -1;
      mapNode.Solved := false;

      // ���а嵼�� XSB
      if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
          str := Clipboard.asText;
          Split(str, mapNode.Map);

          if MapNormalize(mapNode) then begin
             for i := num+1 to len-1 do begin
                 if mapNode.CRC32 = PMapNode(MapList[i])^.CRC32 then begin
                    Result := i;
                    Break;
                 end;
             end;
          end;
      end;
    finally
      MyStringListFree(mapNode.Map);
    end;
  finally
    if Assigned(mapNode) then begin
       Dispose(mapNode);
       mapNode := nil;
    end;
  end;

end;
end.

