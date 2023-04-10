library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
--12 rondas de A
entity RondaB is
    Port ( reset,clock : in std_logic;
           salida: out std_logic_vector(0 to 3));
end RondaB;

architecture Behavioral of RondaB is
signal count : std_logic_vector(0 to 3);
    begin
      process(reset,clock)
        begin
          if (reset = '1') then count <= "0000";
          elsif (clock'event and clock = '1') then count <= count + 1;
          end if;
         end process;
         salida <= count;

end Behavioral;
