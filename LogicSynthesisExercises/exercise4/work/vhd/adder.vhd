-- authoor : Daniel Adamkovic
-- about: A simple synchronous adder, with generic width parameter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
  generic(
    operand_width_g : integer
);
  port(
    clk, rst_n  : in std_logic;
    a_in, b_in  : in std_logic_vector(operand_width_g-1 downto 0);
    sum_out     : out std_logic_vector(operand_width_g downto 0)
  );
end adder;


architecture rtl of adder is
  signal result : signed(operand_width_g downto 0);
  signal next_result : signed(operand_width_g downto 0);
  signal wide_a : signed(operand_width_g downto 0);
  signal wide_b : signed(operand_width_g downto 0);
  
begin
  addProc : process(clk, rst_n)
  begin
    if (rst_n = '0') then
      result <= (others => '0');
    elsif (rising_edge(clk)) then
      result <= next_result;
    end if;
  end process addProc;
  
  wide_a <= resize(signed(a_in),operand_width_g+1);
  wide_b <= resize(signed(b_in),operand_width_g+1);
  next_result <= wide_a + wide_b;
  sum_out <= std_logic_vector( result );
end rtl;
    
