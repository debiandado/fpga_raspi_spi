--------------------------------------------------------------------------------
-- Company:         -
-- Engineer:        debiandado@gmx.de
--
-- Create Date:     2018-10-05 13:01:00
-- Design Name:     spi_slave
-- Module Name:     spi_slave_tx.vhd
-- Project Name:    spi_slave
-- Target Device:   spartan3an starter kit
-- Tool versions:   Xilinx ISE 14.7
-- Description:     
-- Transmission SPI slave block which can work with the Raspberry Pi SPI Master interface.
--
-- VHDL Test Bench Created by ISE for module: None.
-- 
-- Dependencies: None.
-- 
-- Revision:
-- None.
-- Additional Comments:
-- None.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spi_slave_tx is
    generic(
        WORD_SIZE :integer := 8
    );
    port(
        clk     :in     std_logic;
        rst_n   :in     std_logic;
        -- pins
        sclk    :in     std_logic;
        cs_n    :in     std_logic;
        miso    :out    std_logic := '0';
        -- interface
        txd     :in     std_logic_vector(WORD_SIZE-1 downto 0);
        txd_rdy :in     std_logic;
        busy    :buffer std_logic := '0'
    );
end spi_slave_tx;

architecture Behavioural of spi_slave_tx is

    signal   data     :std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0'); -- Sample of the txd port.
    signal   s_miso1  :std_logic := '0';  -- Management of the miso in base on the transmission during the sclk.
    signal   s_miso2  :std_logic := '0';  -- Management of the miso in base on the transmission between the cs_n falling edge and the first rising edge of the sclk.
    signal   toggle   :std_logic := '0';  -- Toggled at the tramissione during the toggling sclk and the end of the word transmission.
    constant zeros    :std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal   s_busy1  :std_logic := '0';  -- Management of the busy block in base on the transmission request.
    signal   s_busy2  :std_logic := '0';  -- Management of the busy block in base on the cs_n activation.

begin

    sample_in :process(clk, rst_n)
        variable counter :integer range 0 to 1 := 0;
    begin
        if rst_n = '0' then
            data    <= zeros;
            s_busy1 <= '0';
            counter := 0;
        elsif rising_edge(clk) then
            -- sampling
            if s_busy1 = '0' and txd_rdy = '1' then
                data    <= txd;
                s_busy1 <= '1';
            elsif s_busy1 = '1' and cs_n = '0' and counter = 0 then
                counter := counter + 1;
            elsif s_busy1 = '1' and cs_n = '1' and counter = 1 then
                s_busy1 <= '0';
                data    <= zeros;
                counter := 0;
            end if;
        end if;
    end process;

    txd1 :process(sclk, rst_n)
        variable counter :integer range 0 to WORD_SIZE-1 := 0;
    begin
        if rst_n = '0' then
            s_miso1 <= '0';
            counter := 0;
            toggle  <= '0';
        elsif falling_edge(sclk) then
            if cs_n = '0' then
                -- shift the data 
                if counter < WORD_SIZE-1 then
                    s_miso1 <= data(WORD_SIZE-2-counter);
                    if counter = 0 then
                        toggle <= not toggle;
                    end if;
                end if;
                -- reset the signal
                if counter + 1 < WORD_SIZE then
                    counter := counter + 1;
                else
                    counter := 0;
                    s_miso1 <= '0';
                    toggle  <= '0';
                end if;
            end if;
        end if;
    end process;
    
    txd2 :process(cs_n, rst_n)
    begin
        -- management of the trasmission start
        if rst_n = '0' then
            s_miso2 <= '0';
            s_busy2 <= '0';
        elsif falling_edge(cs_n) then
            s_miso2 <= data(WORD_SIZE-1);
            s_busy2 <= '1';
        end if;
        if cs_n = '1' then
            s_busy2 <= '0';
        end if;
    end process;

    miso <= (s_miso2 and not toggle) or s_miso1;
    
    busy <= s_busy1 or s_busy2;
    
end Behavioural;
