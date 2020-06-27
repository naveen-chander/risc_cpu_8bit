-- alu_new.vhd
-- Created : 25 JUN 2020
-- Authors : Naveen Chander, Aditya Bhat
-- Function: Performs (i) Additions (ii) Subtraction 
--                    (iii) Increment (iv) Decrement
--                    (v) xor (vi) xnor 
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- --------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity alu is 
port (REG_A, REG_B: in std_logic_vector(7 downto 0);
      ALU_OP_SEL: in std_logic_vector(3 downto 0);
      Y: out std_logic_vector (7 downto 0);
      OV: out std_logic;
      c_out: out std_logic);
end entity;


architecture arch_alu_new of alu is

component adder is
port ( A_add, B_add : in STD_LOGIC_VECTOR (7 downto 0);
       C_add: in STD_LOGIC;
       sum : out STD_LOGIC_VECTOR (7 downto 0);   -- ALU output
       OV: out STD_LOGIC;
       c_out : out STD_LOGIC);
end component;

signal A,B: std_logic_vector(7 downto 0);
signal C: std_logic;
signal sum: std_logic_vector(7 downto 0);
signal O_flow, carry_out: std_logic;
signal logic_Y: std_logic_vector(7 downto 0);
signal arith_logic: std_logic;

begin
arith_logic <= ALU_OP_SEL(3) and not(ALU_OP_SEL(2)); -- Select b/w arith and logic

A <= REG_A;   -- adder input always REG_A

B <= REG_B when ALU_OP_SEL = "1000" else     -- A+B
     not(REG_B) when ALU_OP_SEL = "1001" else  -- A+B'+1
     (others => '0') when ALU_OP_SEL = "1010" else -- A+1
     X"FE" when ALU_OP_SEL = "1011"  else       -- A+FE+1
     (others=>'0');                             -- Naveen Added to avoid inferring as latch
C <= '0' when ALU_OP_SEL = "1000" else -- A+B
     '1' when ALU_OP_SEL = "1001" else -- A+B'+1
     '1' when ALU_OP_SEL = "1010" else -- A+1
     '1' when ALU_OP_SEL = "1011" else -- A+FE+1
     '0' ;

logic_Y <= REG_A xor REG_B when ALU_OP_SEL = "1100" else
           REG_A xnor REG_B when ALU_OP_SEL = "1101" else
           (others=>'0');   -- Added by Naveen to avoid inferring as latch

adder_block: adder port map (A_add => A, B_add => B, C_add => C,
                            sum => sum, OV => O_flow,
                            c_out => carry_out);

-- Outputs  
Y <= X"00" when (ALU_OP_SEL(3) = '0') else      
    sum when (arith_logic = '1') else
     logic_Y;
                    
--Y <= sum when (arith_logic = '1') else
--     logic_Y when (arith_logic = '0') else
--     X"00" when (ALU_OP_SEL(3) = '0'); -- switch between arith and logic
                            
OV <= O_flow;

c_out <= carry_out;

end arch_alu_new;    
