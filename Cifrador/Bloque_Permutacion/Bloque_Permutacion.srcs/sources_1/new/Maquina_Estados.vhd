library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Maquina_Estados is
    Port ( reset,clock : in std_logic;
           salida: out std_logic_vector(2 downto 0));
end Maquina_Estados;

architecture Behavioral of Maquina_Estados is
signal count : std_logic_vector(2 downto 0);
begin
      process(reset,clock)
        begin
          if (reset = '1') then count <= "000";
          elsif (clock'event and clock = '1') then count <= count + 1;
          end if;
         end process;
         salida <= count;


end Behavioral;
