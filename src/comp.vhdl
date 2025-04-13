library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PortComp is
    Port (
        data   : in  std_logic_vector(11999 downto 0);
        result : out std_logic
    );
end PortComp;

architecture BehavioralPortComp of PortComp is
    signal PortI     : std_logic_vector(15 downto 0);
    signal Etherdata : std_logic_vector(15 downto 0);
    signal Macdata : std_logic_vector(47 downto 0);
    signal IPdata  : std_logic_vector(31 downto 0);
    signal Protocol: std_logic_vector(7 downto 0);
begin

    PortI     <= data(279 downto 272) & data(287 downto 280);
    Etherdata <= data(103 downto 96)  & data(111 downto 104);
    Macdata   <= data(87 downto 40);
    IPdata    <= data(239 downto 208);
    Protocol  <= data(191 downto 184);

    process(PortI, Etherdata, Macdata, IPdata, Protocol)
    variable uslovi: boolean;
    begin
    if Protocol = "00000110" or 
           Protocol = "00010111" then
            uslovi := true;
        else
            uslovi := false;
        end if;
        
        if to_integer(unsigned(PortI)) < 1024 or
           (Etherdata(15 downto 8) /= x"08" or Etherdata(7 downto 0) /= x"00")
           or (Macdata = "111111111111111111111111111111111111111111111111") or 
           (IPdata = "11000000101010000000001111111111") or 
           uslovi = false then
            result <= '0';
        else
            result <= '1';
        end if;
    end process;

end BehavioralPortComp;
