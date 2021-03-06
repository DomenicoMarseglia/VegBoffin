#include <WiFi.h>
#include <PubSubClient.h>
#include "MotorSet.h"


MotorSet motorSet;

// Update these with values suitable for your network.

const char* ssid = "xxx";
const char* password = "password";
const char* mqtt_server = "192.168.1.xx";

WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

void setup_wifi() {

  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  randomSeed(micros());

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  if (strcmp(topic,"vegboffin/tap1") == 0)
  {
    float percentPosition = String((char*)payload).toFloat();     
    motorSet.SetMotorPosition(0, percentPosition);
  } 
  else if (strcmp(topic,"vegboffin/tap2") == 0)
  {
    float percentPosition = String((char*)payload).toFloat();     
    motorSet.SetMotorPosition(1, percentPosition);
  }
  else if (strcmp(topic,"vegboffin/tap3") == 0)
  {
    float percentPosition = String((char*)payload).toFloat();     
    motorSet.SetMotorPosition(2, percentPosition);
  }
  else if (strcmp(topic,"vegboffin/tap4") == 0)
  {
    float percentPosition = String((char*)payload).toFloat();     
    motorSet.SetMotorPosition(3, percentPosition);
  }

  

  // Switch on the LED if an 1 was received as first character
  if ((char)payload[0] == '1') {
    digitalWrite(LED_BUILTIN, LOW);   // Turn the LED on (Note that LOW is the voltage level
    // but actually the LED is on; this is because
    // it is active low on the ESP-01)
  } else {
    digitalWrite(LED_BUILTIN, HIGH);  // Turn the LED off by making the voltage HIGH
  }

}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Create a random client ID
    String clientId = "ESP8266Client-";
    clientId += String(random(0xffff), HEX);
    // Attempt to connect
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish("outTopic", "hello world");
      // ... and resubscribe
      client.subscribe("vegboffin/tap1");
      client.subscribe("vegboffin/tap2");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);     // Initialize the BUILTIN_LED pin as an output
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  motorSet.setup();
}

void loop() {

  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  long now = millis();
  if (now - lastMsg > 2000) {
    lastMsg = now;
    ++value;
    snprintf (msg, 50, "hello world #%ld", value);
    Serial.print("Publish message: ");
    Serial.println(msg);
    client.publish("outTopic", msg);
  }

  motorSet.loop();
}
