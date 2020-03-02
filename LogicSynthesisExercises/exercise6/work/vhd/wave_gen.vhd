--------------------------------------------------------------------------------
-- Title       : Exercise 6
-- Project     : Logic synthesis
--------------------------------------------------------------------------------
-- File        : wave_gen.vhd
-- Author      : User Name <daniel.adamkovic@tuni.fi>
-- Company     : Tampere University
-- Created     : Thu Feb 13 22:33:02 2020
-- Last update : Fri Feb 14 00:05:27 2020
-- Platform    : ModelSim
-- Standard    : <VHDL-2008>
--------------------------------------------------------------------------------
-- Copyright (c) 2020 Tampere University
-------------------------------------------------------------------------------
-- Description: Generates a triangular wave with a given width and step. 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------

entity wave_gen is
	generic (
			width_g : integer; 												-- 2^width_g possible values (signed)
			step_g  : integer												-- increment taken when changing output
		);
	port (
			clk,rst_n 		: in std_logic;
			sync_clear_n_in : in std_logic; 								-- a synchronous restart
			value_out		: out std_logic_vector(width_g-1 downto 0)      -- output value (triangle wave)
		);
end wave_gen;


--------------------------------------------------------------------------------
-- ARCHITECTURE BLOCK
--------------------------------------------------------------------------------

architecture RTL of wave_gen is

	----------------------------------------------------------------------------
	-- CONSTANTS
	----------------------------------------------------------------------------
	
	constant max_count 	: integer := ((2**(width_g-1)-1)/step_g)*step_g; 	-- signed is not symetric + we have to always use full step

	----------------------------------------------------------------------------
	-- SIGNALS
	----------------------------------------------------------------------------
	
	signal curr_val		: signed(width_g-1 downto 0);
	signal next_val		: signed(width_g-1 downto 0);
	signal step_2_take	: signed(width_g-1 downto 0); 						-- holds the +/- step value depending on increment/decrement

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
	countProc : process(clk,rst_n)

	begin

		if(rst_n = '0' OR (rising_edge(clk) AND sync_clear_n_in = '0')) then 			-- all reset conditions do the same thing

			curr_val <= (others => '0');
			step_2_take <= to_signed(step_g,width_g); 									-- in case we were decrementing before reset

		elsif(rising_edge(clk)) then 													

			curr_val <= next_val;														-- output already calculated just assign

			if (next_val = to_signed(max_count,width_g)) then 							-- if at the top start going down

				step_2_take <= to_signed(-step_g,width_g); 								

			elsif (next_val = to_signed(-max_count,width_g))  then 						-- if at the bottom start going up

				step_2_take <= to_signed(step_g,width_g);

			end if;

		end if;

	end process countProc;

	next_val <= curr_val + step_2_take;													-- calc. next value

	value_out <= std_logic_vector(curr_val); 											-- assign output

END RTL;