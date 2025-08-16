#define CLK 2	//Connect to CB1
#define DATA 3	//Connect to CB2
#define INT 4	//Connect to IRQB

void setup() {
	digitalWrite(CLK, HIGH);
	pinMode(CLK, OUTPUT);
	pinMode(DATA, INPUT);
	pinMode(INT, INPUT);

	Serial.begin(115200);
}

void loop() {

	int data = 0;
	for (int i=0;i < 8;i++)
	{
		digitalWrite(CLK, LOW);
		digitalWrite(CLK, HIGH);
		int bitin = digitalRead(DATA);
		data = (data << 1) + bitin;
	}
	Serial.println(data, BIN);
	while (true){	//Wait untill MCU reloads Shift register with new values
		int check = digitalRead(INT);
		if (check == HIGH){break;}		
	}

}
