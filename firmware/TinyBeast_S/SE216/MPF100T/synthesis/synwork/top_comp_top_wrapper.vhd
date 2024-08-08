--
-- Synopsys
-- Vhdl wrapper for top level design, written on Tue Mar 29 05:57:36 2022
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity wrapper_for_system_top is
   port (
      reset : in std_logic;
      sys_clk : in std_logic;
      sys_clk45 : in std_logic;
      fmc_in : in std_logic_vector(33 downto 0);
      fmc_out : out std_logic_vector(33 downto 0);
      led : out std_logic_vector(1 downto 0)
   );
end wrapper_for_system_top;

architecture arch_imp of wrapper_for_system_top is

component system_top
 port (
   reset : in std_logic;
   sys_clk : in std_logic;
   sys_clk45 : in std_logic;
   fmc_in : in std_logic_vector (33 downto 0);
   fmc_out : out std_logic_vector (33 downto 0);
   led : out std_logic_vector (1 downto 0)
 );
end component;

signal tmp_reset : std_logic;
signal tmp_sys_clk : std_logic;
signal tmp_sys_clk45 : std_logic;
signal tmp_fmc_in : std_logic_vector (33 downto 0);
signal tmp_fmc_out : std_logic_vector (33 downto 0);
signal tmp_led : std_logic_vector (1 downto 0);

begin

tmp_reset <= reset;

tmp_sys_clk <= sys_clk;

tmp_sys_clk45 <= sys_clk45;

tmp_fmc_in <= fmc_in;

fmc_out <= tmp_fmc_out;

led <= tmp_led;



u1:   system_top port map (
		reset => tmp_reset,
		sys_clk => tmp_sys_clk,
		sys_clk45 => tmp_sys_clk45,
		fmc_in => tmp_fmc_in,
		fmc_out => tmp_fmc_out,
		led => tmp_led
       );
end arch_imp;
