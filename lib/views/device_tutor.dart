import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ta_web/classes/colors_cl.dart';

class SendValueTutorial extends StatelessWidget {
  String deviceId;

  SendValueTutorial({super.key, required this.deviceId});

  User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    String completeExample = '''
#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

#define WIFI_SSID "Your WiFi SSiD"
#define WIFI_PASSWORD "*your wifi password"

#define API_KEY "AIzaSyAbBIkZKdUUZr-Nm5I1UAM991fiZOm37eY"
#define DATABASE_URL "https://project-st-iot-default-rtdb.firebaseio.com/" 

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("Wifi Connected");
  }
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  auth.user.email = "user registered email";
  auth.user.password = "user password";

  Firebase.reconnectNetwork(true);
  fbdo.setBSSLBufferSize(4096, 1024);

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Firebase.setDoubleDigits(5);
}

void loop() {
  float val1 = random(0,100);
  float val2 = random(0,200);

  if(Firebase.ready()) {
    // This is how to send data
    Firebase.setInt(fbdo, "/devices/$deviceId/value/val1", val1);
    Firebase.setInt(fbdo, "/devices/$deviceId/value/val2", val2);

    // This is how to fetch data
    Firebase.getInt(fbdo, "/devices/$deviceId/value/val2", &val2);

    Serial.println(val2);
  }
  delay(2000);
}
''';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ColorApp.lapisLazuli,
                width: 1,
              )),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'How to Connect The Device',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: ColorApp.lapisLazuli,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '1',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const Text(
                            ' Open Arduino IDE and install the Firebase Arduino Client Library for ESP8266 and ESP32 by Mobitz',
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset('assets/picture/step1.png')),
                  const SizedBox(
                    height: 10,
                  ),
                  IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: ColorApp.lapisLazuli,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '2',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const Text(
                            ' Create New Project Then Import <FirebaseESP32.h> if you using ESP32 or <FirebaseESP8266.h> if you using ESP8266',
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/picture/step2.png'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: ColorApp.lapisLazuli,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '3',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const Text(' Define the API key and the database URL',
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    // height: 200,
                    width: 620,
                    decoration: BoxDecoration(
                        color: ColorApp.tutorialBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(const ClipboardData(
                                      text:
                                          '#define API_KEY "AIzaSyAbBIkZKdUUZr-Nm5I1UAM991fiZOm37eY"\n#define DATABASE_URL"https://project-st-iot-default-rtdb.firebaseio.com/"'));
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                  size: 16,
                                )),
                          ),
                          const Text(
                            '#define API_KEY "AIzaSyAbBIkZKdUUZr-Nm5I1UAM991fiZOm37eY"',
                            style: TextStyle(color: Colors.white),
                          ),
                          const Text(
                            '#define DATABASE_URL "https://project-st-iot-default-rtdb.firebaseio.com/"',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: ColorApp.lapisLazuli,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '4',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const Text(' Define the variables for setup',
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    // height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        color: ColorApp.tutorialBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(const ClipboardData(
                                      text:
                                          'FirebaseData fbdo;\nFirebaseAuth auth;\nFirebaseConfig config;'));
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                  size: 16,
                                )),
                          ),
                          const Text(
                            'FirebaseData fbdo;\nFirebaseAuth auth;\nFirebaseConfig config;',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: ColorApp.lapisLazuli,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '5',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const Text(' Setup the Firebase connection',
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    // height: 200,
                    width: 620,
                    decoration: BoxDecoration(
                        color: ColorApp.tutorialBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          'void  setup()\n{\n //WiFi Setup\n ...\n config.api_key = API_KEY;\n config.database_url = DATABASE_URL;\n auth.user.email = ${user.email};\n auth.user.password = "*your account password";\n Firebase.reconnectNetwork(true);\n fbdo.setBSSLBufferSize(4096, 1024);\n Firebase.begin(&config, &auth);\n Firebase.reconnectWiFi(true);\n Firebase.setDoubleDigits(5);\n}'));
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                  size: 16,
                                )),
                          ),
                          Text(
                            'void  setup()\n{\n //WiFi Setup\n ...\n config.api_key = API_KEY;\n config.database_url = DATABASE_URL;\n auth.user.email = ${user.email};\n auth.user.password = "*your account password";\n Firebase.reconnectNetwork(true);\n fbdo.setBSSLBufferSize(4096, 1024);\n Firebase.begin(&config, &auth);\n Firebase.reconnectWiFi(true);\n Firebase.setDoubleDigits(5);\n}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  IntrinsicWidth(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: ColorApp.lapisLazuli,
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '6',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const Text(' Send the Data',
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    // height: 200,
                    width: 700,
                    decoration: BoxDecoration(
                        color: ColorApp.tutorialBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          "void loop()\n{\n float val1 = random(0,100);\n float val2 = random(0,200);\n if(Firebase.ready()){\n //here is how to send data to server\n //Firebase.setInt(fbdo,\"/devices/'deviceId'/value/variable_name\", variable_name);\n //example\n Firebase.setInt(fbdo, \"/devices/$deviceId/value/val1\", val1);\n Firebase.setInt(fbdo, \"/devices/$deviceId/value/val2\", val2);\n //here is how to fetch the data from server\n //Firebase.getInt(fbdo, \"/devices/'deviceId'/value/variable_name\", &variable_name);\n//example\nFirebase.getInt(fbdo, \"/devices/$deviceId/value/val1\", &val1);\nSerial.println(val1);\n}\ndelay(2000);\n}"));
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                  size: 16,
                                )),
                          ),
                          Text(
                            "void loop()\n{\n float val1 = random(0,100);\n float val2 = random(0,200);\n if(Firebase.ready()){\n //here is how to send data to server\n //Firebase.setInt(fbdo,\"/devices/'deviceId'/value/variable_name\", variable_name);\n //example\n Firebase.setInt(fbdo, \"/devices/$deviceId/value/val1\", val1);\n Firebase.setInt(fbdo, \"/devices/$deviceId/value/val2\", val2);\n //here is how to fetch the data from server\n //Firebase.getInt(fbdo, \"/devices/'deviceId'/value/variable_name\", &variable_name);\n //example\n Firebase.getInt(fbdo, \"/devices/$deviceId/value/val1\", &val1);\n Serial.println(val1); \n } \n delay(2000);\n}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                      'This is the complete example code to send and fetch data from and to this device',
                      style: TextStyle(fontSize: 20)),
                  Container(
                    // height: 200,
                    width: 700,
                    decoration: BoxDecoration(
                        color: ColorApp.tutorialBg,
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: completeExample));
                                },
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                  size: 16,
                                )),
                          ),
                          Text(
                            completeExample,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
