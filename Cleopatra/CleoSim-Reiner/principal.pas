unit principal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AdvMemo, Advmps, Menus, ComCtrls;

type
  TForm1 = class(TForm)
    Memo: TAdvMemo;
    AdvPascalMemoStyler1: TAdvPascalMemoStyler;
    MainMenu1: TMainMenu;
    Arquivo1: TMenuItem;
    Abrir1: TMenuItem;
    Salvar1: TMenuItem;
    SalvarComo1: TMenuItem;
    Fechar1: TMenuItem;
    N1: TMenuItem;
    Sair1: TMenuItem;
    Cleopatra1: TMenuItem;
    Make1: TMenuItem;
    Run1: TMenuItem;
    StatusBar1: TStatusBar;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Sobre1: TMenuItem;
    N2: TMenuItem;
    Save1: TMenuItem;
    SaveDialog2: TSaveDialog;
    procedure Sair1Click(Sender: TObject);
    procedure Run1Click(Sender: TObject);
    procedure Make1Click(Sender: TObject);
    procedure Abrir1Click(Sender: TObject);
    procedure Salvar1Click(Sender: TObject);
    procedure SalvarComo1Click(Sender: TObject);
    procedure Fechar1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure Sobre1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
  private
    { Private declarations }
    estagio_parse: integer; //Estágio em que está o parse!
    area_programa: boolean; //Está na área do programa ou na área de dados
    posicao_memoria: integer; //Registra a posição da memória em que está!
    posicao_memoria_dados: integer; //Registra a posição da memória em que está!
//    row_program: integer; //Váriavel de Controle de onde os dados do programa deverão ser escritos nas tabelas!
  public
    function Parse(line: String): integer;
    function Parse_Bloco(line: String): integer;
    function Parse_Label(line: String): integer;
    function Parse_ORG(line: String): integer;
    function Parse_LDA(line: String): integer;
    function Parse_ADD(line: String): integer;
    function Parse_NOT(line: String): integer;
    function Parse_STA(line: String): integer;
    function Parse_OR(line: String): integer;
    function Parse_AND(line: String): integer;
    function Parse_JMP(line: String): integer;
    function Parse_JC(line: String): integer;
    function Parse_JV(line: String): integer;
    function Parse_JN(line: String): integer;
    function Parse_JZ(line: String): integer;
    function Parse_JSR(line: String): integer;
    function Parse_RTS(line: String): integer;
    function Parse_HLT(line: String): integer;
    function Parse_DB(line: String): integer;
    function Parse_ACESSO(line: String): integer;

    function Parse2: Boolean;
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses frmExecution, frmAbout, Math;

{$R *.dfm}

function RemoveHexa(texto:string):string;
var
  i_pos_char: integer;
  i_pedaco_linha: string;
begin
  try
    if length(trim(texto)) > 0 then
    begin
      if copy(texto,1,1) = '#' then
      begin
        i_pos_char := pos('H',UpperCase(texto)) ;
        if i_pos_char > 0 then
          texto:=IntToStr(StrToInt('$'+copy(texto,2,i_pos_char-2)))
        else
          texto:=copy(texto,2,length(texto)-1);
      end;
      if (StrToInt('$'+copy(texto,1,1)) >= $0) AND (StrToInt('$'+copy(texto,1,1)) <= $F) AND (UpperCase(copy(texto,Length(texto),1))='H') then
      begin
        RemoveHexa:=copy(texto,1,(Length(texto)-1));
      end
      else
      begin
        RemoveHexa:=texto;
      end;
    end;
  except
    on EConvertError do RemoveHexa:=texto
  end;
end;

procedure TForm1.Sair1Click(Sender: TObject);
begin
close();
end;

procedure TForm1.Run1Click(Sender: TObject);
begin
  execution.Regs.Cells[1,1]:='00';
  execution.Regs.Cells[1,2]:='00';
  execution.Regs.Cells[1,3]:='00';
  execution.Regs.Cells[1,4]:='00';
  execution.Regs.Cells[1,5]:='00';
  execution.Regs.Cells[1,6]:='00';
  execution.Negative.Checked:=false;
  execution.Zero.Checked:=false;
  execution.Carry.Checked:=false;
  execution.Overflow.Checked:=false;
  execution.MicroCode();
  execution.ShowModal();
end;

procedure TForm1.Make1Click(Sender: TObject);
var
  i: integer;
  resultParse: TStrings;
  continua: boolean;
begin
  StatusBar1.SimpleText:='';
//  estagio_parse := 0;
  area_programa := true;
  posicao_memoria := $0;
  posicao_memoria_dados := $0;

  execution.ProgramData.RowCount:=2;
  execution.MachineCode.RowCount:=2;

  execution.DataMemory.RowCount:=257;
  for i:=0 to 255 do
  begin
    execution.DataMemory.Cells[0,i+1]:='';
    execution.DataMemory.Cells[1,i+1]:=IntToHex(i,2)+'h';
    execution.DataMemory.Cells[2,i+1]:='';
  end;

  for i:=0 to 255 do
  begin
    execution.memoria_dados_colorir[i]:=false;
  end;

  execution.Regs.Cells[1,1]:='00';
  execution.Regs.Cells[1,2]:='00';
  execution.Regs.Cells[1,3]:='00';
  execution.Regs.Cells[1,4]:='00';
  execution.Regs.Cells[1,5]:='00';
  execution.Regs.Cells[1,6]:='00';

  execution.MicroInstructionSimulation.RowCount:=2;
  execution.MicroInstructionSimulation.Cells[0,1]:='';
  execution.MicroInstructionSimulation.Cells[1,1]:='';
  execution.MicroInstructionSimulation.Cells[2,1]:='';
  execution.MicroInstructionSimulation.Cells[3,1]:='';
  execution.MicroInstructionSimulation.Cells[4,1]:='';
  execution.MicroInstructionSimulation.Cells[5,1]:='';
  execution.MicroInstructionSimulation.Cells[6,1]:='';
  execution.MicroInstructionSimulation.Cells[7,1]:='';
  execution.MicroInstructionSimulation.Cells[8,1]:='';
  execution.MicroInstructionSimulation.Cells[9,1]:='';
  execution.MicroInstructionSimulation.Cells[10,1]:='';
  execution.MicroInstructionSimulation.Cells[11,1]:='';
  execution.MicroInstructionSimulation.Cells[12,1]:='';
  execution.MicroInstructionSimulation.Cells[13,1]:='';
  execution.MicroInstructionSimulation.Cells[14,1]:='';
  execution.MicroInstructionSimulation.Cells[15,1]:='';
  execution.MicroInstructionSimulation.Cells[16,1]:='';

  execution.zero.Checked:=false;
  execution.Carry.Checked:=false;
  execution.Overflow.Checked:=false;
  execution.Negative.Checked:=false;

  continua:=true;
//  row_program:=1;

  for i:=0 to memo.Lines.Count-1 do
  begin
    Memo.ActiveLine:=i;
    if ( Parse(Memo.Lines.Strings[i]) > 1 ) then
    begin
      continua:=false;
      break;
    end;
  end;
  if continua then
  begin
    Memo.ActiveLine:=-1;
    if Parse2() = True then
    begin
      Run1.Enabled:=true;
      Save1.Enabled:=true;
    end;
  end;
  execution.ProgramData.RowCount:=execution.ProgramData.RowCount-1;
  execution.MachineCode.RowCount:=execution.MachineCode.RowCount-1;
  if execution.DataMemory.RowCount < 2 then
    execution.DataMemory.RowCount:=2;
  execution.DataMemory.FixedRows:=1;
  execution.btnPasso.Enabled:=true;
  execution.btnRodar.Enabled:=true;
end;

function TForm1.Parse(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
  result_subparse: integer;
begin
  Result:=0;
  line:=trim(line);

  if Length(line) > 0 then
  begin
    if (pos(';',line)-1) >= 0 then //Remove comentário
      line:=trim(copy(line,1,pos(';',line)-1));

    if Length(line) > 0 then
    begin
      result_subparse:=Parse_Bloco(line);
      if result_subparse > 0 then
      begin
        Result:=result_subparse;
        exit;
      end
      else
      begin
        result_subparse:=Parse_Label(line);
        if result_subparse > 0 then
        begin
          Result:=result_subparse;
          exit;
        end
        else
        begin
          result_subparse:=Parse_ORG(line);
          if result_subparse > 0 then
          begin
            Result:=result_subparse;
            exit;
          end
          else
          begin
            if area_programa then
            begin
              result_subparse:=Parse_LDA(line);
              if result_subparse > 0 then
              begin
                Result:=result_subparse;
                exit;
              end
              else
              begin
                result_subparse:=Parse_ADD(line);
                if result_subparse > 0 then
                begin
                  Result:=result_subparse;
                  exit;
                end
                else
                begin
                  result_subparse:=Parse_STA(line);
                  if result_subparse > 0 then
                  begin
                    Parse:=result_subparse;
                    exit;
                  end
                  else
                  begin
                    result_subparse:=Parse_NOT(line);
                    if result_subparse > 0 then
                    begin
                      Result:=result_subparse;
                      exit;
                    end
                    else
                    begin
                      result_subparse:=Parse_OR(line);
                      if result_subparse > 0 then
                      begin
                        Parse:=result_subparse;
                        exit;
                      end
                      else
                      begin
                        result_subparse:=Parse_JMP(line);
                        if result_subparse > 0 then
                        begin
                          Result:=result_subparse;
                          exit;
                        end
                        else
                        begin
                          result_subparse:=Parse_JC(line);
                          if result_subparse > 0 then
                          begin
                            Result:=result_subparse;
                            exit;
                          end
                          else
                          begin
                            result_subparse:=Parse_JV(line);
                            if result_subparse > 0 then
                            begin
                              Result:=result_subparse;
                              exit;
                            end
                            else
                            begin
                              result_subparse:=Parse_JN(line);
                              if result_subparse > 0 then
                              begin
                                Result:=result_subparse;
                                exit;
                              end
                              else
                              begin
                                result_subparse:=Parse_JZ(line);
                                if result_subparse > 0 then
                                begin
                                  Result:=result_subparse;
                                  exit;
                                end
                                else
                                begin
                                  result_subparse:=Parse_JSR(line);
                                  if result_subparse > 0 then
                                  begin
                                    Result:=result_subparse;
                                    exit;
                                  end
                                  else
                                  begin
                                    result_subparse:=Parse_RTS(line);
                                    if result_subparse > 0 then
                                    begin
                                      Result:=result_subparse;
                                      exit;
                                    end
                                    else
                                    begin
                                      result_subparse:=Parse_HLT(line);
                                      if result_subparse > 0 then
                                      begin
                                        Result:=result_subparse;
                                        exit;
                                      end
                                      else
                                      begin
                                        result_subparse:=Parse_AND(line);
                                        if result_subparse > 0 then
                                        begin
                                          Result:=result_subparse;
                                          exit;
                                        end
                                        else
                                        begin
                                          Result:=2;
                                          StatusBar1.SimpleText:='Operação desconhecida!';
                                        end;
                                      end;
                                    end;
                                  end;
                                end;
                              end;
                            end;
                          end;
                        end;
                      end;
                    end;
                  end;
                end;
              end;
            end
            else
            begin
              result_subparse:=Parse_DB(line);
              if result_subparse > 0 then
              begin
                Result:=result_subparse;
                exit;
              end
              else
              begin
                Result:=2;
                StatusBar1.SimpleText:='Operação desconhecida!';
              end;
            end;
          end;
        end;
      end;
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_Bloco(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    //Localiza .(code/endconde/data/endata)
    pos_char:=pos('.',line);
    if pos_char > 0 then //tem um label
    begin
      if line = '.code' then
      begin
        area_programa:=true;
        Result:=1;
        exit;
      end
      else
      begin
        if line = '.endcode' then
        begin
          area_programa:=false;
          Result:=1;
          exit;
        end
        else
        begin
          if line = '.data' then
          begin
            area_programa:=false;
            Result:=1;
            exit;
          end
          else
          begin
            if line = '.enddata' then
            begin
              area_programa:=true;
              Result:=1;
              exit;
            end
            else
            begin
              Result:=2;
              exit;
            end;
          end;
        end;
      end;
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;
end;

function TForm1.Parse_Label(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;
  
  if Length(line) > 0 then
  begin
    //Localiza Label
    pos_char:=pos(':',line);
    if pos_char > 0 then //tem um label
    begin
      pedaco_linha:=trim(copy(line,1,pos_char-1));
      if length(pedaco_linha) > 0 then
      begin
        execution.updateDataMemory(posicao_memoria,'',pedaco_linha,false);
//        execution.DataMemory.Cells[0,execution.DataMemory.RowCount]:=pedaco_linha;
//        execution.DataMemory.Cells[1,execution.DataMemory.RowCount]:=IntToHex(posicao_memoria,2)+'h';
        execution.memoria_dados[posicao_memoria_dados][0]:=pedaco_linha;
        execution.memoria_dados[posicao_memoria_dados][2]:=IntToStr(posicao_memoria); //Aqui corrigir para que ele possa achar a próxima memória
        if area_programa then
        begin
          posicao_memoria_dados:=posicao_memoria_dados+1;
          //execution.DataMemory.RowCount:=execution.DataMemory.RowCount+1;
        end;
        if Length(trim(copy(line,pos_char,Length(line))))=0 then //caso tenha a inicialização de um label numa linha considera a próxima linha válida como sendo o endereço a apontar
        begin
          Result:=1;
          exit;
        end
        else
        begin
          Parse(trim(copy(line,pos_char+1,Length(line))));
          Result:=1;
        end;
      end
      else
      begin
        Result:=2; // Erro no Label
        //exit;
      end;
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_ORG(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;
  
  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'ORG' then //É o LDA
    begin
      try
        posicao_memoria:=StrToInt(RemoveHexa(trim(copy(line,4,Length(line)))));
        Result:=1;
      except
        on EConvertError do Result:=2;
      end;
      exit;
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_LDA(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;
  
  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'LDA' then //É o LDA
    begin
      pedaco_linha:=trim(copy(line,4,Length(line)));

      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='LDA';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($40);

      Result := Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_DB(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,3))) = 'DB' then //É o DB
    begin
      pedaco_linha:=trim(copy(line,3,Length(line)));
      execution.memoria[posicao_memoria]:=RemoveHexa(pedaco_linha);
      execution.memoria_dados[posicao_memoria_dados][1]:=pedaco_linha;
      execution.memoria_dados[posicao_memoria_dados][2]:=IntToStr(posicao_memoria);


      if copy(pedaco_linha,1,1) = '#' then
        execution.updateDataMemory(posicao_memoria,copy(pedaco_linha,2,length(pedaco_linha)),'',false)
//        execution.DataMemory.Cells[2,execution.DataMemory.RowCount]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.updateDataMemory(posicao_memoria,pedaco_linha,'',false);
//        execution.DataMemory.Cells[2,execution.DataMemory.RowCount]:=pedaco_linha;
//      execution.DataMemory.Cells[1,execution.DataMemory.RowCount]:=IntToHex(posicao_memoria,2)+'h';
//      execution.DataMemory.RowCount:=execution.DataMemory.RowCount+1;

      posicao_memoria:=posicao_memoria+1;
      posicao_memoria_dados:=posicao_memoria_dados+1;
      Result:=1;
//      Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;


function TForm1.Parse_ADD(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;
  
  if Length(line) > 0 then
  begin
    if UpperCase(TRIM(copy(line,1,4))) = 'ADD' then //É o LDA
    begin
      pedaco_linha:=trim(copy(line,4,Length(line)));
      
      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='ADD';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($50);

      Result:=Parse_acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;
end;



function TForm1.Parse_Acesso(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;

begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if copy(line,1,1)='#' then //Acesso Imediato
    begin
      posicao_memoria:=posicao_memoria+1;
      if RemoveHexa(copy(line,2,length(line))) = copy(line,2,length(line)) then
        execution.memoria[posicao_memoria]:=RemoveHexa(copy(line,2,length(line)))
      else
        execution.memoria[posicao_memoria]:=IntToStr(StrToint('$'+RemoveHexa(copy(line,2,length(line)))));
      posicao_memoria:=posicao_memoria+1;
      Result:=1;
    end
    else
    begin
      if (UpperCase(copy(line,length(line),1))='I') AND (pos(',',line)>0) then //Acesso Indireto
      begin
        execution.memoria[posicao_memoria]:=IntToStr(StrToInt(execution.memoria[posicao_memoria])+$8);
        posicao_memoria:=posicao_memoria+1;
        execution.memoria[posicao_memoria]:=RemoveHexa(trim(copy(line,1,length(line)-2)));
        posicao_memoria:=posicao_memoria+1;
        Result:=1;
      end
      else
      begin
        if (UpperCase(copy(line,length(line),1))='R') AND (pos(',',line)>0) then //Acesso Relativo
        begin
          execution.memoria[posicao_memoria]:=IntToStr(StrToInt(execution.memoria[posicao_memoria])+$C);
          posicao_memoria:=posicao_memoria+1;
          execution.memoria[posicao_memoria]:=RemoveHexa(trim(copy(line,1,length(line)-2)));
          posicao_memoria:=posicao_memoria+1;
          Result:=1;
        end
        else
        begin //Acesso Direto
          if pos(',',line)=0 then
          begin
            execution.memoria[posicao_memoria]:=IntToStr(StrToInt(execution.memoria[posicao_memoria])+$4);
            posicao_memoria:=posicao_memoria+1;
            execution.memoria[posicao_memoria]:=RemoveHexa(trim(copy(line,1,length(line))));
            posicao_memoria:=posicao_memoria+1;
            Result:=1;
          end
          else
          begin
            StatusBar1.SimpleText:='Forma de acesso a memória desconhecida!';
            Result:=2;
          end;
        end;
      end;
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;
end;

function TForm1.Parse_NOT(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'NOT' then //É o NOT
    begin
      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='NOT';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($00);
      posicao_memoria:=posicao_memoria+1;

      pedaco_linha:=trim(copy(line,4,Length(line)));
      Result:=Parse_Acesso(pedaco_linha);

      if Result > 0 then
      begin
        Result:=2;
        StatusBar1.SimpleText:='Essa operação não permite acesso a memória!';
      end
      else
      begin
        Result:=1
      end;
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;
end;

function TForm1.Parse_STA(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'STA' then //É o STA
    begin
      pedaco_linha:=trim(copy(line,4,Length(line)));

      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='STA';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($20);


      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_OR(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,3))) = 'OR' then //É o OR
    begin
      pedaco_linha:=trim(copy(line,3,Length(line)));

      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='OR';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($60);

      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_AND(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'AND' then //É o AND
    begin
      pedaco_linha:=trim(copy(line,4,Length(line)));
      
      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='AND';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($70);

      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_JMP(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'JMP' then //É o JMP
    begin
      pedaco_linha:=trim(copy(line,4,Length(line)));
      
      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='JMP';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($80);

      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_JC(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,3))) = 'JC' then //É o JC
    begin
      pedaco_linha:=trim(copy(line,3,Length(line)));

      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='JC';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($90);

      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_JV(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,3))) = 'JV' then //É o JV
    begin
      pedaco_linha:=trim(copy(line,3,Length(line)));

      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='JV';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($E0);

      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;


function TForm1.Parse_JN(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,3))) = 'JN' then //É o JN
    begin
      pedaco_linha:=trim(copy(line,4,Length(line)));
      
      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='JN';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($A0);

      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_JZ(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,3))) = 'JZ' then //É o JZ
    begin
      pedaco_linha:=trim(copy(line,3,Length(line)));

      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='JZ';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($B0);


      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_JSR(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'JSR' then //É o JSR
    begin
      pedaco_linha:=trim(copy(line,4,Length(line)));
      
      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='JSR';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($C0);

      Result:=Parse_Acesso(pedaco_linha);
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_RTS(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'RTS' then //É o RTS
    begin
      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='RTS';
      if ( copy(pedaco_linha,1,1) = '#') then
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=copy(pedaco_linha,2,length(pedaco_linha))
      else
        execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:=pedaco_linha;
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($D0);
      posicao_memoria:=posicao_memoria+1;

      pedaco_linha:=trim(copy(line,4,Length(line)));
      Result:=Parse_Acesso(pedaco_linha);

      if Result > 0 then
      begin
        Result:=2;
        StatusBar1.SimpleText:='Essa operação não permite acesso a memória!';
      end
      else
      begin
        Result:=1
      end;
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse_HLT(line: String): integer;
var
  pos_char: integer;
  pedaco_linha: string;
begin
  Result:=0;

  if Length(line) > 0 then
  begin
    if UpperCase(Trim(copy(line,1,4))) = 'HLT' then //É o HLT
    begin
      execution.ProgramData.Cells[0,execution.ProgramData.RowCount-1]:=IntToHex(posicao_memoria,2)+'h';
      execution.ProgramData.Cells[1,execution.ProgramData.RowCount-1]:='HLT';
      execution.ProgramData.Cells[2,execution.ProgramData.RowCount-1]:='';
      execution.ProgramData.RowCount:=execution.ProgramData.RowCount+1;

      execution.memoria[posicao_memoria]:=IntToStr($F0);
      posicao_memoria:=posicao_memoria+1;

      pedaco_linha:=trim(copy(line,4,Length(line)));
      Result:=Parse_Acesso(pedaco_linha);

      if Result > 0 then
      begin
        Result:=2;
        StatusBar1.SimpleText:='Essa operação não permite acesso a memória!';
      end
      else
      begin
        Result:=1
      end;
    end;
  end //  if Length(line) > 0 then
  else //  if Length(line) > 0 then
    exit;

end;

function TForm1.Parse2(): boolean;
var
  i: integer;
  i2: integer;
  temp: integer;
  onde: integer;
  strTemp: string;
begin
  Result:=true;

  for i:=0 to 255 do
  begin
    try
      if length(trim(execution.memoria_dados[i][1])) >0 then
        temp:=StrToInt('$'+RemoveHexa(execution.memoria_dados[i][1]));
    except
      on EConvertError do
      begin
        for i2:=0 to 255 do
        begin
          if trim(execution.memoria_dados[i][1]) = trim(execution.memoria_dados[i2][0]) then
          begin
            execution.memoria_dados[i][1]:='#'+IntToHex(StrToInt(execution.memoria_dados[i2][2]),2)+'h';
            break;
          end;
        end
      end;
    end;
  end;

  for i:=0 to 255 do
  begin
    try
      if ( Length(trim(execution.memoria[i]))>0 ) then
        temp:=StrToInt(execution.memoria[i]);
    except
      on EConvertError do
      begin
        for i2:=0 to 255 do
        begin
          if trim(execution.memoria[i]) = trim(RemoveHexa(execution.memoria_dados[i2][0])) then
          begin
            if (length(trim(execution.memoria[i-1])) > 0) AND (copy(IntToHex(StrToInt(execution.memoria[i-1]),2),2,1) = 'C') then
              begin
                strTemp:=RemoveHexa(execution.memoria_dados[i2][2]);
                execution.memoria[i]:=IntToStr(StrToInt(strTemp)-i-1);
              end
              else
              begin
                execution.memoria[i]:=execution.memoria_dados[i2][2];
              end;
            break;
          end;
        end
      end;
    end;
  end;

  onde:=0;
  for i:=0 to posicao_memoria-1 do
  begin
    try
      temp:=StrToInt(execution.memoria[i]);
      execution.MachineCode.Cells[onde,execution.MachineCode.RowCount-1]:=IntToHex(StrToInt(execution.memoria[i]),2);
      if Length(execution.MachineCode.Cells[onde,execution.MachineCode.RowCount-1])>2 then
        execution.MachineCode.Cells[onde,execution.MachineCode.RowCount-1]:=copy(execution.MachineCode.Cells[onde,execution.MachineCode.RowCount-1],Length(execution.MachineCode.Cells[onde,execution.MachineCode.RowCount-1])-1,2);
        
      if (temp = 0) OR (temp = $F0) OR (temp = $D0) then
      begin
        onde:=0;
        execution.MachineCode.RowCount:=execution.MachineCode.RowCount+1;
      end
      else
      begin
//        execution.MachineCode.Cells[onde,execution.MachineCode.RowCount-1]:=IntToHex(StrToInt(execution.memoria[i]),2);      
        if onde = 0 then
          onde := 1
        else
        begin
          onde := 0;
          execution.MachineCode.RowCount:=execution.MachineCode.RowCount+1;
        end;
      end;
      if execution.MachineCode.RowCount = execution.ProgramData.RowCount then
        break;
    except
      on EConvertError do
      begin
        Run1.Enabled:=False;
        Save1.Enabled:=False;
        Result:=false;
        StatusBar1.SimpleText:='Label não localizado -  '+execution.memoria[i];
      end;
    end;
  end;

end;

procedure TForm1.Abrir1Click(Sender: TObject);
begin
if OpenDialog1.Execute then
begin
  Memo.Lines.LoadFromFile(OpenDialog1.FileName);
end;
end;

procedure TForm1.Salvar1Click(Sender: TObject);
begin
  If OpenDialog1.FileName <> '' then
  begin
    Memo.Lines.SaveToFile(OpenDialog1.FileName);
  end
  else
    SalvarComo1Click(Sender);

end;

procedure TForm1.SalvarComo1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    Memo.Lines.SaveToFile(SaveDialog1.FileName);
    OpenDialog1.FileName:=SaveDialog1.FileName;
  end;
end;

procedure TForm1.Fechar1Click(Sender: TObject);
begin
OpenDialog1.FileName:='';
SaveDialog1.FileName:='';
Memo.Lines.Clear;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
    Run1.Enabled:=false;
    Save1.Enabled:=false;
end;

procedure TForm1.MemoChange(Sender: TObject);
begin
  Run1.Enabled:=false;
  Save1.Enabled:=false;
end;

procedure TForm1.Sobre1Click(Sender: TObject);
begin
  about.ShowModal();
end;



procedure TForm1.Save1Click(Sender: TObject);
var
   objFile : TextFile;
   texto : String;
   i,j:  integer;
begin
  if SaveDialog2.Execute then
  begin
   AssignFile(objFile, SaveDialog2.FileName);
   ReWrite(objFile);

   for i:=0 to 255 do
   begin
      texto:='';
      if execution.memoria[i] <> '' then
        texto:=' '+IntToHex(StrToInt(execution.memoria[i]),2)
      else
        texto := ' 00';

      WriteLn(objFile, IntToHex(i,2)+texto);
   end;

   CloseFile(objFile);
  end;

end;

end.

