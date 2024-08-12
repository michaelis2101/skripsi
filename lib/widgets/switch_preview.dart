import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:ta_web/classes/colors_cl.dart';

class SwitchPreview extends StatefulWidget {
  // bool switchVal;
  String title;
  SwitchPreview({super.key, required this.title});

  @override
  State<SwitchPreview> createState() => _SwitchPreviewState();
}

class _SwitchPreviewState extends State<SwitchPreview> {
  bool sValue = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.title,
                      style:
                          const TextStyle(fontFamily: 'Nunito', fontSize: 20)),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              width: 80,
              child: Center(
                child: AnimatedToggleSwitch.dual(
                  current: sValue,
                  first: false,
                  height: 100,

                  // indicatorSize: Size.fromHeight(height * 0.5),
                  indicatorSize: const Size.fromWidth(100),
                  second: true,
                  // spacing: 50,
                  borderWidth: 10.0,
                  iconBuilder: (value) => value == false
                      ? const Icon(
                          Icons.power_settings_new_rounded,
                          size: 50,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.power_settings_new_rounded,
                          size: 50,
                          color: Colors.green,
                        ),
                  textBuilder: (value) => value == false
                      ? const Center(
                          child: Text(
                          'Off',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 50),
                        ))
                      : const Center(
                          child: Text(
                            'On',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Nunito',
                                fontSize: 50),
                          ),
                        ),
                  styleBuilder: (value) => ToggleStyle(
                      backgroundColor:
                          value == false ? Colors.red : Colors.green,
                      indicatorColor:
                          value == false ? Colors.white : Colors.white),
                  style: ToggleStyle(
                      borderColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black26,
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1.5),
                        ),
                      ],
                      indicatorBorderRadius: BorderRadius.circular(100)

                      // indicatorColor: ColorApp.lightLapisLazuli,
                      ),
                  onChanged: (value) {
                    setState(() {
                      sValue = value;
                    });
                    // print(sValue);
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
