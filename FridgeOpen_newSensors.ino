
int switchState = 0;
int prevState = 0;
const float lightThreshold = 0.7;
int sensorValue = 0, sensorHigh = 0, sensorLow = 1023, lightLevel = 0, tempLevel=0, tempLevelOld=0;
const long int tempInterval = 60000;
long int prevWrite= 0;

void setup () {
  //5 sekundes lai noteiktu gaismas sensora diapazonu
  Serial.begin (9600);
  //Serial.println("Calibration...");
  pinMode(13, OUTPUT);  
  digitalWrite(13,HIGH);
  while (millis() < 10000) {
    sensorValue = analogRead(1);
    Serial.println(sensorValue);
    if (sensorValue > sensorHigh) {
      sensorHigh = sensorValue;
    }
    if (sensorValue < sensorLow) {
      sensorLow = sensorValue;
    }
    tempLevel = analogRead(0);
    Serial.println (sensorHigh);  
    delay (500);
  }
  digitalWrite(13,LOW);
  prevWrite=millis();
/*  Serial.println("Calibration Done (H/L)");
  Serial.println (sensorHigh);
  Serial.println (sensorLow);*/
}

void loop () {

    lightLevel = analogRead(1);
//    Serial.println(lightLevel);
    lightLevel = constrain(lightLevel, sensorLow, sensorHigh);
    if (lightLevel > sensorLow+lightThreshold*sensorHigh) {
      switchState = HIGH;
      digitalWrite (13, HIGH);
      if (prevState != switchState) {
        Serial.print("O");
        prevState = HIGH;
      }
    } else {
      switchState = LOW;
      digitalWrite(13, LOW);
      if (prevState != switchState) {
        Serial.print("C");
        prevState = LOW;
      }
    }
    delay (500);
    if ((millis()-prevWrite) > tempInterval) {
      prevWrite=millis();
      Serial.print("T");
      tempLevel = analogRead(0);
      float temperatura = 59.0-tempLevel/10.0; //Calibration needed
      Serial.println (temperatura);
    } 
}
