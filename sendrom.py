import serial

with serial.Serial('/dev/ttyUSB0', 115200, timeout=1) as s:

	print('\n\n\nResetting\n')
	read = b''
	count_wait = 0
	while read != b'D':	  # Check if erasing is complete
		print("Pos: " + str(count_wait), end="\r", flush=True)

		read = s.read()
		if read == b'.':
			count_wait += 1

	
	with open("binary.bin", 'rb') as f:
		data = bytearray(f.read())

	count = 0

	print('\n\n\n')

	for word in data:
		print("Pos: " + str(count) + " Data: " + str(word), end="\r", flush=True)

		bitformat = '{0:08b}'.format(word)  # word is formatted to bits to send indivisual bits to arduino

		for bit in bitformat:
			s.write(bit.encode('ascii')) # converts unicode(bit in unicode format) to ascii bits so the arduino can decode as ascii

		while True:				# checks if arduino is done writing to eeprom to prevent buffer overload
			check = s.read()
			if check == b'Z':
				count += 1
				break
			else:
				print(check)


	print('\n\n\n\n')


	eepromread = s.readlines()

	for line in eepromread:			# Print out what arduino sends afterwards (usually eeprom read)
		print(str(line))






