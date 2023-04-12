library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--k=128
--a=12
--b=6
--r=64 Datablock, textoplano y datos asociados
--Sr=64 bits
--Sc=256
entity Ascon_Cifrador is
  Port (llave: in std_logic_vector(127 downto 0);
        Nonce: in std_logic_vector(127 downto 0);
        datos_Asociados: in std_logic_vector(127 downto 0);
        texto: in std_logic_vector(127 downto 0);
        reset,clock : in std_logic;
        
        texto_Cifrado: out std_logic_vector(127 downto 0);
        tag: out std_logic_vector(127 downto 0));
end Ascon_Cifrador;

architecture Behavioral of Ascon_Cifrador is
component Bloque_Permutacion_Rondas is
  Port (R:in std_logic_vector(63 downto 0);
        C:in std_logic_vector(255 downto 0);
        Ronda:in std_logic;
        S:out std_logic_vector(319 downto 0));
end component;

component Maquina_Estados is
    Port ( reset,clock : in std_logic;
           salida: out std_logic_vector(0 to 2));
           
end component;
alias Texto0: std_logic_vector(63 downto 0) is texto(63 downto 0);
alias Texto1: std_logic_vector(63 downto 0) is texto(127 downto 64);
alias datos_Asociados0: std_logic_vector(63 downto 0) is datos_Asociados(63 downto 0);
alias datos_Asociados1: std_logic_vector(63 downto 0) is datos_Asociados(127 downto 64);
signal absorbidos:  std_logic_vector(63 downto 0);
signal Texto0Cifrado:  std_logic_vector(63 downto 0);
signal Texto1Cifrado:  std_logic_vector(63 downto 0);

signal Estado_Permutado: std_logic_vector(319 downto 0);

signal IV: std_logic_vector(63 downto 0);
signal Estado_Inicial: std_logic_vector(319 downto 0);

signal EstadoA: std_logic_vector(319 downto 0);
signal EstadoB: std_logic_vector(319 downto 0);

signal Estado: std_logic_vector(319 downto 0);
alias sr: std_logic_vector(63 downto 0) is Estado(63 downto 0);
alias sc: std_logic_vector(255 downto 0) is Estado(319 downto 64);

signal srp: std_logic_vector(63 downto 0);
signal scp: std_logic_vector(255 downto 0);

signal estado_contador: std_logic_vector(0 to 2);

signal cte_0k: std_logic_vector(255 downto 0);
signal cte_01: std_logic_vector(255 downto 0);
signal cte_k0: std_logic_vector(255 downto 0);
signal cte:std_logic_vector(255 downto 0);
signal ctexor:std_logic_vector(255 downto 0);
begin
--IV_{k,r,a,b}||K||N
IV<="1000000001000000000011000000011000000000000000000000000000000000";
Estado_Inicial<=IV&llave&Nonce;

 
Estado_Acual: Maquina_Estados port map (reset=>reset,clock=>clock,salida=>estado_contador);
with estado_contador select Estado<=
                      Estado_Inicial when "000",
                      Estado_Permutado when others;
--tag
with estado_contador select tag<=
                      llave xor sc(127 downto 0) when "101",
                      "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" when others;
                      
--
cte_0k<="00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"&llave;
cte_01<="0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
cte_k0<=llave&"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";

with estado_contador select cte<=
                                 cte_0k when "000",
                                 cte_01 when "010",
                                 cte_k0 when others;
ctexor<=cte xor sc;

--
with estado_contador select scp<=
                                ctexor when "000", 
                                ctexor when "010", 
                                ctexor when "100", 
                                sc when others;
--
with estado_contador select absorbidos<=
                                Texto0 when "000",
                                Texto1 when "001",
                                datos_Asociados0 when "010",
                                datos_Asociados0 when "011",
                                "0000000000000000000000000000000000000000000000000000000000000000" when others;
--
with estado_contador select srp<=
                                sr when "100",
                                sr when "101",
                                sr xor absorbidos when others;
--
with estado_contador select Texto0Cifrado<=
                                srp when "010",
                                "0000000000000000000000000000000000000000000000000000000000000000" when others;
with estado_contador select Texto1Cifrado<=
                                srp when "011",
                                "0000000000000000000000000000000000000000000000000000000000000000" when others;
--
with estado_contador select texto_cifrado<=
                                Texto0Cifrado&Texto1Cifrado when "101",
                                "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" when others;                                 
--
PermutacionA: Bloque_Permutacion_Rondas port map (R=>srp,C=>scp,Ronda=>'0',S=>EstadoA);
PermutacionB: Bloque_Permutacion_Rondas port map (R=>srp,C=>scp,Ronda=>'1',S=>EstadoB);
with estado_contador select Estado<=
                                    EstadoA when "000",
                                    EstadoA when "101",
                                    EstadoB when others;
end Behavioral;
