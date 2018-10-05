--------------------------------------------------------------------------------
-- Company:         -
-- Engineer:        debiandado@gmx.de
--
-- Create Date:     2018-10-05 13:01:00
-- Design Name:     spi_slave
-- Module Name:     spi_slave.vhd
-- Project Name:    spi_slave
-- Target Device:   spartan3an starter kit
-- Tool versions:   Xilinx ISE 14.7
-- Description:     
-- SPI slave block which can work with the Raspberry Pi SPI Master interface.
--
-- VHDL Test Bench Created by ISE for module: None.
-- 
-- Dependencies: spi_slave_rx.vhd, spi_slave_tx.vhd
-- 
-- Revision:
-- None.
-- Additional Comments:
-- None.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity description
-- WORD_SIZE:   SPI transmission word length in bits;
-- clk:         clock reference for the interface tx/rx;
-- rst_n:       active low asynchronous reset;
-- sclk:        SPÍ serial clock;
-- miso:        SPI Master In Serial Out;
-- mosi:        SPI Master Out Serial In;
-- cs_n:        SPI active low chip select;
-- txd:         data that has to be sent to the SPI Master Device;
-- txd_rdy:     active high signal which indicates that the data on the txd port are ready to be read;
-- txd_busy:    the transmission circuitry is busy, so everything on the ports txd and txd_rdy will be ignored;
-- rxd:         data which is arrived from the SPI Master Device;
-- rxd_rdy:     the data on the rxd port are just arrived and it is ready to be read.

-- SPI slave device description
-- mode: 0 -> CPHA and CPOL are both 0;
-- max speed tested: clk = 133MHz, sclk = 15.6MHz;
-- word size tested: 8, 16 and 64 bits.

entity spi_slave is
    generic(
        WORD_SIZE :integer := 8
    );
    port(
        clk      :in     std_logic;
        rst_n    :in     std_logic;
        -- pins
        sclk     :in     std_logic;
        mosi     :in     std_logic;
        miso     :out    std_logic := '0';
        cs_n     :in     std_logic;
        -- internal interface tx
        txd      :in     std_logic_vector(WORD_SIZE-1 downto 0);
        txd_rdy  :in     std_logic;
        txd_busy :buffer std_logic := '0';
        -- internal interface rx
        rxd      :buffer std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
        rxd_rdy  :buffer std_logic := '0'
    );
end spi_slave;

architecture Behavioural of spi_slave is
begin

    spi_slave_rx_inst :entity work.spi_slave_rx
        generic map(
            WORD_SIZE => WORD_SIZE
        )
        port map(
            clk      => clk,
            rst_n    => rst_n,
            -- pins  
            sclk     => sclk,
            mosi     => mosi,
            cs_n     => cs_n,
            -- interface 
            rxd      => rxd,
            rxd_rdy  => rxd_rdy
        );
        
    spi_slave_tx_inst :entity work.spi_slave_tx
        generic map(
            WORD_SIZE => WORD_SIZE
        )
        port map(
            clk      => clk,
            rst_n    => rst_n,
            -- pins 
            sclk     => sclk,
            cs_n     => cs_n,
            miso     => miso,
            -- interface 
            txd      => txd,
            txd_rdy  => txd_rdy,
            busy     => txd_busy
        );
    
end Behavioural;
