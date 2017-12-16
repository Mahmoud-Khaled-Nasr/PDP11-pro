LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.MY_PACKAGE.ALL;

entity FLAG_REGISTER is						
port(
	D	:in	std_logic_vector(3 downto 0);	--input
	RST	:in	std_logic;			--reset
	CLK	:in	std_logic;			--clock
	ENB	:in	std_logic;			--enable
	Q	:out	std_logic_vector(3 downto 0));--output
end FLAG_REGISTER;


architecture FLAG_REGISTER_ARCH of FLAG_REGISTER is
begin
	process(rst,clk,enb)
	begin
		if (RST='1') then
			Q<=(others=>'0');
		elsif(falling_edge(clk) and enb='1')then
			Q<=D;
		end if;
	end process;

END FLAG_REGISTER_ARCH;
