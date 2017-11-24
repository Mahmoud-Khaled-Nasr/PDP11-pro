LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.numeric_std.all;

ENTITY CU IS
	GENERIC (MODE_BITS_NUM: integer := 3; IR_SIZE: integer := 16 );
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
	---------------The Constants
	--Address modes
	CONSTANT REG_ADDRESSING_MODE : integer := 0;
	CONSTANT AUTO_INCR_ADDRESSING_MODE : integer := 1;
	CONSTANT AUTO_DECR_ADDRESSING_MODE : integer := 2;
	CONSTANT INDEXED_ADDRESSING_MODE : integer := 3;
	--CLK period
	CONSTANT HALF_CYCLE : TIME := 50 PS;
	
	SIGNAL CONTROL_CLK : std_logic;
	--TODO set NEW_INSTRUCTION bit at the end of every instruction and clear it at the start of every instruction TO RESET THE CIRCUIT
	SIGNAL NEW_INSTRUCTION : std_logic := '0'; 
	SIGNAL ENABLE_MAIN_COUNTER : std_logic := '1';
	SIGNAL ENABLE_INSTRUCTION_COUNTER : std_logic := '0';
	SIGNAL INITIAL_ADDRESS : std_logic_vector(3 DOWNTO 0) := "0000";
	SIGNAL MODE : std_logic_vector(MODE_BITS_NUM-1 DOWNTO 0);
	SIGNAL MAIN_COUNTER_OUTPUT, INSTRUCTION_COUNTER_OUTPUT: std_logic_vector (3 DOWNTO 0);
	SIGNAL MAIN_COUNTER_INCREMENT : std_logic_vector (1 DOWNTO 0);
	BEGIN
	-------------------------------Port Mapping-----------------------------------------------
	------------------------------------------------------------------------------------------
	MAIN_COUNTER: NBIT_COUNTER_WITH_INCREMENT PORT MAP ( CLK => CONTROL_CLK , RST => NEW_INSTRUCTION, ENABLE => ENABLE_MAIN_COUNTER
		, INCREMENT => MAIN_COUNTER_INCREMENT, DATA_OUT => MAIN_COUNTER_OUTPUT  );
	INSTRUCTION_COUNTER: NBIT_COUNTER_WITH_INITIAL_VALUE PORT MAP ( CLK => CONTROL_CLK , ENABLE => ENABLE_INSTRUCTION_COUNTER
		, DATA_IN => INITIAL_ADDRESS, DATA_OUT => INSTRUCTION_COUNTER_OUTPUT );
	
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
		ELSE "100" WHEN IR(IR_SIZE-1 DOWNTO 12) = X"0111" OR IR(IR_SIZE-1 DOWNTO 12) = "1000"
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
	
	-- PROCESS (MAIN_COUNTER_OUTPUT, MODE)
	-- VARIABLE RESULT : std_logic_vector (1 DOWNTO 0);
	-- BEGIN
		-- IF (MAIN_COUNTER_OUTPUT = X"0")
			-- IF (MODE = X"1") THEN
				-- RESULT := "00"; 
			-- ELSIF (MODE = X"2") THEN
				-- RESULT := "01";
			-- ELSIF (MODE = X"3") THEN
				-- RESULT := "10";
			-- ELSIF (MODE = X"4") THEN 
				-- RESULT := "11";
			-- END IF;
		-- ELSIF (MAIN_COUNTER_OUTPUT = X"1" OR MAIN_COUNTER_OUTPUT = X"2" OR MAIN_COUNTER_OUTPUT = X"3" OR MAIN_COUNTER_OUTPUT = X"4")
			-- RESULT := "00";
		-- ELSIF 
		-- END IF;
		-- INCREMENT <= RESULT;
	-- END PROCESS;
	
END CONTROL_UNIT;
