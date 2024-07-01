library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transposed_FIR_tb is
end transposed_FIR_tb;

architecture sim of transposed_FIR_tb is
  
  constant clk_hz : integer := 100e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk    : std_logic := '1';
  signal rst    : std_logic := '1';
  signal data_i : std_logic_vector(24-1 downto 0) := x"000001";
  signal data_o : std_logic_vector(40-1 downto 0);

begin
  uut : entity work.transposed_FIR
  port map (clk=>clk, rst=>rst, data_i=>data_i, data_o=>data_o);
  
  clk <= not clk after clk_period / 2;

  SEQUENCER_PROC : process
  begin
    wait for clk_period * 2;
    rst <= '0';
    wait for clk_period * 9;
    data_i <= x"000000";
    wait for clk_period * 18;
    data_i <= x"000001";
    wait for clk_period * 9;
    data_i <= x"000000";
    wait;
  end process;

end architecture;