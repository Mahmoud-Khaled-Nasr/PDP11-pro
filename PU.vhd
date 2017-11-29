LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.MY_PACKAGE.ALL;

--The control word format is 
-- The size is ROM WIDTH = 28 signals
	-- 27 CW 23 => ALU operation
	-- 22 CW 19 => B bus outputs, see table 1 in MY_PACKAGE
	-- 18 CW 15 => A bus outputs, see table 1 in MY_PACKAGE
	-- 14 CW 11 => B bus inputs, see table 1 in MY_PACKAGE
	-- 10 CW 6 => Z bus inputs 
		-- 10 CW 9 => transperent registers, see table 2 in MY_PACKAGE
		-- 8 CW 6 => R0 to R7, see table 1 in MY_PACKAGE
	--CW 5 => WMFC
	--CW 4 => READ
	--CW 3 => 16/32 Memory Reading mode
	--CW 2 => WRITE
	--CW 1 => RESET
	--C@ 0 => RESET IR, used by the CU after completing an instruction to reset the IR if needed
	
ENTITY PU IS
	GENERIC (REGISTER_SIZE : INTEGER := 32);
	PORT (
		CONTROL_WORD :IN STD_LOGIC_VECTOR (ROM_WIDTH -1 DOWNTO 0)
	);
END ENTITY PU;

ARCHITECTURE PROCESSING_UNIT OF PU IS
	SIGNAL CONTROL_CLK, PROCESSING_CLK : STD_LOGIC := '1';
BEGIN
	----------------------------------------------------------------------------------------
	----------------------------------CLK Generation----------------------------------------
	PROCESS 
	BEGIN 
		CONTROL_CLK <= '1';
		WAIT FOR HALF_CYCLE / 2;
		PROCESSING_CLK <= '1';
		WAIT FOR HALF_CYCLE / 2;
		CONTROL_CLK <= '0';
		WAIT FOR HALF_CYCLE / 2;
		PROCESSING_CLK <= '0';
		WAIT FOR HALF_CYCLE / 2;
	END PROCESS;
	
	----------------------------------------------------------------------------------------
	
	
END PROCESSING_UNIT;



