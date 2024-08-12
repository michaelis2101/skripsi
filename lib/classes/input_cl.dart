import 'package:flutter/material.dart';
import 'package:ta_web/classes/colors_cl.dart';

class InputStyle {
  InputDecoration fieldStyle = InputDecoration(
    filled: true,
    fillColor: Colors.grey.shade100,
    prefixIconColor: ColorApp.lapisLazuli,
    labelStyle: const TextStyle(color: Colors.grey),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    disabledBorder: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    // hintText: 'Pin Title',
  );

  // ButtonStyle confirmStyle = ButtonStyle(
  //     backgroundColor: MaterialStateProperty<ColorApp.lapisLazuli>,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
}
