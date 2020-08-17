unit LogFile;

interface
  procedure LogFileInit(ph: string);
  procedure LogFileClose();

var
  myLogFile: Textfile;

  AppPath, curSkinFileName: string;      // Ƥ���ĵ���


implementation

// ��ʼ�� Log �ļ�
procedure LogFileInit(ph: string);
begin
  AssignFile(myLogFile, ph + 'BoxMan.log');
  ReWrite(myLogFile);
end;

// �ر� Log �ļ�
procedure LogFileClose();
begin
  Closefile(myLogFile);
end;

end.
