LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.MY_PACKAGE.ALL;

ENTITY CU IS
	GENERIC (MODE_BITS_NUM: integer := 3);
	PORT( --CONTROL_CLK :IN std_logic;
		IR : IN std_logic_vector (IR_SIZE-1 DOWNTO 0);
		FLAG_REGISTER : IN std_logic_vector (3 DOWNTO 0));
END ENTITY CU;

ARCHITECTURE CONTROL_UNIT OF CU IS
	COMPONENT NBIT_COUNTER_WITH_INCREMENT IS
	GENERIC (N: integer := 4 );
	PORT(
		CLK, RST, ENABLE : IN std_logic;
		INCREMENT : IN std_logic_vector (1 DOWNTO 0);
		DATA_OUT : OUT std_logic_vector(N-1 DOWNTO 0));
	END COMPONENT NBIT_COUNTER_WITH_INCREMENT;
	
	COMPONENT NBIT_COUNTER_WITH_INITIAL_VALUE IS
	GENERIC (N: integer := 4 );
	PORT(
		CLK, ENABLE : IN std_logic;
		DATA_IN : IN std_logic_vector(N-1 DOWNTO 0);
		DATA_OUT : OUT std_logic_vector(N-1 DOWNTO 0));
	END COMPONENT NBIT_COUNTER_WITH_INITIAL_VALUE;
	
	COMPONENT SRC_FETCHING_BLOCK IS
	PORT (
		IR : IN std_logic_vector (IR_SIZE-1 DOWNTO 0);
		INSTRUCTION_COUNTER : IN STD_LOGIC_VECTOR (INSTRUCTION_COUNTER_OUTPUT_SIZE-1 DOWNTO 0); 
		CONTROL_WORD: OUT STD_LOGIC_VECTOR (ROM_WIDTH-1 DOWNTO 0);
		INITIAL_ADDRESS: OUT STD_LOGIC_VECTOR (INSTRUCTION_COUNTER_OUTPUT_SIZE-1 DOWNTO 0) );
	END COMPONENT SRC_FETCHING_BLOCK;
	
	SIGNAL CONTROL_CLK : std_logic;
	--TODO set NEW_INSTRUCTION bit at the end of every instruction and clear it at the start of every instruction TO RESET THE CIRCUIT
	SIGNAL NEW_INSTRUCTION : std_logic := '0'; 
	SIGNAL ENABLE_MAIN_COUNTER : std_logic := '1';
	SIGNAL ENABLE_INSTRUCTION_COUNTER : std_logic := '0';
	SIGNAL INITIAL_ADDRESS : std_logic_vector(INSTRUCTION_COUNTER_OUTPUT_SIZE-1 DOWNTO 0) := "000";
	SIGNAL MODE : std_logic_vector(MODE_BITS_NUM-1 DOWNTO 0);
	SIGNAL MAIN_COUNTER_OUTPUT, INSTRUCTION_COUNTER_OUTPUT: std_logic_vector (INSTRUCTION_COUNTER_OUTPUT_SIZE-1 DOWNTO 0);
	SIGNAL MAIN_COUNTER_INCREMENT : std_logic_vector (1 DOWNTO 0);
	SIGNAL ROM_BLOCKS_OUTPUT : STD_LOGIC_VECTOR (ROM_WIDTH-1 DOWNTO 0);
	BEGIN
	-------------------------------Port Mapping-----------------------------------------------
	------------------------------------------------------------------------------------------
	--Counters
	MAIN_COUNTER: NBIT_COUNTER_WITH_INCREMENT 
		GENERIC MAP (N => MAIN_COUNTER_OUTPUT_SIZE) 
		PORT MAP ( CLK => CONTROL_CLK , RST => NEW_INSTRUCTION, ENABLE => ENABLE_MAIN_COUNTER
			, INCREMENT => MAIN_COUNTER_INCREMENT, DATA_OUT => MAIN_COUNTER_OUTPUT  );
	INSTRUCTION_COUNTER: NBIT_COUNTER_WITH_INITIAL_VALUE 
		GENERIC MAP (N => INSTRUCTION_COUNTER_OUTPUT_SIZE) 
		PORT MAP ( CLK => CONTROL_CLK , ENABLE => ENABLE_INSTRUCTION_COUNTER
			, DATA_IN => INITIAL_ADDRESS, DATA_OUT => INSTRUCTION_COUNTER_OUTPUT );
	
	--ROMs Blocks
	SRC_FETCH: SRC_FETCHING_BLOCK PORT MAP (IR => IR, INSTRUCTION_COUNTER => INSTRUCTION_COUNTER_OUTPUT
		, CONTROL_WORD => ROM_BLOCKS_OUTPUT, INITIAL_ADDRESS => INITIAL_ADDRESS);
	-------------------------------Creating the control clk-----------------------------------
	------------------------------------------------------------------------------------------
	PROCESS
	BEGIN
		CONTROL_CLK <= '0';
		WAIT FOR HALF_CYCLE;
		CONTROL_CLK <= '1';
		WAIT FOR HALF_CYCLE;
	END PROCESS;
	
	------------------------------------------------------------------------------------------	
	----------------------------------Logic---------------------------------------------------
	------------------------------------------------------------------------------------------
	
	----------------------------------Counters Enable Circuit----------------------------------
	--TODO 
	-- * ENABLE_MAIN_COUNTER after the operation finishes finishes by a CIRCUIT that GETs THE LAST BIT IN THE ROM CONTROL WORD AT NEGATIVE EDGE OF THE CONTROL CLK 
	-- * RESET THE MAIN COUNTERS AFTER THE INSTRUCTION FINISHES by the end instruction
	-- The enable of the main counter is cleared after every count to allow the operation to be completed to work
	PROCESS (MAIN_COUNTER_OUTPUT)
	BEGIN
		ENABLE_MAIN_COUNTER <= '0';
	END PROCESS;
	-- The enable of the instruction counter changes depending on the main counter 
	PROCESS (ENABLE_MAIN_COUNTER)
	BEGIN
		ENABLE_INSTRUCTION_COUNTER <= NOT ENABLE_MAIN_COUNTER;
	END PROCESS;
	
	------------------------------------------------------------------------------------------
	-------------------------------Decode the IR for the MODE----------------------------
	-- Mode = 0 the IR wasn't fetched yet
	--		= 1 2 operands
	--		= 2 1 operands
	--		= 3 zero operand
	--		= 4 branch
	MODE <= "001" WHEN NOT (IR(IR_SIZE-1 DOWNTO 12) = X"0" OR IR(IR_SIZE-1 DOWNTO 12) = X"7" 
				OR IR(IR_SIZE-1 DOWNTO 12) = X"8" OR IR(IR_SIZE-1 DOWNTO 12) = X"F" )
		ELSE "010" WHEN IR(IR_SIZE-1 DOWNTO 12) = X"0" AND NOT (IR(11 DOWNTO 8) = X"0")
		ELSE "011" WHEN IR(IR_SIZE-1 DOWNTO 8) = X"0" AND NOT (IR(7 DOWNTO 0) = X"01")
		ELSE "100" WHEN IR(IR_SIZE-1 DOWNTO 12) = X"8"
		ELSE "000" WHEN IR = X"0001";
	
	-------------------------------------------------------------------------------------------
	-------------------Operations sequence for different MODES---------------------------------
	--This circuit is to calculate the operations to skip depending on the MODE and the addressing
	--mode in case of two operand operations
	PROCESS (MAIN_COUNTER_OUTPUT, MODE)
	VARIABLE RESULT : std_logic_vector (1 DOWNTO 0);
	BEGIN
		IF (MODE = X"1") THEN
			IF (MAIN_COUNTER_OUTPUT = X"0" AND IR(11 DOWNTO 9)= REG_ADDRESSING_MODE AND IR(5 DOWNTO 3)= REG_ADDRESSING_MODE) THEN
				RESULT := "10"; 
			ELSIF (MAIN_COUNTER_OUTPUT = X"0" AND IR(11 DOWNTO 9)= REG_ADDRESSING_MODE) THEN
				RESULT := "01";
			ELSIF (MAIN_COUNTER_OUTPUT = X"1" AND IR(5 DOWNTO 3)= REG_ADDRESSING_MODE) THEN
				RESULT := "01";
			ELSE 
				RESULT := "00";
			END IF;
		ELSIF (MODE = X"2") THEN 
			IF (MAIN_COUNTER_OUTPUT = X"0") THEN
				RESULT := "01";
			ELSE
				RESULT := "00";
			END IF;
		ELSIF (MODE = X"3") THEN 
			IF (MAIN_COUNTER_OUTPUT = X"0") THEN
				RESULT := "10";
			ELSE 
				RESULT := "00";
			END IF;
		ELSIF (MODE = X"4") THEN 
			IF (MAIN_COUNTER_OUTPUT = X"0") THEN
				RESULT := "11";
			ELSE
				RESULT := "00";
			END IF;
		ELSIF (MODE = X"0")THEN
			RESULT := "00";
		END IF;
		MAIN_COUNTER_INCREMENT <= RESULT;
	END PROCESS;
	
END CONTROL_UNIT;
