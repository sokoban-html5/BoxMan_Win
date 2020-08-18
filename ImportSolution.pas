unit ImportSolution;

interface

uses
  Windows, StdCtrls, Controls, ComCtrls, Classes,
  SysUtils, Forms;

type
  TImportForm = class(TForm)
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;

    procedure FormCreate(Sender: TObject);
    procedure ImportFromBoxmanAN();
    procedure ImportFromBoxmanOld();
    procedure Button1Click(Sender: TObject);

  private

  public

  end;

const
  // ���ڳ��������ҡ��ϡ���
  dr4 : array[0..3] of Integer = (  0, 0, -1, 1 );
  dc4 : array[0..3] of Integer = ( -1, 1,  0, 0 );

var
  ImportForm: TImportForm;

  AppPath: string;
  BoxManDBpath, myFileName: string;

  tmp_Board: array[0..9999] of integer;       // ��ʱ��ͼ
  sMoves, sPushs: integer;                    // ��֤��ʱ����¼�ƶ������ƶ���
  xsb_Goals, xsb_CRC, xsb_CRC_Num: integer;   // �ؿ�����

  isStop: Boolean;                            // �Ƿ��жϵ���

implementation

uses
  DateModule, SQLiteTable3, CRC_32;

{$R *.DFM}

procedure TImportForm.FormCreate(Sender: TObject);
begin
  Caption := '�����';
  Label1.Caption := 'ѡ��:';
  RadioButton1.Caption := '���ֻ��桶������֡��𰸿⵼��';
  RadioButton2.Caption := '�Ӿɰ桶BoxMan���𰸿⵼��';

  Button1.Caption := '����';
  Button2.Caption := 'ȡ��';

  AppPath := ExtractFilePath(Application.ExeName);
  BoxManDBpath := AppPath + 'BoxMan.db';
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

function MapNormalize(var xsb_Test: string; var Goals, xsb_CRC, xsb_CRC_Num: Integer): Boolean;
var
  i, j, k, rows, cols, mr, mc, nRen, dr, dc, r, c: Integer;
  data_Text: TStringList;
  aMap: array[0..99, 0..99] of Char;
  aMap0: array[0..99, 0..99] of Char;
  aMap1: array[0..99, 0..99] of Char;
  aMap2: array[0..99, 0..99] of Char;
  aMap3: array[0..99, 0..99] of Char;
  aMap4: array[0..99, 0..99] of Char;
  aMap5: array[0..99, 0..99] of Char;
  aMap6: array[0..99, 0..99] of Char;
  aMap7: array[0..99, 0..99] of Char;
  Mark: array[0..99, 0..99] of Boolean;
  mr2, mc2, left, top, right, bottom, nBox, nDst, mTop, mLeft, mBottom, mRight: Integer;
  P: TList;
  Pos, F: ^TPoint;
  s1: string;
  key8: array[0..7] of Integer;
begin
  Result := False;

  Goals := 0;
  xsb_CRC := -1;
  xsb_CRC_Num := -1;

  data_Text := Split(xsb_Test);

  rows := data_Text.Count;
  if rows > 100 then Exit;

  for i := 0 to 99 do begin
    for j := 0 to 99 do begin
        aMap[i, j] := '_';
        aMap0[i, j] := '_';
        aMap1[i, j] := '_';
        aMap2[i, j] := '_';
        aMap3[i, j] := '_';
        aMap4[i, j] := '_';
        aMap5[i, j] := '_';
        aMap6[i, j] := '_';
        aMap7[i, j] := '_';
        Mark[i, j] := False;
    end;
  end;

  cols := 0;
  nRen := 0;
  for i := 0 to rows-1 do begin
      j := Length(data_Text[i]);
      if j > 100 then Exit;
      if cols < j then cols := j;
      for j := 1 to cols do begin
          aMap[i, j-1] := data_Text[i][j];
          if aMap[i, j-1] in [ '@', '+' ] then begin
             mr := i;
             mc := j-1;
             Inc(nRen);
          end;
      end;
  end;
  
  if nRen <> 1 then Exit;

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

    case aMap[mr, mc] of
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
      if (mr2 < 0) or (mr2 >= rows) or (mc2 < 0) or (mc2 >= cols) or    // ����
        (Mark[mr2, mc2]) or (aMap[mr2, mc2] = '#') or (aMap[mr2, mc2] = '_') then
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

  if (nBox <> nDst) or (nBox < 1) or (nDst < 1) then Exit;     // �ɴ������ڵ�������Ŀ���������ȷ

  Goals := nDst;
  
  // ��׼����ĳߴ磨��ת��
  rows := bottom - top + 1 + 2;
  cols := right - left + 1 + 2;

  if (rows > 98) or (cols > 98) then Exit;

  // ��׼��
  for r := top to bottom do begin
    for c := left to right do begin
      i := r - top + 1;
      j := c - left + 1;
      aMap0[r, j] := aMap[r, c];

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

  xsb_Test := '';

  // ��׼����İ�ת���ؿ���˳ʱ����ת���õ���0ת��1ת��2ת��3ת����4תΪ0ת�����Ҿ���4ת��˳ʱ����ת���õ���4ת��5ת��6ת��7ת��
  for i := 0 to rows - 1 do begin
    for j := 0 to cols - 1 do begin
      xsb_Test := xsb_Test + aMap0[i, j];
      aMap1[j, rows - 1 - i] := aMap0[i, j];
      aMap2[rows - 1 - i, cols - 1 - j] := aMap0[i, j];
      aMap3[cols - 1 - j, i] := aMap0[i, j];
      aMap4[i, cols - 1 - j] := aMap0[i, j];
      aMap5[cols - 1 - j, rows - 1 - i] := aMap0[i, j];
      aMap6[rows - 1 - i, j] := aMap0[i, j];
      aMap7[j, i] := aMap0[i, j];
    end;
    if i < rows - 1 then xsb_Test := xsb_Test + #10;
  end;

  // �ڼ�ת�� CRC ��С
  key8[1] := Calcu_CRC_32(@aMap1, cols, rows);
  key8[2] := Calcu_CRC_32(@aMap2, rows, cols);
  key8[3] := Calcu_CRC_32(@aMap3, cols, rows);
  key8[4] := Calcu_CRC_32(@aMap4, rows, cols);
  key8[5] := Calcu_CRC_32(@aMap5, cols, rows);
  key8[6] := Calcu_CRC_32(@aMap6, rows, cols);
  key8[7] := Calcu_CRC_32(@aMap7, cols, rows);
  xsb_CRC := Calcu_CRC_32(@aMap0, rows, cols);        // ��׼��׼����Ĺؿ� -- û��ǽ������
  xsb_CRC_Num := 0;

  for i := 1 to 7 do begin
    if xsb_CRC > key8[i] then
    begin
      xsb_CRC := key8[i];
      xsb_CRC_Num := i;
    end;
  end;

  Result := True;
end;

procedure TImportForm.ImportFromBoxmanOld();
var
  sldb: TSQLiteDatabase;
  sltb_: TSQLIteTable;
  sSQL: String;
  solText: string;
  n, Goals, Moves, Pushs, xsbCRC32, xsbCRC_TrunNum, solCRC32: Integer;
  myDateTime: TDateTime;
  total, total_1, total_2: Integer;
begin
  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));
  try
    if not sldb.TableExists('Tab_Solution') then begin
      sSQL := 'CREATE TABLE Tab_Solution ( ' +
              '[ID] INTEGER PRIMARY KEY AUTOINCREMENT, ' +
              '[XSB_CRC32] INTEGER NOT NULL DEFAULT 0, ' +
              '[XSB_CRC_TrunNum] INTEGER NOT NULL DEFAULT 0, ' +
              '[Goals] INTEGER NOT NULL DEFAULT 0, ' +
              '[Sol_CRC32] INTEGER NOT NULL DEFAULT 0, ' +
              '[Moves] INTEGER NOT NULL DEFAULT 0, ' +
              '[Pushs] INTEGER NOT NULL DEFAULT 0, ' +
              '[Sol_Text] TEXT NOT NULL DEFAULT "", ' +
              '[XSB_Text] TEXT NOT NULL DEFAULT "", ' +
              '[Sol_DateTime] TEXT NOT NULL DEFAULT "" )';

      sldb.execsql(sSQL);

    end;
    sldb.execsql('DROP INDEX sol_Index');
    sldb.execsql('CREATE INDEX sol_Index ON Tab_Solution(XSB_CRC32, Goals, Sol_CRC32)');
  except
    MessageBox(handle, PChar('�°�Ĵ𰸿��ĵ�����ʧ�ܣ�' + #10 + BoxManDBpath), '����', MB_ICONERROR or MB_OK);
    Close;
  end;

  // ���Ӵ����ݿ�
  try
    if not FileExists(AppPath + '\BoxMan.dat') then begin
       MessageBox(handle, PChar('û���ҵ��ɰ�Ĵ𰸿��ĵ���' + #10 + '���ȰѾɰ�𰸿��ĵ� BoxMan.dat ���Ƶ���ǰĿ¼�¡�'), '����', MB_ICONERROR or MB_OK);
       Close;
    end;
    DataModule1.ADOConnection1.Close;
    DataModule1.ADOConnection1.ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=BoxMan.dat;Persist Security Info=False;Jet OLEDB:Database Password=boxman2019;';
    DataModule1.ADOConnection1.LoginPrompt := False;
    DataModule1.ADOConnection1.Open;
  except
    DataModule1.ADOConnection1.Close;
    MessageBox(handle, '�򿪾ɰ�𰸿��ĵ�ʱ��������', '����', MB_ICONERROR or MB_OK);
  end;

  total   := 0;
  total_1 := 0;
  total_2 := 0;
  ProgressBar1.Visible := True;
  ProgressBar1.Position := 0;

  try

    sldb.BeginTransaction;

    try
      DataModule1.ADOQuery1.Close;
      DataModule1.ADOQuery1.SQL.Clear;
      DataModule1.ADOQuery1.SQL.Text := 'select * from Tab_Solution';
      DataModule1.ADOQuery1.Open;
      try
        DataModule1.DataSource1.DataSet := DataModule1.ADOQuery1;
        try
           // ��ȡ��
          with DataModule1.DataSource1.DataSet do
          begin
            ProgressBar1.Max := RecordCount;
            First;
            n := 0;
            while not Eof do begin
              if isStop then Break;
              
              Inc(n);
              ProgressBar1.Position := n;

              xsbCRC32       := FieldByName('XSB_CRC32').AsInteger;
              xsbCRC_TrunNum := FieldByName('XSB_CRC_TrunNum').AsInteger;
              Goals          := FieldByName('Goals').AsInteger;
              solCRC32       := FieldByName('Sol_CRC32').AsInteger;
              Moves          := FieldByName('Moves').AsInteger;
              Pushs          := FieldByName('Pushs').AsInteger;
              solText        := FieldByName('Sol_Text').AsString;
              myDateTime     := FieldByName('Sol_DateTime').AsDateTime;

              inc(total);    // ������

              sltb_ := slDb.GetTable('SELECT ID FROM Tab_Solution WHERE XSB_CRC32 = ' + IntToStr(xsbCRC32) + ' and Goals = ' + IntToStr(Goals) + ' and Sol_CRC32 = ' + IntToStr(solCRC32));

              try
                // û���ظ�����ӵ��µĴ𰸿�
                if sltb_.Count = 0 then begin
                  sSQL := 'INSERT INTO Tab_Solution (XSB_CRC32, XSB_CRC_TrunNum, Goals, Sol_CRC32, Moves, Pushs, Sol_Text, Sol_DateTime) ' +
                         'VALUES (' +
                         IntToStr(xsbCRC32) + ', ' +
                         IntToStr(xsbCRC_TrunNum) + ', ' +
                         IntToStr(Goals) + ', ' +
                         IntToStr(solCRC32) + ', ' +
                         IntToStr(Moves) + ', ' +
                         IntToStr(Pushs) + ', ''' +
                         solText + ''', ''' +
                         FormatDateTime(' yyyy-mm-dd hh:nn', myDateTime) + ''');';
                  sldb.ExecSQL(sSQL);
                  inc(total_1);           // �����Ĵ���
                end else inc(total_2);    // �ظ��Ĵ���;

              finally
                sltb_.Free;
              end;

              Next;
            end;
          end;

          ProgressBar1.Visible := False;
          MessageBox(handle, PChar('���������' + #10 +
                                   '��⵽�Ĵ�������' + IntToStr(total) + #10 +
                                   '�ɹ���������' + IntToStr(total_1) + #10 +
                                   '���ظ���������' + IntToStr(total_2) + #10 +
                                   '��Ч������' + IntToStr(total-total_1-total_2)), '��Ϣ', MB_ICONINFORMATION or MB_OK);
        finally
          DataModule1.DataSource1.DataSet.Close;
        end;
      finally
        DataModule1.ADOQuery1.Close;
      end;
    finally
      sldb.Commit;
      sldb.Free;
    end;
  except
    MessageBox(handle, PChar('�������󣬵���ʧ�ܣ�'), '����', MB_ICONERROR or MB_OK);
  end;
  Close;
end;

procedure TImportForm.ImportFromBoxmanAN();
var
  sldb, sldb_: TSQLiteDatabase;
  sltb, sltb_: TSQLIteTable;
  sSQL: String;
  xsbText, solText, strDateTime: string;
  len, n, Goals, Moves, Pushs, xsbCRC32, xsbCRC_TrunNum, solCRC32: Integer;
  total, total_1, total_2, num: Integer;
begin

  sldb := TSQLiteDatabase.Create(AnsiToUtf8(BoxManDBpath));

  try
    if not sldb.TableExists('Tab_Solution') then begin
      sSQL := 'CREATE TABLE Tab_Solution ( ' +
              '[ID] INTEGER PRIMARY KEY AUTOINCREMENT, ' +
              '[XSB_CRC32] INTEGER NOT NULL DEFAULT 0, ' +
              '[XSB_CRC_TrunNum] INTEGER NOT NULL DEFAULT 0, ' +
              '[Goals] INTEGER NOT NULL DEFAULT 0, ' +
              '[Sol_CRC32] INTEGER NOT NULL DEFAULT 0, ' +
              '[Moves] INTEGER NOT NULL DEFAULT 0, ' +
              '[Pushs] INTEGER NOT NULL DEFAULT 0, ' +
              '[Sol_Text] TEXT NOT NULL DEFAULT "", ' +
              '[XSB_Text] TEXT NOT NULL DEFAULT "", ' +
              '[Sol_DateTime] TEXT NOT NULL DEFAULT "" )';

      sldb.execsql(sSQL);
    end;
    sldb.execsql('DROP INDEX sol_Index');
    sldb.execsql('CREATE INDEX sol_Index ON Tab_Solution(XSB_CRC32, Goals, Sol_CRC32)');
  except
    MessageBox(handle, PChar('�°�Ĵ𰸿��ĵ�����ʧ�ܣ�' + #10 + BoxManDBpath), '����', MB_ICONERROR or MB_OK);
    Close;
  end;

  total   := 0;
  total_1 := 0;
  total_2 := 0;
  ProgressBar1.Visible := True;
  ProgressBar1.Position := 0;

  sldb.BeginTransaction;

  try
    sldb_ := TSQLiteDatabase.Create(AnsiToUtf8(AppPath + 'BoxMan_An.db'));
    if sldb_.TableExists('G_State') then begin
      try
        sSQL := 'select * from G_State where G_Solution = 1';
        sltb := slDb_.GetTable(sSQL);
        try
          if sltb.Count > 0 then begin
            ProgressBar1.Max := sltb.Count;
            sltb.MoveFirst;
            n := 0;
            while not sltb.EOF do begin
              if isStop then Break;

              Inc(n);
              ProgressBar1.Position := n;

              xsbText  := sltb.FieldAsString(sltb.FieldIndex['L_thin_XSB']);
              solText  := sltb.FieldAsString(sltb.FieldIndex['G_Ans']);
              Moves := sltb.FieldAsInteger(sltb.FieldIndex['G_Moves']);
              Pushs := sltb.FieldAsInteger(sltb.FieldIndex['G_Pushs']);
              strDateTime := sltb.FieldAsString(sltb.FieldIndex['G_DateTime']);
              len := Length(strDateTime);
              strDateTime := copy(strDateTime, len-18, 16);

              inc(total);    // ������

              if MapNormalize(xsbText, Goals, xsbCRC32, xsbCRC_TrunNum) then begin

                solCRC32 := Calcu_CRC_32_2(PChar(solText), Length(solText));

                sltb_ := slDb.GetTable('SELECT COUNT (*) as _NUM_ FROM Tab_Solution WHERE XSB_CRC32 = ' + IntToStr(xsbCRC32) + ' and Goals = ' + IntToStr(Goals) + ' and Sol_CRC32 = ' + IntToStr(solCRC32));
                num := sltb_.FieldAsInteger(sltb_.FieldIndex['_NUM_']);

                try
                  // û���ظ�����ӵ��µĴ𰸿�
                  if num = 0 then begin
                    sSQL := 'INSERT INTO Tab_Solution (XSB_CRC32, XSB_CRC_TrunNum, Goals, Sol_CRC32, Moves, Pushs, Sol_Text, XSB_Text, Sol_DateTime) ' +
                           'VALUES (' +
                           IntToStr(xsbCRC32) + ', ' +
                           IntToStr(xsbCRC_TrunNum) + ', ' +
                           IntToStr(Goals) + ', ' +
                           IntToStr(solCRC32) + ', ' +
                           IntToStr(Moves) + ', ' +
                           IntToStr(Pushs) + ', ''' +
                           solText + ''', ''' +
                           xsbText + ''', ''' +
                           strDateTime + ''');';
                    sldb.ExecSQL(sSQL);
                    inc(total_1);           // �����Ĵ���
                  end else inc(total_2);    // �ظ��Ĵ���;
                finally
                  sltb_.Free;
                end;
              end;
              sltb.Next;
            end;
            ProgressBar1.Visible := False;
            MessageBox(handle, PChar('���������' + #10 +
                                     '��⵽�Ĵ�������' + IntToStr(total) + #10 +
                                     '�ɹ���������' + IntToStr(total_1) + #10 +
                                     '���ظ���������' + IntToStr(total_2) + #10 +
                                     '��Ч������' + IntToStr(total-total_1-total_2)), '��Ϣ', MB_ICONINFORMATION or MB_OK);
          end else MessageBox(handle, PChar('û���ҵ��ֻ�����ֵĴ𰸣�' + #10 + '���Ȱ��ֻ���𰸿����Ϊ BoxMan_An.db �����Ƶ���ǰĿ¼�¡�'), '����', MB_ICONERROR or MB_OK);
        finally
          sltb.free;
        end;
      finally
        sldb_.Free;
      end;
    end else begin
      MessageBox(handle, PChar('û���ҵ��ֻ�����ֵĴ𰸿⣡' + #10 + '���Ȱ��ֻ���𰸿����Ϊ BoxMan_An.db �����Ƶ���ǰĿ¼�¡�'), '����', MB_ICONERROR or MB_OK);
    end;
  finally
    sldb.Commit;
    sldb.Free;
  end;
  Close;
end;

procedure TImportForm.Button1Click(Sender: TObject);
begin
  isStop := False;
  if RadioButton1.Checked then begin
     ImportFromBoxmanAN;        // ���ֻ���������ֵ����
  end else begin
     ImportFromBoxmanOld;       // �Ӿɰ�Boxman�𰸿⵼���
  end;
end;

end.

