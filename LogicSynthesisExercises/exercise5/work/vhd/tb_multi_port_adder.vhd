--------------------------------------------------------------------------------
-- Title       : Exercise 5
-- Project     : Logic synthesis
--------------------------------------------------------------------------------
-- File        : tb_multi_port_adder.vhd
-- Author      : User Name <daniel.adamkovic@tuni.fi>
-- Company     : Tampere University
-- Created     : Thu Feb 13 22:33:02 2020
-- Last update : Thu Feb 13 23:34:21 2020
-- Platform    : ModelSim
-- Standard    : <VHDL-2008>
--------------------------------------------------------------------------------
-- Copyright (c) 2020 Tampere University
-------------------------------------------------------------------------------
-- Description: A simple testbench for the multiport adder from exercise 4
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------

entity tb_multi_port_adder is
	generic(
		operand_width_g : integer	:= 4
	);
end tb_multi_port_adder;

--------------------------------------------------------------------------------
-- ARCHITECTURE BLOCK
--------------------------------------------------------------------------------

architecture behavorial of tb_multi_port_adder is

	-- CONSTANTS
	constant clk_period_c 	: time 		:= 10 ns;
	constant num_op_c		: integer 	:= 4;			--num of oprators that enter multi_port_adder
	constant duv_delay_c	: integer	:= 2;			--effectively stages of the multiport adder (defines delay)
--------------------------------------------------------------------------------
	--SIGNALS
--------------------------------------------------------------------------------
	signal clk 				: std_logic := '0';
	signal rst_n			: std_logic := '0';
	signal operands_r		: std_logic_vector(num_op_c*operand_width_g-1 downto 0);	--all operators loaded in one vector
	signal sum 				: std_logic_vector(operand_width_g-1 downto 0); 			--will hold the resolt of summation
	signal output_valid_r 	: std_logic_vector(duv_delay_c downto 0); 					--tracks the delay of the first loaded value

--------------------------------------------------------------------------------
-- FILES
--------------------------------------------------------------------------------

	file input_f			: text open READ_MODE is "input.txt";						--holds inputs to the multi_port_adder
	file ref_results_f 		: text open READ_MODE is "ref_results_4b.txt";				--holds correct values
	file output_f 			: text open WRITE_MODE is "output.txt";						--will hold outputed values

--------------------------------------------------------------------------------
-- COMPONENTS
--------------------------------------------------------------------------------
	component multi_port_adder is 														-- see the multi_port_adder.vhd for description
	  generic(
	    operand_width_g 	: integer;
	    num_of_operands_g   : integer
	  );
	  port(
	    clk, rst_n      : in std_logic;
	    operands_in     : in std_logic_vector(operand_width_g*num_of_operands_g -1 downto 0);
	    sum_out         : out std_logic_vector(operand_width_g-1 downto 0)
	  );
	end component;


BEGIN

--------------------------------------------------------------------------------
-- COMPONENT INITIALIZATION
--------------------------------------------------------------------------------

 	i_compMul_0 : multi_port_adder
 	generic map(
 		operand_width_g 		=> operand_width_g,
 		num_of_operands_g		=> num_op_c
 	)
 	port map(
 		clk 					=> clk,
 		rst_n					=> rst_n,
 		operands_in				=> operands_r,
 		sum_out					=> sum
 	);

	--------------------------------------------------------------------------------
	-- purpose  : Generates clock for the simulation
	-- INPUT 	: clk
	-- OUTPUT 	: clk 
	--------------------------------------------------------------------------------
  	clk_gen : process (clk)
 	begin  
  		clk <= not clk after clk_period_c/2;
 	end process clk_gen;



 	-- turning off the reset after 4 clock cycles
 	rst_n <= '1' after clk_period_c*4;


    ----------------------------------------------------------------------------
    -- purpose	: Feed date into multiport adder and read replies
  	-- type   	: synchronous
  	-- inputs 	: clk, rst_n
 	-- outputs	: operands_r, output_valid_r
    ----------------------------------------------------------------------------
    
 	input_reader : process(clk, rst_n)

 		-----------------------------------------------------------------------
 		-- TYPES
 		-----------------------------------------------------------------------

 		type inp_values_t is array(num_op_c-1 downto 0) of integer;

 		-----------------------------------------------------------------------
 		-- VARIABLES
 		-----------------------------------------------------------------------
 		
 		variable in_line_v 		: line;
 		variable in_vals_v		: inp_values_t;
 		variable feed_op_v 		: std_logic_vector(num_op_c*operand_width_g-1 downto 0);
 		variable start_idx_v	: integer;
 		variable end_idx_v		: integer;
 		variable single_oper_v  : signed(operand_width_g-1 downto 0);

 	begin

 		if(rst_n = '0') then

 			operands_r <= (others => '0');										--input to multi_port_adder initalized to 0
 			output_valid_r <= (others => '0');									--tracking of the delay initialized to 0

 		elsif(rising_edge(clk)) then
 			
 			output_valid_r <= output_valid_r(duv_delay_c-1 downto 0)&'1'; 		-- left shift and set the LSB to '1', MSB='1' indicates valid outputs
	 	
	 		if not endfile(input_f) then										-- reading file after EOF would crash simulation  
	 			readline(input_f, in_line_v);
	 			
	 			for i in 0 to num_op_c-1 loop 									-- populate the array of input integers

	 				start_idx_v := (num_op_c-i)*operand_width_g-1;				-- determine where to put the result...
	 				end_idx_v := (num_op_c-1-i)*operand_width_g;				-- values have to follow one after another
	 				single_oper_v := to_signed(in_vals_v(i),operand_width_g);
	 				read(in_line_v, in_vals_v(i));								-- idnividual values stored in the array
	 				feed_op_v(start_idx_v downto end_idx_v) := std_logic_vector(single_oper_v);				
	 			
	 			end loop;

	 			operands_r <= feed_op_v;										-- finally assign the result to multi_port_adder input
	 		
	 		end if;
 		end if;	

 	end process input_reader;


 	---------------------------------------------------------------------------
    -- purpose		: Read multi_port_adder data, check them against a reference and create log file
  	-- type   		: synchronous
  	-- inputs 		: clk, rst_n
 	-- outputs		: output.txt	
 	---------------------------------------------------------------------------
 	checker : process(clk,rst_n)

 	---------------------------------------------------------------------------
 	-- VARIABLES
 	---------------------------------------------------------------------------
 	
 	 	variable in_line_v 		: line;
 		variable out_line_v		: line;
 		variable corr_val_v		: integer;
 		variable from_adder_v 	: integer;


 	begin

	 	if(rising_edge(clk) AND rst_n = '1') then

	 		if(output_valid_r(duv_delay_c) = '1') then							-- this signals that X cycles (stage dependant) have passed... 
	 																			-- since the first input value
	 			if not endfile(ref_results_f) then								-- don't read if there is nothing to read

	 				readline(ref_results_f,in_line_v);
	 				read(in_line_v,corr_val_v);

	 			else 

	 				assert false												-- no more values means finished
	 				report "Simulation done!"
	 				severity failure;

	 			end if;

	 		from_adder_v := to_integer(signed(sum));							-- transform for comparison

	 		assert from_adder_v = corr_val_v									-- reference and output must be equal
	 		report "The values are not equal!"
	 		severity failure;

	 		write(out_line_v,from_adder_v);										-- create log of returned value
	 		writeline(output_f,out_line_v);

	 		end if;
	 	end if;		

	 end process checker;

END behavorial;
