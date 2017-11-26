LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE MY_PACKAGE IS
	---------------The Constants
	--Counters 
	CONSTANT MAIN_COUNTER_OUTPUT_SIZE :INTEGER := 4;
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
	
END MY_PACKAGE;
