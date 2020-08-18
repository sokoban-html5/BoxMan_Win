unit DeadLockDetection;

interface

  function  is_Fang(var map: array of Byte; pos: Integer): boolean;                                                   // ���������������
  function  is_Zhi(var map: array of Byte; pos: Integer; var m_Zhi_Dir: array of Integer): boolean;                   // ��֮�������������
  function  isLock_Double_L(var map: array of Byte; pos: Integer; var m_Double_L_Top: array of Integer): boolean;     // ���Խǡ����������

implementation

uses
  Math;

const
  BT_OUTSIDE           = 0;             // ǽ��
  BT_WALL              = 1;             // ǽ��
  BT_FLOOR             = 2;             // �ذ�
  BT_GOAL              = 3;             // Ŀ���
  BT_BOX               = 4;             // ����
  BT_BOX_ON_GOAL       = 5;             // Ŀ����ϵ�����
  BT_PLAYER            = 6;             // ��
  BT_PLAYER_ON_GOAL    = 7;             // Ŀ����ϵ���

var
  // ����ʸ�������ͼ��أ�����һά��ͼ����ʱʹ�ã������ϡ��ҡ���
  diff                : array of Integer;

  m_Zhi_Dir:      array[0..2] of Integer = ( 0, 0, 0 );   // ��⡰֮����������ʱ����һ��Ԫ�ر�ʶ�Ƿ��������Ŀ����ϵ����ӣ�������Ԫ�ر�ʶ��������1 -- ��2 -- �ң�3 -- �ϣ�4 -- ��
  m_Double_L_Top: array[0..2] of Integer = ( 0, 0, 0 );   // ��⡰˫ L��������ʱ���������㼰�Ƿ������δ��λ������

  Map_Dead            : array of Byte;              // ��ֹ���ӽ��������
  dir                 : array of Byte;              // Ѱ����ʱ����
  pt                  : array of Integer;           // Ѱ����ʱ����

  // ��ͼ��ز���
  nRows               : Integer;                    // ����
  nCols               : Integer;                    // ����
  nArea               : Integer;                    // ��������
  nManPos             : Integer;                    // �˵ĳ�ʼλ��
  bNoSolution         : Boolean;                    // �Ƿ��޽�

// �Ƿ������ӻ�ǽ
function isBoxWall(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_BOX) or (map[pos] = BT_BOX_ON_GOAL) or (map[pos] = BT_WALL);
end;

// �Ƿ�������
function isBox(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_BOX) or (map[pos] = BT_BOX_ON_GOAL);
end;

// �Ƿ��ǵ�λ
function isGoal(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_GOAL) or (map[pos] = BT_BOX_ON_GOAL);
end;

// �Ƿ�����
function isMan(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_PLAYER) or (map[pos] = BT_PLAYER_ON_GOAL);
end;

// �Ƿ���ͨ��
function isPass(var map: array of Byte; pos: Integer): Boolean;
begin
    Result := (map[pos] = BT_FLOOR) or (map[pos] = BT_GOAL);
end;


// ���Ʒ��������Ӳ��ɽ�������� -- ������
procedure dead_Zone(var map1, map2, mark: array of Byte);  // 0:�������  1:��ֹ����
var
  i: Integer;
  // ���Ʒ��������Ӳ��ɽ�������� -- ������
  procedure dead_Zone_sub(pos: Integer; var map2, mark: array of Byte);
  var
    pos1, pos2, k: Integer;
  begin
      mark[pos] := 0;
      for k := 0 to 3 do begin
          pos1 := pos  + diff[k];
          pos2 := pos1 + diff[k];
          if (mark[pos1] = 1) and (isPass(map2, pos1)) and (isPass(map2, pos2)) then dead_Zone_sub(pos1, map2, mark);  // ����������ӵĻ�
      end;
  end;
begin
    for i := 0 to nArea-1 do begin
        mark[i] := 1;
        if map1[i] = BT_WALL then map2[i] := BT_WALL
        else if isGoal(map1, i) then map2[i] := BT_GOAL
        else map2[i] := BT_FLOOR;
    end;
    for i := nCols + 1 to nArea - nCols - 1 do begin  // ��Ŀ�����е���
        if (map2[i] = BT_GOAL) and (mark[i] = 1) then dead_Zone_sub(i, map2, mark);
    end;
end;

// ����̬���������ӱ��ǽ��
procedure set_Dead2Wall(var map: array of Byte);
var
    i: Integer;
begin
    for i := nCols + 1 to nArea - nCols - 2 do begin
        if is_Fang(map, i) then begin                                              // ���ӹ��ɷ�������
            map[i] := BT_WALL;
            if map[i] = BT_BOX then bNoSolution := true;                           // ��̬������������
        end else if is_Zhi(map, i, m_Zhi_Dir) then begin                           // ���ӹ��ɡ�֮�֡�������
            map[i] := BT_WALL;
            if (not bNoSolution) and (m_Zhi_Dir[0] > 0) then bNoSolution := true;  // ��̬������������
        end;
    end;
end;

// ����̬���������ӱ��ǽ��
procedure set_Net2Wall(var map, mark: array of Byte);
var
    k, i: Integer;
    
    function netChesk(pos: Integer; var map, mark: array of Byte): boolean;
    var
        k, p, tail, p1, p2: Integer;
    begin

        for k := 0 to nArea - 1 do mark[k] := 0;
    
        p := 0; tail := 0; pt[0] := pos;       // ��ʼλ������У�����������
        mark[pos] := 1;
        while (p <= tail) do begin
            for k := 0 to 3 do begin
                p1 := pt[P] + diff[k];
                p2 := pt[P] + diff[k] * 2;

                if (map[p1] = BT_WALL) or
                   (p2 < 0) or (p2 >= nArea) or (1 = mark[p2]) or
                   (map[p2] = BT_OUTSIDE) or (map[p2] = BT_WALL) then continue  // ��ǽ�������
                else if map[p2] = BT_BOX_ON_GOAL then begin                     // �������ڵ�����
                    Inc(tail);
                    pt[tail] := p2;
                    mark[p2] := 1;
                end else begin                                                  // ����
                    Result := false;
                    Exit;
                end;
            end;
            Inc(p);
        end;

        Result := true;
    end;
begin
    for k := nCols + 1 to nArea - nCols - 2 do begin
        if (map[k] = BT_BOX_ON_GOAL) and (netChesk(k, map, mark)) then begin  // ����Ŀ����ϵ����ӣ��ҳ�����������ڵ����ӱ��ǽ��
            for i := k to nArea - nCols - 2 do begin
                if 1 = mark[i] then map[i] := BT_WALL;
            end;
        end;
    end;
end;

// �Ƿ񡰷��͡�������ǽ�ߵ�˫�䲢�еȣ�
function is_Fang(var map: array of Byte; pos: Integer): boolean;
var
    p1, p2, p3, p4, p5, p6, p7, p8: Integer;
begin
    if isBox(map, pos) then begin
        p1 := pos + diff[0];  // ��
        p2 := pos + diff[1];  // ��
        p3 := pos + diff[2];  // ��
        p4 := pos + diff[3];  // ��
        p5 := pos + diff[0] + diff[1];  // ����
        p6 := pos + diff[1] + diff[2];  // ����
        p7 := pos + diff[2] + diff[3];  // ����
        p8 := pos + diff[3] + diff[0];  // ����

        if isBoxWall(map, p1) then begin  // ��
            if (isBoxWall(map, p2)) and (isBoxWall(map, p5)) and ((map[pos] = BT_BOX) or (map[p1] = BT_BOX) or (map[p2] = BT_BOX) or (map[p5] = BT_BOX)) then begin  // ��
                Result := true;  // ���Ϸ���
                Exit;
            end;
            if (isBoxWall(map, p4)) and (isBoxWall(map, p8)) and ((map[pos] = BT_BOX) or (map[p1] = BT_BOX) or (map[p4] = BT_BOX) or (map[p8] = BT_BOX)) then begin  // ��
                Result := true;  // ���·���
                Exit;
            end;
        end else if isBoxWall(map, p3) then begin  // ��
            if (isBoxWall(map, p2)) and (isBoxWall(map, p6)) and ((map[pos] = BT_BOX) or (map[p3] = BT_BOX) or (map[p2] = BT_BOX) or (map[p6] = BT_BOX)) then begin  // ��
                Result := true;  // ���Ϸ���
                Exit;
            end;
            if (isBoxWall(map, p4)) and (isBoxWall(map, p7)) and ((map[pos] = BT_BOX) or (map[p3] = BT_BOX) or (map[p4] = BT_BOX) or (map[p7] = BT_BOX)) then begin  // ��
                Result := true;  // ���·���
                Exit;
            end;
        end;
    end;
    Result := false;  // δ���ɷ���
end;

//�Ƿ񹹳ɡ�֮�֡��ͣ�m_Zhi_Dir����һ��Ԫ�ر�ʶ�Ƿ��������Ŀ����ϵ����ӣ�������Ԫ�ر�ʶ��������1 -- ��2 -- �ң�3 -- �ϣ�4 -- ��
function is_Zhi(var map: array of Byte; pos: Integer; var m_Zhi_Dir: array of Integer): boolean;
    // ��֮������������� -- ������
    function is_Zhi_8(var map: array of Byte; pos: Integer; var m_Zhi_Dir: array of Integer): boolean;
    var
        d, p0, p1: Integer;
        flg: Boolean;

            // ʶ��"֮��"��ʱ��ʹ�ô˼�飬�򡰷��͡����Ѳ��ɶ����롰ǽ��ͬ�ȿ���
        function is_Fang2(var map: array of Byte; p1, p0: Integer): boolean;
        var
            p1_R, p1_C, p0_R, p0_C, p2, p3, p4, p5, p6, dir: Integer;
        begin
            p1_R := p1 div nCols;
            p1_C := p1 mod nCols;
            p0_R := p0 div nCols;
            p0_C := p0 mod nCols;

            if p1_R = p0_R then begin  // ������ȶԵ�ͬ��
                dir := IfThen(p1_C > p0_C, 1, 0);
                p2 := p1 + diff[dir * 2];            // ͬ��
                p3 := p1 + diff[1];                  // ��
                p4 := p1 + diff[3];                  // ��
                p5 := p1 + diff[1] + diff[dir * 2];  // ��֮ͬ��
                p6 := p1 + diff[3] + diff[dir * 2];  // ��֮ͬ��
            end else begin             //������ȶԵ�ͬ��
                dir := IfThen(p1_R > p0_R, 1, 0);
                p2 := p1 + diff[1 + dir * 2];            // ͬ��
                p3 := p1 + diff[0];                      // ��
                p4 := p1 + diff[2];                      // ��
                p5 := p1 + diff[0] + diff[1 + dir * 2];  // ��֮ͬ��
                p6 := p1 + diff[2] + diff[1 + dir * 2];  // ��֮ͬ��
            end;
            if (isBoxWall(map, p1)) and (isBoxWall(map, p2)) then begin
                if (isBoxWall(map, p3)) and (isBoxWall(map, p5) or isBoxWall(map, p4)) and (isBoxWall(map, p6)) then begin // �ɷ�
                    Result :=  true;
                    Exit;
                end;
            end;
            Result :=  false;
        end;

    begin
        d   := m_Zhi_Dir[2];  // �ڶ����ķ���
        p0  := pos;
        p1  := pos;
        flg := false;  // ֮��ǰ�벿���Ƿ����

        case m_Zhi_Dir[1] of  // ��һ���ķ���
        1:  // ��һ������
                if d = 4 then begin  // �ڶ�������
                    while (isBox(map, p1)) do begin  // �������¼��
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if (d = 4) then begin  // ��
                            d  := 0;
                            p1 := p1 + diff[0];
                        end else begin       // ��
                            d  := 4;
                            p1 := p1 + diff[3];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                            flg := true;  // ǰ�벿��֮�ֳ���
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // ǰ�벿��֮�ֳ��ͣ������벿��
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;
                        while (isBox(map, p1)) do begin  // �������Ҽ��
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d = 4 then begin  // ��
                                d  := 0;
                                p1 := p1 + diff[1];
                            end else begin       // ��
                                d  := 4;
                                p1 := p1 + diff[2];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                                Result := true;  // ��벿��֮�ֳ���
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end else begin  // �ڶ�������
                    while (isBox(map, p1)) do begin  // �������ϼ��
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d <> 4 then begin  // ��
                            d  := 4;
                            p1 := p1 + diff[0];
                        end else begin       // ��
                            d  := 0;
                            p1 := p1 + diff[1];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                            flg := true;  // ǰ�벿��֮�ֳ���
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // ǰ�벿��֮�ֳ��ͣ������벿��
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;
                        while (isBox(map, p1)) do begin  // �������Ҽ��
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d <> 4 then begin  // ��
                                d  := 4;
                                p1 := p1 + diff[3];
                            end else begin       // ��
                                d  := 0;
                                p1 := p1 + diff[2];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                                Result := true;  // ��벿��֮�ֳ���
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end;
        2:  // ��һ������
                if d = 4 then begin  // �ڶ�������
                    while (isBox(map, p1)) do begin  // �������¼��
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d = 4 then begin  // ��
                            d  := 0;
                            p1 := p1 + diff[2];
                        end else begin       // ��
                            d  := 4;
                            p1 := p1 + diff[3];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                            flg := true;  // ǰ�벿��֮�ֳ���
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // ǰ�벿��֮�ֳ��ͣ������벿��
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // ����������
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d = 4 then begin  // ��
                                d  := 0;
                                p1 := p1 + diff[1];
                            end else begin       // ��
                                d  := 4;
                                p1 := p1 + diff[0];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                                Result := true;  // ��벿��֮�ֳ���
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end else begin  // �ڶ�������
                    while (isBox(map, p1)) do begin  // �������ϼ��
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d <> 4 then begin  // ��
                            d  := 4;
                            p1 := p1 + diff[2];
                        end else begin       // ��
                            d  := 0;
                            p1 := p1 + diff[1];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                            flg := true;  // ǰ�벿��֮�ֳ���
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // ǰ�벿��֮�ֳ��ͣ������벿��
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // ����������
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d <> 4 then begin  // ��
                                d  := 4;
                                p1 := p1 + diff[3];
                            end else begin       // ��
                                d  := 0;
                                p1 := p1 + diff[0];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                                Result := true;  // ��벿��֮�ֳ���
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end;
        3:  // ��һ������
                if d = 2 then begin  // �ڶ�������
                    while (isBox(map, p1)) do begin  // �������Ҽ��
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d = 2 then begin  // ��
                            d  := 0;
                            p1 := p1 + diff[1];
                        end else begin       // ��
                            d  := 2;
                            p1 := p1 + diff[2];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                            flg := true;  // ǰ�벿��֮�ֳ���
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // ǰ�벿��֮�ֳ��ͣ������벿��
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // �������¼��
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d = 2 then begin  // ��
                                d  := 0;
                                p1 := p1 + diff[0];
                            end else begin       // ��
                                d  := 2;
                                p1 := p1 + diff[3];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                                Result := true;  // ��벿��֮�ֳ���
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end else begin  // �ڶ�������
                    while (isBox(map, p1)) do begin  // ����������
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d <> 2 then begin  // ��
                            d  := 2;
                            p1 := p1 + diff[1];
                        end else begin       // ��
                            d  := 0;
                            p1 := p1 + diff[0];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin // ����ǽ�򷽡�
                            flg := true;  // ǰ�벿��֮�ֳ���
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // ǰ�벿��֮�ֳ��ͣ������벿��
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // �������¼��
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d <> 2 then begin  // ��
                                d  := 2;
                                p1 := p1 + diff[2];
                            end else begin       // ��
                                d  := 0;
                                p1 := p1 + diff[3];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                                Result := true;  // ��벿��֮�ֳ���
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end;
        4:  // ��һ������
                if d = 2 then begin  // �ڶ�������
                    while (isBox(map, p1)) do begin  // �������Ҽ��
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d = 2 then begin  // ��
                            d  := 0;
                            p1 := p1 + diff[3];
                        end else begin       // ��
                            d  := 2;
                            p1 := p1 + diff[2];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                            flg := true;  // ǰ�벿��֮�ֳ���
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // ǰ�벿��֮�ֳ��ͣ������벿��
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // �������ϼ��
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d = 2 then begin  // ��
                                d  := 0;
                                p1 := p1 + diff[0];
                            end else begin       // ��
                                d  := 2;
                                p1 := p1 + diff[1];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                                Result := true;  // ��벿��֮�ֳ���
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end else begin  // �ڶ�������
                    while (isBox(map, p1)) do begin  // ����������
                        if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                        if d <> 2 then begin  // ��
                            d  := 2;
                            p1 := p1 + diff[3];
                        end else begin       // ��
                            d  := 0;
                            p1 := p1 + diff[0];
                        end;
                        if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                            flg := true;  // ǰ�벿��֮�ֳ���
                            break;
                        end;
                        p0 := p1;
                    end;
                    if flg then begin  // ǰ�벿��֮�ֳ��ͣ������벿��
                        d  := m_Zhi_Dir[2];
                        p0 := pos;
                        p1 := pos;

                        while (isBox(map, p1)) do begin  // �������ϼ��
                            if (m_Zhi_Dir[0] < 1) and (map[p1] = BT_BOX) then m_Zhi_Dir[0] := 1;
                            if d <> 2 then begin  // ��
                                d  := 2;
                                p1 := p1 + diff[2];
                            end else begin       // ��
                                d  := 0;
                                p1 := p1 + diff[1];
                            end;
                            if (map[p1] = BT_WALL) or (is_Fang2(map, p1, p0)) then begin  // ����ǽ�򷽡�
                                Result := true;  // ��벿��֮�ֳ���
                                Exit;
                            end;
                            p0 := p1;
                        end;
                    end;
                end;
        end;
        m_Zhi_Dir[0] := 0;
        Result := false;  //������֮��û�г��ͻ�û������
    end;

begin
    if isBox(map, pos) then begin  //��λ������
        //1������ - ���£�ͬʱ�������� -- ��
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 2;
        m_Zhi_Dir[2] := 4;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //2������ - ���ң�ͬʱ�������� -- ��
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 4;
        m_Zhi_Dir[2] := 2;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //3������ - ���£�ͬʱ�������� -- �ң�
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 1;
        m_Zhi_Dir[2] := 4;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //4������ - ����ͬʱ�������� -- �ң�
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 4;
        m_Zhi_Dir[2] := 1;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //5������ - ���ϣ�ͬʱ�������� -- ��
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 2;
        m_Zhi_Dir[2] := 3;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //6������ - ���ң�ͬʱ�������� -- ��
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 3;
        m_Zhi_Dir[2] := 2;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //7������ - ����ͬʱ�������� -- �ң�
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 3;
        m_Zhi_Dir[2] := 1;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
        //8������ - ���ϣ�ͬʱ�������� -- �ң�
        m_Zhi_Dir[0] := 0;
        m_Zhi_Dir[1] := 1;
        m_Zhi_Dir[2] := 3;
        if is_Zhi_8(map, pos, m_Zhi_Dir) then begin
           Result := true;
           Exit;
        end;
    end;
    Result := false;
end;

// �Ƿ񹹳ɡ�˫ L���ͣ���������һ����ͣ�����
function isLock_Double_L(var map: array of Byte; pos: Integer; var m_Double_L_Top: array of Integer): boolean;

    //ĳ����˫ L���Ƿ���ͣ�m_Row��m_Col -- �м�յ����ꣻdR��dC -- ���Ƽ�鷽��isSecond -- �Ƿ����ҵڶ�������
    function is_Double_L(var map: array of Byte; pos, dR, dC: Integer; var m_Double_L_Top: array of Integer; isSecond: Boolean): boolean;
    begin
        while (true) do begin
            //�˷����ֶ��㣬�˷���˫ L������
            if (isBoxWall(map, pos)) and (isBoxWall(map, pos - dC)) then begin
                if (isSecond) then begin  //��¼�ڶ������������
                    m_Double_L_Top[2] := pos;
                end else begin  //��¼��һ�����������
                    m_Double_L_Top[1] := pos;
                end;
                Result := true;  //�˷���˫ L������
                Exit;
            end;

            //����Ϊ��˫ L�����м䲿�֣��������
            if (isBoxWall(map, pos + diff[0])) and (isBoxWall(map, pos + diff[2])) then begin
                //�ı��м�յ�����
                pos := pos + dR * nCols + dC;
                continue;
            end;

            break;  //���򣬴˷���˫ L��û�г���
        end;

        Result :=  false;  //�˷���˫ L��û�г���
    end;

    // �Ƿ�˫ L�����������м�Ŀ������ 2 ����ʱ������Ƚϸ��ӣ����ԡ������������������� 2 ��Ŀ���ʱ���Ƿ�����ǣ����飩
    function is_Double_L_Locked(var map: array of Byte; var m_Double_L_Top: array of Integer): boolean;
    var
        pos, dR, dC, n: Integer;                         
        flg: array[0..5] of Boolean;
        f: Boolean;
    begin
        // ͨ�����㣬ʹ����㷨ʱ�����á�����--���¡�����˼��������mTop_Bottom[1] �����󶥵㣬mTop_Bottom[2] �������¶��㣩
        dR := 1; dC := 1;
        if (m_Double_L_Top[1] div nCols > m_Double_L_Top[2] div nCols) then dR := -1;
        if (m_Double_L_Top[1] mod nCols > m_Double_L_Top[2] mod nCols) then dC := -1;

        // ������� 6 �������Ƿ���Ŀ���
        flg[0] := (map[m_Double_L_Top[1]             ] = BT_BOX);       //��
        flg[1] := (map[m_Double_L_Top[1] + dC        ] = BT_BOX);       //����
        flg[2] := (map[m_Double_L_Top[1] + dR * nCols] = BT_BOX);       //�м���
        flg[3] := (map[m_Double_L_Top[2] - dR * nCols] = BT_BOX);       //�м���
        flg[4] := (map[m_Double_L_Top[2] - dC        ] = BT_BOX);       //����
        flg[5] := (map[m_Double_L_Top[2]             ] = BT_BOX);       //��

        // �����м�Ĳ��֣���¼��û��δ��λ�������Լ��м�Ŀյ��м���Ŀ���
        f := (flg[0]) or (flg[1]) or (flg[2]) or (flg[3]) or (flg[4]) or (flg[5]);
        n := 0;
        // ��һ���м�յص�����
        pos := m_Double_L_Top[1] + dR * nCols + dC;
        while (true) do begin
            if (not f) and ((map[pos - dC] = BT_BOX) or (map[pos + dC] = BT_BOX)) then f := true;  // �����в���Ŀ��������

            if map[pos] = BT_GOAL then Inc(n);  // �м���Ŀ���

            pos := pos + dR * nCols + dC;
            if pos = m_Double_L_Top[2] then break;  // ����ڶ�������
        end;

        m_Double_L_Top[0] := n;  // ��һ��Ԫ�ؼ�¼�����Ĳ���Ŀ����ϵ����Ӹ���

        if n = 0 then begin  // û��Ŀ��㣬���ٰ���û�й�λ�����ӣ��ض����ɡ����͡�����
            if f then begin
               Result := true;
               Exit;
            end;
        end else if n = 1 then begin  // һ��Ŀ��㲻���Բ����ˣ���������ͬʱ����δ��λ������ʱ���ض����ɡ����͡�����
            if ((flg[0]) or (flg[1]) or (flg[2])) and ((flg[3]) or (flg[4]) or (flg[5])) then begin
               Result := true;
               Exit;
            end;
        end;
        Result :=  false;
    end;

begin
    if isBox(map, pos) then begin  // ��λ������
        // �Ҳ������ӻ�ǽ������Ϊһ������
        if isBoxWall(map, pos + diff[2]) then begin
            //����Ҳ෽��
            //��Ϊ��һ������
            m_Double_L_Top[1] := pos;
            if (isPass(map, pos + diff[2] + diff[3])) and (is_Double_L(map, pos + diff[2] + diff[3], 1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) or  // ���£�����
               (isPass(map, pos + diff[2] + diff[1])) and (is_Double_L(map, pos + diff[2] + diff[1], -1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  // ���ϣ�����
                Result := true;
                Exit;
            end;
            //�����෽��
            //��Ϊ��һ������
            m_Double_L_Top[1] := pos + diff[2];
            if (isPass(map, pos + diff[1])) and (is_Double_L(map, pos + diff[1], -1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) or  //���ϣ�����
               (isPass(map, pos + diff[3])) and (is_Double_L(map, pos + diff[3], 1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //���£�����
                Result := true;
                Exit;
            end;
        end;

        //��������ӻ�ǽ������Ϊһ������
        if isBoxWall(map, pos + diff[0]) then begin
            //�����෽��
            //��Ϊ��һ������
            m_Double_L_Top[1] := pos;
            if (isPass(map, pos + diff[0] + diff[1])) and (is_Double_L(map, pos + diff[0] + diff[1], -1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) or  //���ϣ�����
               (isPass(map, pos + diff[0] + diff[3])) and (is_Double_L(map, pos + diff[0] + diff[3], 1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //���£�����
                Result := true;
                Exit;
            end;
            //����Ҳ෽��
            //��Ϊ��һ������
            m_Double_L_Top[1] := pos + diff[0];
            if (isPass(map, pos + diff[1])) and (is_Double_L(map, pos + diff[1], -1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) or  //���ϣ�����
               (isPass(map, pos + diff[3])) and (is_Double_L(map, pos + diff[3], 1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //���£�����
                Result := true;
                Exit;
            end;
        end;

        //�Ҳ��� �յأ�Ŀ��㣩 + ���ӻ�ǽ
        if (isPass(map, pos + diff[2])) and (isBoxWall(map, pos + diff[2] * 2)) then begin
            if (is_Double_L(map, pos + diff[2], -1, -1, m_Double_L_Top, false)) and (is_Double_L(map, pos + diff[2], 1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //���ϡ�����
                Result := true;
                Exit;
            end;
            if (is_Double_L(map, pos + diff[2], -1, 1, m_Double_L_Top, false)) and (is_Double_L(map, pos + diff[2], 1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //���ϡ�����
                Result := true;
                Exit;
            end;
        end;

        //����� �յأ�Ŀ��㣩 + ���ӻ�ǽ
        if (isPass(map, pos + diff[0])) and (isBoxWall(map,pos + diff[0] * 2)) then begin
            if (is_Double_L(map, pos + diff[0], -1, -1, m_Double_L_Top, false)) and (is_Double_L(map, pos + diff[0], 1, 1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //���ϡ�����
                Result := true;
                Exit;
            end;
            if (is_Double_L(map, pos + diff[0], -1, 1, m_Double_L_Top, false)) and (is_Double_L(map, pos + diff[0], 1, -1, m_Double_L_Top, true)) and (is_Double_L_Locked(map, m_Double_L_Top)) then begin  //���ϡ�����
                Result := true;
                Exit;
            end;
        end;
    end;
    Result := false;
end;

end.
