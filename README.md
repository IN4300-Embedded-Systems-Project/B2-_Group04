## IoT-based Indoor Air Quality Monitoring System

### Description
Indoor air quality is crucial for maintaining a healthy and comfortable environment. Poor air quality, caused by excessive **CO₂**, **VOCs**, and unsuitable **temperature and humidity** levels, can lead to health issues and decreased productivity.

This project, developed by **SyncCore**, aims to create an IoT-based **Indoor Air Quality Monitoring System** that continuously tracks key environmental factors:
- **Temperature**
- **Humidity**
- **Equivalent CO₂ (eCO₂)**
- **Total Volatile Organic Compounds (TVOC)**

Using the **ESP32 microcontroller**, sensor readings are transmitted to an **MQTT-based backend server** over Wi-Fi. The collected data is processed, analyzed, and displayed on a **real-time dashboard**, allowing users to monitor air quality trends and take action when necessary.

### Features
- **Real-time Monitoring:** Continuously tracks and updates air quality parameters.
- **Interactive Dashboard:** Displays data trends and alerts through an intuitive interface.
- **IoT Connectivity:** Uses Wi-Fi and MQTT protocols for efficient communication.
- **Scalability:** Can be extended with additional sensors and multiple locations.
- **Instant Alerts:** Notifies users when air quality parameters exceed safe thresholds.

### Components Used

#### **Hardware Components**
- **ESP32 Microcontroller** – Handles data acquisition and transmission.
- **ENS160 Sensor** – Measures eCO₂ and TVOC levels.
- **AHT21 Sensor** – Measures temperature and humidity.
- **Power Supply** – 5V adapter or battery pack for ESP32.
- **Jumper Wires** – For sensor connections.
- **Breadboard** – For circuit assembly.
- **Built-in ESP32 Wi-Fi Module** – Enables wireless data transmission.
- **LED Indicators** – Provides status updates.
- **Casing/Enclosure** – Protects sensors and circuit components.

#### **Software Components**
- **PlatformIO** – Used for ESP32 programming and project management.
- **Python** – Supports data flow simulation.
- **Flutter** – Mobile application development for real-time monitoring.
- **Visual Studio Code (VS Code)** – IDE for software development.
- **EMQX MQTT Broker** – Handles real-time communication between ESP32 and the backend.

### Circuit Diagram
