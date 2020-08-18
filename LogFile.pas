unit LogFile;

interface
  procedure LogFileInit(ph: string);
  procedure LogFileClose();
  procedure LogFileInit_(ph: string);
  procedure LogFileClose_();

var
  myLogFile, myLogFile_: Textfile;

  AppPath, curSkinFileName: string;      // Ƥ���ĵ���


implementation

// ��ʼ�� Log �ļ�
procedure LogFileInit(ph: string);
begin
  AssignFile(myLogFile, ph);
  ReWrite(myLogFile);
end;

// �ر� Log �ļ�
procedure LogFileClose();
begin
  Closefile(myLogFile);
end;

// ��ʼ������ Log �ļ�
procedure LogFileInit_(ph: string);
begin
  AssignFile(myLogFile_, ph);
  ReWrite(myLogFile_);
end;

// �رն��� Log �ļ�
procedure LogFileClose_();
begin
  Closefile(myLogFile_);
end;

end.
