----------------------------------------------------------------------------------
-- File Name: interrupt_synchronizer.vhd 
-- Author: Naveen Chander, Aditya Bhat  
-- 
-- Create Date: 25.05.2020 
-- Design Name: 
-- Module Name: control_unit - Behavioral
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- Description:  Synchronize interrupt ( 5 clock) and convert it to Pulse
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity level_to_pulse is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           level_inp : in STD_LOGIC;
           pul_out : out STD_LOGIC);
end level_to_pulse;

architecture Behavioral of level_to_pulse is
signal reg_line : std_logic_vector(14 downto 0);

begin

pul_out <= ( reg_line(10) xor reg_line(0) ) and reg_line(12);

delay_line:process(clk,reset)
begin
    if(reset = '1') then
        reg_line <= (others=>'0');
    elsif(rising_edge(clk)) then
        reg_line(14 downto 0) <= level_inp&reg_line(14 downto 1);    
    end if;
end process;

end Behavioral;
