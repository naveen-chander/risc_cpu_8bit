----------------------------------------------------------------------------------
-- File Name: top_risc.vhd 
-- Author: Naveen Chander, Aditya Bhat  
-- 
-- Create Date: 25.05.2020 
-- Design Name: 
-- Module Name: CPU_top- Behavioral
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- Description:  Top Module
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity CPU_top is
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
end CPU_top;

architecture Behavioral of CPU_top is

-- Component Definitions
-----------------------------------------------------------------
-- 1. ALU
component alu is
port (REG_A, REG_B: in std_logic_vector(7 downto 0);
      ALU_OP_SEL: in std_logic_vector(3 downto 0);
      Y: out std_logic_vector (7 downto 0);
      OV: out std_logic;
      c_out: out std_logic);
end component;
-----------------------------------------------------------------
-- 2. Register File
component reg_file is
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
end component;

-----------------------------------------------------------------
-- 3. Program Counter Mux
component PC is
port (clk, reset: in STD_LOGIC;
      INTR_ADDR: in STD_LOGIC_VECTOR (7 downto 0);
      JMP_ADDR: in STD_LOGIC_VECTOR (7 downto 0);
      RET_ADDR: in STD_LOGIC_VECTOR ( 7 downto 0);
      PC_OP_SEL: in STD_LOGIC_VECTOR(2 downto 0);
      PC_out: out STD_LOGIC_VECTOR(7 downto 0)
      );
end component;
-----------------------------------------------------------------
-- 4. Memory Controller
component mem_ctrl is
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
end component;
-----------------------------------------------------------------
-- 5. Status Register
component status_reg is
port ( clk : in STD_LOGIC ;
       reset : in STD_LOGIC;
       ALU_EN : in STD_LOGIC;
       REG_A, REG_B : in STD_LOGIC_VECTOR (7 downto 0);       -- To check GEL
       c_out : in STD_LOGIC;                            -- CARRY
       OV: in STD_LOGIC;
       Y : in STD_LOGIC_VECTOR (7 downto 0);  
       INTR_DFF : in STD_LOGIC;        -- FOR OVERFLOW;                         -- INTERRUPT FLAG
       STATUS : out STD_LOGIC_VECTOR (7 downto 0));   -- STATUS REGISTER
end component;
-----------------------------------------------------------------
-- 6. muxes
component muxes is
Port ( ALU_Y            : in STD_LOGIC_VECTOR (7 downto 0);  -- ALU _Op
       DMEM_DOUT        : in STD_LOGIC_VECTOR (7 downto 0);  -- D_MEM Data Read
       ALU_MEM_SEL      : in STD_LOGIC;                      -- Sel : 1 =ALU
       REG_DIN          : out STD_LOGIC_VECTOR (7 downto 0); -- REG
       --------------------------------------------------------------------------------------
       A_REG            : in STD_LOGIC_VECTOR (7 downto 0);  -- A_REG from RegFile
       B_REG            : in STD_LOGIC_VECTOR (7 downto 0);  -- B_REG from RegFile
       PC               : in STD_LOGIC_VECTOR (7 downto 0);  -- Program Counter Register Output
       SEL_AB_PC        : in STD_LOGIC_VECTOR(1 downto 0);   -- Select RegA/RegB/PC as Data to D_MEM
       DMEM_DIN         : out STD_LOGIC_VECTOR (7 downto 0); -- DMEM_Write_data
       ----------------------------------------------------------------------------------
       REG_FILE_OUTADDR : in STD_LOGIC_VECTOR (7 downto 0);  -- OutAddr from RegFile
       DMEM_ADDR        : out STD_LOGIC_VECTOR (7 downto 0)      -- Address to Data Memory
      );
end component;
-----------------------------------------------------------------
-- 7. Control Unit
component control_unit is 
port(clk, reset: in STD_LOGIC;
     start     : in STD_LOGIC;
     OP_CODE: in STD_LOGIC_VECTOR (3 downto 0); 
     STATUS_Z: in STD_LOGIC;                            -- Status reg zero for JZ
     INTERRUPT_OCCRD : in std_logic ;                   -- From STS REG
     D_MEM_CS: out STD_LOGIC;                 -- Chip Selects
     D_MEM_RE: out STD_LOGIC;                 -- Read Enables
     D_MEM_WE: out STD_LOGIC;                           -- Write Enable for D-MEM only
     ALU_OP_SEL: out STD_LOGIC_VECTOR (3 downto 0);     -- ALU OP Select
     PC_OP_SEL: out STD_LOGIC_VECTOR (2 downto 0);      -- PC OP Select
     ALU_MEM_SEL: out STD_LOGIC;                        -- Selection b/w ALU/D-MEM  0/1
     REG_WE: out STD_LOGIC;                             -- Register Write Enable
     STR_AB_PC_SEL: out STD_LOGIC_VECTOR(1 downto 0);    -- Select A or B register or PC to Din of D_MEM when STRA or STRB inst is given
     LDA: out STD_LOGIC;                          -- Select A register to load MEM Data during LD cycle
     LDB: out STD_LOGIC;                          -- Select B register to load MEM Data during LD cycle
     SEL_A_WE: out STD_LOGIC;                           -- SEL A 
     SEL_B_WE: out STD_LOGIC                           -- SEL B enable
    );
end component;
------------------------------------------------------
-- 8 . Interrupt Level to Pulse COnverter
component level_to_pulse is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           level_inp : in STD_LOGIC;
           pul_out : out STD_LOGIC);
end component; 
------------------------------------------------------
-- SIGNALS 
------------------------------------------------------
--1. ALU Related
signal A_REG      		: std_logic_vector(7 downto 0);
signal B_REG      		: std_logic_vector(7 downto 0);
signal ALU_OP_SEL 		: std_logic_vector(3 downto 0);
signal ALU_Y      		: std_logic_vector (7 downto 0);
signal ALU_OV     		: std_logic;
signal ALU_c_out  		: std_logic;

--2. RegFile Related
                 
signal reg_file_data_in : STD_LOGIC_VECTOR (7 downto 0);
signal sel_RD 			: STD_LOGIC_VECTOR (3 downto 0); 
signal reg_file_WE   	: STD_LOGIC;                       
signal reg_file_LDA  	: STD_LOGIC;                       
signal reg_file_LDB  	: STD_LOGIC;                       
signal reg_file_SelA_WE : STD_LOGIC;                    
signal reg_file_SelB_WE : STD_LOGIC;                    

signal reg_file_OUT_ADDR: STD_LOGIC_VECTOR(7 downto 0);
                                               
--3. PC Mux Related
signal INTR_ADDR		: STD_LOGIC_VECTOR (7 downto 0);
signal JMP_ADDR			: STD_LOGIC_VECTOR (7 downto 0);
signal PC_OP_SEL		: STD_LOGIC_VECTOR(2 downto 0);
signal PC_out			: STD_LOGIC_VECTOR(7 downto 0);

-- 4. memory Controller
signal I_ADDR 	: STD_LOGIC_VECTOR (7 downto 0);
signal D_ADDR 	: STD_LOGIC_VECTOR (7 downto 0);
signal D_DOUT 	: STD_LOGIC_VECTOR (7 downto 0);
signal I_DOUT 	: STD_LOGIC_VECTOR (7 downto 0);
signal D_DIN  	: STD_LOGIC_VECTOR (7 downto 0);
signal I_DIN  	: STD_LOGIC_VECTOR (7 downto 0);
signal D_CS 	: STD_LOGIC;
signal I_CS 	: STD_LOGIC;  
signal D_WE 	: STD_LOGIC;
signal I_WE 	: STD_LOGIC;
signal D_RE 	: STD_LOGIC;
signal I_RE 	: STD_LOGIC;

--5. Status Reg Related
signal STS_REG	:  STD_LOGIC_VECTOR (7 downto 0);   -- STATUS REGISTER

--6 . Muxes
signal STR_AB_PC_SEL          : STD_LOGIC_VECTOR(1 downto 0);
signal ALU_MEM_SEL            : STD_LOGIC;
signal A_REG_B_REG_PC         : STD_LOGIC_VECTOR(7 downto 0);
signal DMEM_DIN_REGA_REGB_PC  : STD_LOGIC_VECTOR(7 downto 0);
signal DMEM_ADDR_REGFILE_FF   : STD_LOGIC_VECTOR(7 downto 0);

--7. COntrol Unit Related
signal 	   OP_CODE	  : STD_LOGIC_VECTOR (3 downto 0); 
signal 	   STATUS_Z	  : STD_LOGIC;  
signal     CTRL_START : STD_LOGIC;

signal     D_WE_CONTROL_UNIT : STD_LOGIC;
signal     D_CS_CONTROL_UNIT : STD_LOGIC;
signal     D_RE_CONTROL_UNIT : STD_LOGIC;

--8 . Levl To Pul Related
signal     INTERRUPT_PUL       : STD_LOGIC;
-------------------------------------------------------------
--------               Top_Level Beings                ------
-------------------------------------------------------------
begin
-- Instantiations
-- 1. ALU
alu_RISC: alu port map(
REG_A      => A_REG,
REG_B      => B_REG,
ALU_OP_SEL => ALU_OP_SEL,
Y          => ALU_Y,
OV         => ALU_OV,
c_out      => ALU_C_out
);

-- 2.RegFile
reg_file_RISC : reg_file port map(
 clk 		=>	clk 			   ,
 reset 		=>	reset 			   ,
 data_in 	=>	reg_file_data_in   ,
 sel_RD 	=>	sel_RD 			   ,
 WE   		=>	reg_file_WE   	   ,
 LDA  		=>	reg_file_LDA  	   ,
 LDB  		=>	reg_file_LDB  	   ,
 SelA_WE 	=>	reg_file_SelA_WE   ,
 SelB_WE 	=>	reg_file_SelB_WE   ,
 A_REG 		=>	A_REG 			   ,
 B_REG 		=>	B_REG 			   ,
 OUT_ADDR 	=>	reg_file_OUT_ADDR
 );
 
-- 3. PC Mux
PC_Mux_RISC : PC port map (
clk				=>	clk			 ,
reset			=>	reset		 ,
INTR_ADDR		=>	INTR_ADDR	 ,
JMP_ADDR		=>	JMP_ADDR	 ,
RET_ADDR        =>  D_DOUT       ,
PC_OP_SEL		=>	PC_OP_SEL	 ,
PC_out			=>	PC_out	
);

--4. Memory Controller
mem_ctrl_RISC : mem_ctrl port map(
 clk 		 =>  clk 	  ,
reset        =>  reset     ,
I_ADDR       =>  I_ADDR    ,
D_ADDR       =>  D_ADDR    ,
D_DOUT       =>  D_DOUT    ,
I_DOUT       =>  I_DOUT    ,
D_DIN        =>  D_DIN     ,
I_DIN        =>  I_DIN     ,
D_CS         =>  D_CS      ,
I_CS         =>  I_CS      ,
D_WE         =>  D_WE      ,
I_WE         =>  I_WE      ,
D_RE         =>  D_RE      ,
I_RE         =>  I_RE     
);

-- 5 . Status Register
STS_REG_RISC : status_reg port map(
clk 		=> 	  clk 	       ,
reset 		=>    reset 	   ,
ALU_EN      =>    ALU_OP_SEL(3),
REG_A		=>    A_REG	       ,
REG_B 		=>    B_REG 	   ,
INTR_DFF    =>    INTERRUPT_PUL, 
c_out 		=>    ALU_C_out	   ,
OV			=>    ALU_OV	   ,
Y			=>    ALU_Y		   ,
STATUS		=>    STS_REG	
);

--6. Muxes
MUXES_RISC :muxes port map(
ALU_Y            =>     ALU_Y                  ,
DMEM_DOUT        =>     D_DOUT                 ,
ALU_MEM_SEL      =>     ALU_MEM_SEL            ,
REG_DIN          =>     reg_file_data_in       ,
-----------------=>                            ,
A_REG            =>     A_REG                  ,
B_REG            =>     B_REG                  ,
PC               =>     PC_out                 ,
SEL_AB_PC        =>     STR_AB_PC_SEL          ,
DMEM_DIN         =>     DMEM_DIN_REGA_REGB_PC ,
-----------------=>                            ,
REG_FILE_OUTADDR =>     reg_file_OUT_ADDR      ,
DMEM_ADDR        =>     DMEM_ADDR_REGFILE_FF
);

--7. Control UNit
CONTROL_UNIT_RISC : control_unit port map(
clk				=>	clk			        ,
reset		    =>	reset		        ,
start           =>  CTRL_START          ,
OP_CODE	        =>	OP_CODE	            ,
STATUS_Z	    =>	STATUS_Z	        ,
INTERRUPT_OCCRD =>  INTERRUPT_PUL       ,
D_MEM_CS	    =>	D_CS_CONTROL_UNIT	,
D_MEM_RE	    =>	D_RE_CONTROL_UNIT	,
D_MEM_WE	    =>	D_WE_CONTROL_UNIT	,
ALU_OP_SEL	    =>	ALU_OP_SEL          ,
PC_OP_SEL	    =>	PC_OP_SEL	        ,
ALU_MEM_SEL     =>	ALU_MEM_SEL         ,
REG_WE		    =>	reg_file_WE		    ,
STR_AB_PC_SEL	=>	STR_AB_PC_SEL       ,
LDA		        =>	reg_file_LDA	    ,
LDB		        =>	reg_file_LDB	    ,
SEL_A_WE	    =>	reg_file_SelA_WE	,
SEL_B_WE	    =>	reg_file_SelB_WE	
);

lvl_2_pul_RISC : level_to_pulse port map(
clk             => clk,
reset           => reset,
level_inp       => INTERRUPT,
pul_out         => INTERRUPT_PUL
);

----------------------------------------------------------------
----------       TOP LEVEL LOGIC                            ----
----------------------------------------------------------------

OP_CODE  <= I_DOUT(7 downto 4);       -- To COntrol Unit
Sel_RD   <= I_DOUT(3 downto 0);       -- To Register File
JMP_ADDR <= reg_file_OUT_ADDR ;       -- To PC_Mux
--D_ADDR   <= reg_file_OUT_ADDR ;       -- To Data Memory Din
INTR_ADDR<= x"C0";  

                  -- ISR Accdress
I_ADDR       <= PC_OUT         when PRGM_MODE_SEL = '0' else
                I_MEM_ADDR;
I_CS         <= '1'            when PRGM_MODE_SEL = '0' else 
                I_MEM_CS;
I_RE         <= '1'            when PRGM_MODE_SEL = '0' else 
                I_MEM_RE;
I_WE         <= '0'            when PRGM_MODE_SEL = '0' else 
                I_MEM_WE;
I_DIN        <= (others=>'0')  when PRGM_MODE_SEL = '0' else 
                I_MEM_DIN ;
                
I_MEM_DOUT   <= I_DOUT;


-- Data Memory Related
D_ADDR       <= DMEM_ADDR_REGFILE_FF         when PRGM_MODE_SEL = '0' else 
                D_MEM_ADDR;
D_CS         <= D_CS_CONTROL_UNIT            when PRGM_MODE_SEL = '0' else 
                D_MEM_CS;
D_RE         <= D_RE_CONTROL_UNIT            when PRGM_MODE_SEL = '0' else  
                D_MEM_RE;
D_WE         <= D_WE_CONTROL_UNIT            when PRGM_MODE_SEL = '0' else  
                D_MEM_WE;
D_DIN        <= DMEM_DIN_REGA_REGB_PC        when PRGM_MODE_SEL = '0' else
                D_MEM_DIN ;
D_MEM_DOUT   <= D_DOUT;


CTRL_START <= not(PRGM_MODE_SEL); 

-- Map Zero and Interrupt flags
STATUS_Z <= STS_REG(4);
--INTERRUPT <= To be added;


end Behavioral;
