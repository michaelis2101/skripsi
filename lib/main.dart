import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ta_web/firebase_options.dart';
import 'package:ta_web/services/login_handler.dart';
import 'package:ta_web/views/add_device.dart';
import 'package:ta_web/views/device_detail.dart';
import 'package:ta_web/views/login_screen.dart';
import 'package:ta_web/widgets/exportlog_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3ZXl1a2JseXB0a3JiaHdoY2F3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTIwNDg3MDMsImV4cCI6MjAyNzYyNDcwM30.3RpcktL4y6V0Yv_Y6YByAgXJRnPqJZzGg8wah5UjWjI',
      url: 'https://wweyukblyptkrbhwhcaw.supabase.co');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ta_web',
      theme: ThemeData(
          fontFamily: "Nunito",
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      // home: ExportLog(deviceID: '541974269')
      // home: DeviceDetail(deviceName: 'newDevice', deviceID: '541974269')
      // home: DeviceDetail(deviceName: 'ANEMOMETER', deviceID: '316586517')
      // home: DeviceDetail(deviceName: 'anemometer', deviceID: '194606961')
      home: const LoginHandler(),
    );
  }
}
