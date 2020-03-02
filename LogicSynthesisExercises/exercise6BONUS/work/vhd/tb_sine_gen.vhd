-------------------------------------------------------------------------------
-- Title      : TKT-1212, Exercise 03
-- Project    : 
-------------------------------------------------------------------------------
-- File       : tb_adder.vhd
-- Author     : Antti Rasmus
-- Company    : TUT/DCS
-- Created    : 2008-11-28
-- Last update: 2008-11-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Tests all combinations of summing two 8-bit values
-------------------------------------------------------------------------------
-- Copyright (c) 2008 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008-11-28  1.0      ege	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sine_gen is 

end tb_sine_gen;

architecture behavorial of tb_sine_gen is

  	constant clk_period_c : time    := 100 ns;
  	constant width_c : integer := 8 ;
  	constant step_c : integer := 5 ;

	component sine_gen is
		generic (
			width_g : integer := 8;
			step_g  : integer := 5
		);
		port (
			clk,rst_n       : in  std_logic;
			sync_clear_n_in : in  std_logic;
			value_out       : out std_logic_vector(2*width_c-1 downto 0)
		);
	end component;


	signal clk   			: std_logic 		:= '0';
  	signal rst_n 			: std_logic 		:= '0';
  	signal sync_clear_n_in 	: std_logic 		:= '0';
  	signal value_out 		: std_logic_vector(2*width_c-1 downto 0);	

begin
	i_compWav_0 : sine_gen
		generic map (
			width_g 			=> width_c,
			step_g    			=> step_c
		)
		port map(
			clk 				=> clk,
			rst_n				=> rst_n,
			sync_clear_n_in		=> sync_clear_n_in,
			value_out 			=> value_out
		);

	clk_gen : process (clk)
  	begin  -- process clk_gen
    	clk <= not clk after clk_period_c/2;
  	end process clk_gen;

	rst_n <= '1' after clk_period_c*2;
	sync_clear_n_in <= '1' after clk_period_c*3;


end behavorial;
