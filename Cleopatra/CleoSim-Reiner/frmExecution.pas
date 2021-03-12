unit frmExecution;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ValEdit, ComCtrls, XStringGrid;

type
  Texecution = class(TForm)
    GroupBox1: TGroupBox;
    ProgramData: TStringGrid;
    MachineCode: TStringGrid;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Regs: TValueListEditor;
    Negative: TCheckBox;
    Overflow: TCheckBox;
    zero: TCheckBox;
    Carry: TCheckBox;
    btnReset: TButton;
    btnPasso: TButton;
    MicroInstructionSimulation: TStringGrid;
    TrackBar1: TTrackBar;
    btnRodar: TButton;
    btnParar: TButton;
    chkMicro: TCheckBox;
    DataMemory: TXStringGrid;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnPassoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnResetClick(Sender: TObject);
    procedure btnRodarClick(Sender: TObject);
    procedure btnPararClick(Sender: TObject);
    procedure chkMicroClick(Sender: TObject);
    procedure DataMemoryCellProps(Sender: TObject; Canvas: TCanvas;
      var Alignment: TAlignment; var CellText: String;
      AState: TGridDrawState; Row, Col: Integer);
//    property pMar read RRMar write WRMar;
//    property pAc read RRAc write WRAc;
  private
    ac_reg,pc_reg,rs_reg,mar_reg,mdr_reg,ir_reg: integer;
    busa,busb,data: string;
    bContinuar: Boolean;

    procedure Fetch();
    procedure BlocoDeControle();
    procedure instrucao_lda(acesso: string);
    procedure instrucao_add(acesso: string);
    procedure instrucao_sta(acesso: string);
    procedure instrucao_sta_refresh(addr: string);
    procedure instrucao_not(acesso: string);
    procedure instrucao_or(acesso: string);
    procedure instrucao_and(acesso: string);
    procedure instrucao_hlt(acesso: string);
    procedure instrucao_jmp(acesso: string);
    procedure instrucao_jz(acesso: string);
    procedure instrucao_jn(acesso: string);
    procedure instrucao_jc(acesso: string);
    procedure instrucao_jv(acesso: string);
    procedure instrucao_jsr(acesso: string);
    procedure instrucao_rts(acesso: string);
    procedure BC_MicroInstr(p_alu_opcode, p_write_reg, p_read_reg : Integer; p_ce, p_rw, p_lnz, p_lcv: Boolean;p_microinstrucao: string);
    function pmem(mar: string):integer;
    function GetDATA(tipo: integer):integer;
    procedure ativa_proxima();
    { Private declarations }

  public
    memoria: array[0..255] of string;  //instrução por instrução
    memoria_dados: array[0..255] of array[0..2] of string;  //instrução por instrução
    memoria_dados_colorir: array[0..255] of boolean;  //instrução por instrução

//    ce,rw: boolean;
    procedure MicroCode();
    function alu_processor(op_code:integer; lnz: boolean;lcv: boolean;bus: array of string): integer;
    function write_reg(code: integer; valor: string; ce,rw: Boolean): string;
    //procedure write_reg(code: integer; valor: string; ce,rw: Boolean);
    //procedure read_reg(code: integer);
    function read_reg(code,p_bus: integer): string;
//    procedure read_reg(code,p_bus: integer);
    procedure gravaEstatus(ck: integer;data: string;alu_op,write_reg,read_reg: integer;lnz,lcv,ce, rw: boolean;microinstrucao: string);
//    procedure gravaEstatus(ck: integer; data: string; alu_op: string; write_reg: string; read_reg: string; lnz: string; lcv: string; microinstrucao: string);
    { Public declarations }
    procedure updateDataMemory(addr: integer; data: string; plabel: string; colorir: Boolean);
  end;

var
  execution: Texecution;
  row_colorir: integer;

implementation

uses principal, Math;
{$R *.dfm}

procedure Texecution.updateDataMemory(addr: integer;
                       data: string;
                       plabel: string;
                       colorir: Boolean);
begin
    if plabel <> '' then
      DataMemory.Cells[0,addr+1]:=plabel; // Label
    if data <> '' then
      DataMemory.Cells[2,addr+1]:=data; // Dado

    if colorir then
      memoria_dados_colorir[addr]:=true;
end;


procedure Texecution.gravaEstatus(ck: integer;
                       data: string;
                       alu_op,write_reg,read_reg: integer;
                       lnz,lcv,ce, rw: boolean;
                       microinstrucao: string);
var
  nzcv : string;
begin
  MicroInstructionSimulation.Cells[0,ck]:=IntToStr(ck);
  MicroInstructionSimulation.Cells[1,ck]:=data;
  MicroInstructionSimulation.Cells[2,ck]:=IntToStr(alu_op);
  MicroInstructionSimulation.Cells[3,ck]:=IntToStr(write_reg);
  MicroInstructionSimulation.Cells[4,ck]:=IntToStr(read_reg);
  if lnz then
    MicroInstructionSimulation.Cells[5,ck]:='1'
  else
    MicroInstructionSimulation.Cells[5,ck]:='0';

  if lcv then
    MicroInstructionSimulation.Cells[6,ck]:='1'
  else
    MicroInstructionSimulation.Cells[6,ck]:='0';

  if ce then
    MicroInstructionSimulation.Cells[7,ck]:='1'
  else
    MicroInstructionSimulation.Cells[7,ck]:='0';

  if rw then
    MicroInstructionSimulation.Cells[8,ck]:='1'
  else
    MicroInstructionSimulation.Cells[8,ck]:='0';

  MicroInstructionSimulation.Cells[9,ck]:=Regs.Cells[1,mar_reg];
  MicroInstructionSimulation.Cells[10,ck]:=Regs.Cells[1,mdr_reg];
  MicroInstructionSimulation.Cells[11,ck]:=Regs.Cells[1,ir_reg];
  MicroInstructionSimulation.Cells[12,ck]:=Regs.Cells[1,pc_reg];
  MicroInstructionSimulation.Cells[13,ck]:=Regs.Cells[1,ac_reg];
  MicroInstructionSimulation.Cells[14,ck]:=Regs.Cells[1,rs_reg];
  if Negative.Checked then
    nzcv:= '1 '
  else
    nzcv:= '0 ';

  if zero.Checked then
    nzcv:= nzcv+'1 '
  else
    nzcv:= nzcv+'0 ';

  if Carry.Checked then
    nzcv:= nzcv+'1 '
  else
    nzcv:= nzcv+'0 ';

  if Overflow.Checked then
    nzcv:= nzcv+'1 '
  else
    nzcv:= nzcv+'0 ';
  MicroInstructionSimulation.Cells[15,ck]:=nzcv;
  MicroInstructionSimulation.Cells[16,ck]:=microinstrucao;
end;


function IntToBin(Value: LongInt;Size: Integer): String;
var
  i: Integer;
begin
  Result:='';
  for i:=Size-1 downto 0 do
  begin
    if Value and (1 shl i)<>0 then
    begin
      Result:=Result+'1';
    end
    else
    begin
      Result:=Result+'0';
    end;
  end;
end;

function BinToInt(Value: String): Integer;
var
  i,Size: Integer;
begin
  Result:=0;
  Size:=Length(Value);
  for i:=Size downto 1 do
    if Value[i]='1' then Result:=Result+(1 shl (Size-i));
end;



procedure Texecution.FormShow(Sender: TObject);
var
  i: integer;
  j: integer;
begin
  ativa_proxima();

  Regs.Cells[1,pc_reg]:=IntToHex(0,2);

  if DataMemory.RowCount < 2 then
  begin
    DataMemory.RowCount:=2;
  end;
  DataMemory.FixedRows:=1;
  DataMemory.Cells[0,0]:='Variável';
  DataMemory.Cells[1,0]:='End';
  DataMemory.Cells[2,0]:='Valor';


  if MachineCode.RowCount < 2 then
  begin
    MachineCode.RowCount:=2;
  end;
  MachineCode.FixedRows:=1;
  MachineCode.Cells[0,0]:='opcode';
  MachineCode.Cells[1,0]:='data';

  if ProgramData.RowCount < 2 then
  begin
    ProgramData.RowCount:=2;
  end;
  ProgramData.FixedRows:=1;
  ProgramData.Cells[0,0]:='Mem';
  ProgramData.Cells[1,0]:='Inst';
  ProgramData.Cells[2,0]:='Data';

  MicroInstructionSimulation.Cells[0,0]:='Clk';
  MicroInstructionSimulation.Cells[1,0]:='Data';
  MicroInstructionSimulation.Cells[2,0]:='alu_op';
  MicroInstructionSimulation.Cells[3,0]:='write_reg';
  MicroInstructionSimulation.Cells[4,0]:='read_reg';
  MicroInstructionSimulation.Cells[5,0]:='lnz';
  MicroInstructionSimulation.Cells[6,0]:='lcv';
  MicroInstructionSimulation.Cells[7,0]:='ce';
  MicroInstructionSimulation.Cells[8,0]:='rw';
  MicroInstructionSimulation.Cells[9,0]:='addr';
  MicroInstructionSimulation.Cells[10,0]:='mdr';
  MicroInstructionSimulation.Cells[11,0]:='ir';
  MicroInstructionSimulation.Cells[12,0]:='pc';
  MicroInstructionSimulation.Cells[13,0]:='ac';
  MicroInstructionSimulation.Cells[14,0]:='rs';
  MicroInstructionSimulation.Cells[15,0]:='N Z C V';
  MicroInstructionSimulation.Cells[16,0]:='MicroInst';

  bContinuar:=true;
//  j:=15 or 0;
//  alu_processor(1,true,true,'12','1f');
  
 { j:=0;
  for i:=1 to MachineCode.RowCount do
  begin
    memoria[j]:=MachineCode.Cells[0,i];
    j:=j+1;

    if Length(MachineCode.Cells[1,i])>0 then
    begin
      memoria[j]:=MachineCode.Cells[1,i];
      j:=j+1;
    end;
  end;}

//  ProgramData.Row:=0;
//  MachineCode.Row:=0;

  if ( chkMicro.Checked = false ) then
    execution.Height:=289
  else
    execution.Height:=598;
end;

procedure Texecution.FormCreate(Sender: TObject);
begin
  row_colorir:=-1;
  ac_reg:=1;
  pc_reg:=2;
  rs_reg:=3;
  mar_reg:=4;
  mdr_reg:=5;
  ir_reg:=6;

  Regs.Cells[1,pc_reg]:=IntToHex(0,2);
end;

procedure Texecution.btnPassoClick(Sender: TObject);
var
  i: integer;

begin
  if MicroInstructionSimulation.RowCount > 2 then
    MicroInstructionSimulation.RowCount:=MicroInstructionSimulation.RowCount+1;

  Fetch();  // 3 Cliclos
  BlocoDeControle();
  ativa_proxima();
  for i:= 1 to ProgramData.RowCount do
  begin
    if ProgramData.Cells[0,i] = Regs.Cells[1,pc_reg]+'h' then
    begin
      ProgramData.Row:=i;
      MachineCode.Row:=i;
      break;
    end;
  end;


  MicroInstructionSimulation.RowCount:=MicroInstructionSimulation.RowCount-1;
  MicroInstructionSimulation.Row:=MicroInstructionSimulation.RowCount-1;

end;

procedure Texecution.Fetch();
begin
  BC_MicroInstr(7, 0, 3,false,false, false, false,'mar<-pc');
{  ce:=false;
  rw:=false;
  read_reg(3);
  write_reg(0,IntToStr(alu_processor(7,false,false)));
  gravaEstatus(MicroInstructionSimulation.RowCount-1,'ZZ','7','0','3','0','0','mar<-pc');
  MicroInstructionSimulation.RowCount:=MicroInstructionSimulation.RowCount+1;}

  BC_MicroInstr(1, 6, 3,true,true, false, false,'mdr<-pmem(mar)');
{  ce:=true;
  rw:=true;
  read_reg(3);
  write_reg(6,IntToStr(alu_processor(1,false,false)));
  gravaEstatus(MicroInstructionSimulation.RowCount-1,data,'1','6','3','0','0','mdr<-pmem(mar)');
  MicroInstructionSimulation.RowCount:=MicroInstructionSimulation.RowCount+1;}

  BC_MicroInstr(4, 2, 1,false,false, false, false,'ir<-mdr');
{  ce:=false;
  rw:=false;
  read_reg(1);
  write_reg(2,IntToStr(alu_processor(4,false,false)));
  gravaEstatus(MicroInstructionSimulation.RowCount-1,'ZZ','4','2','1','0','0','ir<-mdr');
  MicroInstructionSimulation.RowCount:=MicroInstructionSimulation.RowCount+1;}
end;

function Texecution.pmem(mar: string):integer;
begin
  Result:=StrToInt(memoria[StrToInt('$'+mar)]);//
end;

function Texecution.GetDATA(tipo: integer):integer;
begin
  case tipo of
    $0: //Acesso Imediato
      begin
        // MAR<-PC
        // MDR<-PMEM(MAR)
        // PC++      
        Fetch();

        GetDATA:=StrToInt('$'+Regs.Cells[1,mdr_reg]);
      end;
    $4: //Acesso Direto
      begin
        // MAR<-PC
        // MDR<-PMEM(MAR)
        // PC++
        Fetch();
        // MAR<-MDR
        // MDR<-PMEM(MAR)
        Regs.Cells[1,mar_reg]:=Regs.Cells[1,mdr_reg];
        Regs.Cells[1,mdr_reg]:=IntToHex(pmem(Regs.Cells[1,mar_reg]),2); //MDR <- PMEM(MAR)
        
        GetDATA:=StrToInt('$'+Regs.Cells[1,mdr_reg]);
      end;
      
    $8: //Acesso Indireto
      begin
        // MAR<-PC
        // MDR<-PMEM(MAR)
        // PC++
        Fetch();
        // MAR<-MDR
        // MDR<-PMEM(MAR)
        Regs.Cells[1,mar_reg]:=Regs.Cells[1,mdr_reg];
        Regs.Cells[1,mdr_reg]:=IntToHex(pmem(Regs.Cells[1,mar_reg]),2); //MDR <- PMEM(MAR)
        // MAR<-MDR
        // MDR<-PMEM(MAR)
        Regs.Cells[1,mar_reg]:=Regs.Cells[1,mdr_reg];
        Regs.Cells[1,mdr_reg]:=IntToHex(pmem(Regs.Cells[1,mar_reg]),2); //MDR <- PMEM(MAR)

        GetDATA:=StrToInt('$'+Regs.Cells[1,mdr_reg]);
      end;
    $C: //Acesso Relativo
      begin
        // MAR<-PC
        // MDR<-PMEM(MAR)
        // PC++
        Fetch();
        // MAR<-PC+MDR
        // MDR<-PMEM(MAR)
        Regs.Cells[1,mar_reg]:=IntToHex(StrToInt('$'+Regs.Cells[1,mdr_reg])+StrToInt('$'+Regs.Cells[1,pc_reg]),2);
        Regs.Cells[1,mdr_reg]:=IntToHex(pmem(Regs.Cells[1,mar_reg]),2); //MDR <- PMEM(MAR)
        
        GetDATA:=StrToInt('$'+Regs.Cells[1,mdr_reg]);
      end;
  end;
end;

procedure Texecution.BlocoDeControle();
begin
  case StrToInt('$'+copy(Regs.Cells[1,ir_reg],1,1)) of
    0..1:
      begin
        instrucao_not(copy(Regs.Cells[1,ir_reg],2,1));
      end;
    2:
      begin
        instrucao_sta(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    4:
      begin
        instrucao_lda(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    5:
      begin
        instrucao_add(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    6:
      begin
        instrucao_or(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    7:
      begin
        instrucao_and(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    8:
      begin
        instrucao_jmp(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    9:
      begin
        instrucao_jc(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    10:
      begin
        instrucao_jn(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    11:
      begin
        instrucao_jz(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    12:
      begin
        instrucao_jsr(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    13:
      begin
        instrucao_rts(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    14:
      begin
        instrucao_jv(copy(Regs.Cells[1,ir_reg],2,1));
      end;

    15:
      begin
        instrucao_hlt(copy(Regs.Cells[1,ir_reg],2,1));
      end;

  end;
end;

procedure Texecution.BC_MicroInstr(p_alu_opcode, p_write_reg, p_read_reg : Integer; p_ce, p_rw, p_lnz, p_lcv: Boolean;p_microinstrucao: string);
var
  alu_result: integer;
  bus: array[0..1] of string;  //instrução por instrução
  data: string;
begin
  bus[0]:=read_reg(p_read_reg,0);
  bus[1]:=read_reg(p_read_reg,1);

  alu_result:=alu_processor(p_alu_opcode,p_lnz,p_lcv,bus);
  data:=write_reg(p_write_reg,IntToStr(alu_result),p_ce,p_rw);
  gravaEstatus(MicroInstructionSimulation.RowCount-1,data,p_alu_opcode,p_write_reg,p_read_reg,p_ce,p_rw,p_lnz,p_lcv,p_microinstrucao);
  MicroInstructionSimulation.RowCount:=MicroInstructionSimulation.RowCount+1;
end;

procedure Texecution.instrucao_lda(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

  if acesso = '0' then
  begin
    BC_MicroInstr(4, 4, 1,false,false,true,false,'ac<-pc');
  end
  else
  begin
    if acesso = '4' then
    begin
      BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

      BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

      BC_MicroInstr(4, 4, 1,false,false,true,false,'ac<-mdr');
    end
    else
    begin
      if acesso = '8' then
      begin
        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 4, 1,false,false,true,false,'ac<-mdr');
      end
      else
      begin
        if UpperCase(acesso) = 'C' then
        begin
          BC_MicroInstr(0, 0, 7,false,false,false,false,'mar<-pc+mdr');

          BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(4, 4, 1,false,false,true,false,'ac<-mdr');
        end;
      end;
    end;
  end;
end;

procedure Texecution.instrucao_add(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

  if acesso = '0' then
  begin
    BC_MicroInstr(0, 4, 6,false,false,true,true,'ac<-ac+mdr');
  end
  else
  begin
    if acesso = '4' then
    begin
      BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

      BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

      BC_MicroInstr(0, 4, 6,false,false,true,true,'ac<-ac+mdr');
    end
    else
    begin
      if acesso = '8' then
      begin
        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(0, 4, 6,false,false,true,true,'ac<-ac+mdr');
      end
      else
      begin
        if UpperCase(acesso) = 'C' then
        begin
          BC_MicroInstr(0, 0, 7,false,false,true,true,'mar<-pc+mdr');

          BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(0, 4, 6,false,false,true,true,'ac<-ac+mdr');
        end;
      end;
    end;
  end;
end;

procedure Texecution.instrucao_sta(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  if acesso = '0' then
  begin
    BC_MicroInstr(7, 7, 4,true,false,false,false,'pmem(mar)<-ac');
  end
  else
  begin
    if acesso = '4' then
    begin
      BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

      BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

      BC_MicroInstr(7, 7, 4,true,false,false,false,'pmem(mar)<-ac');
    end
    else
    begin
      if acesso = '8' then
      begin
        BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 7, 4,true,false,false,false,'pmem(mar)<-ac');
      end
      else
      begin
        if UpperCase(acesso) = 'C' then
        begin
          BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(0, 0, 7,false,false,false,false,'mar<-pc+mdr');

          BC_MicroInstr(7, 7, 4,true,false,false,false,'pmem(mar)<-ac');
        end;
      end;                                                    
    end;
  end;
end;

procedure Texecution.instrucao_jmp(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  if acesso = '0' then
  begin
    BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
  end
  else
  begin
    if acesso = '4' then
    begin
      BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

      BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
    end
    else
    begin
      if acesso = '8' then
      begin
        BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
      end
      else
      begin
        if UpperCase(acesso) = 'C' then
        begin
          BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
          
          BC_MicroInstr(0, 3, 7,false,false,false,false,'pc<-pc+mdr');
        end;
      end;
    end;
  end;
end;

procedure Texecution.instrucao_jsr(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  if acesso = '0' then
  begin
    BC_MicroInstr(1, 5, 3,false,false,false,false,'rs<-pc++');

    BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
  end
  else
  begin
    if acesso = '4' then
    begin
      BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

      BC_MicroInstr(7, 5, 3,false,false,false,false,'rs<-pc');
      
      BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
    end
    else
    begin
      if acesso = '8' then
      begin
        BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(7, 5, 3,false,false,false,false,'rs<-pc');

        BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
      end
      else
      begin
        if UpperCase(acesso) = 'C' then
        begin
          BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(7, 5, 3,false,false,false,false,'rs<-pc');

          BC_MicroInstr(0, 3, 7,false,false,false,false,'pc<-pc+mdr');
        end;
      end;
    end;
  end;
end;

procedure Texecution.instrucao_rts(acesso: string);
begin
  BC_MicroInstr(7, 3, 5,true,true,false,false,'pc<-rs');
end;

procedure Texecution.instrucao_jz(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  if zero.checked then
  begin
    if acesso = '0' then
    begin
      BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
    end
    else
    begin
      if acesso = '4' then
      begin
        BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
        
        BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
      end
      else
      begin
        if acesso = '8' then
        begin
          BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
          
          BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

          BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
        end
        else
        begin
          if UpperCase(acesso) = 'C' then
          begin
            BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
            
            BC_MicroInstr(0, 3, 7,false,false,false,false,'pc<-pc+mdr');
          end;
        end;
      end;
    end;
  end
  else
    BC_MicroInstr(1, 3, 3,false,false,false,false,'pc<-pc++');
end;

procedure Texecution.instrucao_jn(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  if negative.checked then
  begin
    if acesso = '0' then
    begin
      BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
    end
    else
    begin
      if acesso = '4' then
      begin
        BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
        
        BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
      end
      else
      begin
        if acesso = '8' then
        begin
          BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
          
          BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

          BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
        end
        else
        begin
          if UpperCase(acesso) = 'C' then
          begin
            BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
            
            BC_MicroInstr(0, 3, 7,false,false,false,false,'pc<-pc+mdr');
          end;
        end;
      end;
    end;
  end
  else
    BC_MicroInstr(1, 3, 3,false,false,false,false,'pc<-pc++');
end;

procedure Texecution.instrucao_jc(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  if carry.checked then
  begin
    if acesso = '0' then
    begin
      BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
    end
    else
    begin
      if acesso = '4' then
      begin
        BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
        
        BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
      end
      else
      begin
        if acesso = '8' then
        begin
          BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
          
          BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

          BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
        end
        else
        begin
          if UpperCase(acesso) = 'C' then
          begin
            BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
            
            BC_MicroInstr(0, 3, 7,false,false,false,false,'pc<-pc+mdr');
          end;
        end;
      end;
    end;
  end
  else
    BC_MicroInstr(1, 3, 3,false,false,false,false,'pc<-pc++');
end;

procedure Texecution.instrucao_jv(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  if Overflow.checked then
  begin
    if acesso = '0' then
    begin
      BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
    end
    else
    begin
      if acesso = '4' then
      begin
        BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
        
        BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
      end
      else
      begin
        if acesso = '8' then
        begin
          BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
          
          BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

          BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(4, 3, 1,false,false,false,false,'pc<-mdr');
        end
        else
        begin
          if UpperCase(acesso) = 'C' then
          begin
            BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');
            
            BC_MicroInstr(0, 3, 7,false,false,false,false,'pc<-pc+mdr');
          end;
        end;
      end;
    end;
  end
  else
    BC_MicroInstr(1, 3, 3,false,false,false,false,'pc<-pc++');
end;

procedure Texecution.instrucao_sta_refresh(addr: string);
var
  i: integer;
begin
    updateDataMemory(StrToInt('$'+addr),IntToHex(StrToInt(memoria[StrToInt('$'+addr)]),2)+'h','',true)
//  for i:=1 to DataMemory.RowCount do
//  begin
//    if DataMemory.Cells[1,i]=addr+'h' then
//    begin
//      DataMemory.Cells[2,i]:='#'+IntToHex(StrToInt(memoria[StrToInt('$'+addr)]),2)+'h';
//      row_colorir:=i;
//      break;
//    end;
//  end;
end;

procedure Texecution.instrucao_not(acesso: string);
begin
  BC_MicroInstr(2, 4, 4,true,true,false,false,'ac<-not ac');
end;

procedure Texecution.instrucao_or(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

  if acesso = '0' then
  begin
    BC_MicroInstr(5, 4, 6,false,false,true,true,'ac<-ac OR mdr');
  end
  else
  begin
    if acesso = '4' then
    begin
      BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

      BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

      BC_MicroInstr(5, 4, 6,false,false,true,true,'ac<-ac OR mdr');
    end
    else
    begin
      if acesso = '8' then
      begin
        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(5, 4, 6,false,false,true,true,'ac<-ac OR mdr');
      end
      else
      begin
        if UpperCase(acesso) = 'C' then
        begin
          BC_MicroInstr(0, 0, 7,false,false,true,true,'mar<-pc+mdr');

          BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(5, 4, 6,false,false,true,true,'ac<-ac OR mdr');
        end;
      end;
    end;
  end;
end;

procedure Texecution.instrucao_and(acesso: string);
begin
  BC_MicroInstr(7, 0, 3,false,false,false,false,'mar<-pc');

  BC_MicroInstr(1, 6, 3,true,true,false,false,'mdr<-pmem(mar)');

  if acesso = '0' then
  begin
    BC_MicroInstr(6, 4, 6,false,false,true,true,'ac<-ac AND mdr');
  end
  else
  begin
    if acesso = '4' then
    begin
      BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

      BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

      BC_MicroInstr(6, 4, 6,false,false,true,true,'ac<-ac AND mdr');
    end
    else
    begin
      if acesso = '8' then
      begin
        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(4, 0, 1,false,false,false,false,'mar<-mdr');

        BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

        BC_MicroInstr(6, 4, 6,false,false,true,true,'ac<-ac AND mdr');
      end
      else
      begin
        if UpperCase(acesso) = 'C' then
        begin
          BC_MicroInstr(0, 0, 7,false,false,true,true,'mar<-pc+mdr');

          BC_MicroInstr(7, 1, 0,true,true,false,false,'mdr<-pmem(mar)');

          BC_MicroInstr(6, 4, 6,false,false,true,true,'ac<-ac AND mdr');
        end;
      end;
    end;
  end;
end;

procedure Texecution.instrucao_hlt(acesso: string);
begin
{  btnPasso.Enabled:=false;

  ProgramData.Row:=ProgramData.RowCount-1;
  MachineCode.Row:=MachineCode.RowCount-1;}

  Regs.Cells[1,pc_reg]:=IntToHex(StrToInt('$'+Regs.Cells[1,pc_reg])-1,2);
  btnPasso.Enabled:=false;
  btnRodar.Enabled := false;
  btnRodar.Visible:=true;
  btnParar.Visible:=false;
end;

procedure Texecution.MicroCode();
var
  i: integer;
begin
  for i := 1 to MachineCode.RowCount do
  begin

  end;
end;

function Texecution.alu_processor(op_code:integer; lnz,lcv: boolean; bus: array of string): integer;
var
  bin_busa: string;
  bin_busb: string;
  bin_busc: string;
  i: Integer;
  i_carry: integer;
  i_overflow: integer;
  temp: integer;
  temp2: integer;
begin
  if (Length(bus[0])>0)AND (bus[0]<>'ZZ') then
    bin_busa:=IntToBin(StrToInt('$'+bus[0]),8);

  if (Length(bus[1])>0)AND (bus[1]<>'ZZ') then
    bin_busb:=IntToBin(StrToInt('$'+bus[1]),8);

  i:=0;
  i_carry:=0;
  i_overflow:=0;
  temp:=0;
  temp2:=0;

  case op_code of
    0: //soma
      begin
//        alu_processor:=(StrToInt('$'+bus[0])+StrToInt('$'+bus[1]));
        for i:=8 downto 1 do
        begin
          i_overflow:=i_carry;
          temp:=StrToInt(copy(bin_busa,i,1))+StrToInt(copy(bin_busb,i,1))+i_carry;
          if temp=2 then
          begin
            temp:=0;
            i_carry:=1;
          end
          else
          begin
            if temp = 3 then
            begin
              temp:=1;
              i_carry:=1;
            end
            else
            begin
              //temp:=0;
              i_carry:=0;
            end;
          end;
          bin_busc:=IntToStr(temp)+bin_busc;
        end;
      end;
    1: //incremento
      begin
//        alu_processor:=(StrToInt('$'+bus[0])+1);
        temp2:=1;
        for i:=8 downto 1 do
        begin
          i_overflow:=i_carry;
          temp:=StrToInt(copy(bin_busa,i,1))+temp2+i_carry;
          if temp=2 then
          begin
            temp:=0;
            i_carry:=1;
          end
          else
          begin
            if temp = 3 then
            begin
              temp:=1;
              i_carry:=1;
            end
            else
            begin
              //temp:=1 ;
              i_carry:=0;
            end;
          end;
          temp2:=0;
          bin_busc:=IntToStr(temp)+bin_busc;
        end;
      end;
    2: //not
      begin
//        alu_processor:=not StrToInt('$'+bus[0]);
        for i:=8 downto 1 do
        begin
          if copy(bin_busa,i,1) = '1' then
            bin_busc:='0'+bin_busc
          else
            bin_busc:='1'+bin_busc;
        end;
      end;
    4: // PassaB
      begin
        bin_busc:=bin_busb;
        //alu_processor:=StrToInt('$'+bus[1]);
      end;
    5: // ou
      begin
        //alu_processor:=StrToInt('$'+bus[0]) OR StrToInt('$'+bus[1]);
        for i:=8 downto 1 do
        begin
          i_overflow:=i_carry;
          if (copy(bin_busa,i,1) = '1') OR (copy(bin_busb,i,1) = '1') then
            bin_busc:='1'+bin_busc
          else
            bin_busc:='0'+bin_busc;
        end;
      end;
    6: // and
      begin
        //alu_processor:=StrToInt('$'+bus[0]) AND StrToInt('$'+bus[1]);
        for i:=8 downto 1 do
        begin
          i_overflow:=i_carry;
          if (copy(bin_busa,i,1) = '1') AND (copy(bin_busb,i,1) = '1') then
            bin_busc:='1'+bin_busc
          else
            bin_busc:='0'+bin_busc;
        end;
      end;
    7: // PassaA
      begin
        bin_busc:=bin_busa;
        //alu_processor:=StrToInt('$'+bus[0]);
      end;
  end;

  alu_processor:=BinToInt(bin_busc);

  if lcv then
  begin
    if i_carry=1 then
      Carry.Checked:=true
    else
      Carry.Checked:=false;

    if (i_overflow=1) XOR (i_carry=1) then
      Overflow.Checked:=true
    else
      Overflow.Checked:=false;
  end;

  if lnz then
  begin
    if bin_busc = '00000000' then
      zero.Checked:=true
    else
      zero.Checked:=false;

    if copy(bin_busc,1,1) = '1' then
      Negative.Checked:=true
    else
      Negative.Checked:=false;
  end;
end;

function Texecution.write_reg(code: integer; valor: string; ce,rw: Boolean): string;
begin
  Result:='ZZ';
  
  if ce AND RW then
  begin
    data := IntToHex(pmem(Regs.Cells[1,mar_reg]),2);
    Regs.Cells[1,mdr_reg]:=data;
    Result:=data;
  end;

  if ce AND (NOT RW) then
  begin
    memoria[StrToInt('$'+Regs.Cells[1,mar_reg])]:=valor;
    instrucao_sta_refresh(Regs.Cells[1,mar_reg]);
  end;

  case code of
    0: //MAR
      begin
        Regs.Cells[1,mar_reg]:=IntToHex(StrToInt(valor),2);
        data := IntToHex(pmem(Regs.Cells[1,mar_reg]),2);
      end;
    1: //MDR
      begin
        if (ce) AND (RW) then
        begin
          data := IntToHex(pmem(Regs.Cells[1,mar_reg]),2);
          Regs.Cells[1,mdr_reg]:=data;
        end
        else
        begin
          Regs.Cells[1,mdr_reg]:=IntToHex(StrToInt(valor),2);

        end;
      end;

    2: //IR
      begin
        Regs.Cells[1,ir_reg]:=IntToHex(StrToInt(valor),2);
      end;
    3: //PC
      begin
        Regs.Cells[1,pc_reg]:=IntToHex(StrToInt(valor),2);
      end;
    4: //AC
      begin
        Regs.Cells[1,ac_reg]:=IntToHex(StrToInt(valor),2);
      end;
    5: //RS
      begin
        Regs.Cells[1,rs_reg]:=IntToHex(StrToInt(valor),2);
      end;
    6: //PC_MDR
      begin
        Regs.Cells[1,pc_reg]:=IntToHex(StrToInt(valor),2);
        Regs.Cells[1,mdr_reg]:=data;
      end;
    7: //NULL
      begin
        //Regs.Cells[1,mar_reg]:=IntToHex(StrToInt(valor),2);
      end;
  end;
end;

function Texecution.read_reg(code,p_bus: integer): string;
begin
  case code of
    0: //NULL
      begin
        Result:='ZZ';
      end;
    1: //MDR
      begin
        if p_bus = 1 then
          Result:=Regs.Cells[1,mdr_reg];
      end;
    2: //IR
      begin
        if p_bus = 1 then
          Result:=Regs.Cells[1,ir_reg];
      end;
    3: //PC
      begin
        if p_bus = 0 then
          Result:=Regs.Cells[1,pc_reg];
      end;
    4: //AC
      begin
        if p_bus = 0 then
          Result:=Regs.Cells[1,ac_reg];
      end;
    5: //RS
      begin
        if p_bus = 0 then
          Result:=Regs.Cells[1,rs_reg];
      end;
    6: //AC_MDR
      begin
        if p_bus = 1 then
          Result:=Regs.Cells[1,mdr_reg];
        if p_bus = 0 then
          Result:=Regs.Cells[1,ac_reg];
      end;
    7: //PC_MDR
      begin
        if p_bus = 0 then
          Result:=Regs.Cells[1,pc_reg];
        if p_bus = 1 then
          Result:=Regs.Cells[1,mdr_reg];
      end;
  end;
end;

procedure Texecution.ativa_proxima();
var
  line: string;
  ok: boolean;
  intrs,i: integer;

begin
  for i:= 1 to ProgramData.RowCount do
  begin
    if ProgramData.Cells[0,i] = '#'+Regs.Cells[1,pc_reg]+'H' then
    begin
      intrs:=i;
      break;
    end;
  end;
  Form1.Memo.ActiveLine:=0;
  ok:=false;
  repeat
    Form1.Memo.ActiveLine:=Form1.Memo.ActiveLine+1;
    line:=Form1.Memo.Lines[Form1.Memo.ActiveLine];

    if (pos(';',line)-1) >= 0 then //Remove comentário
      line:=trim(copy(line,1,pos(';',line)-1));

    if Length(line) > 0 then
    begin
      if Form1.Parse_Bloco(line)=0 then
      begin
        ok:=true;
        if intrs > 0 then
          intrs:=intrs-1;
      end;
    end;
  until (ok=true) AND (intrs<=0);



end;
procedure Texecution.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.Memo.ActiveLine:=-1;
end;

procedure Texecution.btnResetClick(Sender: TObject);
begin
  row_colorir:=-1;

  DataMemory.RowCount:=2;
  DataMemory.Cells[0,1]:='';
  DataMemory.Cells[1,1]:='';
  DataMemory.Cells[2,1]:='';

  Regs.Cells[1,ac_reg]:='00';
  Regs.Cells[1,pc_reg]:='00';
  Regs.Cells[1,rs_reg]:='00';
  Regs.Cells[1,mar_reg]:='00';
  Regs.Cells[1,mdr_reg]:='00';
  Regs.Cells[1,ir_reg]:='00';

  MicroInstructionSimulation.RowCount:=2;
  MicroInstructionSimulation.Cells[0,1]:='';
  MicroInstructionSimulation.Cells[1,1]:='';
  MicroInstructionSimulation.Cells[2,1]:='';
  MicroInstructionSimulation.Cells[3,1]:='';
  MicroInstructionSimulation.Cells[4,1]:='';
  MicroInstructionSimulation.Cells[5,1]:='';
  MicroInstructionSimulation.Cells[6,1]:='';
  MicroInstructionSimulation.Cells[7,1]:='';
  MicroInstructionSimulation.Cells[8,1]:='';
  MicroInstructionSimulation.Cells[9,1]:='';
  MicroInstructionSimulation.Cells[10,1]:='';
  MicroInstructionSimulation.Cells[11,1]:='';
  MicroInstructionSimulation.Cells[12,1]:='';
  MicroInstructionSimulation.Cells[13,1]:='';
  MicroInstructionSimulation.Cells[14,1]:='';
  MicroInstructionSimulation.Cells[15,1]:='';
  MicroInstructionSimulation.Cells[16,1]:='';

  Form1.Make1Click(nil);
  ativa_proxima();
end;

procedure Texecution.btnRodarClick(Sender: TObject);
begin
  bContinuar:=true;
  if (btnRodar.Caption = 'Rodar') AND (bContinuar=true) then
  begin
    btnParar.Visible:=true;
    btnRodar.Visible:=false;
    while btnPasso.Enabled=true AND (bContinuar=true) do
    begin
      btnPassoClick(nil);
      case TrackBar1.Position of
        0: Sleep(1000);
        1: Sleep(900);
        2: Sleep(800);
        3: Sleep(700);
        4: Sleep(600);
        5: Sleep(500);
        6: Sleep(400);
        7: Sleep(300);
        8: Sleep(200);
        9: Sleep(100);
      end;
      Application.HandleMessage;
      Refresh;
    end;
  end;


end;

procedure Texecution.btnPararClick(Sender: TObject);
begin
  bContinuar:=false;
  btnRodar.Visible:=true;
  btnParar.Visible:=false;
end;

procedure Texecution.chkMicroClick(Sender: TObject);
begin
  if ( chkMicro.Checked = false ) then
    execution.Height:=289
  else
    execution.Height:=598;
end;

procedure Texecution.DataMemoryCellProps(Sender: TObject; Canvas: TCanvas;
  var Alignment: TAlignment; var CellText: String; AState: TGridDrawState;
  Row, Col: Integer);
var
  i: integer;
begin
  if memoria_dados_colorir[Row-1] then
  begin
    Canvas.Font.Color:=clRed;
  end;
end;

end.
