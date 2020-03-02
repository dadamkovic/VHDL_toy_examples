-- authoor : Daniel Adamkovic
-- about: A simple synchronous adder, with generic width parameter

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity multi_port is
  generic(
    operand_width_g : integer := 16;
    num_of_operands_g     : integer := 4    --this means opernads = 2**num_of_operands_g
  );
  port(
    clk, rst_n      : in std_logic;
    operands_in     : in std_logic_vector(operand_width_g*num_of_operands_g -1 downto 0);
    sum_out         : out std_logic_vector(operand_width_g-1 downto 0)
  );
end multi_port;

architecture structural of multi_port is
  component adder
    generic (
      operand_width_g :     integer
    );
    port (
      clk             : in  std_logic;
      rst_n           : in  std_logic;
      a_in            : in  std_logic_vector(operand_width_g-1 downto 0);
      b_in            : in  std_logic_vector(operand_width_g-1 downto 0);
      sum_out         : out std_logic_vector(operand_width_g downto 0));
  end component;

alias n             : integer is num_of_operands_g;
alias w             : integer is operand_width_g;
alias operand_shift : integer is (2*w)*i+2*(i-1);
alias max_operands  : integer is (n**2+2*n*w+w)-1;

signal all_mem      : std_logic_vector( (
signal operand_mem  : std_logic_vector( max_operands downto 0 ); 

begin
  
  genAdders :
  for i in 0 to n generate  --we need this because of the offset iregularity
    firstAdder: if i = 0 generate
      i_compAdd_x : adder
        generic map (
          operand_width_g => operand_width_g+i
        )
        port map (
          clk             => clk,
          rst_n           => rst_n,
          a_in            => operand_mem(max_operands downto max_operands-w+1),
          b_in            => operand_mem(max_operands-w downto max_operands-2*w+1),
          sum_out         => subtotal(0)
      );
    end generate;
    
    remainingAdders: if i > 0 generate
      i_compAdd_x : adder
          generic map (
            operand_width_g => operand_width_g+i
          )
          port map (
            clk             => clk,
            rst_n           => rst_n,
            a_in            => operand_mem(max_operands-operand_shift downto max_operands-operand_shift-(w+i-1)),
            b_in            => operand_mem(max_operands-operand_shift-(w+i) downto max_operands-operand_shift-(w+i-1)-(w+i)),
            sum_out         => subtotal(0)
        );
      end generate;
    
    
  
  addMult : process(clk,rst_n)
  begin
    
  
  sum_out <= total(operand_width_g-1 downto 0);
end structural;



































    