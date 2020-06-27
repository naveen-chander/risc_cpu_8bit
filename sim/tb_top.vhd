----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.06.2020 05:09:45
-- Design Name: 
-- Module Name: tb_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
--use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_top is
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is

component CPU_top is
    Port ( clk           : in STD_LOGIC;
       reset         : in STD_LOGIC;
       INTERRUPT     : in STD_LOGIC;
       PRGM_MODE_SEL : in STD_LOGIC;
-- Inst Memory
       I_MEM_ADDR    : in STD_LOGIC_VECTOR(7 downto 0);
       I_MEM_CS      : in STD_LOGIC;
       I_MEM_RE      : in STD_LOGIC;
       I_MEM_WE      : in STD_LOGIC;
       I_MEM_DIN     : in STD_LOGIC_VECTOR(7 downto 0);
       I_MEM_DOUT    : out STD_LOGIC_VECTOR(7 downto 0);
-- Data Memory
       D_MEM_ADDR    : in STD_LOGIC_VECTOR(7 downto 0);
       D_MEM_CS      : in STD_LOGIC;
       D_MEM_RE      : in STD_LOGIC;
       D_MEM_WE      : in STD_LOGIC;
       D_MEM_DIN     : in STD_LOGIC_VECTOR(7 downto 0);
       D_MEM_DOUT    : out STD_LOGIC_VECTOR(7 downto 0)           
        
     ); 
end component;


signal clk            :  STD_LOGIC;
signal reset          :  STD_LOGIC;
signal INTERRUPT      :  STD_LOGIC;
signal PRGM_MODE_SEL  :  STD_LOGIC;
signal I_MEM_ADDR     :  STD_LOGIC_VECTOR(7 downto 0);
signal I_MEM_CS       :  STD_LOGIC;
signal I_MEM_RE       :  STD_LOGIC;
signal I_MEM_WE       :  STD_LOGIC;
signal I_MEM_DIN      :  STD_LOGIC_VECTOR(7 downto 0);
signal I_MEM_DOUT     :  STD_LOGIC_VECTOR(7 downto 0);
signal D_MEM_ADDR     :  STD_LOGIC_VECTOR(7 downto 0);
signal D_MEM_CS       :  STD_LOGIC;
signal D_MEM_RE       :  STD_LOGIC;
signal D_MEM_WE       :  STD_LOGIC;
signal D_MEM_DIN      :  STD_LOGIC_VECTOR(7 downto 0);
signal D_MEM_DOUT     :  STD_LOGIC_VECTOR(7 downto 0);  

signal period: time := 20 ns;
 file file_VECTORS_I : text;
 file file_VECTORS_D : text;
--
--
--procedure read_inst(
--    signal   clk   : in std_logic;
--    signal  I_ADDR : in std_logic_vector(7 downto 0);
--    signal  I_DOUT : out std_logic_vector(7 downto 0);
--    variable read_ok   : out   boolean) is
--    
--    begin
--        
--        wait until rising_edge(clk);
--        
--    end procedure;

begin

-- POrt Map 
UUT : CPU_top port map(
clk            => clk            ,
reset          => reset          ,
INTERRUPT      => INTERRUPT      ,
PRGM_MODE_SEL  => PRGM_MODE_SEL  ,
I_MEM_ADDR     => I_MEM_ADDR     ,
I_MEM_CS       => I_MEM_CS       ,
I_MEM_RE       => I_MEM_RE       ,
I_MEM_WE       => I_MEM_WE       ,
I_MEM_DIN      => I_MEM_DIN      ,
I_MEM_DOUT     => I_MEM_DOUT     ,
D_MEM_ADDR     => D_MEM_ADDR     ,
D_MEM_CS       => D_MEM_CS       ,
D_MEM_RE       => D_MEM_RE       ,
D_MEM_WE       => D_MEM_WE       ,
D_MEM_DIN      => D_MEM_DIN      , 
D_MEM_DOUT     => D_MEM_DOUT     
);

clk_gen : process
begin
clk <= '1';
wait for PERIOD/2;
clk <= '0';
wait for PERIOD/2;
end process;

test : process

-- variable Declaration/ Defintion for File IO
variable v_ILINE        : line;
variable v_OLINE        : line;
variable v_FILE_READ_DATA : std_logic_vector(7 downto 0);

--variable v_SPACE        : character;

begin
file_open(file_VECTORS_I, "instructions.txt",  read_mode);
--Initiallize
reset           <= '1';
interrupt       <= '0';
PRGM_MODE_SEL   <= '1';
I_MEM_ADDR      <= (others=>'0');
I_MEM_CS        <= '0';
I_MEM_RE        <= '0';
I_MEM_WE        <= '0';
I_MEM_DIN       <= (others=>'0'); 
D_MEM_ADDR      <= (others=>'0');
D_MEM_CS        <= '0';
D_MEM_RE        <= '0';
D_MEM_WE        <= '0';
D_MEM_DIN       <= (others=>'0');

wait for 5*PERIOD;
reset           <= '0';
PRGM_MODE_SEL   <= '1';
-- Read from File and Dump Into Instruction Memory
while not endfile(file_VECTORS_I) loop
   readline(file_VECTORS_I, v_ILINE);
   hread(v_ILINE, v_FILE_READ_DATA);
    -- Pass the variable to a signal
    -- Fill Instruction memory with instructions
    I_MEM_DIN  <= v_FILE_READ_DATA;
    I_MEM_WE   <= '1';
    I_MEM_RE   <= '0';
    I_MEM_CS   <= '1';
    wait for 2*period;
    I_MEM_ADDR <= I_MEM_ADDR+1;
 end loop;
 wait for 2*period;
 file_close(file_VECTORS_I);
 -- Write RET instruction in C5
 I_MEM_ADDR <= x"C5";
 I_MEM_DIN  <= x"E5";
 I_MEM_WE   <= '1';
 I_MEM_RE   <= '0';
 I_MEM_CS   <= '1';
 wait for 2*period;
 -------------------------------------
 I_MEM_WE   <= '0';
 I_MEM_RE   <= '0';
 I_MEM_CS   <= '0';
 wait for 10*PERIOD;
  -------------------------------------

 -- Read Data memory File and Porpulrate D_MEM
 file_open(file_VECTORS_D, "data.txt",  read_mode);
 while not endfile(file_VECTORS_D) loop
    readline(file_VECTORS_D, v_ILINE);
    hread(v_ILINE, v_FILE_READ_DATA);
     -- Pass the variable to a signal
     -- Fill Instruction memory with instructions
     D_MEM_DIN  <= v_FILE_READ_DATA;

     D_MEM_WE   <= '1';
     D_MEM_RE   <= '0';
     D_MEM_CS   <= '1';

     wait for 2*period;
     D_MEM_ADDR <= D_MEM_ADDR+1;
  end loop;
  D_MEM_WE   <= '0';
  D_MEM_RE   <= '0';
  D_MEM_CS   <= '0';
  
  wait for 10*PERIOD;
file_close(file_VECTORS_D);
I_MEM_ADDR <= (others=>'0');

wait for 10*PERIOD;
for i in 1 to 5 loop
    I_MEM_RE   <= '1';
    I_MEM_CS   <= '1';
    wait for 2*period;
    I_MEM_ADDR <= I_MEM_ADDR+1;
 end loop;
 
 wait for 6 ns;
PRGM_MODE_SEL   <= '1';

  I_MEM_WE   <= '0';
  I_MEM_RE   <= '0';
  I_MEM_CS   <= '0';


wait for 10*PERIOD;
for i in 1 to 5 loop
    D_MEM_ADDR <= D_MEM_ADDR+1;
    D_MEM_RE   <= '1';
    D_MEM_CS   <= '1';
    wait for 2*period;
 end loop;
PRGM_MODE_SEL   <= '1';

  D_MEM_WE   <= '0';
  D_MEM_RE   <= '0';
  D_MEM_CS   <= '0';
  
  wait for 10*PERIOD;
  PRGM_MODE_SEL   <= '0';
wait for 3000 ns;
INTERRUPT <= '1';
wait for 1000 ns;
INTERRUPT <= '0';
wait;
end process;
end Behavioral;
