--------------------------------------------------------------------------
-- Bloco de Controle do Processador Cle�patra (8 bits)
-- Solu��o hardwired, via m�quina de estados 
--
--  19/08/2004 - troca de nome de alguns estados, coer�ncia de l�ngua (Calazans)
--  15/08/2004 - inser��o do sinal hold e codifica��o estendida
--		para instru��es not/sta (Moraes)
--  14/08/2004 - m�quina de estados simplificada (15 estados) (Moraes)
--  1/08/2004 - revis�o para s�ntese em hardware. trocar processo �nico
--  com muitos waits por estrutura de FSM convencional. (Calazans)
--------------------------------------------------------------------------
library IEEE; 
use IEEE.Std_Logic_1164.all;
use work.cleo.all;

entity control is
    port( reset, clock, hold : in std_logic;
          halt: out std_logic;
          ir :   in internal_bus;
          n, z, c, v: in std_logic;
          uins : out microinstrucao
        ); 
end control;

architecture control of control is 

   type CleoStates_type is (
       SIDLE,                             -- estado dummy, apenas para garantir que borda de subida seguinte
                                          -- � desativa��o do reset � o que faz o processamento come�ar.
       FETCH0, FETCH1, FETCH2,            -- estados onde se faz busca de instru��o
       
       Sop1a, Sop1b,                      --  busca do primeiro operando das demais instru��es
       
       Sop2a, Sop2b, Sop3a, Sop3b, Salu,  -- estados para execu��o das instru��es l�gicas aritm�ticas 
          
       OP2jp1, OP2jp2, Sjump,            -- estados para execu��o dos saltos
       
       Sjsr
   );
   
   -- CODIFICA��O DAS INSTRUCOES
   constant NOT1  : std_logic_vector(3 downto 0) :=  x"0";     -- duas codifica��es poss�veis para o NOT
   constant NOT2  : std_logic_vector(3 downto 0) :=  x"1";   
   constant STA1  : std_logic_vector(3 downto 0) :=  x"2";     -- duas codifica��es poss�veis para o STA
   constant STA2  : std_logic_vector(3 downto 0) :=  x"3";  
   constant LDA   : std_logic_vector(3 downto 0) :=  x"4";  
   constant ADD   : std_logic_vector(3 downto 0) :=  x"5";
   constant ORL   : std_logic_vector(3 downto 0) :=  x"6";
   constant ANDL  : std_logic_vector(3 downto 0) :=  x"7";
   constant JMP   : std_logic_vector(3 downto 0) :=  x"8";     
   constant JC    : std_logic_vector(3 downto 0) :=  x"9";     
   constant JN    : std_logic_vector(3 downto 0) :=  x"A";
   constant JZ    : std_logic_vector(3 downto 0) :=  x"B";
   constant JSR   : std_logic_vector(3 downto 0) :=  x"C";
   constant RTS   : std_logic_vector(3 downto 0) :=  x"D";
   constant JV    : std_logic_vector(3 downto 0) :=  x"E";
   constant HLT   : std_logic_vector(3 downto 0) :=  x"F";

   -- CODIFICA��O DOS MODOS DE ENDERE�AMENTO
   constant IM    : std_logic_vector(1 downto 0) :=  "00";
   constant DIR   : std_logic_vector(1 downto 0) :=  "01";    
   constant IND   : std_logic_vector(1 downto 0) :=  "10";
   constant REL   : std_logic_vector(1 downto 0) :=  "11";    

   --
   -- definicao das microinstrucoes em funcao dos registradores destino/origem
   --                                       alu    wr     rd    lnz lcv  ce  rw 
   constant mar_pc    : microinstrucao := ("111", "000", "011", '0','0', '0','0');  -- mar <- pc  
   constant mar_mdr   : microinstrucao := ("100", "000", "001", '0','0', '0','0');  -- mar <- mdr
   constant mdr_MmarP : microinstrucao := ("001", "110", "011", '0','0', '1','1');  -- mdr <- pmem(mar); pc++
   constant mdr_Mmar  : microinstrucao := ("111", "001", "110", '0','0', '1','1');  -- mdr <- pmem(mar)
   constant mar_mdrpc : microinstrucao := ("000", "000", "111", '0','0', '0','0');  -- mar <- mdr+PC 
   constant ir_mdr    : microinstrucao := ("100", "010", "001", '0','0', '0','0');  -- ir  <- mdr
   constant pc_mdr    : microinstrucao := ("100", "011", "001", '0','0', '0','0');  -- pc  <- mdr
   constant pc_mdrpc  : microinstrucao := ("000", "011", "111", '0','0', '0','0');  -- pc  <- mdr + pc
   constant rts_pc    : microinstrucao := ("111", "101", "011", '0','0', '0','0');  -- rts <- pc
   constant nop       : microinstrucao := ("111", "111", "110", '0','0', '0','0');  -- nao faz nada 

   alias i  : std_logic_vector(3 downto 0) is ir(7 downto 4);     -- peda�os do IR
   alias me : std_logic_vector(1 downto 0) is ir(3 downto 2);

   signal salta, logic_arith : std_logic;                         -- auxiliares

   signal EA, PE: CleoStates_type;                                -- estados da m�quina de estado

begin
       
   salta <= '1'  when ((i=JC and c='1') or (i=JV and v='1') or (i=JN and n='1') or (i=JZ and z='1')) else
            '0';
             
   logic_arith <= '1' when  i=LDA or i=ADD or i=ORL or i=ANDL else
                  '0';
   
   -- processo para implementar registrador de estado 
   process (clock, reset)
    begin
         if reset='1' then
              EA  <= Sidle; -- Sidle is the state the machine stays while processor is being reset
              halt <= '0';
         elsif clock'event and clock='1' then
              if i=HLT then 
                  halt <= '1';        -- avisa que trancou
              elsif hold='0' then     -- processador p�ra com hold='0'
                  EA <= PE;           -- prossegue se hold='1'
              end if;  
         end if;
   end process;
  
  -- processo para implementar fun��es de sa�da e pr�ximo estado
  process (hold, i, salta, EA, logic_arith, me)
  begin                  
     case EA is
          
       when SIDLE  => uins <= nop; 
                      PE <= FETCH0;                       -- n�o faz nada em SIDLE

       --- 
       --- BUSCA DA INSTRU��O
       ---             
       when FETCH0 => uins <= mar_pc;                     -- MAR <- PC              primeiro ciclo da busca
                      PE <= FETCH1;
                       
       when FETCH1 => uins <= mdr_MmarP;                  -- MDR <- MEM(MAR); PC++  segundo ciclo da busca.
                      PE <= FETCH2;
              
       when FETCH2 => uins <= ir_mdr;                     -- IR <- MDR              carga do ir
                  
                      case i is
                            when RTS | NOT1 | NOT2 | HLT =>  PE <=  Salu;
                            when others                  =>  PE <=  Sop1a;
                      end case;                                          
       --- 
       --- BUSCA DO OPERANDO DA INSTRU��O
       ---  
       when Sop1a =>  uins <= mar_pc;        -- MAR <- PC 
                      PE <=  Sop1b;
        
       when Sop1b =>  uins <= mdr_MmarP;     -- MDR <- MEM(MAR); PC++
       
                      if logic_arith='1' and ME=IM then
                             PE <= Salu;
                      elsif  (logic_arith='1' and (ME=DIR or ME=IND or ME=REL)) or (i=STA1 or i=STA2) then
                             PE <= Sop2a;
                      elsif  (i=JMP  or salta='1') and (ME=IM or ME=DIR or ME=REL) then
                             PE <= Sjump;
                      elsif  (i=JMP  or salta='1') and  ME=IND then
                             PE <= OP2jp1;
                      elsif i=JSR then
                             PE <= Sjsr;
                      else
                             PE <= FETCH0;    -- volta para o FETCH, e.g., salto condicional com flag=0    
                      end if;    
      --- 
      --- A��ES ESPEC�FICAS DAS INSTRU��ES L�GICAS ARITM�TICAS -- lda, and, or, add, not + STA + RTS
      ---
      when Sop2a =>   case ME is
                            when REL    =>  uins <= mar_mdrpc;    -- MAR <- MDR + PC
                            when others =>  uins <= mar_mdr;      -- MAR <- MDR
                      end case;                                          
 
                      if (i=STA1 or i=STA2) and (ME=REL or ME=DIR) then
                                PE <= Salu;
                        else
                                PE <=  Sop2b;
                      end if;
                        
      when Sop2b =>   uins <= mdr_Mmar;            -- MDR <- MEM(MAR)
                        
                      case ME is
                            when IND    =>  PE <=  Sop3a;
                            when others =>  PE <=  Salu;
                      end case;                                          
                                            
      when Sop3a =>   uins <= mar_mdr;             -- MAR <- MDR

                      case i is
                            when STA1 | STA2 =>  PE <=  Salu;
                            when others      =>  PE <=  Sop3b;
                      end case;                                          
           
      when Sop3b =>   uins <= mdr_Mmar;            -- MDR <- MEM(MAR)
                      PE <=  Salu;
         
      when Salu  =>   case i is 
    --                                               alu    wr     rd    lnz lcv  ce  rw 
                       when LDA         => uins <= ("100", "100", "001", '1','0', '0','0'); -- ac <- mdr; lnz
                       when ADD         => uins <= ("000", "100", "110", '1','1', '0','0'); -- ac <- ac + mdr;lnz;lcv
                       when ORL         => uins <= ("101", "100", "110", '1','0', '0','0'); -- ac <- ac or mdr; lnz
                       when ANDL        => uins <= ("110", "100", "110", '1','0', '0','0'); -- ac <- ac and mdr; lnz
                       when NOT1 | NOT2 => uins <= ("010", "100", "100", '1','0', '0','0'); -- ac <- not ac ; lnz
                       when RTS         => uins <= ("111", "011", "101", '0','0', '0','0'); -- pc <- rts
                       when STA1 | STA2 => uins <= ("111", "111", "100", '0','0', '1','0'); -- pmem(mar) <- ac
                       when others      => uins <= nop;                                   -- halt
                      end case;    
                      
                      PE <= FETCH0;
                    
      --- 
      --- A��ES ESPEC�FICAS DAS INSTRU��O DE SALTO
      ---
      when Sjsr =>    uins <= rts_pc;              -- RS <- PC

                      case ME is
                            when IND    =>  PE <=  OP2jp1;
                            when others =>  PE <=  Sjump;
                      end case;                                          
            
      when OP2jp1  => uins <= mar_mdr;             -- MAR <- MDR
                      PE <=  OP2jp2;
 
      when OP2jp2  => uins <= mdr_Mmar;            -- MDR <- MEM(MAR)
                      PE <=  Sjump;
                        
      when Sjump =>  case ME is
                            when REL    =>  uins <= pc_mdrpc;      -- PC <- MDR + PC
                            when others =>  uins <= pc_mdr;        -- PC <- MDR
                      end case; 
                                            
                      PE <= FETCH0;
     end case;
  end process; 
end control;
