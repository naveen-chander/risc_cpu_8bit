----------------------------------------------------------------------------------
-- File Name: pc.vhd 
-- Author: Naveen Chander, Aditya Bhat  
-- 
-- Create Date: 25.05.2020 
-- Design Name: 
-- Module Name: PC - Behavioral
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- Description:  Selects the right PC for next instruction
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity PC is
port (clk, reset: in STD_LOGIC;
      INTR_ADDR: in STD_LOGIC_VECTOR (7 downto 0);
      JMP_ADDR: in STD_LOGIC_VECTOR (7 downto 0);
      RET_ADDR: in STD_LOGIC_VECTOR ( 7 downto 0);
      PC_OP_SEL: in STD_LOGIC_VECTOR(2 downto 0);
      PC_out: out STD_LOGIC_VECTOR(7 downto 0)
      );
end entity;


architecture arch_PC of PC is 

signal PC_signal, PC_temp: STD_LOGIC_VECTOR (7 downto 0);


begin
PC_out <= PC_temp;

PC_signal <= unsigned(PC_temp) + 1 when PC_OP_SEL = "001" else 
            JMP_ADDR  when PC_OP_SEL = "010" else 
            INTR_ADDR when PC_OP_SEL = "011" else
            RET_ADDR  when PC_OP_SEL = "111" else
            PC_temp; --(000,110,101,110)
             
process(reset, clk)
begin
    if(reset = '1') then 
        PC_temp <= (others => '0');
    elsif (rising_edge(clk)) then
        PC_temp <= PC_signal;
    end if;
end process;

end arch_PC;
