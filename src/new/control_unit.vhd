----------------------------------------------------------------------------------
-- File Name: control_unit.vhd 
-- Author: Naveen Chander, Aditya Bhat  
-- 
-- Create Date: 25.05.2020 
-- Design Name: 
-- Module Name: control_unit - Behavioral
-- Target Devices: xc7a35t
-- Tool Versions: vivado 2018.2
-- Description:  Control FSM + Interrupt FSM + Instruction Decoding + Giving right control signals
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_ARITH.all;


entity control_unit is 
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
end entity;


architecture arch_CU of control_unit is

type statetype is (T0, T1, T2, T3, T4,T_INT_0, T_INT_1,T_INT_2,T_INT_3,T_INT_4,T_INT_5,T_INT_6);
signal pr_state, nx_state: statetype;
signal zero_check: std_logic; 
signal LD_ST_PC_SEL : std_logic;

begin
-- ALU_MEM_SEl : Let ALU _data be selected by default
--ALU_MEM_SEL  <= (not(OP_CODE(3)) and OP_CODE(2) and OP_CODE(1) and not(OP_CODE(0))) or 
                --(not(OP_CODE(3)) and OP_CODE(2) and OP_CODE(1)and OP_CODE(0));  -- '1' when OP_CODE= X"6" or X"7"

ALU_MEM_SEL <= '0' when (OP_CODE = "0110" OR OP_CODE ="0111") else '1';
STR_AB_PC_SEL  <= (OP_CODE(3) and not(OP_CODE(2)) and not(OP_CODE(1)) and OP_CODE(0)) & LD_ST_PC_SEL ; --'1' when OP_CODE =X"9" default at A

LDA        <= '1' when OP_CODE = "0110" else '0';
LDB        <= '1' when OP_CODE = "0111" else '0';
zero_check <= STATUS_Z and OP_CODE(3) and OP_CODE(2) and not(OP_CODE(1)) and OP_CODE(0);


process (pr_state,start)                 -- Mealy Machine wrt Start only
begin  
    case pr_state is
        when T0 =>
        D_MEM_CS 		<= '0'; 
		D_MEM_RE 		<= '0';    -- Deassert D-Mem
        D_MEM_WE 		<= '0';     
        REG_WE 			<= '0';    -- Disable
        ALU_OP_SEL 		<= "0000"; -- Disable
        PC_OP_SEL		<= "000";  -- PC=PC Hold PC value
        SEL_A_WE 		<= '0';
        SEL_B_WE 		<= '0';
		LD_ST_PC_SEL 	<= '0';    -- Only Enabled when INTERRUPT_OCCRD
        if (start = '1') then
            nx_state <= T1;
         else
            nx_state <= T0;
         end if;
         
         
    -- When not in use make all signals '0'
        when T1 =>            -- Common For all instructions
            D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
            D_MEM_WE 		<= '0';     -- No D_MemWrite
            REG_WE 			<= '0';     -- No RegFileWrite
            ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
            PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
            SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
            SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
            nx_state 		<= T2;      -- NextState
            
        when T2 => 
            case OP_CODE is
				---------------------------ADD-----------------------------
                when X"0"  =>					-- ADD
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '1';     -- RegFileWrite
				    ALU_OP_SEL 		<= "1000";  -- ALU_ADD 
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState
				------------------------SUB------------------------------
                when X"1" =>					-- SUBTRACT
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '1';     -- RegFileWrite
				    ALU_OP_SEL 		<= "1001";  -- ALU_ADD 
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState
				------------------------INCR------------------------------
                when X"2" =>					-- INCR
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '1';     -- RegFileWrite
				    ALU_OP_SEL 		<= "1010";  -- INCR 
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState				
				------------------------DECR------------------------------
                when X"3" =>					-- DECR
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '1';     -- RegFileWrite
				    ALU_OP_SEL 		<= "1011";  -- DECR 
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState				
				------------------------XOR------------------------------
                when X"4" =>					-- XOR
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '1';     -- RegFileWrite
				    ALU_OP_SEL 		<= "1100";  -- XOR 
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState
				------------------------XNOR------------------------------
                when X"5" =>					-- XNOR
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '1';     -- RegFileWrite
				    ALU_OP_SEL 		<= "1101";  -- XNOR 
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState
                    nx_state <= T3;
				------------------------LDA------------------------------
                when X"6" =>					-- LDA
					D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
				    D_MEM_RE 		<= '1'; 	-- D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- No RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected  
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState
				------------------------LDB------------------------------
                when X"7" =>					-- LDB (Same as LDA)
					D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
				    D_MEM_RE 		<= '1'; 	-- D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- No RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected  
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState
				------------------------STA------------------------------
                when X"8" =>					-- STA 
					D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '1';     -- D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected  
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState					
				------------------------STB------------------------------
                when X"9" =>					-- STA 
					D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '1';     -- D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected 
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T3;      -- NextState	
				------------------------SELA------------------------------
                when X"A" =>					-- SELA
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected 
				    PC_OP_SEL 		<= "001";   -- PC+1
				    SEL_A_WE 		<= '1';		-- Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
					if (INTERRUPT_OCCRD ='1') then
						nx_state <= T_INT_0;
					else
						nx_state <= T0;
					end if;		
				------------------------SELB------------------------------
                when X"B" =>					-- SELB
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected 
				    PC_OP_SEL 		<= "001";   -- PC+1
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '1';     -- Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
					if (INTERRUPT_OCCRD ='1') then
						nx_state <= T_INT_0;
					else
						nx_state <= T0;
					end if;	
				------------------------JMP------------------------------
                when X"C" =>					-- JMP
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected 
				    PC_OP_SEL 		<= "010";   -- JMP_ADDR
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
					if (INTERRUPT_OCCRD ='1') then
						nx_state <= T_INT_0;
					else
						nx_state <= T0;
					end if;	
				------------------------JZ------------------------------
                when X"D" =>					-- JZ
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected 
				    PC_OP_SEL 		<= '0' & zero_check & not(zero_check);  -- COND_JMP_ADDR
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
					if (INTERRUPT_OCCRD ='1') then
						nx_state <= T_INT_0;
					else
						nx_state <= T0;
					end if;	
				------------------------RET------------------------------
                when X"E" =>					-- RET
					D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
				    D_MEM_RE 		<= '1'; 	-- D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected 
				    PC_OP_SEL 		<= "000";   -- Same PC
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '1';     -- Load the Stored PC from Stack into PC 
												-- Emit DMEM Addr as Ff to fetch Return PC
					nx_state     <= T3  ;
				------------------------DEFAULT----------------------------
                when others =>
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
					D_MEM_RE 		<= '0'; 	-- No D_MemRead
					D_MEM_WE 		<= '0';     -- No D_MemWrite
					REG_WE 			<= '0';     -- No RegFileWrite
					ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
					PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
					SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
					SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
					LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
					nx_state 		<= T0 ;      -- NextState
					-----------------------------------------------------------
            end case;
			------------------------------------------------------------------------
       when T3 => 
            case OP_CODE is
				---------------------------ADD-----------------------------
                when x"0" | x"1" | x"2" | x"3" | x"4" | x"5"  =>					-- ADD
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- No RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- ALU_ADD 
				    PC_OP_SEL 		<= "001";   -- PC+1
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    if (INTERRUPT_OCCRD ='1') then
					   nx_state <= T_INT_0;
				    else
					   nx_state <= T0;
				    END IF;
				------------------------LDA------------------------------
                when X"6" | x"7"=>					-- LDA
					D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
				    D_MEM_RE 		<= '1'; 	-- D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '1';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected  
				    PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    nx_state 		<= T4;      -- NextState
				------------------------STA------------------------------
                when x"8" | x"9" =>					-- STA 
					D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
				    D_MEM_RE 		<= '0'; 	-- No D_MemRead
				    D_MEM_WE 		<= '1';     -- D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected  
				    PC_OP_SEL 		<= "001";   -- PC+1
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
				    if (INTERRUPT_OCCRD ='1') then
                        nx_state <= T_INT_0;
                    else
                        nx_state <= T0;
                    end if;				
				------------------------RET------------------------------
                when X"E" =>					-- RET
					D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
				    D_MEM_RE 		<= '1'; 	-- D_MemRead
				    D_MEM_WE 		<= '0';     -- No D_MemWrite
				    REG_WE 			<= '0';     -- RegFileWrite
				    ALU_OP_SEL 		<= "0000";  -- No ALU_OP Selected 
				    PC_OP_SEL 		<= "111" ;  -- RET ADDR
				    SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
				    SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
				    LD_ST_PC_SEL 	<= '1';     -- Load the Stored PC from Stack into PC 
												-- Emit DMEM Addr as Ff to fetch Return PC
					if (INTERRUPT_OCCRD ='1') then
						nx_state <= T_INT_0;
					else
						nx_state <= T0;
					end if;
				------------------------DEFAULT----------------------------
                when others =>
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
					D_MEM_RE 		<= '0'; 	-- No D_MemRead
					D_MEM_WE 		<= '0';     -- No D_MemWrite
					REG_WE 			<= '0';     -- No RegFileWrite
					ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
					PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
					SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
					SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
					LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
					nx_state 		<= T0 ;      -- NextState
					-----------------------------------------------------------
            end case;
			------------------------------------------------------------------------	   
	 
        when T4 =>           -- Only for LDA and LDB inst
			------------------------LDA-LDB----------------------------
			case(OP_CODE) is
				when x"6" | x"7" =>
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
					D_MEM_RE 		<= '0'; 	-- No D_MemRead
					D_MEM_WE 		<= '0';     -- No D_MemWrite
					REG_WE 			<= '0';     -- No RegFileWrite
					ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
					PC_OP_SEL 		<= "001";   -- PC+1
					SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
					SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
					LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
					if (INTERRUPT_OCCRD ='1') then
						nx_state <= T_INT_0;
					else
						nx_state <= T0;
					END IF;
					------------------------DEFAULT----------------------------
				when others =>
					D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
					D_MEM_RE 		<= '0'; 	-- No D_MemRead
					D_MEM_WE 		<= '0';     -- No D_MemWrite
					REG_WE 			<= '0';     -- No RegFileWrite
					ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
					PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
					SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
					SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
					LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCRD
					nx_state 		<= T0 ;      -- NextState
					-----------------------------------------------------------
            end case;			
		-------------------------------------------------------------------
		--   INTERRUPT FSM  STATES 
		--   T_INT_0    , T_INT_1 , T_INT_2   
		--	
		when T_INT_0  =>
		-- Allow PC to get registered to its next proper value => PC+1 or JMP_PC
		-- At the rising edge of clock at this state, PC <--updated_PC
			D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
			D_MEM_WE 		<= '0';     -- No D_MemWrite
			REG_WE 			<= '0';     -- No RegFileWrite
			ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
			PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
			SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
			SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCR
			nx_state  		<= T_INT_1;
		-----------------------------------------------------------	
		when T_INT_1   =>
			-- Save PC to Location x"C0"(hardwired address)
			-- issue mux select lines for this
			-- Updated PC is ready to be stored
			D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
			D_MEM_WE 		<= '1';     -- D_MemWrite
			REG_WE 			<= '0';     -- No RegFileWrite
			ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
			PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
			SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
			SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '1';     -- Only Enabled when INTERRUPT_OCCR
			nx_state  		<= T_INT_2;			
										-- Only Enabled when INTERRUPT_OCCRD
										-- Enables storing Updated PC in DataMem
										-- Program can resume execution from here.
		-----------------------No CHange----------------------------	
		when T_INT_2   =>  -- No Change
			D_MEM_CS  		<= '1'; 	-- D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
			D_MEM_WE 		<= '1';     -- D_MemWrite
			REG_WE 			<= '0';     -- No RegFileWrite
			ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
			PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
			SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
			SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '1';     -- Only Enabled when INTERRUPT_OCCR
			nx_state  		<= T_INT_3;			
										-- Only Enabled when INTERRUPT_OCCRD
										-- Enables storing Updated PC in DataMem
										-- Program can resume execution
		-----------------------------------------------------------	
		when T_INT_3  =>
			-- Change the PC value to ISR and enable execution from there
			-- Save PC to Location x"C0"(hardwired address)
			-- issue mux select lines for this
			-- Updated PC is ready to be stored
			D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
			D_MEM_WE 		<= '0';     -- No D_MemWrite
			REG_WE 			<= '0';     -- No RegFileWrite
			ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
			PC_OP_SEL 		<= "000";   -- PC_to_hold_current_Value
			SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
			SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCR
			nx_state  		<= T_INT_4;			
										-- Only Enabled when INTERRUPT_OCCRD
										-- Enables storing Updated PC in DataMem
										-- Program can resume execution
		-----------------------------------------------------------	
		when T_INT_4   =>
			D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
			D_MEM_WE 		<= '0';     -- No D_MemWrite
			REG_WE 			<= '0';     -- No RegFileWrite
			ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
			PC_OP_SEL 		<= "011";   -- PC <-- ISR
			SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
			SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCR
			nx_state  		<= T_INT_5;			
										-- Only Enabled when INTERRUPT_OCCRD
										-- Enables storing Updated PC in DataMem
										-- Program can resume execution
		------------------NO CHANGE-----------------------------	
		when T_INT_5   =>
			-- PC would have latched ISR address
			-- just wait for one clock
			D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
			D_MEM_WE 		<= '0';     -- No D_MemWrite
			REG_WE 			<= '0';     -- No RegFileWrite
			ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
			PC_OP_SEL 		<= "011";   -- PC <-- ISR
			SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
			SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCR
			nx_state  		<= T_INT_6;			
										-- Only Enabled when INTERRUPT_OCCRD
										-- Enables storing Updated PC in DataMem
										-- Program can resume execution
		-------Wait for One more cycle and GOTO T0-----------------------------
		when T_INT_6   =>
			D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
			D_MEM_WE 		<= '0';     -- No D_MemWrite
			REG_WE 			<= '0';     -- No RegFileWrite
			ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
			PC_OP_SEL 		<= "011";   -- PC <-- ISR
			SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
			SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCR
			nx_state  		<= T0;			
										-- Only Enabled when INTERRUPT_OCCRD
										-- Enables storing Updated PC in DataMem
										-- Program can resume execut
		----------------------------------------------------------------------
        when others => 
			D_MEM_CS  		<= '0'; 	-- No D_Mem_ChipSelect
			D_MEM_RE 		<= '0'; 	-- No D_MemRead
			D_MEM_WE 		<= '0';     -- No D_MemWrite
			REG_WE 			<= '0';     -- No RegFileWrite
			ALU_OP_SEL 		<= "0000";  -- No ALU_Ops 
			PC_OP_SEL 		<= "000";   -- PC <-- ISR
			SEL_A_WE 		<= '0';		-- No Writing SelA_reg in RegFile
			SEL_B_WE 		<= '0';     -- No Writing SelB_reg in RegFile
			LD_ST_PC_SEL 	<= '0';     -- Only Enabled when INTERRUPT_OCCR
			nx_state  		<= T0;	
       ----------------------------------------------------------------------
	   end case; 
end process;
----------------------------------------------------------------------
----------------------FSM PRESENT STATE LOGIC-------------------------------
----------------------------------------------------------------------
process(clk, reset)
    begin
    if(reset = '1') then
        pr_state <= T0;
    elsif(rising_edge(clk)) then
            pr_state <= nx_state;
    end if;
end process;

end architecture;

    