library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_PortComp is
end tb_PortComp;

architecture Behavioral of tb_PortComp is

    -- Component Declaration
    component PortComp is
        Port (
            data   : in  std_logic_vector(11999 downto 0);
            result : out std_logic
        );
    end component;

    -- Testbench signals
    signal data   : std_logic_vector(11999 downto 0) := (others => '0');
    signal result : std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: PortComp
        Port map (
            data   => data,
            result => result
        );

    -- Stimulus process
    stim_proc: process
        variable temp_data : std_logic_vector(11999 downto 0);
    begin

        -- Case 1: Valid Packet (expected result = '1')
        temp_data := (others => '0');

        -- PortI = 1025 -> data(279 downto 272) & data(287 downto 280)
        temp_data(287 downto 280) := std_logic_vector(to_unsigned(1025 mod 256, 8));  -- lower byte
        temp_data(279 downto 272) := std_logic_vector(to_unsigned(1025 / 256, 8));    -- upper byte

        -- Etherdata = 0x0800
        temp_data(111 downto 104) := x"00";
        temp_data(103 downto 96)  := x"08";

        -- Macdata = any non-broadcast
        temp_data(87 downto 40) := (others => '0');

        -- IPdata ≠ 192.168.3.255 (11000000101010000000001111111111)
        temp_data(239 downto 208) := x"C0A80301"; -- 192.168.3.1

        -- Protocol = 0x06 (00000110)
        temp_data(191 downto 184) := "00000110";

        data <= temp_data;
        wait for 10 ns;

        -- Case 2: Invalid Port (expected result = '0')
        temp_data := data;
        temp_data(287 downto 280) := x"01"; -- PortI = 0x0001
        temp_data(279 downto 272) := x"00";
        data <= temp_data;
        wait for 10 ns;

        -- Case 3: Invalid EtherType (expected result = '0')
        temp_data := data;
        temp_data(111 downto 104) := x"FF";
        temp_data(103 downto 96)  := x"FF";
        data <= temp_data;
        wait for 10 ns;

        -- Case 4: Broadcast MAC (expected result = '0')
        temp_data := data;
        temp_data(87 downto 40) := (others => '1');
        data <= temp_data;
        wait for 10 ns;

        -- Case 5: Bad IP address (expected result = '0')
        temp_data := data;
        temp_data(239 downto 208) := x"C0A803FF"; -- 192.168.3.255
        data <= temp_data;
        wait for 10 ns;

        -- Case 6: Unsupported Protocol (expected result = '0')
        temp_data := data;
        temp_data(191 downto 184) := "00000001";
        data <= temp_data;
        wait for 10 ns;

        -- Done
        wait;
    end process;

end Behavioral;
