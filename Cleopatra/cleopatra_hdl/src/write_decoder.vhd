-------------------------------------------------------------------------
-- Decodificador de Escrita
-- Este bloco combinacional gera sinais de habilita��o de escrita nos 
-- registradores do Bloco de Dados.
--
--  30/07/2004 - revis�o para considerar o sinal de hold na interface
--		externa do processador. (Calazans)
-------------------------------------------------------------------------
library IEEE;
use IEEE.Std_Logic_1164.all;
use work.cleo.all;

--  30/07/2004 - a escrita de registradores deve ser condicionada
-- 		� inexist�ncia de ativa��o de hold. (Calazans)
entity write_decoder is
    port(write_reg :in std_logic_vector(2 downto 0); hold :in std_logic;
	w_mar, w_mdr, w_ir, w_pc, w_ac, w_rs :out std_logic);
end write_decoder;

architecture write_decoder of write_decoder is
begin
    ---
    --- C�digos de escrita nos registradores (codifica��o de escrita):
    --- 0 MAR, 1 MDR, 2 IR, 3 PC, 4 AC, 5 RS, 6 PC/MDR, 7 nenhum reg. alterado
    ---
    w_mar <= '1' when hold='0' and write_reg="000"             		    else '0';
    w_mdr <= '1' when hold='0' and (write_reg="001" or write_reg="110")	else '0';
    w_ir  <= '1' when hold='0' and write_reg="010"                 		else '0';
    w_pc  <= '1' when hold='0' and (write_reg="011" or write_reg="110") 	else '0';
    w_ac  <= '1' when hold='0' and write_reg="100"                 		else '0';
    w_rs  <= '1' when hold='0' and write_reg="101"                		else '0';    
end write_decoder;																	 
