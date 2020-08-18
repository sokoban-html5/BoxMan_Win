unit EditorHelp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TEditorHelpForm = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  EditorHelpForm: TEditorHelpForm;

const
  HelpText =
              '======================' + #10 +
              '=     《关卡编辑板块》' + #10 +
              '======================' + #10 +
              #10 +
              '本版块分“绘制模式”和“浏览模式”：' + #10 +
              '“绘制模式”下：【左键】: 绘制，【右键】: 擦除；拖动鼠标，可连续绘制或擦除！' + #10 +
              '“浏览模式”下，【右键】: 功能菜单' + #10 +
              #10 +
              '【Ctrl + C】: 送入剪切板' + #10 +
              '【Ctrl + V】: 从剪切板读入' + #10 +
              '【Ctrl + S】: 保存到文档' + #10 +
              '【Ctrl + Z】: 撤销' + #10 +
              '【Shift + Z】: 重做' + #10 +
              #10 +
              '【Ctrl + Ins】: 向右平移地图' + #10 +
              '【Ctrl + Del】: 向左平移地图' + #10 +
              '【Shift + Ins】: 向下平移地图' + #10 +
              '【Shift + Del】: 向上平移地图' + #10 +
              '' +
              '【Ctrl + 方向键】: 上下左右平移地图' + #10 +
              #10 +
              '【滑轮】: 上下卷动地图' + #10 +
              '【Ctrl + 滑轮】: 左右卷动地图' + #10 +
              '【PgUp/PgDn/Home/End】: 也可以卷动地图（同时，还可以配合 Ctrl 键使用）' + #10 +
              #10 +
              '【+、-、Shif + 滑轮】: 缩放地图' + #10 +
              '【*、Esc】：缩放还原' + #10 +
              #10 +
              '当配合截图识别进行关卡编辑时：' + #10 +
              '【G】: 是否显示“参考图”开关' + #10 +
              '【T】: 是否显示“小参考图”开关' + #10 +
              #10 +
              '======================' + #10 +
              '=     《截图识别板块》' + #10 +
              '======================' + #10 +
              #10 +
              '本版块有“调整边框”、“自动识别”和“手动编辑”三种模式：' + #10 +
              #10 +
              '1、“调整边框”模式下：' + #10 +
              #10 +
              '可用鼠标拖动边框进行调整（直接拖动左上角，可以同时调整左框线和上框线；行高和列宽也可以同时拖动进行调整），还可以用【L、T、R、B】键快速指定“左上右下”边框' + #10 +
              '特别的：【左键双击】可快速指定“左上角”；【右键单击】可快速指定“右下角”' + #10 +
              '        【鼠标滚轮】可对顶行获得焦点（鼠标过来即可获得焦点）的边界或行高列宽进行微调' + #10 +
              '        【Shift + 鼠标滚轮】可对鼠标贴近的格线（那6条特别的格线或左上角第一个单元格才可以）进行微调' + #10 +
              #10 +
              '2、“自动识别”模式下：' + #10 +
              #10 +
              '当识别效果不佳时，调整左侧边栏下面的三个参数，识别效果会有一定的改善' + #10 +
              '选好识别元素后，在图像上单击鼠标【左键】即可自动识别同类元素，【右键】为擦除功能' + #10 +
              #10 +
              '3、“手动编辑”模式下：' + #10 +
              #10 +
              '【左键】为编辑功能，【右键】为擦除功能' + #10 +
              #10 +
              '4、三种模式下：' + #10 +
              #10 +
              '【Ctrl + 移动鼠标】，屏蔽某格子的识别；【Shift + 移动鼠标】，屏蔽某格子的同类识别' + #10 +
              #10 +
              '滑轮: 鼠标停在顶行工具栏的“上下左右”等编辑框上时，微调相应数值；否则，上下卷动地图' + #10 +
              'Ctrl + 滑轮: 左右卷动地图' + #10 +
              #10 +
              '5、特别提醒：' + #10 +
              #10 +
              '识别图块时，会比对图块的“造型相似度”、“色调”和“平均灰度” 等 3 项指标，所以，有时虽然“相似度”很高，但是，不一定做出识别！' + #10 +
              '而且，“相似度”是图像做“灰度二值化”后，逐像素进行比对，需要对应位置的像素完全相同才可以，所以，可能会与眼睛看到的感觉有所差异！';

implementation

{$R *.dfm}

procedure TEditorHelpForm.FormCreate(Sender: TObject);
begin
  Caption := '帮助';
  Memo1.Lines.Text := HelpText;
end;

end.
