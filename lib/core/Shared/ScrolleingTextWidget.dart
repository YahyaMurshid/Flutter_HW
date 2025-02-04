import 'dart:async';
import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Axis scrollAxis;
  final double ratioOfBlankToScreen;

  const ScrollingText({
    Key? key,
    required this.text,
    required this.textStyle,
    required this.scrollAxis,
    required this.ratioOfBlankToScreen,
  }) : super(key: key);

  @override
  ScrollingTextState createState() => ScrollingTextState();
}

class ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late ScrollController scrollController;
  late double screenWidth;
  late double screenHeight;
  double position = 0.0;
  Timer? timer;
  final double _moveDistance = 3.0;
  final int _timerRest = 100;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startTimer();
    });
  }

  void startTimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _key.currentContext == null) return;

      final renderObject = _key.currentContext!.findRenderObject();
      if (renderObject is! RenderBox) return;

      double widgetWidth = renderObject.size.width;
      double widgetHeight = renderObject.size.height;
      double maxScrollExtent = scrollController.position.maxScrollExtent;

      timer = Timer.periodic(Duration(milliseconds: _timerRest), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        double pixels = scrollController.position.pixels;
        if (pixels + _moveDistance >= maxScrollExtent) {
          position = widget.scrollAxis == Axis.horizontal
              ? (maxScrollExtent -
                      screenWidth * widget.ratioOfBlankToScreen +
                      widgetWidth) /
                  2 -
                  widgetWidth +
                  pixels -
                  maxScrollExtent
              : (maxScrollExtent -
                      screenHeight * widget.ratioOfBlankToScreen +
                      widgetHeight) /
                  2 -
                  widgetHeight +
                  pixels -
                  maxScrollExtent;
          scrollController.jumpTo(position);
        }

        position += _moveDistance;
        scrollController.animateTo(position,
            duration: Duration(milliseconds: _timerRest), curve: Curves.linear);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  Widget getBothEndsChild() {
    if (widget.scrollAxis == Axis.vertical) {
      String newString = widget.text.split("").join("\n");
      return Center(
        child: Text(
          newString,
          style: widget.textStyle,
          textAlign: TextAlign.center,
        ),
      );
    }
    return Center(
      child: Text(
        widget.text,
        style: widget.textStyle,
      ),
    );
  }

  Widget getCenterChild() {
    return widget.scrollAxis == Axis.horizontal
        ? Container(width: screenWidth * widget.ratioOfBlankToScreen)
        : Container(height: screenHeight * widget.ratioOfBlankToScreen);
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: _key,
      scrollDirection: widget.scrollAxis,
      controller: scrollController,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        getBothEndsChild(),
        getCenterChild(),
        getBothEndsChild(),
      ],
    );
  }
}
