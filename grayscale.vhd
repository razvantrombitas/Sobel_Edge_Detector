-- Grayscale RTL

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;


entity grayscale is
  port (
    -- RGB input
    r_in : in std_logic_vector(7 downto 0);
    g_in : in std_logic_vector(7 downto 0);
    b_in : in std_logic_vector(7 downto 0);

    -- RGB output
    r_out : out std_logic_vector(7 downto 0);
    g_out : out std_logic_vector(7 downto 0);
    b_out : out std_logic_vector(7 downto 0)
  );
end grayscale; 

architecture rtl of grayscale is

  signal local : std_logic_vector(7 downto 0);

  signal r_local : unsigned(7 downto 0);
  signal g_local : unsigned(7 downto 0);
  signal b_local : unsigned(7 downto 0);

begin

  -- There are 2 possibilities for shift operation: using the shift command or using the concatenation with zeros
  r_local <= shift_right(unsigned(r_in),2);
  g_local <= shift_right(unsigned(g_in),1);
  b_local <= shift_right(unsigned(b_in),4);
  
  --r_local <= unsigned("00" & r_in(7 downto 2));
  --g_local <= unsigned("0" & g_in(7 downto 1));
  --b_local <= unsigned("0000" & b_in(7 downto 4));

  -- The result of bit shifting: local = 0.25R + 0.5G + 0.0625B
  local <= std_logic_vector(r_local + g_local + b_local);
  
  r_out <= std_logic_vector(local);
  g_out <= std_logic_vector(local);
  b_out <= std_logic_vector(local);

end architecture;