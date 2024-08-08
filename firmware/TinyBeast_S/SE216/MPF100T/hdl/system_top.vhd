library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity system_top is
	port (
		reset               : in std_logic; 
		
		sys_clk		        : in std_logic;
		sys_clk45           : in std_logic;
		
		fmc_in              : in std_logic_vector(33 downto 0);
		fmc_out             : out std_logic_vector(33 downto 0);
		
		led					: out std_logic_vector(1 downto 0)
	);
end system_top;

architecture arch_imp of system_top is
	signal counter     	: std_logic_vector(33 downto 0) := (others => '0'); 
	signal counter_1	: std_logic_vector(33 downto 0) := (others => '0');
	signal counter_2	: std_logic_vector(33 downto 0) := (others => '0');
begin
	process (sys_clk, reset)
	begin
		if rising_edge(sys_clk) then
		    if reset = '0' then
			    counter_1 	<= "01" & X"55555555";
		    else
			    counter_1 	<= counter_1(32 downto 0) & counter_1(33);
			end if;
		end if;
	end process;

	fmc_out 	<= counter_1;
	
	process (sys_clk45, reset)
	begin
        if rising_edge(sys_clk45) then
		    if reset = '0' then
		        counter     <= (others => '0');
                counter_2 	<= "01" & X"55555555";
			    led         <= (others => '0');
			else
			    counter 	<= counter + 1;
			    counter_2 	<= counter_2(32 downto 0) & counter_2(33);
			    if (fmc_in = counter_2) then
				    led <= "11";
			    else 
				    led <= counter(24 downto 23);
			    end if;
			end if;
		end if;
	end process;
end arch_imp;
