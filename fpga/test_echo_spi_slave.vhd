library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_echo_spi_slave is
    generic(
        WORD_SIZE :integer := 8
    );
    port(
        clk     :in  std_logic;
        rst_n   :in  std_logic;
        --
        sclk    :in  std_logic;
        miso    :out std_logic := '0';
        mosi    :in  std_logic;
        cs_n    :in  std_logic;
        -- 
        led     :out std_logic_vector(7 downto 0) := (others => '0')
    );
end test_echo_spi_slave;

architecture Behavioural of test_echo_spi_slave is

    signal s_txd      :std_logic_vector(7 downto 0) := (others => '0');
    signal s_txd_rdy  :std_logic := '0';
    signal s_txd_busy :std_logic := '0';
    signal s_rxd      :std_logic_vector(7 downto 0) := (others => '0');
    signal s_rxd_rdy  :std_logic := '0';
    
    signal flag       :boolean   := false;
    
    constant zeros    :std_logic_vector(7 downto 0) := (others => '0');

begin

    spi_slave_int :entity work.spi_slave
        generic map(
            WORD_SIZE => 8
        )
        port map(
            clk       => clk,
            rst_n     => rst_n,
            -- pins   
            sclk      => sclk,
            mosi      => mosi,
            miso      => miso,
            cs_n      => cs_n,
            -- interface tx
            txd       => s_txd,
            txd_rdy   => s_txd_rdy,
            txd_busy  => s_txd_busy,
            -- interface rx
            rxd       => s_rxd,
            rxd_rdy   => s_rxd_rdy
        );
        
    echo :process(clk, rst_n)
    begin
        if rst_n = '0' then
            flag       <= false;
            led        <= zeros;
            s_txd      <= zeros;
            s_txd_rdy  <= '0';
        elsif rising_edge(clk) then
            if s_rxd_rdy = '1' and flag = false then
                s_txd  <= s_rxd;
                flag <= true;
                led  <= s_rxd;
            end if;
            if flag = true and s_txd_busy = '0' then
                s_txd_rdy <= '1';
            end if;
            if s_txd_rdy = '1' then
                s_txd_rdy <= '0';
                flag      <= false;
            end if;
        end if;
    end process;

end Behavioural;
