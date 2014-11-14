
long int switchState = 0;
long int prevState = 0;




void setup () {
  pinMode (2,OUTPUT);
  pinMode (3,INPUT);
  Serial.begin (9600);

}

void loop () {

    switchState = digitalRead(3);
    if (switchState == HIGH) {
      digitalWrite (2, HIGH);
      if (prevState != switchState) {
        Serial.print("O");
        prevState = HIGH;
      }
    } else {
      digitalWrite(2, LOW);
      if (prevState != switchState) {
        Serial.print("C");
        prevState = LOW;
      }
    delay (10);
    }
}
