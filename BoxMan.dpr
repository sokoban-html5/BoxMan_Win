program BoxMan;

uses
  Forms,
  Dialogs,
  SysUtils,
  Registry,
  Windows,
  LoadSkin in 'LoadSkin.pas' {LoadSkinForm},
  MainForm in 'MainForm.pas' {main},
  PathFinder in 'PathFinder.pas',
  LoadMapUnit in 'LoadMapUnit.pas',
  LogFile in 'LogFile.pas',
  LurdAction in 'LurdAction.pas',
  Actions in 'Actions.pas' {ActionForm},
  BrowseLevels in 'BrowseLevels.pas' {BrowseForm},
  inf in 'inf.pas' {InfForm},
  Submit in 'Submit.pas' {MySubmit},
  ShowSolutionList in 'ShowSolutionList.pas' {ShowSolutuionList},
  OpenFile in 'OpenFile.pas' {MyOpenFile};

const
  iAtom = 'yuweng_BoxMan_2019_';        // �ó���ֻ����һ�ε�ȫ��ԭ��

var
  PreInstanceWindow: HWnd;

{$R *.RES}

// ����رճ�����֡�runtime error 216 at xxxxxxx"�Ĵ�����ʾ
procedure Halt0;
begin
  Halt;
end;

begin
   if GlobalFindAtom(iAtom) = 0 then begin
      GlobalAddAtom(iAtom);                        // ���ȫ��ԭ��

      Application.Title := 'yuweng_BoxMan_2019';

      Application.Initialize;
      Application.CreateForm(Tmain, main);
  Application.CreateForm(TActionForm, ActionForm);
  Application.CreateForm(TInfForm, InfForm);
  Application.CreateForm(TMySubmit, MySubmit);
  Application.CreateForm(TShowSolutuionList, ShowSolutuionList);
  Application.CreateForm(TMyOpenFile, MyOpenFile);
  Application.Run;
      
      GlobalDeleteAtom(GlobalFindAtom(iAtom));  // ɾ����ӵ�ȫ��ԭ��

      // ����رճ�����֡�runtime error 216 at xxxxxxx"�Ĵ�����ʾ
      asm
          xor edx, edx
          push ebp
          push OFFSET @@safecode
          push dword ptr fs:[edx]
          mov fs:[edx],esp

          call Halt0
          jmp @@exit;

          @@safecode:
          call Halt0;

          @@exit:
      end;
   end else begin
      PreInstanceWindow := findWindow(nil, PChar('yuweng_BoxMan_2019'));
      if PreInstanceWindow <> 0 then
      begin
        if IsIconic(PreInstanceWindow) then
          showWindow(PreInstanceWindow, SW_RESTORE)
        else
          SetForegroundWindow(PreInstanceWindow);
      end else GlobalDeleteAtom(GlobalFindAtom(iAtom));  // ɾ����ӵ�ȫ��ԭ��
   end;
end.
