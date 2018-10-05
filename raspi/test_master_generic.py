import wiringpi

SPI_CHANNEL         = 0
SPEED_HZ            = 15600000 #Hz
CHIP_ENABLE_CHANNEL = 0

wiringpi.wiringPiSPISetup(SPI_CHANNEL, SPEED_HZ)
# send 64 bit
buf = bytes([9, 10, 11, 12, 13, 14, 15, 16])
retlen, retdata = wiringpi.wiringPiSPIDataRW(CHIP_ENABLE_CHANNEL, buf)

print("Number of sent bytes: %d" % retlen)
print("%d Bytes received: %s" % (retlen, str(list(retdata))))
