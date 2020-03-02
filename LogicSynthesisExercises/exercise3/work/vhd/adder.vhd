--------------------------------------------------------------------------------
-- Title       : Exercise 2
-- Project     : Logic synthesis
--------------------------------------------------------------------------------
-- File        : adder.vhd
-- Author      : User Name <daniel.adamkovic@tuni.fi>
-- Company     : Tampere University
-- Created     : Thu Feb 13 22:33:02 2020
-- Last update : Thu Feb 13 23:53:23 2020
-- Platform    : ModelSim
-- Standard    : <VHDL-2008>
--------------------------------------------------------------------------------
-- Copyright (c) 2020 Tampere University
-------------------------------------------------------------------------------
-- Description: Simple synchronous adder that takes 2 signed numbers and outputs their sum...
-- width of the OUTPUT is +1 more than width of the inputs to prevent overflow. 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------

entity adder is
	generic(
    	operand_width_g : integer										   	-- input argument width
	);
  	port(
    	clk, rst_n  : in std_logic;
    	a_in, b_in  : in std_logic_vector(operand_width_g-1 downto 0);		-- input operands
    	sum_out     : out std_logic_vector(operand_width_g downto 0)		-- output (width + 1)
  	);
end adder;

--------------------------------------------------------------------------------
-- ARCHITECTURE BLOCK
--------------------------------------------------------------------------------

architecture rtl of adder is

--------------------------------------------------------------------------------
-- SIGNALS 
--------------------------------------------------------------------------------

	signal result : signed(operand_width_g downto 0);
  	signal next_result : signed(operand_width_g downto 0);
  	signal wide_a : signed(operand_width_g downto 0);
  	signal wide_b : signed(operand_width_g downto 0);
 
--------------------------------------------------------------------------------
-- ARCHITECTURE BODY
--------------------------------------------------------------------------------

BEGIN

	---------------------------------------------------------------------------
    -- purpose		: Take the two numbers and add them on possitive edge
  	-- type   		: synchronous
  	-- inputs 		: clk, rst_n
 	-- outputs		: result	
 	---------------------------------------------------------------------------
	addProc : process(clk, rst_n)
	begin

	if (rst_n = '0') then

		result <= (others => '0');

	elsif (rising_edge(clk)) then

		result <= next_result;

	end if;

	end process addProc;

	wide_a <= resize(signed(a_in),operand_width_g+1);			-- operands have to be resized 
	wide_b <= resize(signed(b_in),operand_width_g+1);
	next_result <= wide_a + wide_b;

	sum_out <= std_logic_vector( result );

end rtl;
    
