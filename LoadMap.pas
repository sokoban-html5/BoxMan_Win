unit LoadMap;
// �ؿ��ı�������Ԫ

interface

uses
  windows, classes, StrUtils, SysUtils, Clipbrd, CRC_32;
  
type                  // �ؿ��ڵ� -- �ؿ����еĸ����ؿ�
  TMapNode = record
    Map                  :TStringList;    // �ؿ� XSB
    Rows, Cols           :integer;        // �ؿ��ߴ�
    Goals                :integer;        // Ŀ�����
    Trun                 :integer;        // �ؿ���ת�Ǽ�
    Title                :string;         // ����
    Author               :string;         // ����
    Comment              :string;         // �ؿ�������Ϣ
    CRC32                :integer;        // CRC32
    CRC_Num              :integer;        // �ڼ�ת��CRC��С��
    Solved               :Boolean;        // �Ƿ��ɴ�
  end;
  PMapNode    =   ^TMapNode;              // �ؿ��ڵ�ָ��

  function GetXSB(): string;                                     // ȡ�ùؿ� XSB
  procedure XSBToClipboard();                                    // XSB ������а�
  function LoadMapsFromClipboard(): boolean;                     // ���عؿ� -- ���а�
  function LoadMaps(FileName: string): boolean;                  // ���عؿ� -- �ĵ�
  function MapNormalize(var mapNode: PMapNode): Boolean;         // ��ͼ��׼�����������򵥱�׼�� -- �����ؿ���ǽ�����ͣ���׼��׼�� -- �������ؿ���ǽ�����ͣ�ͬʱ���� CRC ��
  function isSolution(mapNode: PMapNode; sol: PChar): Boolean;   // ����֤

var
  ManPos_BK_0           :integer;                     // �˵�λ�� -- ���ƣ�����Ѿ�ָ����λ��
  ManPos_BK_0_2         :integer;                     // �˵�λ�� -- ���ƣ�����������λ��

  sMoves, sPushs: integer;                            // ��֤��ʱ����¼�ƶ������ƶ���

  MapList: TList;                          // �ؿ���
  MapArray: array[0..99, 0..99] of Char;   // ��׼���ùؿ�����     
  Mark: array[0..99, 0..99] of Boolean;    // ��׼���ñ�־����
  curMapNode : PMapNode;                   // ��ǰ�ؿ��ڵ�

  tmp_Board : array[0..9999] of integer;   // ��ʱ��ͼ
  
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
  LogFile,    // ����
  LurdAction, DateModule;

const
  EmptyCell        = 0;
  WallCell         = 1;
  FloorCell        = 2;
  GoalCell         = 3;
  BoxCell          = 4;
  BoxGoalCell      = 5;
  ManCell          = 6;
  ManGoalCell      = 7;

// �ж��Ƿ�Ϊ��Ч�� XSB ��
function isXSB(str: String): boolean;
var
  n, k: Integer;

begin
  result := False;

  n := Length(str);

  if n = 0 then exit;
  
  k := 1;
  // ����Ƿ��ǿ��� -- ���пո�������
  while k <= n do begin
     if (str[k] <> #20) and (str[k] <> #8) or (str[k] = '') then Break;
     Inc(k);
  end;
  if k > n then Exit;

  k := 1;
  while k <= n do begin
     if not (str[k] in [ ' ', '_', '-', '#', '.', '$', '*', '@', '+' ]) then Break;
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
  for i := 0 to Rows-1 do begin
      for j := 1 to Cols do begin
          ch := mapNode.Map[i][j];
          case ch of
              '#': tmp_Board[i * Cols + j] := WallCell;
              '-': tmp_Board[i * Cols + j] := FloorCell;
              '.': tmp_Board[i * Cols + j] := GoalCell;
              '$': tmp_Board[i * Cols + j] := BoxCell;
              '*': tmp_Board[i * Cols + j] := BoxGoalCell;
              '@': tmp_Board[i * Cols + j] := ManCell;
              '+': tmp_Board[i * Cols + j] := ManGoalCell;
              else tmp_Board[i * Cols + j] := EmptyCell;
          end;
          
          if ch in [ '@', '+' ] then mpos := i * Cols + j;
      end;
  end;

  if mpos < 0 then Exit;
  sPushs := 0;
  sMoves := 0;

  // ����֤
  len := Length(sol);
  for i := 0 to len-1 do begin
      pos1 := -1;
      pos2 := -1;
      ch := sol[i];
      case ch of
         'l', 'L': begin
            pos1 := mpos - 1;
            pos2 := mpos - 2;
         end;
         'r', 'R': begin
            pos1 := mpos + 1;
            pos2 := mpos + 2;
         end;
         'u', 'U': begin
            pos1 := mpos - mapNode.Cols;
            pos2 := mpos - mapNode.Cols * 2;
         end;
         'd', 'D': begin
            pos1 := mpos + mapNode.Cols;
            pos2 := mpos + mapNode.Cols * 2;
         end;
      end;
      isPush := ch in [ 'L', 'R', 'U', 'D' ];

      if (pos1 < 0) or (pos1 >= size) or (isPush and ((pos1 < 0) or (pos1 >= size))) then Exit;             // ����

      if isPush then begin                                                                                 // ��Ч�ƶ�
         if (tmp_Board[pos1] <> BoxCell) and (tmp_Board[pos1] <> BoxGoalCell) or (tmp_Board[pos2] <> FloorCell) and (tmp_Board[pos2] <> GoalCell) then Exit;
         if tmp_Board[pos2] = FloorCell then tmp_Board[pos2] := BoxCell
         else tmp_Board[pos2] := BoxGoalCell;
         if tmp_Board[pos1] = BoxCell then tmp_Board[pos1] := ManCell
         else tmp_Board[pos1] := ManGoalCell;
         if tmp_Board[mpos] = ManCell then tmp_Board[mpos] := FloorCell
         else tmp_Board[mpos] := GoalCell;
      end else begin
         if (tmp_Board[pos1] <> FloorCell) and (tmp_Board[pos1] <> GoalCell) then Exit;                    // ��Ч�ƶ�
         if tmp_Board[pos1] = FloorCell then tmp_Board[pos1] := ManCell
         else tmp_Board[pos1] := ManGoalCell;
         if tmp_Board[mpos] = ManCell then tmp_Board[mpos] := FloorCell
         else tmp_Board[mpos] := GoalCell;
      end;

      if isPush then Inc(sPushs);
      Inc(sMoves);
      
      mpos := pos1;
      
      okNum := 0;
      for j := 0 to size - 1 do begin
          if (tmp_Board[j] = BoxGoalCell) then Inc(okNum);

          if okNum = mapNode.Goals then begin                     // �ܹ���أ�Ϊ��Ч��
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
  mapNode.Map     := TStringList.Create;
  mapNode.Rows    := 0;
  mapNode.Cols    := 0;
  mapNode.Trun    := 0;
  mapNode.Title   := '';
  mapNode.Author  := '';
  mapNode.Comment := '';
  mapNode.CRC32   := -1;
  mapNode.CRC_Num := -1;
  mapNode.Solved  := false;

  mpList.Add(mapNode);          // ����ؿ����б�

end;

// ����Ƿ�Ϊ�н�ؿ�
procedure SetSolved(mapNode: PMapNode; var Solitions: TStringList);
var
  i, l: Integer;
  is_Solved: Boolean;
  
begin
  is_Solved := false;
  mapNode.Solved := false;

  // ���������˴𰸣�����֤�𰸲��������
  if Solitions.Count > 0 then begin
     l := Solitions.Count;
     for i := l-1 downto 0 do begin
         if isSolution(mapNode, PChar(Solitions[i])) then begin    // ���浽���ݿ�
            // ����𰸵����ݿ�
            try
              DataModule1.ADOQuery1.Close;
              DataModule1.ADOQuery1.SQL.Clear;
              DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
              DataModule1.ADOQuery1.Open;
              DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;

              with DataModule1.ADOQuery1 do begin

                Append;    // �޸�

                FieldByName('XSB_CRC32').AsInteger := mapNode.CRC32;
                FieldByName('XSB_CRC_TrunNum').AsInteger := mapNode.CRC_Num;
                FieldByName('Goals').AsInteger := mapNode.Goals;
                FieldByName('Sol_CRC32').AsInteger := Calcu_CRC_32_2(PChar(Solitions[i]), Length(Solitions[i]));
                FieldByName('Moves').AsInteger := sMoves;
                FieldByName('Pushs').AsInteger := sPushs;
                FieldByName('Sol_Text').AsString := Solitions[i];

                Post;    // �ύ

              end;
            except
            end;
            DataModule1.ADOQuery1.Close;
         end else begin
            Solitions.Delete(i);
         end;
     end;
     is_Solved := (Solitions.Count > 0);
     Solitions.Clear;
  end;

  if is_Solved then mapNode.Solved := is_Solved
  else begin
      // ���ݿ����Ƿ��н�
      try
        DataModule1.ADOQuery1.Close;
        DataModule1.ADOQuery1.SQL.Clear;
        DataModule1.ADOQuery1.SQL.Text := 'select id from Tab_Solution where XSB_CRC32 = ' + IntToStr(mapNode.CRC32) + ' and Goals = ' + IntToStr(mapNode.Goals);
        DataModule1.ADOQuery1.Open;
        mapNode.Solved := (DataModule1.ADOQuery1.RecordCount > 0);
      except
      end;
      DataModule1.ADOQuery1.Close;
  end;
end;

// ��ȡ�ؿ��ĵ�
function LoadMaps(FileName: string): boolean;
var
  txtFile: TextFile;
  line, line2: String;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Solution: Boolean;            // �Ƿ����
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  num, l, n: Integer;              // XSB�Ľ�������
  mapNode: PMapNode;               // �������ĵ�ǰ�ؿ��ڵ�ָ��
  mapSolution: TStringList;        // �ؿ���
  tmpList: TList;

begin
  Result := False;

  try
    AssignFile(txtFile, FileName);
    Reset(txtFile);

    tmpList     := TList.Create;
    mapSolution := TStringList.Create;

    NewMapNode(tmpList);             // �ȴ���һ���ؿ��ڵ�
    is_XSB      := False;
    is_Comment  := False;
    is_Solution := False;
    mapNode := tmpList.Items[0];     // ָ�����´����Ľڵ�

    while not eof(txtFile) do begin

       readln(txtFile, line);        // ��ȡһ��
       line2 := Trim(line);

       if (not is_Comment) and isXSB(line) then begin       // ����Ƿ�Ϊ XSB ��
          if not is_XSB then begin     // ��ʼ XSB ��
        
             if mapNode.Map.Count > 2 then begin   // ǰ���н������Ĺؿ� XSB����ѵ�ǰ�ؿ�����ؿ����б�

                // ���ؿ��ı�׼��������CRC��
                if MapNormalize(mapNode) then begin

                    SetSolved(mapNode, mapSolution);

                    NewMapNode(tmpList);                      // ����һ���µĹؿ��ڵ�
                    num     := tmpList.Count-1;
                    mapNode := tmpList.Items[num];            // ָ�����´����Ľڵ�
                end else begin
                    mapNode.Map.Clear;
                end;
             end;

             is_XSB      := True;    // ��ʼ�ؿ� XSB ��
             is_Comment  := False;
             mapNode.Rows    := 0;
             mapNode.Cols    := 0;
             mapNode.Title   := '';
             mapNode.Author  := '';
             mapNode.Comment := '';
          end;

          mapNode.Map.Add(line);    // �� XSB ��

       end else
       if (not is_Comment) and (AnsiStartsText('title', line2)) then begin   // ƥ�� Title������
          l := Length(line2);
          n := Pos(':', line2);
          if n > 0 then mapNode.Title := trim(RightStr(line2, l-n))
          else          mapNode.Title := trim(RightStr(line2, l-5));
        
          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
       end else
       if (not is_Comment) and (AnsiStartsText('author', line2)) then begin  // ƥ�� Author������
          l := Length(line2);
          n := Pos(':', line2);
          if n > 0 then mapNode.Author := trim(RightStr(line2, l-n))
          else          mapNode.Author := trim(RightStr(line2, l-6));

          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
       end else
       if (not is_Comment) and (AnsiStartsText('solution', line2)) then begin  // ƥ�� Solution����
          l := Length(line2);
          n := Pos(':', line2);
          if n = 0 then n := Pos(')', line2);
        
          if n > 0 then line := trim(RightStr(line2, l-n))
          else          line := trim(RightStr(line2, l-8));

          if Length(line) > 0 then mapSolution.Add(line)
          else                     mapSolution.Add('');

          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
          is_Solution := true;                 // ��ʼ�𰸽���
       end else
       if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // ƥ��"ע��"�����
          is_Comment := False;;  // ����"ע��"��
       end else
       if (AnsiStartsText('comment', line2)) then begin  //ƥ��"ע��"�鿪ʼ
          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
        
          l := Length(line2);
          n := Pos(':', line2);
          if n > 0 then line := trim(RightStr(line2, l-n))
          else          line := trim(RightStr(line2, l-7));

          if Length(line) > 0 then mapNode.Comment := line     // ����"ע��"
          else is_Comment := True;;  // ����"ע��"��
       end else
       if is_Comment then begin  // "˵��"��Ϣ
          if Length(mapNode.Comment) > 0 then mapNode.Comment := mapNode.Comment + #10 + line
          else                                mapNode.Comment := line;
        
          if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
       end else
       if is_Solution then begin  // ����
          if isLurd(line2) then begin
             n := mapSolution.Count-1;
             mapSolution[n] := mapSolution[n] + line2;
          end;
       end else begin
          if is_XSB then is_XSB := false;      // �����ؿ�SXB��Ľ���
       end;
    end;

    // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
    num     := tmpList.Count-1;
    mapNode := tmpList.Items[num];
    if mapNode.Map.Count < 3 then tmpList.Delete(num)
    else begin
       if MapNormalize(mapNode) then begin
          SetSolved(mapNode, mapSolution);
       end else tmpList.Delete(num);
    end;

    CloseFile(txtFile);                //�رմ򿪵��ļ�
    FreeAndNil(mapSolution);

    if tmpList.Count > 0 then begin
       MapList := tmpList;
       Result := true;
    end;
  except
  end;
end;

// �ָ��ַ���
function Split(src: string): TStringList;
var
  i : integer;
  str : string;

begin
  result := TStringList.Create;

  src := StringReplace (src, #13, #10, [rfReplaceAll]);
  src := StringReplace (src, #10#10, #10, [rfReplaceAll]);

  repeat
    i := pos(#10, src);
    str := copy(src, 1, i-1);
    if (str = '') and (i > 0) then begin
      result.Add('');
      delete(src, 1, 1);
      continue;
    end;
    if i > 0 then begin
      result.Add(str);
      delete(src, 1, i);
    end;
  until i <= 0;
  if src <> '' then result.Add(src);
end;

// ��ȡ�ؿ� -- ���а�
function LoadMapsFromClipboard(): boolean;
var
  line, line2: String;
  is_XSB: Boolean;                 // �Ƿ����ڽ����ؿ�XSB
  is_Solution: Boolean;            // �Ƿ����
  is_Comment: Boolean;             // �Ƿ����ڽ����ؿ�˵����Ϣ
  num, l, n, k, i: Integer;        // XSB�Ľ�������
  mapNode: PMapNode;               // �������ĵ�ǰ�ؿ��ڵ�ָ��
  mapSolution: TStringList;        // �ؿ���
  XSB_Text: string;
  data_Text: TStringList;
  tmpList: TList;
  is_Solved: Boolean;              // �Ƿ����

begin
  Result := False;

  // ��ѯ���������ض���ʽ����������
  if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then begin
      XSB_Text  := Clipboard.asText;
      data_Text := Split(XSB_Text);
  end else Exit;

  tmpList     := TList.Create;
  mapSolution := TStringList.Create;

  NewMapNode(tmpList);                // �ȴ���һ���ؿ��ڵ�
  is_XSB      := False;
  is_Comment  := False;
  is_Solution := False;
  mapNode     := tmpList.Items[0];    // ָ�����´����Ľڵ�
  k := 0;

  while k < data_Text.Count do begin

     line := data_Text.Strings[k];       // ��ȡһ��
     Inc(k);
     line2 := Trim(line);

     if (not is_Comment) and isXSB(line) then begin       // ����Ƿ�Ϊ XSB ��
        if not is_XSB then begin     // ��ʼ XSB ��
        
           if mapNode.Map.Count > 2 then begin   // ǰ���н������Ĺؿ� XSB����ѵ�ǰ�ؿ�����ؿ����б�

              // ���ؿ��ı�׼��������CRC��
              if MapNormalize(mapNode) then begin

                  SetSolved(mapNode, mapSolution);
                  
                  NewMapNode(tmpList);                                  // ����һ���µĹؿ��ڵ�
                  num     := tmpList.Count-1;
                  mapNode := tmpList.Items[num];                        // ָ�����´����Ľڵ�

              end else begin
                  mapNode.Map.Clear;
              end;
           end;

           is_XSB      := True;    // ��ʼ�ؿ� XSB ��
           is_Comment  := False;
           mapNode.Rows    := 0;
           mapNode.Cols    := 0;
           mapNode.Title   := '';
           mapNode.Author  := '';
           mapNode.Comment := '';
        end;

        mapNode.Map.Add(line);    // �� XSB ��

     end else
     if (not is_Comment) and (AnsiStartsText('title', line2)) then begin   // ƥ�� Title������
        l := Length(line2);
        n := Pos(':', line2);
        if n > 0 then mapNode.Title := trim(RightStr(line2, l-n))
        else          mapNode.Title := trim(RightStr(line2, l-5));
        
        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
     end else
     if (not is_Comment) and (AnsiStartsText('author', line2)) then begin  // ƥ�� Author������
        l := Length(line2);
        n := Pos(':', line2);
        if n > 0 then mapNode.Author := trim(RightStr(line2, l-n))
        else          mapNode.Author := trim(RightStr(line2, l-6));

        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
     end else
     if (not is_Comment) and (AnsiStartsText('solution', line2)) then begin  // ƥ�� Solution����
        l := Length(line2);
        n := Pos(':', line2);
        if n = 0 then n := Pos(')', line2);
        
        if n > 0 then line := trim(RightStr(line2, l-n))
        else          line := trim(RightStr(line2, l-8));

        if Length(line) > 0 then mapSolution.Add(line)
        else                     mapSolution.Add('');

        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
        is_Solution := true;                 // ��ʼ�𰸽���
     end else
     if (AnsiStartsText('comment-end', line2)) or (AnsiStartsText('comment_end', line2)) then begin  // ƥ��"ע��"�����
        is_Comment := False;;  // ����"ע��"��
     end else
     if (AnsiStartsText('comment', line2)) then begin  //ƥ��"ע��"�鿪ʼ
        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
        
        l := Length(line2);
        n := Pos(':', line2);
        if n > 0 then line := trim(RightStr(line2, l-n))
        else          line := trim(RightStr(line2, l-7));

        if Length(line) > 0 then mapNode.Comment := line     // ����"ע��"
        else is_Comment := True;;  // ����"ע��"��
     end else
     if is_Comment then begin  // "˵��"��Ϣ
        if Length(mapNode.Comment) > 0 then mapNode.Comment := mapNode.Comment + #10 + line
        else                                mapNode.Comment := line;
        
        if is_XSB then is_XSB := false;      // �����ؿ�SXB�Ľ���
     end else
     if is_Solution then begin  // ����
        if isLurd(line2) then begin
           n := mapSolution.Count-1;
           mapSolution[n] := mapSolution[n] + line2;
        end;
     end else begin
        if is_XSB then is_XSB := false;      // �����ؿ�SXB��Ľ���
     end;
  end;

  // ������Ľڵ㣬��û�� XSB ���ݣ�����ɾ��
  num     := tmpList.Count-1;
  mapNode := tmpList.Items[num];
  if mapNode.Map.Count < 3 then tmpList.Delete(num)
  else begin
     if MapNormalize(mapNode) then begin
        SetSolved(mapNode, mapSolution);
     end else tmpList.Delete(num);
  end;

  FreeAndNil(mapSolution);

  if tmpList.Count > 0 then begin
     MapList := tmpList;
     Result := true;
  end;

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

  mr := -1; mc := -1;
  nRen := 0;
  Rows := mapNode.Map.Count;
  Cols := 0;
  for i := 0 to Rows-1 do begin
      nLen := Length(mapNode.Map[i]);
      if Cols < nLen then Cols := nLen;
  end;

  if (Rows >= 100) or (Cols >= 100) then Exit;

  for i := 0 to Rows-1 do begin
    nLen := Length(mapNode.Map[i]);
    for j := 0 to Cols-1 do begin
      if j < nLen then ch := mapNode.Map[i][j+1]
      else             ch := '-';

      case (ch) of
        '#', '.', '$', '*': begin
           MapArray[i, j] := ch;
        end;
        '@', '+': begin
          MapArray[i, j] := ch;
          Inc(nRen);
          mr := i;
          mc := j;
        end;
        else MapArray[i, j] := '-';
      end;
      
    end;
  end;

  if nRen <> 1 then begin  // �ֹ�Ա <> 1
     Exit;
  end;

  for i := 0 to Rows-1 do begin
    for j := 0 to Cols-1 do begin
      Mark[i][j] := false;
    end;
  end;

  left := mc; top := mr; right := mc; bottom := mr; nBox := 0; nDst := 0;

  P := TList.Create;
  New(Pos);
  Pos.x := mc;
  Pos.y := mr;
  P.add(Pos);
  Mark[mr][mc] := true;
  while P.Count > 0 do begin // �����Mark[][]Ϊ true �ģ�Ϊǽ��
    F := P.Items[0];
    mr := F.Y;
    mc := F.X;
    P.Delete(0);
    
    case MapArray[mr, mc] of
      '$': begin
        Inc(nBox);
      end;
      '*': begin
        Inc(nBox);
        Inc(nDst);
      end;
      '.', '+': begin
        Inc(nDst);
      end;
    end;
    for k := 0 to 3 do begin   // �ֹ�Ա���ĸ�������
      mr2 := mr + dr4[k];
      mc2 := mc + dc4[k];
      if (mr2 < 0) or (mr2 >= Rows) or (mc2 < 0) or (mc2 >= Cols) or    // ����
         (Mark[mr2, mc2]) or (MapArray[mr2, mc2] = '#') then continue;  // �ѷ��ʻ�����ǽ

      // ��������
      if left   > mc2 then left   := mc2;
      if top    > mr2 then top    := mr2;
      if right  < mc2 then right  := mc2;
      if bottom < mr2 then bottom := mr2;

      New(Pos);
      Pos.x := mc2;
      Pos.y := mr2;
      P.add(Pos);
      Mark[mr2][mc2] := true;  //���Ϊ�ѷ���
    end;
  end;
  FreeAndNil(P);

  if (nBox <> nDst) or (nBox < 1) or (nDst < 1) then begin  // �ɴ������ڵ�������Ŀ���������ȷ
     exit;
  end;

  mapNode.Goals := nDst;

  // ��׼����ĳߴ磨��ת��
  nRows := bottom-top+1+2;
  nCols := right-left+1+2;

  // ����ؿ�Ԫ��
  for i := 0 to Rows-1 do begin
    for j := 0 to Cols-1 do begin
      ch := MapArray[i, j];
      if (Mark[i, j]) then begin  // ǽ��
        if not (ch in [ '-', '.', '$', '*', '@', '+' ]) then begin  //��ЧԪ��
          ch := '-';
          MapArray[i, j] := ch;
        end;
      end else begin  // ǽ������
        if (ch = '*') or (ch = '$') then begin
          ch := '#';
          MapArray[i, j] := ch;
        end else if not (ch in [ '#', '_' ]) then begin  // ��ЧԪ��
          ch := '_';
          MapArray[i, j] := ch;
        end;
      end;
      if (i >= top) and (i <= bottom) and (j >= left) and (j <= right) then begin  // ����������Χ��
        if Mark[i, j] then aMap0[i-top+1, j-left+1] := ch  // ��׼���ؿ�����ЧԪ�أ���ʱ�ճ����ܣ�
        else               aMap0[i-top+1, j-left+1] := '_';
      end;
    end;
  end;

  // �ؿ���С��
  mTop := 0; mLeft := 0; mBottom := Rows-1; mRight := Cols-1;
  for k := 0 to Rows-1 do begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do Inc(t);

    if t = Cols then Inc(mTop)
    else break;
  end;
  for k := Rows-1 downto mTop+1 do begin
    t := 0;
    while (t < Cols) and (MapArray[k, t] = '_') do Inc(t);
    if t = Cols then Dec(mBottom)
    else break;
  end;
  if mBottom - mTop < 2 then begin
     Exit;
  end;

  for k := 0 to Cols-1 do begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do Inc(t);
    if t > mBottom then Inc(mLeft)
    else break;
  end;
  for k := Cols-1 downto mLeft+1 do begin
    t := mTop;
    while (t <= mBottom) and (MapArray[t, k] = '_') do Inc(t);
    if t > mBottom then Dec(mRight)
    else break;
  end;
  if mRight - mLeft < 2 then begin
     Exit;
  end;

  // �ؿ�ԭò�������򵥱�׼��������ǽ�����ͣ�
  mapNode.Map.Clear;  
  for i := mTop to mBottom do begin
    s1 := '';  // ���ֹؿ�ԭò����ǽ�����Ͳ��ֲ�������
    for j := mLeft to mRight do begin
      s1 := s1 + MapArray[i, j];
    end;
    mapNode.Map.Add(s1);
  end;
//  mapNode.Rows := mBottom-mTop+1;
//  mapNode.Cols := mRight-mLeft+1;
  mapNode.Rows := mapNode.Map.Count;
  mapNode.Cols := Length(mapNode.Map[0]);

  // ��׼���ؿ���������� '_'
  for i := 0 to nRows-1 do begin
    for j := 0 to nCols-1 do begin
      if (i = 0) or (j = 0) or (i = nRows-1) or (j = nCols-1) then aMap0[i, j] := '_';
    end;
  end;

  // ��׼��
  for i := 1 to nRows-2 do begin
    for j := 1 to nCols-2 do begin
      if (aMap0[i, j] <> '_') and (aMap0[i, j] <> '#') then begin  // ̽���ڲ���ЧԪ�صİ˸���λ���Ƿ���԰���ǽ��
        if (aMap0[i-1, j] = '_') then aMap0[i-1, j] := '#';
        if (aMap0[i+1, j] = '_') then aMap0[i+1, j] := '#';
        if (aMap0[i, j-1] = '_') then aMap0[i, j-1] := '#';
        if (aMap0[i, j+1] = '_') then aMap0[i, j+1] := '#';
        if (aMap0[i+1, j-1] = '_') then aMap0[i+1, j-1] := '#';
        if (aMap0[i+1, j+1] = '_') then aMap0[i+1, j+1] := '#';
        if (aMap0[i-1, j-1] = '_') then aMap0[i-1, j-1] := '#';
        if (aMap0[i-1, j+1] = '_') then aMap0[i-1, j+1] := '#';
      end;
    end;
  end;

  // ��׼����İ�ת���ؿ���˳ʱ����ת���õ���0ת��1ת��2ת��3ת����4תΪ0ת�����Ҿ���4ת��˳ʱ����ת���õ���4ת��5ת��6ת��7ת��
  for i := 0 to nRows-1 do begin
    for j := 0 to nCols-1 do begin
      aMap1[j, nRows-1-i] := aMap0[i, j];
      aMap2[nRows-1-i, nCols-1-j] := aMap0[i, j];
      aMap3[nCols-1-j, i] := aMap0[i, j];
      aMap4[i, nCols-1-j] := aMap0[i, j];
      aMap5[nCols-1-j, nRows-1-i] := aMap0[i, j];
      aMap6[nRows-1-i, j] := aMap0[i, j];
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
  mapNode.CRC32   := Calcu_CRC_32(@aMap0, nRows, nCols);        // ��׼��׼����Ĺؿ� -- û��ǽ������
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
    if mapNode.CRC32 > key8[i] then begin
      mapNode.CRC32   := key8[i];
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

   if curMapNode.Map.Count > 0 then begin
      for i := 0 to curMapNode.Map.Count-1 do begin
          Result := Result + curMapNode.Map.Strings[i] + #10;
      end;
      if Trim(curMapNode.Title) <> '' then Result := Result + 'Title: ' + curMapNode.Title + #10;
      if Trim(curMapNode.Author) <> '' then Result := Result + 'Author: ' + curMapNode.Author + #10;
      if Trim(curMapNode.Comment) <> '' then begin
         Result := Result + 'Comment: ' + curMapNode.Comment + #10;
         Result := Result + 'Comment_end: ' + #10;
      end;
   end;
end;

// XSB ������а�
procedure XSBToClipboard();
begin
   if curMapNode.Map.Count > 0 then begin
      Clipboard.SetTextBuf(PChar(GetXSB()));
   end;
end;


end.
