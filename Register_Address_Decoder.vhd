LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.MY_PACKAGE.ALL;

ENTITY REGISTER_ADDRESS_DECODER IS
	PORT (
		REG_CODE	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		DECODER_OUT	: OUT STD_LOGIC_VECTOR (REGISTER_STATES_ON_BUS-1 DOWNTO 0)
	);

END ENTITY REGISTER_ADDRESS_DECODER;



architecture REGISTER_ADDRESS_DECODER_ARCH of REGISTER_ADDRESS_DECODER is
begin

	DECODER_OUT <=	(OTHERS=>'0')		WHEN  REG_CODE = "0000"	--NO REGISTER
	ELSE		(0=>'1',OTHERS=>'0')	WHEN  REG_CODE = "0001"	--R0
	ELSE		(1=>'1',OTHERS=>'0')	WHEN  REG_CODE = "0010"	--R1
	ELSE		(2=>'1',OTHERS=>'0')	WHEN  REG_CODE = "0011"	--R2
	ELSE		(3=>'1',OTHERS=>'0')	WHEN  REG_CODE = "0100"	--R3
	ELSE		(4=>'1',OTHERS=>'0')	WHEN  REG_CODE = "0101"	--R4
	ELSE		(5=>'1',OTHERS=>'0')	WHEN  REG_CODE = "0110"	--R5
	ELSE		(6=>'1',OTHERS=>'0')	WHEN  REG_CODE = "0111"	--R6(SP)
	ELSE		(7=>'1',OTHERS=>'0')	WHEN  REG_CODE = "1000"	--R7(PC)
	ELSE		(8=>'1',OTHERS=>'0')	WHEN  REG_CODE = "1001"	--MAR
	ELSE		(9=>'1',OTHERS=>'0')	WHEN  REG_CODE = "1010"	--MDR
	ELSE		(10=>'1',OTHERS=>'0')	WHEN  REG_CODE = "1011"	--IR
	ELSE		(11=>'1',OTHERS=>'0')	WHEN  REG_CODE = "1100"	--SRC
	ELSE		(others=>'1');	--THE IMPOSIBLE CASE (IT WILL OPEN ALL TRI-STATES) ,IT WILL BE LIKE "FARA7 EL-3OMDA"




end REGISTER_ADDRESS_DECODER_ARCH;