program BoxManEditor;

uses
  Forms,
  Editor_ in 'Editor_.pas' {EditorForm_},
  EditorInf_ in 'EditorInf_.pas' {EditorInfForm_},
  Recog_ in 'Recog_.pas' {RecogForm_},
  LoadSkin in 'LoadSkin.pas' {LoadSkinForm},
  EditorHelp in 'EditorHelp.pas' {EditorHelpForm};

{$R *.res}

// ����رճ�����֡�runtime error 216 at xxxxxxx"�Ĵ�����ʾ
procedure Halt0;
begin
  Halt;
end;

begin
  Application.Initialize;
  Application.CreateForm(TEditorForm_, EditorForm_);
  Application.CreateForm(TEditorInfForm_, EditorInfForm_);
  Application.CreateForm(TRecogForm_, RecogForm_);
  Application.CreateForm(TLoadSkinForm, LoadSkinForm);
  Application.CreateForm(TEditorHelpForm, EditorHelpForm);
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
