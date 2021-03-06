-------------------------------------------------------
-- Project : project or course name
-- Author : Aulis Kaakko (,student number)
-- Date : 2007-30-11 14:05:01
-- File : example.vhd
-- Design : Course exercise 1
------------------------------------------------------
-- Description : This unit does function X so that...
--------------------------------------------------------- $Log$-------------------------------------------------------

-- TODO: Add library called ieee here
--       And use package called std_logic_1164 from the library
library ieee;
use ieee.std_logic_1164.all;

-- TODO: Declare entity here
-- Name: ripple_carry_adder
-- No generics yet
-- Ports: a_in  3-bit std_logic_vector
--        b_in  3-bit std_logic_vector
--        s_out 4-bit std_logic_vector

entity ripple_carry_adder is
	port (
		a_in 	: in std_logic_vector(2 downto 0);
		b_in 	: in std_logic_vector(2 downto 0);
		s_out   : out std_logic_vector(3 downto 0)
	);
end ripple_carry_adder;

-------------------------------------------------------------------------------

-- Architecture called 'gate' is already defined. Just fill it.
-- Architecture defines an implementation for an entity
architecture gate of ripple_carry_adder is
	signal carry_ha 	: std_logic;
	signal carry_fa 	: std_logic;
	signal C,D,E,F,G,H  : std_logic;
  
begin  -- gate
	carry_ha <= a_in(0) AND b_in(0);
	carry_fa <= D OR E;

	C <= a_in(1) XOR b_in(1);
	D <= carry_ha AND C;
	E <= a_in(1) AND b_in(1);
	F <= a_in(2) XOR b_in(2);
	G <= F AND carry_fa;
	H <= a_in(2) AND b_in(2);

-- signals assigned, output calc. values
    s_out(0) <= a_in(0) XOR b_in(0);
    s_out(1) <= C XOR carry_ha;
    s_out(2) <= F XOR carry_fa;
    s_out(3) <= G OR H;

end gate;
