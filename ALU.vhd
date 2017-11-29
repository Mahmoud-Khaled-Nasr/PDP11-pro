LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

 
ENTITY ALU IS
PORT(
   A,B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
   OPCODE : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
   FLAG_REGISTER : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);		--FLAG REGISTER(3 DOWNTO 0)->(_ _ C Z)
   OUTPUT : OUT STD_LOGIC_VECTOR(31 downto 0));
END ALU;
ARCHITECTURE ALU_arch OF ALU IS

CONSTANT ZEROES : STD_LOGIC_VECTOR(31 DOWNTO 0) :="00000000000000000000000000000000";

BEGIN


PROCESS (A,B,OPCODE) IS
VARIABLE TEMP_OUTPUT : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS=>'0');
VARIABLE TEMP_OUTPUT_WITH_CARRY : STD_LOGIC_VECTOR(32 DOWNTO 0);
VARIABLE CARRY_FLAG  : STD_LOGIC;
VARIABLE ZERO_FLAG   : STD_LOGIC;
VARIABLE OVER_FLOW_FLAG : STD_LOGIC;
VARIABLE NEGATIVE_FLAG : STD_LOGIC;
BEGIN
      -- NO OPERATION --
      IF(OPCODE=X"00")THEN   
        TEMP_OUTPUT_WITH_CARRY := (OTHERS=>'0');
-------------------------------------------------------------------------

     -- ADD OPERATION --
     ELSIF(OPCODE=X"01") THEN
         TEMP_OUTPUT_WITH_CARRY := ('0' & A) + (B);  -- RESULT WITH CARRY 
         TEMP_OUTPUT := TEMP_OUTPUT_WITH_CARRY(31 DOWNTO 0);     -- RESULT WITHOUT CARRY
         
-------------------------------------------------------------------------

    -- ADC OPERATION --     
     ELSIF (OPCODE=X"02") THEN
          TEMP_OUTPUT_WITH_CARRY :=('0' & A) + B + FLAG_REGISTER(1);
          TEMP_OUTPUT:=TEMP_OUTPUT_WITH_CARRY(31 DOWNTO 0);
-------------------------------------------------------------------------
    -- SUB OPERATION --        
     ELSIF (OPCODE=X"03") THEN
           TEMP_OUTPUT_WITH_CARRY := ('0' & A) - (B);
           TEMP_OUTPUT :=TEMP_OUTPUT_WITH_CARRY(31 DOWNTO 0);
-------------------------------------------------------------------------

    -- SBC OPERATION --  
     ELSIF (OPCODE=X"04") THEN
        
           TEMP_OUTPUT_WITH_CARRY := ('0' & A) - (B)-FLAG_REGISTER(1);
           TEMP_OUTPUT :=TEMP_OUTPUT_WITH_CARRY(31 DOWNTO 0);
        
-------------------------------------------------------------------------

     -- MOVE OPERATION --
     ELSIF(OPCODE=X"05") THEN
         TEMP_OUTPUT := (OTHERS=>'0');
        
-------------------------------------------------------------------------
     -- BIC OPERATION --
    ELSIF(OPCODE=X"06") THEN
        TEMP_OUTPUT :=((NOT A) AND B);
       
-------------------------------------------------------------------------
     -- BIS & OR OPERATION --
    ELSIF(OPCODE=X"07" OR OPCODE=X"09") THEN
       TEMP_OUTPUT := (A OR B);
      
-------------------------------------------------------------------------
     -- AND OPERATION --
    ELSIF (OPCODE=X"08") THEN
     TEMP_OUTPUT :=(A AND B);      
      
-------------------------------------------------------------------------
     -- XOR OPERATION --
     ELSIF (OPCODE=X"0A") THEN
       TEMP_OUTPUT :=(A XOR B);
     
-------------------------------------------------------------------------
     -- INV OPERATION --
     ELSIF (OPCODE=X"0B") THEN 
        TEMP_OUTPUT := (NOT A);
       
-------------------------------------------------------------------------
   --======== INC , DEC WILL BE TREATED LIKE ADD ,SUB =========--

      -- INCR 1 OPERATION --
     ELSIF (OPCODE=X"0C") THEN
      TEMP_OUTPUT_WITH_CARRY := ('0' & A) + 1;  -- RESULT WITH CARRY 
      TEMP_OUTPUT := TEMP_OUTPUT_WITH_CARRY(31 DOWNTO 0);     -- RESULT WITHOUT CARRY
-------------------------------------------------------------------------
      -- INCR 2 OPERATION --
     ELSIF (OPCODE=X"0D") THEN
      TEMP_OUTPUT_WITH_CARRY := ('0' & A) + 2;  -- RESULT WITH CARRY 
      TEMP_OUTPUT := TEMP_OUTPUT_WITH_CARRY(31 DOWNTO 0);     -- RESULT WITHOUT CARRY
-------------------------------------------------------------------------
      -- DECR 1 OPERATION --
     ELSIF (OPCODE=X"0E") THEN
       TEMP_OUTPUT_WITH_CARRY := ('0' & A) - 1;
       TEMP_OUTPUT :=TEMP_OUTPUT_WITH_CARRY(31 DOWNTO 0);
-------------------------------------------------------------------------
      -- DECR 2 OPERATION --
     ELSIF (OPCODE=X"0F") THEN
        TEMP_OUTPUT_WITH_CARRY := ('0' & A) - 2;
        TEMP_OUTPUT :=TEMP_OUTPUT_WITH_CARRY(31 DOWNTO 0);
-------------------------------------------------------------------------
      -- CLR OPERATION --
     ELSIF (OPCODE=X"10") THEN
        TEMP_OUTPUT := (OTHERS=>'0');
        CARRY_FLAG :='0';
-------------------------------------------------------------------------
      -- LSR OPERATION --
     ELSIF (OPCODE=X"11") THEN
         TEMP_OUTPUT :=('0' & A(31 DOWNTO 1)) ;
-------------------------------------------------------------------------
      -- ROR OPERATION --
     ELSIF (OPCODE=X"12") THEN 
       TEMP_OUTPUT := (A(0) & A(31 DOWNTO 1)) ;
-------------------------------------------------------------------------
      -- RRC OPERATION --
     ELSIF (OPCODE=X"13") THEN
      TEMP_OUTPUT :=(FLAG_REGISTER(1)& A(31 DOWNTO 1));
-------------------------------------------------------------------------
      -- ASR OPERATION --
     ELSIF (OPCODE=X"14") THEN
      TEMP_OUTPUT :=(A(31) & A(31 DOWNTO 1));
-------------------------------------------------------------------------
      -- LSL OPERATION --
      ELSIF(OPCODE=X"15") THEN
       TEMP_OUTPUT :=(A(30 DOWNTO 0)& '0');
-------------------------------------------------------------------------
      -- ROL OPERATION --
      ELSIF(OPCODE=X"16") THEN 
       TEMP_OUTPUT :=(A(30 DOWNTO 0)& A(31));
-------------------------------------------------------------------------
      -- RLC OPERATION --
      ELSIF(OPCODE=X"17") THEN
       TEMP_OUTPUT :=(A(30 DOWNTO 0)& FLAG_REGISTER(1));
      
      END IF ;

 -----------------------------------------------------------------------    
     OUTPUT<=TEMP_OUTPUT;
 -----------------------------------------------------------------------  
   -- CHECK FOR CARRY FLAG --

IF(OPCODE=X"01" OR OPCODE=X"02" OR OPCODE=X"0C" OR OPCODE=X"0D")THEN
    CARRY_FLAG := TEMP_OUTPUT_WITH_CARRY(32);    -- CARRY

END IF;

IF(OPCODE=X"03" OR OPCODE=X"04" OR OPCODE=X"0E" OR OPCODE=X"0F")THEN
 CARRY_FLAG :=TEMP_OUTPUT_WITH_CARRY(32);
           IF(CARRY_FLAG ='0') THEN
               CARRY_FLAG :='1';
           ELSE CARRY_FLAG :='0';
        END IF; 
END IF;


IF(OPCODE=X"11" OR OPCODE=X"12" OR OPCODE=X"13" OR OPCODE=X"14") THEN

CARRY_FLAG :=A(0);

END IF;

IF(OPCODE=X"15" OR OPCODE=X"16" OR OPCODE=X"17") THEN

CARRY_FLAG :=A(31);

END IF;





 IF(OPCODE=X"01" OR OPCODE=X"02" OR OPCODE=X"0C" OR OPCODE=X"0D" OR OPCODE=X"03" OR OPCODE=X"04" OR OPCODE=X"0E" OR OPCODE=X"0F" OR OPCODE=X"10" OR OPCODE=X"11" OR OPCODE=X"12" OR OPCODE=X"13" OR OPCODE=X"14" OR OPCODE=X"15" OR OPCODE=X"16" OR OPCODE=X"17") THEN
         FLAG_REGISTER(1)<=CARRY_FLAG;
     END IF;
--------------------------------------------------------------------- 
   --CHECK FOR ZERO FLAG
    IF(OPCODE/= X"00" AND TEMP_OUTPUT = ZEROES) THEN
         FLAG_REGISTER(0)<='1';
      ELSE FLAG_REGISTER(0)<='0';     
        END IF;
---------------------------------------------------------------------
  -- CHECK FOR NEGATIVE FLAG --------------------
      IF(OPCODE /= X"00") THEN
        IF(TEMP_OUTPUT(31)='1') THEN
            FLAG_REGISTER(2)<='1';
        ELSE FLAG_REGISTER(2)<='0';
        END IF;
       
----------------------------------------------------------------------




  
-- CHECK OVERFLOW FLAG WITH ADDITION AND SUBTRACTION --
IF(OPCODE=X"01" OR OPCODE=X"02" OR OPCODE=X"03" OR OPCODE=X"04" OR OPCODE=X"0C" OR OPCODE=X"0D" OR OPCODE=X"0E" OR OPCODE=X"0F")THEN
          IF(  ( ( (NOT A(31)) AND (NOT B(31)) AND (TEMP_OUTPUT(31))  )='1')  OR (( A(31) AND B(31)  AND (NOT TEMP_OUTPUT(31)))='1')) THEN
          OVER_FLOW_FLAG :='1';
         ELSE OVER_FLOW_FLAG :='0';
          END IF;
       END IF;
    
---------------------------------------------------------------------

-- CHECK OVERFLOW FLAG WITH OTHER OPERATIONS --
IF(OPCODE=X"05" OR OPCODE=X"06" OR OPCODE=X"07" OR OPCODE=X"08" OR OPCODE=X"09" OR OPCODE=X"0A" OR OPCODE=X"0B" OR OPCODE=X"10") THEN
OVER_FLOW_FLAG :='0';
END IF;
---------------------------------------------------------------------
-- CHECK OVERFLOW FLAG WITH SHIFT & ROTATE --
IF(OPCODE=X"11" OR OPCODE=X"12" OR OPCODE=X"13" OR OPCODE=X"14" OR OPCODE=X"15" OR OPCODE=X"16" OR OPCODE=X"17")THEN
OVER_FLOW_FLAG := FLAG_REGISTER(2) XOR FLAG_REGISTER(1);
END IF;


IF(OPCODE /= X"00") THEN
FLAG_REGISTER(3) <= OVER_FLOW_FLAG;
END IF;




END IF;


END PROCESS;


end ALU_arch;

