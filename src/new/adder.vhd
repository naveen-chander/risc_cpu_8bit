-- adder.vhd
-- Created : 25 JUN 2020
-- Authors : Naveen Chander, Aditya Bhat
-- Function: Performs signed addition of 2 8 bit numbers
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
---------------------------------------------------------
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
-- use IEEE.NUMERIC_STD.ALL;


entity adder is 
port ( A_add, B_add : in STD_LOGIC_VECTOR (7 downto 0);
       C_add: in STD_LOGIC;
       sum : out STD_LOGIC_VECTOR (7 downto 0);   -- ALU output
       OV: out STD_LOGIC;
       c_out : out STD_LOGIC);
end entity;


architecture arch_adder of adder is

signal psum   : std_logic_vector (7 downto 0); -- partial sum
signal c7_in  : std_logic;
signal c7_out : std_logic;

begin

psum <= ("0" & unsigned(A_add(6 downto 0))) + unsigned(B_add(6 downto 0)) + C_add;
c7_in         <= psum(7);
sum(6 downto 0) <= psum(6 downto 0); -- 7 bit output
sum(7)   <= A_add(7) xor B_add(7) xor c7_in; -- 8th bit half full adder
c7_out <= ((A_add(7) xor B_add(7)) and c7_in) or A_add(7); -- generate carry out

c_out <= c7_out; -- carry out
OV  <= c7_in xor c7_out; -- check overflow

end arch_adder;



      
