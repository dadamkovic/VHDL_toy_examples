--------------------------------------------------------------------------------
-- Title       : Exercise 6 BONUS
-- Project     : Logic synthesis
--------------------------------------------------------------------------------
-- File        : sine_gen.vhd
-- Author      : User Name <daniel.adamkovic@tuni.fi>
-- Company     : Tampere University
-- Created     : Thu Feb 13 22:33:02 2020
-- Last update : Fri Feb 14 01:39:40 2020
-- Platform    : ModelSim
-- Standard    : <VHDL-2008>
--------------------------------------------------------------------------------
-- Copyright (c) 2020 Tampere University
-------------------------------------------------------------------------------
-- Description: Generates a sine wave approximation with a given frequency (modify step_g)...
-- as it is the num of points per wave is fixed to (512), it could be increased...
-- but the polynomial coeficients would have to be recalculated 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------

entity sine_gen is
	generic (
			width_g : integer := 8;												-- 2^width_g possible values DO NOT TOUCH for now
			step_g  : integer := 1												-- increment taken when changing output
		);
	port (
			clk,rst_n 		: in std_logic;
			sync_clear_n_in : in std_logic; 								-- a synchronous restart
			value_out		: out std_logic_vector(2*width_g-1 downto 0)      -- output value (triangle wave)
		);
end sine_gen;


--------------------------------------------------------------------------------
-- ARCHITECTURE BLOCK
--------------------------------------------------------------------------------

architecture RTL of sine_gen is

	--------------------------------------------------------------------------------
	-- CONSTANTS
	--------------------------------------------------------------------------------

	constant max_res_c		: integer := 2*((2**(width_g-1)-1)/step_g)*step_g;  

	----------------------------------------------------------------------------
	-- SIGNALS
	----------------------------------------------------------------------------
	
	signal curr_val			: signed(2*width_g-1 downto 0);
	signal next_val			: signed(2*width_g-1 downto 0);
	signal calc_val			: signed(2*width_g-1 downto 0);
	signal a_term			: signed(2*width_g-1 downto 0);
	signal b_term			: signed(2*width_g-1 downto 0);
	signal curr_step   		: unsigned(7 downto 0);
	signal next_step   		: unsigned(7 downto 0); 	
	signal pos_part_curr	: std_logic;
	signal pos_part_next	: std_logic;					

--------------
--------------------------------------------------------------------------------
-- ARCHITECTURE BODY
--------------------------------------------------------------------------------
--------------

BEGIN

	---------------------------------------------------------------------------
    -- purpose		: Assignes the next value of the output / tracks if we are rising or falling
  	-- type   		: synchronous
  	-- inputs 		: clk, rst_n
 	-- outputs		: curr_val	
 	---------------------------------------------------------------------------
	countProc : process(clk, rst_n)

	begin

		if(rst_n = '0' OR (rising_edge(clk) AND sync_clear_n_in = '0')) then 			-- all reset conditions do the same thing

			curr_val <= (others => '0');
			curr_step <= (others => '0'); 		
			pos_part_curr <= '1';							

		elsif(rising_edge(clk)) then 													

			if( curr_step = to_unsigned(max_res_c,curr_step'length) ) then				-- max value means we need to zero step counter

				pos_part_curr <= pos_part_next; 
				curr_step <= to_unsigned(0,curr_step'length);
			
			else

				curr_step <= next_step;													-- if not max value just cont. adding

			end if;

			
			curr_val <= next_val;
																						-- output already calculated just assign
		end if;

	end process countProc;

	pos_part_next <= NOT pos_part_curr;
	next_step <= curr_step + to_unsigned(step_g,curr_step'length);

	a_term <= signed(shift_left(resize(curr_step,2*width_g),8));						-- these 2 terms are acquired using polynomial approx.
	b_term <= signed(curr_step*curr_step);

	calc_val <= a_term - b_term;

	next_val <= calc_val when pos_part_curr='1' else 									-- we make a choice based on the sing. flag
				-calc_val;													

	value_out <= std_logic_vector(curr_val); 											-- assign output

END RTL;