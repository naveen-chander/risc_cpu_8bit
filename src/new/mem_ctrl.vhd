----------------------------------------------------------------------------------
-- File Name: mem_ctrl.vhd 
-- Author: Naveen Chander, Aditya Bhat  
-- 
-- Create Date: 25.05.2020 
-- Design Name: 
-- Module Name: PC - Behavioral
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- Description:  Memory Controller for Instruction and Data Memories
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mem_ctrl is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           I_ADDR : in STD_LOGIC_VECTOR (7 downto 0);
           D_ADDR : in STD_LOGIC_VECTOR (7 downto 0);
           D_DOUT : out STD_LOGIC_VECTOR (7 downto 0);
           I_DOUT : out STD_LOGIC_VECTOR (7 downto 0);
           D_DIN  : in STD_LOGIC_VECTOR (7 downto 0);
           I_DIN  : in STD_LOGIC_VECTOR (7 downto 0);
           D_CS : in STD_LOGIC;
           I_CS : in STD_LOGIC;  
           D_WE : in STD_LOGIC;
           I_WE : in STD_LOGIC;
           D_RE : in STD_LOGIC;
           I_RE : in STD_LOGIC);
end mem_ctrl;

architecture Behavioral of mem_ctrl is
COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

begin

I_MEM : blk_mem_gen_0  port map (
clka  => clk,
ena   => I_CS,
wea(0)   => I_WE,
addra => I_ADDR,
dina  => I_DIN,
clkb  => clk,
enb   => I_RE,
addrb => I_ADDR,
doutb => I_DOUT
);

D_MEM : blk_mem_gen_0  port map (
clka  => clk,
ena   => D_CS,
wea(0)   => D_WE,
addra => D_ADDR,
dina  => D_DIN,
clkb  => clk,
enb   => D_RE,
addrb => D_ADDR,
doutb => D_DOUT
);

end Behavioral;
