--------------------------------------------------------------------------------
-- Title       : Exercise 4
-- Project     : Logic synthesis
--------------------------------------------------------------------------------
-- File        : multi_port_adder.vhd
-- Author      : User Name <daniel.adamkovic@tuni.fi>
-- Company     : Tampere University
-- Created     : Thu Feb 13 22:33:02 2020
-- Last update : Thu Feb 13 23:45:42 2020
-- Platform    : ModelSim
-- Standard    : <VHDL-2008>
--------------------------------------------------------------------------------
-- Copyright (c) 2020 Tampere University
-------------------------------------------------------------------------------
-- Description: Adder that takes in 4 values in a signel vector and performs their sum. 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- ENTITY
--------------------------------------------------------------------------------

entity multi_port_adder is
  generic(
    operand_width_g       : integer := 16;              
    num_of_operands_g     : integer := 4
  );
  port(
    clk, rst_n      : in std_logic;
    operands_in     : in std_logic_vector(operand_width_g*num_of_operands_g -1 downto 0);
    sum_out         : out std_logic_vector(operand_width_g-1 downto 0)
  );
end multi_port_adder;

--------------------------------------------------------------------------------
-- ARCHITECTURE BLOCK
--------------------------------------------------------------------------------

architecture structural of multi_port_adder is
  
  ------------------------------------------------------------------------------
  -- TYPES
  ------------------------------------------------------------------------------
  
  type new_type is array (num_of_operands_g /2-1 downto 0) of std_logic_vector(operand_width_g downto 0);
  
  ------------------------------------------------------------------------------
  -- SIGNALS
  ------------------------------------------------------------------------------
  
  signal subtotal : new_type;
  signal total    : std_logic_vector(operand_width_g+1 downto 0);

  ------------------------------------------------------------------------------
  -- ALIASES  (VERY ugly in this case)
  ------------------------------------------------------------------------------
  
  alias first_operand   : std_logic_vector is operands_in(operand_width_g*num_of_operands_g -1 downto operand_width_g*(num_of_operands_g -1));
  alias second_operand  : std_logic_vector is operands_in(operand_width_g*(num_of_operands_g -1)-1 downto operand_width_g*(num_of_operands_g -2));
  alias third_operand   : std_logic_vector is operands_in(operand_width_g*(num_of_operands_g -2)-1 downto operand_width_g*(num_of_operands_g -3));
  alias fourth_operand  : std_logic_vector is operands_in(operand_width_g*(num_of_operands_g -3)-1 downto 0);

  --------------------------------------------------------------------------------
  -- COMPONENTS
  --------------------------------------------------------------------------------

  component adder                                                               -- see the adder.vhd for description
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
  
------------------------------
--------------------------------------------------------------------------------
-- ARCHITECTURE BODY
--------------------------------------------------------------------------------
------------------------------
BEGIN
  
  assert  num_of_operands_g  = 4
  report "Num of operands is not the length it should be"
  severity failure;
  

  ------------------------------------------------------------------------------
  -- BELLOW all componenents mapped to create a 2 layer, 2 - 1 structue... 
  -- this means that it takes 2 clock cycles for the value to 'trickle down'...
  -- to the result

--                 0
--      |OP0-----(_|_)__________
--      |OP1-----( | )          |     2
--      |                       |----(+)----> RESULT
--      |OP2-----(_|_)__________|
    ----|OP3-----( | )
--                 1
  ------------------------------------------------------------------------------
  
  i_compAdd_0 : adder
    generic map (
      operand_width_g => operand_width_g
    )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      a_in            => first_operand,
      b_in            => second_operand,
      sum_out         => subtotal(0)
  );
  
  i_compAdd_1 : adder
    generic map (
      operand_width_g => operand_width_g
    )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      a_in            => third_operand,
      b_in            => fourth_operand,
      sum_out         => subtotal(1)
  );
  i_compAdd_2 : adder
    generic map (
      operand_width_g => operand_width_g+1
    )
    port map (
      clk             => clk,
      rst_n           => rst_n,
      a_in            => subtotal(0),
      b_in            => subtotal(1),
      sum_out         => total 
  );
  
  sum_out <= total(operand_width_g-1 downto 0);         -- finally retun sum of all operands  

END structural;

    