import paho.mqtt.client as mqtt
import random
import time
import ssl

# MQTT Broker details
broker_url = "c197f092.ala.us-east-1.emqxsl.com"
broker_port = 8883  # Secure SSL port
username = "krishantha"
password = "krishantha"

# MQTT topics
topics = {
    "temperature": "air_quality/temperature",
    "humidity": "air_quality/humidity",
    "tvoc": "air_quality/tvoc",
    "eco2": "air_quality/eco2"
}

# Debug log function
def on_log(client, userdata, level, buf):
    print(f"LOG: {buf}")

# Connection callback
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Connected successfully to MQTT Broker!")
    else:
        print(f"❌ Failed to connect, return code {rc}")
        client.loop_stop()  # Stop loop if not connected

# Initialize MQTT client
client = mqtt.Client(client_id="simulator_krishantha", protocol=mqtt.MQTTv311)
client.username_pw_set(username, password)
client.on_log = on_log  # Enable logging
client.on_connect = on_connect

# Configure SSL for secure connection
client.tls_set(cert_reqs=ssl.CERT_NONE)  # Ignore certificate validation (for testing)
client.tls_insecure_set(True)  # Allow insecure SSL (for EMQX testing)

# Connect to the broker
print("🔄 Attempting to connect to the broker...")
client.connect(broker_url, broker_port, 60)

# Publish random sensor data
def simulate_sensor_data():
    client.loop_start()
    
    while not client.is_connected():
        print("⌛ Waiting for connection...")
        time.sleep(2)

    while True:
        temperature = round(random.uniform(20, 35), 2)
        humidity = round(random.uniform(30, 60), 2)
        tvoc = round(random.uniform(0, 600), 2)
        eco2 = round(random.uniform(400, 600), 2)

        # Publish data
        client.publish(topics["temperature"], temperature)
        client.publish(topics["humidity"], humidity)
        client.publish(topics["tvoc"], tvoc)
        client.publish(topics["eco2"], eco2)

        print(f"📡 Published: Temp={temperature}°C, Hum={humidity}%, TVOC={tvoc} ppb, eCO2={eco2} ppm")
        time.sleep(5)

if __name__ == "__main__":
    simulate_sensor_data()
