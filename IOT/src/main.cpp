#include <Arduino.h>
#include <Wire.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <WiFiUdp.h>
#include <NTPClient.h>
#include <time.h>

#include "Custom_AHT21.h"
#include "Custom_ENS160.h"

#define DEBUG 1

#if DEBUG == 1
#define debug(x) Serial.print(x)
#define debugln(x) Serial.println(x)
#else
#define debug(x)
#define debugln(x)
#endif

// WiFi credentials
const char *WIFI_SSID = "Galaxy M13";
const char *WIFI_PASSWORD = "krishantha256";

// MQTT broker settings
const char *MQTT_HOST = "c197f092.ala.us-east-1.emqxsl.com";
const char *MQTT_USER = "krishantha";
const char *MQTT_PASWORD = "krishantha";
#define MQTT_PORT 8883

// MQTT topics
#define ECO2_TOPIC "air_quality/eco2"
#define HUMIDITY_TOPIC "air_quality/humidity"
#define TVOC_TOPIC "air_quality/tvoc"
#define TEMPERATURE_TOPIC "air_quality/temperature"

#define LED_PIN 2

// I2C Pins
#define SDA_PIN 21
#define SCL_PIN 22
#define I2C_FREQUENCY 100000 // 100 kHz

long lastMsg = 0;

I2cInterface i2c;

WiFiClientSecure wifiSecure;
PubSubClient client(wifiSecure);
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org", 0, 60000);

CustomAHT21 aht21;
CustomENS160 ens160;

/**
 * @brief Initializes the WiFi connection.
 */
void initializeWiFi()
{
    debugln("\n🔄 [WiFi] Connecting...");
    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    debug("[WiFi] Connecting to: ");
    debugln(WIFI_SSID);

    while (WiFi.status() != WL_CONNECTED)
    {
        debug(".");
        delay(500);
    }
    debugln("\n✅ [WiFi] Connected!");
    debug("[WiFi] IP Address: ");
    debugln(WiFi.localIP());
}

/**
 * @brief Initializes the MQTT connection.
 */
void initializeMqtt()
{
    debugln("\n🔄 [MQTT] Setting up secure connection...");

    wifiSecure.setInsecure(); // Allow insecure SSL like in Python
    client.setServer(MQTT_HOST, MQTT_PORT);
    
    String clientId = "esp32_client";

    while (!client.connected())
    {
        debugln("[MQTT] Connecting to broker...");
        if (client.connect(clientId.c_str(), MQTT_USER, MQTT_PASWORD))
        {
            debugln("✅ [MQTT] Successfully connected!");
            digitalWrite(LED_PIN, HIGH);
        }
        else
        {
            debug("[MQTT] Failed, rc=");
            debug(client.state());
            debugln(" ❌ Retrying in 5 seconds...");
            delay(5000);
        }
    }
}

/**
 * @brief Initializes debugging settings.
 */
void initializeDebugging()
{
    Serial.begin(115200);
    debugln("🔍 [Debug] Debugging initialized");
}

/**
 * @brief Initializes I2C communication.
 */
void initializeI2C()
{
    debugln("🔄 [I2C] Initializing...");
    Wire.begin(SDA_PIN, SCL_PIN, I2C_FREQUENCY);
    i2c.begin(Wire, ENS160_I2C_ADDRESS);
    debugln("✅ [I2C] Initialized.");
}

/**
 * @brief Initializes sensors.
 */
void initializeSensors()
{
    debugln("\n🔄 [Sensors] Initializing...");
    
    debug("[Sensors] ENS160... ");
    ens160.begin(&i2c);
    debugln("✅ Done.");

    debug("[Sensors] AHT21... ");
    aht21.begin();
    debugln("✅ Done.");
}

/**
 * @brief Publishes sensor data to MQTT topics.
 */
void publishSensorData()
{
    debugln("\n📡 [Publishing] Collecting sensor data...");

    AHT21Data aht21d = aht21.read();
    ENS160Data ens160d = ens160.read();

    debug("[Sensor] Temperature: "); debug(aht21d.temp); debugln(" °C");
    debug("[Sensor] Humidity: "); debug(aht21d.humidity); debugln(" %");
    debug("[Sensor] TVOC: "); debug(ens160d.tvoc); debugln(" ppb");
    debug("[Sensor] eCO2: "); debug(ens160d.eco2); debugln(" ppm");

    char tempBuffer[10], humidBuffer[10], tvocBuffer[10], eco2Buffer[10];

    dtostrf(aht21d.temp, 4, 2, tempBuffer);
    dtostrf(aht21d.humidity, 4, 2, humidBuffer);
    dtostrf(ens160d.tvoc, 4, 2, tvocBuffer);
    dtostrf(ens160d.eco2, 4, 2, eco2Buffer);

    client.publish(TEMPERATURE_TOPIC, tempBuffer);
    client.publish(HUMIDITY_TOPIC, humidBuffer);
    client.publish(TVOC_TOPIC, tvocBuffer);
    client.publish(ECO2_TOPIC, eco2Buffer);

    debugln("✅ [MQTT] Published all sensor data.");
}

/**
 * @brief ESP32 setup function.
 */
void setup()
{
    debugln("\n🚀 [Setup] Starting...");
    pinMode(LED_PIN, OUTPUT);

    initializeDebugging();
    initializeWiFi();
    initializeMqtt();
    initializeI2C();
    initializeSensors();

    timeClient.begin();
    timeClient.setTimeOffset(0);
    debugln("\n✅ [Setup] Complete.");
}

/**
 * @brief ESP32 main loop function.
 */
void loop()
{
    if (WiFi.status() != WL_CONNECTED)
    {
        debugln("\n❌ [WiFi] Disconnected! Reconnecting...");
        initializeWiFi();
    }

    if (!client.connected())
    {
        digitalWrite(LED_PIN, LOW);
        debugln("\n❌ [MQTT] Disconnected! Reconnecting...");
        initializeMqtt();
    }

    long now = millis();
    if (now == 0 || now - lastMsg > 4000)
    {
        lastMsg = now;
        publishSensorData();
    }

    client.loop();
}