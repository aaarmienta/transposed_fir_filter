library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transposed_FIR is
  generic(
    FILT_LENGTH  : integer := 9;
    INPUT_WIDTH  : integer range 8 to 25 := 24;
    COEFF_WIDTH  : integer range 8 to 18 := 16;
    OUTPUT_WIDTH : integer := 40
  );
  port(
    clk    : in std_logic;
    rst    : in std_logic;
    data_i : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    data_o : out std_logic_vector(OUTPUT_WIDTH-1 downto 0)
  );
end transposed_FIR;

architecture arch_transposed_FIR of transposed_FIR is
  attribute use_dsp : string;
  attribute use_dsp of arch_transposed_FIR : architecture is "yes";

  type in_pipe_regs_t is array(0 to FILT_LENGTH-1) of signed(INPUT_WIDTH-1 downto 0);
  signal pipe_regs_s : in_pipe_regs_t;

  type coeff_regs_t is array(0 to FILT_LENGTH-1) of signed(COEFF_WIDTH-1 downto 0);
  signal coeff_s : coeff_regs_t;

  type mult_regs_t is array(0 to FILT_LENGTH-1) of signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0);
  signal mult_s : mult_regs_t;

  type adder_regs_t is array(0 to FILT_LENGTH-1) of signed(INPUT_WIDTH+COEFF_WIDTH-1 downto 0);
  signal addr_s : adder_regs_t;

  type lut_coeffs_t is array(0 to FILT_LENGTH-1) of signed(COEFF_WIDTH-1 downto 0);
  constant lut_coeffs : lut_coeffs_t := (
  -- Blackman 500Hz LPF
    x"0005", x"0001", x"0005", x"000C", 
    x"0016", x"0025", x"0037", x"004E", 
    x"0069"
  );
  
begin
  COEFFS_GEN: for i in 0 to FILT_LENGTH-1 generate
    coeff_s(i) <= lut_coeffs(i);
  end generate;

  data_o <= std_logic_vector(addr_s(0));

  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        pipe_regs_s <= (others => (others => '0'));
        mult_s  <= (others => (others => '0'));
        addr_s <= (others => (others => '0'));
      elsif (rst = '0') then
        for i in 0 to FILT_LENGTH-1 loop
          pipe_regs_s(i) <= signed(data_i);
          if (i < FILT_LENGTH-1) then
            mult_s(i) <= pipe_regs_s(i) * coeff_s(i);
            addr_s(i) <= mult_s(i) + addr_s(i+1);
          elsif (i = FILT_LENGTH-1) then
            mult_s(i) <= pipe_regs_s(i) * coeff_s(i);
            addr_s(i) <= mult_s(i);
          end if;
        end loop;
      end if;
    end if;
  end process;
  

end arch_transposed_FIR;