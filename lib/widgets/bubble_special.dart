import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';

class BubbleSpecialOne extends StatelessWidget {
  final bool isSender;
  final String text;
  final bool tail;
  final Color color;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle textStyle;
  final List<Widget>? actions;

  const BubbleSpecialOne(
      {Key? key,
      this.isSender = true,
      required this.text,
      this.color = Colors.white70,
      this.tail = true,
      this.sent = false,
      this.delivered = false,
      this.seen = false,
      this.textStyle = const TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
      this.actions})
      : super(key: key);

  ///chat bubble builder method
  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (sent) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (delivered) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF97AD8E),
      );
    }
    if (seen) {
      stateTick = true;
      stateIcon = Icon(
        Icons.done_all,
        size: 18,
        color: Color(0xFF92DEDA),
      );
    }

    return Align(
      alignment: isSender ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: CustomPaint(
          painter: SpecialChatBubbleOne(
              color: color,
              alignment: isSender ? Alignment.topRight : Alignment.topLeft,
              tail: tail),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .7,
            ),
            margin: isSender
                ? stateTick
                    ? EdgeInsets.fromLTRB(7, 7, 14, 7)
                    : EdgeInsets.fromLTRB(7, 7, 17, 7)
                : EdgeInsets.fromLTRB(17, 7, 7, 7),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: stateTick
                      ? EdgeInsets.only(right: 20)
                      : EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Column(
                    children: [
                      ...actions ?? [],
                      Text(
                        text,
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                stateIcon != null && stateTick
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: stateIcon,
                      )
                    : SizedBox(
                        width: 1,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
