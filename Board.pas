unit Board;

interface

type
  TMapNode = record             // �ؿ��ڵ� -- �ؿ����еĸ����ؿ�
    Map_Thin: string;           // ���ؿ� XSB
    Map: string;                // �ؿ� XSB
    Rows, Cols: integer;        // �ؿ��ߴ�
    Boxs: integer;              // ������
    Goals: integer;             // Ŀ����
    Trun: integer;              // �ؿ���ת�Ǽ�
    Title: string;              // ����
    Author: string;             // ����
    Comment: string;            // �ؿ�������Ϣ
    CRC32: integer;             // CRC32
    CRC_Num: integer;           // ����ǰ��ͼΪ 0 ת����С CRC λ�ڵڼ�ת��
    Solved: Boolean;            // �Ƿ��ɴ�
    isEligible: Boolean;        // �Ƿ�ϸ�Ĺؿ�XSB
    Num: integer;               // �ؿ���� -- �������ĵ����һ���ؿ�ʱʹ��
  end;
  PMapNode = ^TMapNode;         // �ؿ��ڵ�ָ��

var
  curMapNode: PMapNode;    // ��ǰ�ؿ��ڵ�

  Map_Thin: string;        // ���ؿ� XSB
  Map: string;             // �ؿ� XSB
  Title: string;           // ����
  Author: string;          // ����
  Comment: string;         // �ؿ�������Ϣ
  Rows, Cols: integer;     // �ؿ��ߴ�
  Boxs, Goals: integer;    // ��������Ŀ����
  Trun: integer;           // �ؿ���ת�Ǽ�
  CRC32: integer;          // CRC32
  CRC_Num: integer;        // ����ǰ��ͼΪ 0 ת����С CRC λ�ڵڼ�ת��
  Solved: Boolean;         // �Ƿ��ɴ�
  isEligible: Boolean;     // �Ƿ�ϸ�Ĺؿ�XSB

  CurrentLevel: integer;   // ��ǰ�ؿ����
  ManPosition: integer;    // ���Ƴ�ʼ״̬���˵�λ��
  MapSize: integer;        // ��ͼ�ߴ�
  CellSize: integer;       // ����ͼʱ����ǰ�ĵ�Ԫ��ߴ�
  Recording: Boolean;      // �Ƿ��ڶ���¼��״̬
  Recording_BK: Boolean;   // �Ƿ��ڶ���¼��״̬ -- ����
  StartPos: Integer;       // ����¼�ƵĿ�ʼ��
  StartPos_BK: Integer;    // ����¼�ƵĿ�ʼ�� -- ����
  isFinish: Boolean;       // �Ƿ�õ��𰸣�����ۿ����� - ����سɹ�������ȷ�𰸺󣬴˱�־Ϊ�棬��ʾ���ԡ��ۿ�������

  ManPos_BK_0: integer;    // �˵�λ�� -- ���ƣ�����Ѿ�ָ����λ��
  ManPos_BK_0_2: integer;  // �˵�λ�� -- ���ƣ�����������λ��

implementation

end.
