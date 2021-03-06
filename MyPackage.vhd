LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE MY_PACKAGE IS
	---------------The Constants
	--Counters 
	CONSTANT MAIN_COUNTER_OUTPUT_SIZE :INTEGER := 3;
	CONSTANT INSTRUCTION_COUNTER_OUTPUT_SIZE : INTEGER := 3;
	--IR Size 
	CONSTANT IR_SIZE: INTEGER := 16;
	--ROM Width
	CONSTANT ROM_WIDTH: INTEGER := 28;
	--Address modes
	CONSTANT REG_ADDRESSING_MODE : INTEGER := 0;
	CONSTANT AUTO_INCR_ADDRESSING_MODE : INTEGER := 1;
	CONSTANT AUTO_DECR_ADDRESSING_MODE : INTEGER := 2;
	CONSTANT INDEXED_ADDRESSING_MODE : INTEGER := 3;
	--CLK period
	CONSTANT HALF_CYCLE : TIME := 50 PS;
	--MODE CONSTANTS
	CONSTANT MODE_BITS_NUM: integer := 3;
	CONSTANT NO_INSTRUCTION:STD_LOGIC_VECTOR (MODE_BITS_NUM-1 DOWNTO 0):="000";
	CONSTANT TWO_OPERAND:STD_LOGIC_VECTOR (MODE_BITS_NUM-1 DOWNTO 0):="001";
	CONSTANT ONE_OPERAND:STD_LOGIC_VECTOR (MODE_BITS_NUM-1 DOWNTO 0):="010";
	CONSTANT ZERO_OPERAND:STD_LOGIC_VECTOR (MODE_BITS_NUM-1 DOWNTO 0):="011";
	CONSTANT BRANCH:STD_LOGIC_VECTOR (MODE_BITS_NUM-1 DOWNTO 0):="100";
	CONSTANT COMPAIR:STD_LOGIC_VECTOR (MODE_BITS_NUM-1 DOWNTO 0):="101";
	

	CONSTANT REGISTER_STATES_ON_BUS : INTEGER :=12;
	CONSTANT RAM_SIZE		: INTEGER :=11;
	CONSTANT RAM_INDX		: INTEGER :=2047;	--THIS CONSTATNT IS NOT USED , IF YOU WANT TO CHANGE IT GO TO (RAM.VHD) AND CHANGE IT MANUALLY PLEASE
	

	----------------------------------OPCODES FOR EXECUTE_BLOCK-------------------------------
	--BRANCH_OPPERATIONS
--	CONSTANT NO_JUMP	: INTEGER := 0;
--	CONSTANT JUMP		: INTEGER := 1;
	CONSTANT BRANCH_MODE_IR_OPCODE	:INTEGER :=8;
	CONSTANT BR	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"81";
	CONSTANT BNE	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"82";
	CONSTANT BEQ	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"83";
	CONSTANT BLO	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"84";
	CONSTANT BLS	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"85";
	CONSTANT BH	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"86";
	CONSTANT BHS	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"87";
	CONSTANT BGE	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"88";
	CONSTANT BGT	:STD_LOGIC_VECTOR (BRANCH_MODE_IR_OPCODE-1 DOWNTO 0):=X"89";

	--TWO_OPPERAND_OPERATIONS
	CONSTANT TWO_OPP_OPCODE_SIZE 	: INTEGER :=4;
	CONSTANT MOV	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"1";
	CONSTANT ADD	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"2";
	CONSTANT ADC	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"3";
	CONSTANT SUBB	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"4";
	CONSTANT SBC	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"5";
	CONSTANT BIC	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"6";

	CONSTANT BIS	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"9";
	CONSTANT XORR	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"A";
	CONSTANT ORR	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"B";
	CONSTANT ANDD	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"C";
	CONSTANT COMP	:STD_LOGIC_VECTOR (TWO_OPP_OPCODE_SIZE-1 DOWNTO 0):=X"D";


	--ONE_OPPERAND_OPERATIONS
	CONSTANT ONE_OPP_OPCODE_SIZE 	: INTEGER :=10;
	CONSTANT INC	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"01";
	CONSTANT DEC	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"02";
	CONSTANT CLR	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"03";
	CONSTANT INV	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"04";
	CONSTANT LSR	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"05";
	CONSTANT RORR	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"06";
	CONSTANT RRC	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"07";
	CONSTANT ASR	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"08";
	CONSTANT LSL	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"09";
	CONSTANT ROLL	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"0A";
	CONSTANT RLC	:STD_LOGIC_VECTOR (ONE_OPP_OPCODE_SIZE-1 DOWNTO 0):="00"&X"0B";

	

	----------------------ALU OPERATIONS---------------------------------
	CONSTANT ALU_SEL_SIZE :INTEGER :=5;
	CONSTANT NO_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"0";
	CONSTANT ADD_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"1";
	CONSTANT ADC_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"2";
	CONSTANT SUB_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"3";
	CONSTANT SBC_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"4";
	CONSTANT MOV_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"5";
	CONSTANT BIC_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"6";
	CONSTANT BIS_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"7";
	CONSTANT AND_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"8";
	CONSTANT OR_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"9";
	CONSTANT XOR_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"A";
	CONSTANT INV_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"B";
	CONSTANT INC1_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"C";
	CONSTANT INC2_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"D";
	CONSTANT DEC1_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"E";
	CONSTANT DEC2_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):='0'&X"F";
	CONSTANT CLR_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):="10000";
	CONSTANT LSR_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):="10001";
	CONSTANT ROR_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):="10010";
	CONSTANT RRC_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):="10011";
	CONSTANT ASR_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):="10100";
	CONSTANT LSL_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):="10101";
	CONSTANT ROL_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):="10110";
	CONSTANT RLC_OP	:STD_LOGIC_VECTOR (ALU_SEL_SIZE-1 DOWNTO 0):="10111";

END MY_PACKAGE;



-----------------------------------------------------------------------------------
------------------------------------Table 1----------------------------------------

-----------------------------------------
--  CODE	|	Register				|
-----------------------------------------
--	0000	|	NO Register is selected	|
--	0001	|	R0						|
--	0010	|	R1						|
--	0011	|	R2						|
--	0100	|	R3						|
--	0101	|	R4						|
--	0110	|	R5						|
--	0111	|	R6						|
--	1000	|	R7						|
--	1001	|	MAR						|
--	1010	|	MDR						|
--	1011	|	IR 						|
--	1100	|	SRC						|
--	1111	|	PLACE HOLDER (used only by the CU)
-----------------------------------------


-----------------------------------------------------------------------------------
------------------------------------Table 2----------------------------------------

-----------------------------------------
--  CODE	|	Register				|
-----------------------------------------
--	00		|	NO Register is selected	|
--	01		|	MAR						|
--	10		|	MDR						|
--	11		|	SRC						|
-----------------------------------------




