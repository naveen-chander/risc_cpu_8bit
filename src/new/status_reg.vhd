----------------------------------------------------------------------------------
-- File Name: mem_ctrl.vhd 
-- Author: Naveen Chander, Aditya Bhat  
-- 
-- Create Date: 25.05.2020 
-- Design Name: 
-- Module Name: status_reg - Behavioral
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- Description:  Status Register . Only Zero Flag is readable
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity status_reg is
port ( clk : in STD_LOGIC ;
       reset : in STD_LOGIC;
       ALU_EN : in std_logic;
       REG_A, REG_B : in STD_LOGIC_VECTOR (7 downto 0);       -- To check GEL
       c_out : in STD_LOGIC;                            -- CARRY
       OV: in STD_LOGIC;
       Y : in STD_LOGIC_VECTOR (7 downto 0);          -- FOR OVERFLOW
       INTR_DFF : in STD_LOGIC;                         -- INTERRUPT FLAG
       STATUS : out STD_LOGIC_VECTOR (7 downto 0));   -- STATUS REGISTER
end entity;

-- STATUS fields G E L Z OV C INTR X ;
-- GEL if A (GEL) B;
architecture arch_status_reg of status_reg is

signal STATUS_sig: STD_LOGIC_VECTOR (7 downto 0);

begin




process(clk, reset)
begin
    if (reset = '1') then
        STATUS <= (others => '0');
    elsif(falling_edge(clk)) then
        if (ALU_EN = '1') then
        -----------------------------------------------------
        -- G Field
            if(signed(REG_A) > signed(REG_B)) then
                STATUS(7) <= '1';
            else
                STATUS(7) <= '1';
            end if;
        -----------------------------------------------------
        -- E field
        if (REG_A = REG_B) then
            STATUS(6) <= '1';
        else
            STATUS(6) <= '0';
        end if;
        -----------------------------------------------------
        -- L field   
        if (signed(REG_A) > signed(REG_B)) then          
            STATUS(5) <= '1';
        else
            STATUS(5) <= '0';
        end if;
        -----------------------------------------------------
        -- Z field   
        if(Y = x"00") then      
            STATUS(4) <= '1';
        else
            STATUS(4) <= '0';
        end if;
        -----------------------------------------------------
        --OV Field
        STATUS(3) <= OV; --check validity
        -----------------------------------------------------
        --Carry
        STATUS(2) <= c_out;
        -----------------------------------------------------
        -- INTR
        STATUS(1) <= INTR_DFF;
        -----------------------------------------------------
        -- X
        STATUS(0) <= '0'; 
        end if;
    end if;
end process;

end arch_status_reg;
  
    

