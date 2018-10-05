# fpga_raspi_spi

VHDL module with the description of the SPI compatible with the Raspbery Pi device.

In the fpga folder it is located the vhdl files ready to be syntetized and the bit files for the spartan3an starter kit. 
The echo test is will be send data received during the following transmission. See the file spi_slave.vhd for the documentation
of the entity.

The raspi folder contains the python file associated to the SPI number 0 of the Raspberry Pi, which is using the CS n.0. The requirement 
file is useful for install the required libraries.

see the blog debiandado.com for the related article: http://debiandado.com/#bigpost?pk=11
