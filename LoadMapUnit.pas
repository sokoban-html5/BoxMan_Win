unit LoadMapUnit;
// �ؿ��ı�������Ԫ

interface

uses
  windows, classes, StrUtils, SysUtils, Clipbrd, Graphics, Math, CRC_32;

type
  TLoadMapThread = class(TThread)         // ��̨���ص�ͼ�ĵ��߳�
  protected
    procedure UpdateCaption;
    procedure Execute; override;
  public
    isRunning: Boolean;
  end;

type                  // �ؿ��ڵ� -- �ؿ����еĸ����ؿ�
  TMapNode = record
    Map: TStringList;    // �ؿ� XSB
    Rows, Cols: integer;        // �ؿ��ߴ�
    Boxs: integer;        // ������
    Goals: integer;        // Ŀ�����
    Trun: integer;        // �ؿ���ת�Ǽ�
    Title: string;         // ����
    Author: string;         // ����
    Comment: string;         // �ؿ�������Ϣ
    CRC32: integer;        // CRC32
    CRC_Num: integer;        // ����ǰ��ͼΪ 0 ת����С CRC λ�ڵڼ�ת��
    Solved: Boolean;        // �Ƿ��ɴ�
    isEligible: Boolean;        // �Ƿ�ϸ�Ĺؿ�XSB
    Num: integer;        // �ؿ���� -- �������ĵ����һ���ؿ�ʱʹ��
  end;

  PMapNode = ^TMapNode;              // �ؿ��ڵ�ָ��

function GetXSB(): string;                                     // ȡ�ùؿ� XSB

procedure XSBToClipboard();                                    // XSB ������а�

function LoadMapsFromText(text: string): boolean;         // ���عؿ� -- �Ӽ��а���ı��ַ���

function QuicklyLoadMap(FileName: string; number: Integer): PMapNode;  // Ѹ�ٵļ���ָ���ĵ��ĵ� number �ŵ�ͼ

function MapNormalize(var mapNode: PMapNode): Boolean;         // ��ͼ��׼�����������򵥱�׼�� -- �����ؿ���ǽ�����ͣ���׼��׼�� -- �������ؿ���ǽ�����ͣ�ͬʱ���� CRC ��

function isSolution(mapNode: PMapNode; sol: PChar): Boolean;   // ����֤

var
  isStopThread: Boolean;                              // �Ƿ���ֹ��̨�߳�
  LoadMapThread: TLoadMapThread;                     // ��̨���ص�ͼ�ĵ��߳�
  ManPos_BK_0: integer;                     // �˵�λ�� -- ���ƣ�����Ѿ�ָ����λ��
  ManPos_BK_0_2: integer;                     // �˵�λ�� -- ���ƣ�����������λ��

  sMoves, sPushs: integer;                            // ��֤��ʱ����¼�ƶ������ƶ���

  MapList: TList;                          // �ؿ��б�
  MapArray: array[0..99, 0..99] of Char;   // ��׼���ùؿ�����
  Mark: array[0..99, 0..99] of Boolean;    // ��׼���ñ�־����
  curMapNode: PMapNode;                   // ��ǰ�ؿ��ڵ�
  SolvedLevel: array[0..30] of Integer;     // ����̨û�м�����ؿ�ʱ����ʱ�ǼǼ����ڼ���ҽ⿪�Ĺؿ����

  isOnlyXSB: boolean;                      // �򿪹ؿ��ĵ�ʱ��������XSB -- ���Դ�

  tmp_Board: array[0..9999] of integer;   // ��ʱ��ͼ

  // ��׼���ùؿ�����
  aMap0: array[0..99, 0..99] of Char;
  aMap1: array[0..99, 0..99] of Char;
  aMap2: array[0..99, 0..99] of Char;
  aMap3: array[0..99, 0..99] of Char;
  aMap4: array[0..99, 0..99] of Char;
  aMap5: array[0..99, 0..99] of Char;
  aMap6: array[0..99, 0..99] of Char;
  aMap7: array[0..99, 0..99] of Char;

implementation

uses
  LogFile, OpenFile, BrowseLevels, //
  LurdAction, DateModule, MainForm, LoadSkin;

const
  EmptyCell = 0;
  WallCell = 1;
  FloorCell = 2;
  GoalCell = 3;
  BoxCell = 4;
  BoxGoalCell = 5;
  ManCell = 6;
  ManGoalCell = 7;

// ȡ���Ӵ������ֵ�λ��
function LastPos(const SubStr, Str: ansistring): Integer;
var
  Idx: Integer;
begin
  Result := 0;
  Idx := StrUtils.PosEx(SubStr, Str);
  if Idx = 0 then
    Exit;
  while Idx > 0 do
  begin
    Result := Idx;
    Idx := StrUtils.PosEx(SubStr, Str, Idx + 1);
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
  for i := 0 to Rows - 1 do
  begin
    for j := 1 to Cols do
    begin
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

      if ch in ['@', '+'] then
        mpos := i * Cols + j;
    end;
  end;

  if mpos < 0 then
    Exit;
  sPushs := 0;
  sMoves := 0;

  // ����֤
  len := Length(sol);
  for i := 0 to len - 1 do
  begin
    pos1 := -1;
    pos2 := -1;
    ch := sol[i];
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
    isPush := ch in ['L', 'R', 'U', 'D'];

    if (pos1 < 0) or (pos1 >= size) or (isPush and ((pos1 < 0) or (pos1 >= size))) then
      Exit;             // ����

    if isPush then
    begin                                                                                 // ��Ч�ƶ�
      if (tmp_Board[pos1] <> BoxCell) and (tmp_Board[pos1] <> BoxGoalCell) or (tmp_Board[pos2] <> FloorCell) and (tmp_Board[pos2] <> GoalCell) then
        Exit;
      if tmp_Board[pos2] = FloorCell then
        tmp_Board[pos2] := BoxCell
      else
        tmp_Board[pos2] := BoxGoalCell;
      if tmp_Board[pos1] = BoxCell then
        tmp_Board[pos1] := ManCell
      else
        tmp_Board[pos1] := ManGoalCell;
      if tmp_Board[mpos] = ManCell then
        tmp_Board[mpos] := FloorCell
      else
        tmp_Board[mpos] := GoalCell;
    end
    else
    begin
      if (tmp_Board[pos1] <> FloorCell) and (tmp_Board[pos1] <> GoalCell) then
        Exit;                    // ��Ч�ƶ�
      if tmp_Board[pos1] = FloorCell then
        tmp_Board[pos1] := ManCell
      else
        tmp_Board[pos1] := ManGoalCell;
      if tmp_Board[mpos] = ManCell then
        tmp_Board[mpos] := FloorCell
      else
        tmp_Board[mpos] := GoalCell;
    end;

    if isPush then
      Inc(sPushs);
    Inc(sMoves);

    mpos := pos1;

    okNum := 0;
    for j := 0 to size - 1 do
    begin
      if (tmp_Board[j] = BoxGoalCell) then
        Inc(okNum);

      if okNum = mapNode.Goals then
      begin                     // �ܹ���أ�Ϊ��Ч��
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

end;

// ����Ƿ�Ϊ�н�ؿ� -- ���а嵼��ʱʹ��
procedure SetSolved(mapNode: PMapNode; var Solitions: TStringList);
var
  i, l, solCRC: Integer;
  is_Solved: Boolean;
begin
  is_Solved := false;
  mapNode.Solved := false;

  // ���������˴𰸣�����֤�𰸲��������
  if Solitions.Count > 0 then
  begin
    l := Solitions.Count;
    for i := l - 1 downto 0 do
    begin
      if isSolution(mapNode, PChar(Solitions[i])) then      // �Դ𰸽�����֤
      begin    // ���浽���ݿ�
            // ����𰸵����ݿ�
        try
          DataModule1.ADOQuery1.Close;
          DataModule1.ADOQuery1.SQL.Clear;
          DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
          DataModule1.ADOQuery1.Open;
          DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;

          with DataModule1.DataSource1.DataSet do
          begin
                // ����
            solCRC := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
            First;
            while not Eof do
            begin
              if (FieldByName('Sol_CRC32').AsInteger = solCRC) and (FieldByName('Moves').AsInteger = sMoves) and (FieldByName('Pushs').AsInteger = sPushs) then
                Break;

              Next;
            end;

            // û���ظ��𰸣�����ӵ��𰸿�
            if Eof then
            begin
              Append;    // �޸�

              FieldByName('XSB_CRC32').AsInteger := mapNode.CRC32;
              FieldByName('XSB_CRC_TrunNum').AsInteger := mapNode.CRC_Num;
              FieldByName('Goals').AsInteger := mapNode.Goals;
              FieldByName('Sol_CRC32').AsInteger := solCRC;
              FieldByName('Moves').AsInteger := sMoves;
              FieldByName('Pushs').AsInteger := sPushs;
              FieldByName('Sol_Text').AsString := Solitions[i];

              Post;    // �ύ
            end;
          end;
        except
        end;
      end
      else
      begin
        Solitions.Delete(i);
      end;
    end;
    is_Solved := True;
    Solitions.Clear;
  end;

  if is_Solved then
    mapNode.Solved := is_Solved
  else
  begin
    // ���ݿ����Ƿ��н�
    try
      DataModule1.ADOQuery1.Close;
      DataModule1.ADOQuery1.SQL.Clear;
      DataModule1.ADOQuery1.SQL.Text := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
      DataModule1.ADOQuery1.Open;
      mapNode.Solved := (DataModule1.ADOQuery1.RecordCount > 0);
    except
    end;
  end;
  DataModule1.ADOQuery1.Close;
end;

// ����Ƿ�Ϊ�н�ؿ� -- ��̨�߳�ʹ��
procedure SetSolved_2(mapNode: PMapNode; var Solitions: TStringList);
var
  i, l, solCRC: Integer;
  is_Solved: Boolean;
begin
  is_Solved := false;
  mapNode.Solved := false;

  // ���������˴𰸣�����֤�𰸲��������
  if Solitions.Count > 0 then
  begin
    l := Solitions.Count;
    for i := l - 1 downto 0 do
    begin
      if isSolution(mapNode, PChar(Solitions[i])) then      // �Դ𰸽�����֤
      begin    // ���浽���ݿ�
            // ����𰸵����ݿ�
        try
          DataModule1.ADOQuery2.Close;
          DataModule1.ADOQuery2.SQL.Clear;
          DataModule1.ADOQuery2.SQL.Text := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
          DataModule1.ADOQuery2.Open;
          DataModule1.DataSource2.DataSet := DataModule1.ADOQuery2;

          with DataModule1.DataSource2.DataSet do
          begin
                // ����
            solCRC := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
            First;
            while not Eof do
            begin
              if (FieldByName('Sol_CRC32').AsInteger = solCRC) and (FieldByName('Moves').AsInteger = sMoves) and (FieldByName('Pushs').AsInteger = sPushs) then
                Break;

              Next;
            end;

            // û���ظ��𰸣�����ӵ��𰸿�
            if Eof then
            begin
              Append;    // �޸�

              FieldByName('XSB_CRC32').AsInteger := mapNode.CRC32;
              FieldByName('XSB_CRC_TrunNum').AsInteger := mapNode.CRC_Num;
              FieldByName('Goals').AsInteger := mapNode.Goals;
              FieldByName('Sol_CRC32').AsInteger := solCRC;
              FieldByName('Moves').AsInteger := sMoves;
              FieldByName('Pushs').AsInteger := sPushs;
              FieldByName('Sol_Text').AsString := Solitions[i];

              Post;    // �ύ
            end;
          end;
        except
        end;
      end
      else
      begin
        Solitions.Delete(i);
      end;
    end;
    is_Solved := True;
    Solitions.Clear;
  end;

  if is_Solved then
    mapNode.Solved := is_Solved
  else
  begin
    // ���ݿ����Ƿ��н�
    try
      DataModule1.ADOQuery2.Close;
      DataModule1.ADOQuery2.SQL.Clear;
      DataModule1.ADOQuery2.SQL.Text := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
      DataModule1.ADOQuery2.Open;
      mapNode.Solved := (DataModule1.ADOQuery2.RecordCount > 0);
    except
    end;
  end;
  DataModule1.ADOQuery2.Close;
end;


// Ѹ�ٵļ���ָ���ĵ��ĵ� num �ŵ�ͼ
function QuicklyLoadMap(FileName: string; number: Integer): PMapNode;
var
  txtFile: TextFile;
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  num, n: Integer;                 // XSB�Ľ�������

begin
  try
    AssignFile(txtFile, FileName);
    Reset(txtFile);

    New(Result);
    Result.Map := TStringList.Create;
    Result.Rows := 0;
    Result.Cols := 0;
    Result.Trun := 0;
    Result.Title := '';
    Result.Author := '';
    Result.Comment := '';
    Result.CRC32 := -1;
    Result.CRC_Num := -1;
    Result.Solved := false;
    Result.isEligible := True;      // Ĭ���Ǻϸ�Ĺؿ� XSB

    is_XSB := False;
    is_Comment := False;
    num := 0;

    while not eof(txtFile) do
    begin

      readln(txtFile, line);        // ��ȡһ��
      line2 := Trim(line);

      if (not is_Comment) and isXSB(line) then
      begin       // ����Ƿ�Ϊ XSB ��
        if not is_XSB then
        begin     // ��ʼ XSB ��

          if (Result.Rows > 2) or (num = 0) then
            inc(num);     // �����ĵ� num �� XSB ��

          if num > number then
            Break;

          is_XSB := True;    // ��ʼ�ؿ� XSB ��
          is_Comment := False;
          Result.Map.Clear;
          Result.Rows := 0;
          Result.Num := num;
        end;

        if num = number then
        begin
          Result.Map.Add(line);      // �� XSB ��
        end;
        inc(Result.Rows);

      end
      else if (not is_Comment) and (AnsiStartsText('title', line2)) then
      begin   // ƥ�� Title������
        if num = number then
        begin
          n := Pos(':', line2);
          if n > 0 then
            Result.Title := trim(Copy(line2, n + 1, MaxInt))
          else
            Result.Title := trim(Copy(line2, 6, MaxInt));
        end;

        if is_XSB then
          is_XSB := false;      // �����ؿ�SXB�Ľ���
      end
      else if (not is_Comment) and (AnsiStartsText('author', line2)) then
      begin  // ƥ�� Author������
        if num = number then
        begin
          n := Pos(':', line2);
          if n > 0 then
            Result.Author := trim(Copy(line2, n + 1, MaxInt))
          else
            Result.Author := trim(Copy(line2, 7, MaxInt));
        end;

        if is_XSB then
          is_XSB := false;      // �����ؿ�SXB�Ľ���
      end
      else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then
      begin  // ƥ��"ע��"�����
        is_Comment := False;
        ;      // ����"ע��"��
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
        begin
          if num = number then
            Result.Comment := line;     // ����"ע��"
        end
        else
          is_Comment := True;
        ;                            // ����"ע��"��

        if is_XSB then
          is_XSB := false;      // �����ؿ�SXB�Ľ���
      end
      else if is_Comment then
      begin  // "˵��"��Ϣ
        if num = number then
        begin
          if Length(Result.Comment) > 0 then
            Result.Comment := Result.Comment + #10 + line
          else
            Result.Comment := line;
        end;
      end
      else
      begin
        if is_XSB then
          is_XSB := false;      // �����ؿ�SXB��Ľ���
      end;
    end;

    // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
    if Result.Rows > 2 then
      MapNormalize(Result)
    else
    begin
      Result.Map.Clear;
      Result.Rows := 0;
    end;

    CloseFile(txtFile);                //�رմ򿪵��ļ�
  except
    Result.Map.Clear;
    Result.Rows := 0;
  end;
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

// ��ȡ�ؿ� -- �Ӽ��а���ı��ַ�����text = nil ʱ���Զ��Ӽ��а����
function LoadMapsFromText(text: string): boolean;
var
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Solution: Boolean;            // �Ƿ����
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  num, n, k: Integer;        // XSB�Ľ�������
  mapNode: PMapNode;               // �������ĵ�ǰ�ؿ��ڵ�ָ��
  mapSolution: TStringList;        // �ؿ���
  XSB_Text: string;
  data_Text: TStringList;
  tmpList: TList;
begin
  Result := False;

  if text = '' then begin
     // ��ѯ���������ض���ʽ����������
     if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
        XSB_Text := Clipboard.asText;
        data_Text := Split(XSB_Text);
     end else Exit;
  end else data_Text := Split(text);     // ���ַ�������
  

  MapList.Clear;
  tmpList := TList.Create;
  mapSolution := TStringList.Create;

  NewMapNode(tmpList);                // �ȴ���һ���ؿ��ڵ�
  is_XSB := False;
  is_Comment := False;
  is_Solution := False;
  mapNode := tmpList.Items[0];    // ָ�����´����Ľڵ�
  mapNode.isEligible := True;         // Ĭ���Ǻϸ�Ĺؿ�XSB
  k := 0;

  while k < data_Text.Count do
  begin

    line := data_Text.Strings[k];       // ��ȡһ��
    Inc(k);
    line2 := Trim(line);

    if (not is_Comment) and isXSB(line) then
    begin       // ����Ƿ�Ϊ XSB ��
      if not is_XSB then
      begin     // ��ʼ XSB ��

        if mapNode.Map.Count > 2 then
        begin   // ǰ���н������Ĺؿ� XSB����ѵ�ǰ�ؿ�����ؿ����б�
              // ���ؿ��ı�׼��������CRC��
          if MapNormalize(mapNode) then
          begin
            SetSolved(mapNode, mapSolution);
          end;

          NewMapNode(tmpList);                                  // ����һ���µĹؿ��ڵ�
          num := tmpList.Count - 1;
          mapNode := tmpList.Items[num];                        // ָ�����´����Ľڵ�
          mapNode.isEligible := True;                           // Ĭ���Ǻϸ�Ĺؿ�XSB

        end
        else
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
    else if (not is_Comment) and (AnsiStartsText('title', line2)) then
    begin   // ƥ�� Title������
      n := Pos(':', line2);
      if n > 0 then
        mapNode.Title := trim(Copy(line2, n + 1, MaxInt))
      else
        mapNode.Title := trim(Copy(line2, 6, MaxInt));

      if is_XSB then
        is_XSB := false;      // �����ؿ�SXB�Ľ���
    end
    else if (not is_Comment) and (AnsiStartsText('author', line2)) then
    begin  // ƥ�� Author������
      n := Pos(':', line2);
      if n > 0 then
        mapNode.Author := trim(Copy(line2, n + 1, MaxInt))
      else
        mapNode.Author := trim(Copy(line2, 7, MaxInt));

      if is_XSB then
        is_XSB := false;      // �����ؿ�SXB�Ľ���
    end
    else if (not is_Comment) and (AnsiStartsText('solution', line2)) then
    begin  // ƥ�� Solution����
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

      if is_XSB then
        is_XSB := false;      // �����ؿ�SXB�Ľ���
      is_Solution := true;                 // ��ʼ�𰸽���
    end
    else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then
    begin  // ƥ��"ע��"�����
      is_Comment := False;
      ;  // ����"ע��"��
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
        mapNode.Comment := line     // ����"ע��"
      else
        is_Comment := True;
      ;  // ����"ע��"��
    end
    else if is_Comment then
    begin  // "˵��"��Ϣ
      if Length(mapNode.Comment) > 0 then
        mapNode.Comment := mapNode.Comment + #10 + line
      else
        mapNode.Comment := line;

      if is_XSB then
        is_XSB := false;      // �����ؿ�SXB�Ľ���
    end
    else if is_Solution then
    begin  // ����
      line2 := StringReplace(line2, #9, '', [rfReplaceAll]);
      line2 := StringReplace(line2, ' ', '', [rfReplaceAll]);
      if isLurd(line2) then
      begin
        n := mapSolution.Count - 1;
        mapSolution[n] := mapSolution[n] + line2;
      end;
    end
    else
    begin
      if is_XSB then
        is_XSB := false;      // �����ؿ�SXB��Ľ���
    end;
  end;

  // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
  num := tmpList.Count - 1;
  mapNode := tmpList.Items[num];
  if mapNode.Map.Count < 3 then
    tmpList.Delete(num)
  else
  begin
    if MapNormalize(mapNode) then
    begin
      SetSolved(mapNode, mapSolution);
    end
    else
      tmpList.Delete(num);
  end;


  if tmpList.Count > 0 then
  begin
    MapList := tmpList;
    tmpList := nil;
    Result := true;
  end;

  FreeAndNil(tmpList);
  FreeAndNil(mapSolution);

end;

// ��ͼ��׼�����������򵥱�׼�� -- �����ؿ���ǽ�����ͣ���׼��׼�� -- �������ؿ���ǽ�����ͣ�ͬʱ���� CRC ��
function MapNormalize(var mapNode: PMapNode): Boolean;
var
  i, j, k, t, mr, mc, Rows, Cols, nLen, nRen, nRows, nCols: Integer;
  ch: Char;
  mr2, mc2, left, top, right, bottom, nBox, nDst, mTop, mLeft, mBottom, mRight: Integer;
  P: TList;
  Pos, F: ^TPoint;
  s1: string;
  key8: array[0..7] of Integer;
begin
  Result := False;

  mr := -1;
  mc := -1;
  nRen := 0;
  Rows := mapNode.Map.Count;
  Cols := 0;
  for i := 0 to Rows - 1 do
  begin
    nLen := Length(mapNode.Map[i]);
    if Cols < nLen then
      Cols := nLen;
  end;

  mapNode.Rows := Rows;
  mapNode.Cols := Cols;

  if (Rows >= 100) or (Cols >= 100) then
  begin
    mapNode.Rows := 100;
    mapNode.Cols := 100;
    mapNode.isEligible := False;        // ���ϸ�Ĺؿ�XSB
    Exit;
  end;

  for i := 0 to Rows - 1 do
  begin
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
            Inc(nRen);
            mr := i;
            mc := j;
          end;
      else
        MapArray[i, j] := '-';
      end;

    end;
  end;

  if nRen <> 1 then
  begin  // �ֹ�Ա <> 1
    mapNode.isEligible := False;        // ���ϸ�Ĺؿ�XSB
    Exit;
  end;

  for i := 0 to Rows - 1 do
  begin
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

  P := TList.Create;
  New(Pos);
  Pos.x := mc;
  Pos.y := mr;
  P.add(Pos);
  Mark[mr][mc] := true;
  while P.Count > 0 do
  begin // �����Mark[][]Ϊ true �ģ�Ϊǽ��
    F := P.Items[0];
    mr := F.Y;
    mc := F.X;
    P.Delete(0);

    case MapArray[mr, mc] of
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
    for k := 0 to 3 do
    begin   // �ֹ�Ա���ĸ�������
      mr2 := mr + dr4[k];
      mc2 := mc + dc4[k];
      if (mr2 < 0) or (mr2 >= Rows) or (mc2 < 0) or (mc2 >= Cols) or    // ����
        (Mark[mr2, mc2]) or (MapArray[mr2, mc2] = '#') then
        continue;  // �ѷ��ʻ�����ǽ
      // ��������
      if left > mc2 then
        left := mc2;
      if top > mr2 then
        top := mr2;
      if right < mc2 then
        right := mc2;
      if bottom < mr2 then
        bottom := mr2;

      New(Pos);
      Pos.x := mc2;
      Pos.y := mr2;
      P.add(Pos);
      Mark[mr2][mc2] := true;  //���Ϊ�ѷ���
    end;
  end;
  FreeAndNil(P);

  mapNode.Goals := nDst;

  if (nBox <> nDst) or (nBox < 1) or (nDst < 1) then
  begin  // �ɴ������ڵ�������Ŀ���������ȷ
    mapNode.isEligible := False;        // ���ϸ�Ĺؿ�XSB
    exit;
  end;

  // ��׼����ĳߴ磨��ת��
  nRows := bottom - top + 1 + 2;
  nCols := right - left + 1 + 2;

  // ����ؿ�Ԫ��
  for i := 0 to Rows - 1 do
  begin
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
  for k := 0 to Rows - 1 do
  begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do
      Inc(t);

    if t = Cols then
      Inc(mTop)
    else
      break;
  end;
  for k := Rows - 1 downto mTop + 1 do
  begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do
      Inc(t);
    if t = Cols then
      Dec(mBottom)
    else
      break;
  end;
  if mBottom - mTop < 2 then
  begin
    Exit;
  end;

  for k := 0 to Cols - 1 do
  begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do
      Inc(t);
    if t > mBottom then
      Inc(mLeft)
    else
      break;
  end;
  for k := Cols - 1 downto mLeft + 1 do
  begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do
      Inc(t);
    if t > mBottom then
      Dec(mRight)
    else
      break;
  end;
  if mRight - mLeft < 2 then
  begin
    Exit;
  end;

  // �ؿ�ԭò�������򵥱�׼��������ǽ�����ͣ�
  mapNode.Map.Clear;
  for i := mTop to mBottom do
  begin
    s1 := '';  // ���ֹؿ�ԭò����ǽ�����Ͳ��ֲ�������
    for j := mLeft to mRight do
    begin
      s1 := s1 + MapArray[i, j];
    end;
    mapNode.Map.Add(s1);
  end;
//  mapNode.Rows := mBottom-mTop+1;
//  mapNode.Cols := mRight-mLeft+1;
  mapNode.Rows := mapNode.Map.Count;
  mapNode.Cols := Length(mapNode.Map[0]);

  // ��׼���ؿ���������� '_'
  for i := 0 to nRows - 1 do
  begin
    for j := 0 to nCols - 1 do
    begin
      if (i = 0) or (j = 0) or (i = nRows - 1) or (j = nCols - 1) then
        aMap0[i, j] := '_';
    end;
  end;

  // ��׼��
  for i := 1 to nRows - 2 do
  begin
    for j := 1 to nCols - 2 do
    begin
      if (aMap0[i, j] <> '_') and (aMap0[i, j] <> '#') then
      begin  // ̽���ڲ���ЧԪ�صİ˸���λ���Ƿ���԰���ǽ��
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

  // ��׼����İ�ת���ؿ���˳ʱ����ת���õ���0ת��1ת��2ת��3ת����4תΪ0ת�����Ҿ���4ת��˳ʱ����ת���õ���4ת��5ת��6ת��7ת��
  for i := 0 to nRows - 1 do
  begin
    for j := 0 to nCols - 1 do
    begin
      aMap1[j, nRows - 1 - i] := aMap0[i, j];
      aMap2[nRows - 1 - i, nCols - 1 - j] := aMap0[i, j];
      aMap3[nCols - 1 - j, i] := aMap0[i, j];
      aMap4[i, nCols - 1 - j] := aMap0[i, j];
      aMap5[nCols - 1 - j, nRows - 1 - i] := aMap0[i, j];
      aMap6[nRows - 1 - i, j] := aMap0[i, j];
      aMap7[j, i] := aMap0[i, j];
    end;
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


  for i := 1 to 7 do
  begin
    if mapNode.CRC32 > key8[i] then
    begin
      mapNode.CRC32 := key8[i];
      mapNode.CRC_Num := i;
    end;
  end;

  Result := True;
end;

// ȡ�ùؿ� XSB
function GetXSB(): string;
var
  i: Integer;
begin
  Result := '';

  if curMapNode.Map.Count > 0 then
  begin
    for i := 0 to curMapNode.Map.Count - 1 do
    begin
      Result := Result + curMapNode.Map.Strings[i] + #10;
    end;
    if Trim(curMapNode.Title) <> '' then
      Result := Result + 'Title: ' + curMapNode.Title + #10;
    if Trim(curMapNode.Author) <> '' then
      Result := Result + 'Author: ' + curMapNode.Author + #10;
    if Trim(curMapNode.Comment) <> '' then
    begin
      Result := Result + 'Comment: ' + curMapNode.Comment + #10;
      Result := Result + 'Comment_end: ' + #10;
    end;
  end;
end;

// XSB ������а�
procedure XSBToClipboard();
begin
  if curMapNode.Map.Count > 0 then
  begin
    Clipboard.SetTextBuf(PChar(GetXSB()));
  end;
end;

// ���������ڱ���
procedure TLoadMapThread.UpdateCaption;
var
  i: Integer;
  mNode: PMapNode;               // �������ĵ�ǰ�ؿ��ڵ�ָ��

begin
  for i := 0 to MapList.Count do begin
      if SolvedLevel[i] > 0 then begin
         mNode := MapList[SolvedLevel[i]-1];
         mNode.Solved := True;
      end;
      Break;
  end;
  main.Caption := AppName + AppVer + ' - ' + ExtractFileName(ChangeFileExt(main.mySettings.MapFileName, EmptyStr)) + ' ~ [' + inttostr(main.curMap.CurrentLevel) + '/' + inttostr(MapList.Count) + ']';
  main.Caption := main.Caption + '���ߴ�: ' + IntToStr(curMapNode.Cols) + '��' + IntToStr(curMapNode.Rows) + '������: ' + IntToStr(curMapNode.Boxs) + '��Ŀ��: ' + IntToStr(curMapNode.Goals);

end;

// �ں�̨�߳��м��ص�ͼ�ĵ�
procedure TLoadMapThread.Execute;
var
  FileName: string;
  is_zhouzhuan: Boolean;           // �Ƿ���ת�ؿ��� -- ��ת���ĵ���BoaMan.xsb���ڽ���ʱ��ֻ�ܽ���ǰ100���ؿ�������ؿ�����ת��ʱ�����ԡ�׷�ӡ���ʽ����ӵ��ĵ�β���Ҳ���100��������
  txtFile: TextFile;
  line, line2: string;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Solution: Boolean;            // �Ƿ����
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  num, n, k, size: Integer;        // XSB�Ľ�������
  mapNode: PMapNode;               // �������ĵ�ǰ�ؿ��ڵ�ָ��
  mapSolution: TStringList;        // �ؿ���
  tmpMapList: TList;               // ��ʱ�ؿ��б�
  R: TRect;
//  MapIcon: TBitmap;                // �ؿ�ͼ��

begin
  isRunning := True;
  isStopThread := False;

  MapList.Clear;

  FileName := main.mySettings.MapFileName;
  is_zhouzhuan := AnsiSameText(FileName, 'BoxMan.xsb');    // �Ƿ��������ת���ĵ�

  if Pos(':', FileName) =0 then FileName := AppPath + FileName;
  if FileExists(FileName) then
  begin

    tmpMapList := TList.Create;             // �ؿ��б�

    try
      AssignFile(txtFile, FileName);
      Reset(txtFile);

      mapSolution := TStringList.Create;

      NewMapNode(tmpMapList);              // �ȴ���һ���ؿ��ڵ�
      is_XSB := False;
      is_Comment := False;
      is_Solution := False;
      mapNode := tmpMapList.Items[0];      // ָ�����´����Ľڵ�
      mapNode.isEligible := True;          // Ĭ���Ǻϸ�Ĺؿ�XSB

      while not eof(txtFile) and (not isStopThread) do
      begin

        readln(txtFile, line);            // ��ȡһ��      WideToAnsi

        line2 := Trim(line);

        if (not is_Comment) and isXSB(line) then
        begin       // ����Ƿ�Ϊ XSB ��
          if not is_XSB then
          begin       // ��ʼ XSB ��

            if mapNode.Map.Count > 2 then
            begin   // ǰ���н������Ĺؿ� XSB����ѵ�ǰ�ؿ�����ؿ����б�
                    // ���ؿ��ı�׼��������CRC��
              if MapNormalize(mapNode) then
              begin
                SetSolved_2(mapNode, mapSolution);
              end;

              if is_zhouzhuan and (tmpMapList.Count >= 100) then Break;

              NewMapNode(tmpMapList);                      // ����һ���µĹؿ��ڵ�
              num := tmpMapList.Count - 1;
              mapNode := tmpMapList.Items[num];            // ָ�����´����Ľڵ�
              mapNode.isEligible := True;               // Ĭ���Ǻϸ�Ĺؿ�XSB

            end
            else
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
        else if (not is_Comment) and (AnsiStartsText('title', line2)) then
        begin   // ƥ�� Title������
          n := Pos(':', line2);
          if n > 0 then
            mapNode.Title := trim(Copy(line2, n + 1, MaxInt))
          else
            mapNode.Title := trim(Copy(line2, 6, MaxInt));

          if is_XSB then
            is_XSB := false;      // �����ؿ�SXB�Ľ���
        end
        else if (not is_Comment) and (AnsiStartsText('author', line2)) then
        begin  // ƥ�� Author������
          n := Pos(':', line2);
          if n > 0 then
            mapNode.Author := trim(Copy(line2, n + 1, MaxInt))
          else
            mapNode.Author := trim(Copy(line2, 7, MaxInt));

          if is_XSB then
            is_XSB := false;      // �����ؿ�SXB�Ľ���
        end
        else if (not is_Comment) and (AnsiStartsText('solution', line2)) then
        begin  // ƥ�� Solution����
          is_Solution := not isOnlyXSB;     // ��ʼ�𰸽���

          if is_Solution then begin
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
          end;
          if is_XSB then
            is_XSB := false;   // �����ؿ�SXB�Ľ���
        end
        else if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then
        begin  // ƥ��"ע��"�����
          is_Comment := False;
          ;  // ����"ע��"��
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
            mapNode.Comment := line     // ����"ע��"
          else
            is_Comment := True;
          ;  // ����"ע��"��
        end
        else if is_Comment then
        begin  // "˵��"��Ϣ
          if Length(mapNode.Comment) > 0 then
            mapNode.Comment := mapNode.Comment + #10 + line
          else
            mapNode.Comment := line;

          if is_XSB then
            is_XSB := false;      // �����ؿ�SXB�Ľ���
        end
        else if is_Solution then
        begin  // ����
          line2 := StringReplace(line2, #9, '', [rfReplaceAll]);
          line2 := StringReplace(line2, ' ', '', [rfReplaceAll]);
          if isLurd(line2) then
          begin
            n := mapSolution.Count - 1;
            mapSolution[n] := mapSolution[n] + line2;
          end;
        end
        else
        begin
          if is_XSB then
            is_XSB := false;      // �����ؿ�SXB��Ľ���
        end;
      end;

        // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
      num := tmpMapList.Count - 1;
      mapNode := tmpMapList.Items[num];
      if mapNode.Map.Count < 3 then
        tmpMapList.Delete(num)
      else
      begin
        if MapNormalize(mapNode) then
        begin
          SetSolved_2(mapNode, mapSolution);
        end
        else
          tmpMapList.Delete(num);
      end;

    finally
      DataModule1.ADOQuery2.Close;
      CloseFile(txtFile);                //�رմ򿪵��ļ�
      FreeAndNil(mapSolution);
    end;

    if (not isStopThread) and (tmpMapList.Count > 0) then
    begin         // ���Ƿ���������

         // ���ɹؿ��б���
      BrowseForm.ImageList1.Clear;
      BrowseForm.ListView1.Items.Clear;

//      MapIcon := TBitmap.Create;                // �ؿ�ͼ��
//      MapIcon.Width := BrowseForm.ImageList1.Width;
//      MapIcon.Height := BrowseForm.ImageList1.Height;
//      MapIcon.Canvas.Brush.Color := BrowseForm.BK_Color;
//      R := Rect(0, 0, MapIcon.Width, MapIcon.Height);
      R := Rect(0, 0, BrowseForm.Map_Icon.Width, BrowseForm.Map_Icon.Height);
      size := tmpMapList.Count;
      try
        for k := 0 to size - 1 do
        begin
          mapNode := tmpMapList[k];

          BrowseForm.ListView1.Items.add;

          if mapNode.Title = '' then
            BrowseForm.ListView1.Items[k].Caption := '����: ' + IntToStr(k + 1) + '��'
          else
            BrowseForm.ListView1.Items[k].Caption := mapNode.Title;

          BrowseForm.ListView1.Items[k].ImageIndex := -1;       // ��Ĭ��û��ͼ��

          // ��ͼ��
//          MapIcon.Canvas.FillRect(R);
//          BrowseForm.DrawIcon(MapIcon.Canvas, mapNode);
//          BrowseForm.ImageList1.Add(MapIcon, nil);
//          BrowseForm.ListView1.Items[k].ImageIndex := BrowseForm.ImageList1.Count-1;

        end;
      finally
        mapNode := nil;
//        FreeAndNil(MapIcon);
      end;

      MapList := tmpMapList;
      tmpMapList := nil;

      synchronize(UpdateCaption);     // ���������ڱ���
    end;

    FreeAndNil(tmpMapList);

  end;

  isRunning := False;
  isStopThread := True;
end;

end.

