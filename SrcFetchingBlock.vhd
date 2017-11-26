LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.MY_PACKAGE.ALL;

ENTITY SRC_FETCHING_BLOCK IS
	--YOU CAN ADD ANY SIGNAL YOU WANT FOR EXAMPLE THE MODE OR OTHER SIGNALS
	PORT (
		IR : IN std_logic_vector (IR_SIZE-1 DOWNTO 0);
		INSTRUCTION_COUNTER : IN STD_LOGIC_VECTOR (INSTRUCTION_COUNTER_OUTPUT_SIZE-1 DOWNTO 0); 
		CONTROL_WORD: OUT STD_LOGIC_VECTOR (ROM_WIDTH-1 DOWNTO 0);
		INITIAL_ADDRESS: OUT STD_LOGIC_VECTOR (INSTRUCTION_COUNTER_OUTPUT_SIZE-1 DOWNTO 0) );
END ENTITY SRC_FETCHING_BLOCK;

ARCHITECTURE FETCH_SOURCE OF SRC_FETCHING_BLOCK IS
	-----------------Signals---------
	SIGNAL ROM_OUTPUT : STD_LOGIC_VECTOR(ROM_WIDTH-1 DOWNTO 0);
	SIGNAL IR_SRC : STD_LOGIC_VECTOR(3 DOWNTO 0);
	-----------------ROM------------
	CONSTANT ROM_LENGTH : INTEGER := 7; --LENGTH OF THE ROM USED IN THIS BLOCK
	TYPE ROM_TYPE IS ARRAY(0 TO ROM_LENGTH - 1) OF std_logic_vector(ROM_WIDTH-1 DOWNTO 0);
	CONSTANT ROM_DATA : ROM_TYPE := 
	(
		0 => B"01101_1111_0000_1001_1111_00_10100",
		1 => B"00000_1010_0000_1100_0000_00_00010",
		2 => B"01111_1111_0000_0000_1111_01_10100",
		3 => B"00000_1010_0000_1100_0000_00_00010",
		4 => B"01100_1000_0000_1001_1000_00_10000",
		5 => B"00001_1010_1111_0000_0000_01_10100",
		6 => B"00000_1010_0000_1100_0000_00_00010"
	);
	BEGIN
	-------------------------Circuit that calculate the initial value
	INITIAL_ADDRESS <= "000" WHEN IR(11 DOWNTO 9) = AUTO_INCR_ADDRESSING_MODE 
		ELSE "010" WHEN IR(11 DOWNTO 9) = AUTO_DECR_ADDRESSING_MODE
		ELSE "100" WHEN IR(11 DOWNTO 9) = INDEXED_ADDRESSING_MODE;
	-------------------------the ROM process---------------
	ROM_OUTPUT <= ROM_DATA(to_integer(unsigned(INSTRUCTION_COUNTER)));
	CONTROL_WORD <= ROM_OUTPUT;
	-------------------------Place Holder circuits
	IR_SRC <= '0'&IR (2 DOWNTO 0);
	
	CONTROL_WORD(22 DOWNTO 19) <= STD_LOGIC_VECTOR(UNSIGNED (IR_SRC) + 1) WHEN ROM_OUTPUT(22 DOWNTO 19) = "1111"
		ELSE ROM_OUTPUT(22 DOWNTO 19) WHEN NOT (ROM_OUTPUT(22 DOWNTO 19) = "1111");
	
	CONTROL_WORD(18 DOWNTO 15) <= STD_LOGIC_VECTOR(UNSIGNED (IR_SRC) + 1) WHEN ROM_OUTPUT(18 DOWNTO 15) = "1111"
		ELSE ROM_OUTPUT(18 DOWNTO 15) WHEN NOT (ROM_OUTPUT(18 DOWNTO 15) = "1111");
	
	CONTROL_WORD(10 DOWNTO 7) <= STD_LOGIC_VECTOR(UNSIGNED (IR_SRC) + 1) WHEN ROM_OUTPUT(10 DOWNTO 7) = "1111"
		ELSE ROM_OUTPUT(10 DOWNTO 7) WHEN NOT (ROM_OUTPUT(10 DOWNTO 7) = "1111");
	
END FETCH_SOURCE;
