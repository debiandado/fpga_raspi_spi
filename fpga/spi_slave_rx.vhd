--------------------------------------------------------------------------------
-- Company:         -
-- Engineer:        debiandado@gmx.de
--
-- Create Date:     2018-10-05 13:01:00
-- Design Name:     spi_slave
-- Module Name:     spi_slave_rx.vhd
-- Project Name:    spi_slave
-- Target Device:   spartan3an starter kit
-- Tool versions:   Xilinx ISE 14.7
-- Description:     
-- Receiving SPI slave block which can work with the Raspberry Pi SPI Master interface.
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

entity spi_slave_rx is
    generic(
        WORD_SIZE :integer := 8
    );
    port(
        clk     :in     std_logic;
        rst_n   :in     std_logic;
        -- pins
        sclk    :in     std_logic;
        mosi    :in     std_logic;
        cs_n    :in     std_logic;
        -- internal interface
        rxd     :buffer std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
        rxd_rdy :buffer std_logic := '0'
    );
end spi_slave_rx;

architecture Behavioural of spi_slave_rx is

    signal   toggle     :std_logic := '0'; -- It changes everytime a word is received.
    signal   old_toggle :std_logic := '0'; -- Method to synch the end of a receiption and the internal interface.
    constant zeros      :std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    
begin
    
    rxd_process: process(sclk, rst_n)
        variable counter :integer range 0 to WORD_SIZE-1 := 0;
    begin
        if rst_n = '0' then
            counter := 0;
            rxd     <= zeros;
            toggle  <= '0';
        elsif rising_edge(sclk) then
            if cs_n = '0' then
                rxd <= rxd(WORD_SIZE-2 downto 0) & mosi;
                if counter + 1 < WORD_SIZE then
                    counter := counter + 1;
                else
                    counter := 0;
                    toggle  <= not toggle;
                end if;
            end if;
        end if;
    end process;
    
    interface :process(clk, rst_n)
    begin
        if rst_n = '0' then
            rxd_rdy    <= '0';
            old_toggle <= '0';
        elsif rising_edge(clk) then
            if old_toggle /= toggle then
                old_toggle <= toggle;
                rxd_rdy <= '1';
            end if;
            if rxd_rdy = '1' then
                rxd_rdy <= '0';
            end if;
        end if;
    end process;

end Behavioural;
