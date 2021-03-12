--------------------------------------------------------------------------
-------------------------------------------------------------------------
--  CONSTRU��O DA ARQUITETURA CLE�PATRA COMPLETA
--
--  Fernando Moraes
--  Ney Calazans
--
--  In�cio: 11/maio/1998             Ultima modifica��o:  17/agosto/2004
--
--  17/08/2004 - sincroniza��o do sinal externo hold na subida do sinal
--		externo de rel�gio e gera��o da vers�o 3.0 de distribui��o da
--  	arquitetura (Calazans)
--  02/08/2004 - mudan�a da Unidade de Controle para m�quina de estados
--		(Calazans)
--  30/07/2004 - revis�o para separar barramento bidirecional de dados
--		em dois barramentos unidirecionais e acrescentar um sinal de
--		hold na interface externa do processador. Estas s�o as primeiras
-- 		altera��es visando a prototipa��o em hardware. (Calazans)
--  28/07/2004 - revis�o para modularizar implementa��o - (Calazans)
--  06/06/2003 - revis�o do c�digo - (Calazans/Moraes)
--  04/08/2002 - inser��o do flag de overflow e decorr�ncias - (Calazans)
--  15/10/2001 - simplifica��o da Unidade de Controle e corre��o dos
--		jumps indiretos - (Moraes)
--
--  CPU: uni�o do bloco de dados com o bloco de controle
--------------------------------------------------------------------------
--------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.cleo.all;
	-- signal clock, reset, halt, hold, ce, rw, go, int_rqst, int_ack(saida), irq_time (entrada): std_logic;
entity cleopatra is
	port(clock, reset, hold, irq_time : in std_logic;
		   halt, int_rqst, int_ack	    : out std_logic;
         ce, rw		: out std_logic; 
         address		: out internal_bus;
         datain		: in internal_bus;
		   dataout		: out internal_bus;
        ); 
end cleopatra;
    
architecture cleopatra of cleopatra is
   signal uins : microinstrucao; 
   signal n,z,c,v : std_logic;
   signal ir : internal_bus;
   SIGNAL hold_int : std_logic; -- hold interno
   
begin
   ce <= uins.ce;
   rw <= uins.rw;
   
   -- processo para registrar, e assim sincronizar, o sinal externo hold
   -- na borda de subida do rel�gio
   process (clock, reset)
   begin
	   if reset='1' then
		   hold_int <='0';   
	   elsif clock'event and clock='1' then
		   hold_int <= hold;
	   end if;
   end process;
	   
   DP: entity work.datapath port map (clock=>clock, reset=>reset,
	   hold=>hold_int, address=>address, datain=>datain, dataout=>dataout,
	   ir=>ir, uins=>uins, n=>n, z=>z, c=>c, v=>v);  
                           
   CU: entity work.control port map (clock=>clock, reset=>reset,
	   hold=>hold_int, halt=>halt, ir=>ir, uins=>uins,
	   n=>n, z=>z, c=>c, v=>v);
end cleopatra;
