----------------------------------------------------------------------------------
-- File Name: regfile.vhd 
-- Author: Naveen Chander, Aditya Bhat  
-- 
-- Create Date: 15.05.2020 13:32:01
-- Design Name: 
-- Module Name: reg_file - Behavioral
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- Description:  8 bit Register File R0--> R15
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity reg_file is
    Port ( clk : in STD_LOGIC;                           -- Master Clock
           reset : in STD_LOGIC;                         -- Master Async Reset
           data_in : in STD_LOGIC_VECTOR (7 downto 0);   -- Data for Writing to REG
           sel_RD : in STD_LOGIC_VECTOR (3 downto 0);      -- REGister Address (Also D-inputs to SElA and SelB Regs)
           WE   : in STD_LOGIC;                          -- Write Enable
           LDA  : in STD_LOGIC;                          -- Durin Loadto A
           LDB  : in STD_LOGIC;                          -- Durin Loadto B
           SelA_WE : in STD_LOGIC;                       -- Select A Regsiter Write Enable
           SelB_WE : in STD_LOGIC;                       -- Select A Regsiter Write Enable
           A_REG : out STD_LOGIC_VECTOR (7 downto 0);    -- A_REG to ALU
           B_REG : out STD_LOGIC_VECTOR (7 downto 0);    -- B_REG to ALU
           OUT_ADDR  :out STD_LOGIC_VECTOR(7 downto 0)   -- Used as Address for Load/Store from Data Mem 
                                                         --  and Jump Address for Prog Mem
           );
end reg_file;

architecture Behavioral of reg_file is
-- Create a REG_ARRAY of 16 x 8
type reg_array is array (15 downto 0) of std_logic_vector(7 downto 0);
signal reg :reg_array;

signal SEL_A : std_logic_vector(3 downto 0);
signal SEL_B : std_logic_vector(3 downto 0);

signal WR_ADDR  : std_logic_vector(3 downto 0);
----------------------------------------------------------------------------------

begin
-- RegADDR Select Logic
WR_ADDR <= SEL_A when (LDA = '1' and LDB = '0') else        -- when Load_A inst.
        SEL_B when (LDB = '1' and LDA = '0') else        -- when Load_B inst.
        Sel_RD;                          -- By Defaulr, ADDR = Dest_Reg
------------------------------------------------
-- Write Data into Registers
REG_WRITE: process(clk,reset)
begin
    if (reset = '1') then
        for i in 0 to 15 loop
            reg(i) <= (others=>'0');
        end loop;
    elsif (rising_edge(clk)) then
        if (WE = '1') then
            reg(conv_integer(WR_ADDR)) <= data_in;  -- Write Data to Destination REG
        end if;
    end if;
end process REG_WRITE;
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
SelA_Regsiter: process(clk,reset)
begin
    if (reset = '1') then
        SEL_A <= (others =>'0');  -- Default Value of SelA 
    elsif (rising_edge(clk)) then
        if(SelA_WE = '1') then
            SEL_A <= Sel_RD;
        end if;
    end if;
end process;
----------------------------------------------------------------------------------
SelB_Regsiter: process(clk,reset)
begin
    if (reset = '1') then
        SEL_B <= "0001";          -- Default Value of SelB
    elsif (rising_edge(clk)) then
        if(SelB_WE = '1') then
            SEL_B <= Sel_RD;
        end if;
    end if;
end process;
----------------------------------------------------------------------------------
-- Outputting A_REG and B_REG to ALU 
A_REG <= reg(conv_integer(SEL_A));         -- These go to ALU and DATA_MEM
B_REG <= reg(conv_integer(SEL_B));
----------------------------------------------------------------------------------
-- Jump Address Output
OUT_ADDR <= reg(conv_integer(Sel_RD));       -- Jump_Address / Data_Memory Load/Store Address
-- Note : JumpAdr Addr should 
-- not go thru LDA/LDB MUX (Changed on 31st may 2020)                           
---------------------------------------------------------------------------------

end Behavioral;
