program BoxMan;

uses
  Forms,
  Dialogs,
  SysUtils,
  Registry,
  Windows,
  DateModule in 'DateModule.pas' {DataModule1: TDataModule},
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

{$R *.RES}

// ����رճ�����֡�runtime error 216 at xxxxxxx"�Ĵ�����ʾ
procedure Halt0;
begin
  Halt;
end;

begin
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(Tmain, main);
  //  Application.CreateForm(TLoadSkinForm, LoadSkinForm);
  Application.CreateForm(TActionForm, ActionForm);
  Application.CreateForm(TInfForm, InfForm);
  Application.CreateForm(TMySubmit, MySubmit);
  Application.CreateForm(TShowSolutuionList, ShowSolutuionList);
  Application.CreateForm(TMyOpenFile, MyOpenFile);
//  Application.CreateForm(TBrowseForm, BrowseForm);
  Application.Run;

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
end.
