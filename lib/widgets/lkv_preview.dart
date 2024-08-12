import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LKVPreview extends StatefulWidget {
  String title;
  LKVPreview({super.key, required this.title});

  @override
  State<LKVPreview> createState() => _LKVPreviewState();
}

class _LKVPreviewState extends State<LKVPreview> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (widget.title.isNotEmpty)
          Expanded(
            child: Container(
              height: 130,
              // color: Colors.yellowAccent,
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
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          Container(
            height: 170,
            // color: Colors.red,
            child: Align(
              alignment: Alignment.topCenter,
              child: Expanded(
                child: const Text(
                  overflow: TextOverflow.ellipsis,
                  'String',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 45),
                ).animate().fadeIn(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
