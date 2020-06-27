----------------------------------------------------------------------------------
-- File Name: muxes.vhd 
-- Author: Naveen Chander, Aditya Bhat  
-- 
-- Create Date: 25.05.2020 
-- Design Name: 
-- Module Name: muxes - Behavioral
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- Description:  Databus Router
-- 
----------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity muxes is
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
end muxes;

architecture Behavioral of muxes is

begin
REG_DIN    <= DMEM_DOUT when ALU_MEM_SEL = '0' else
              ALU_Y;

--SEL_AB_PC  =[SEL_AB][Sel_PC] 
DMEM_ADDR  <= REG_FILE_OUTADDR when SEL_AB_PC(0) ='0' else
              x"FF";                                             -- HardWired Address for storing the PC during Interrupt

DMEM_DIN   <= B_REG  when SEL_AB_PC = "10" else 
              A_REG when SEL_AB_PC = "00" else
              PC    ;

end Behavioral;
