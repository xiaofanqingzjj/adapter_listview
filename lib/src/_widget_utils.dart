import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


///
/// 快速的创建一个Text
///
Widget quickText(String text,
    {double textSize = 14,
      Color color,
      bool isWeight = false,
      int maxLines = 99999,
      TextAlign textAlign,

      double paddingLeft = 0,
      double paddingTop = 0,
      double paddingRight = 0,
      double paddingBottom = 0,

      double marginLeft = 0,
      double marginTop = 0,
      double marginRight = 0,
      double marginBottom = 0,

      double width,
      double height,
      Color backgroundColor,

      AlignmentGeometry alignment,}) {
//  print("quick text ------- color:$color");

  if (color == null) {
    color = Colors.black;
  }

  Widget result = null;

  if (text == null) {
    text = "";
  }

  final textWidget = Text(
    text,
    textAlign:  textAlign,
    style: TextStyle(
      fontSize: textSize,
      color: color,
      fontWeight: isWeight ? FontWeight.bold : FontWeight.normal,
    ),
    maxLines: maxLines,
  );

  result = textWidget;

  if (paddingLeft != 0
      || paddingTop != 0
  ) {

  }

  result = quickContainer(textWidget,

      paddingLeft: paddingLeft,
      paddingTop: paddingTop,
      paddingRight: paddingRight,
      paddingBottom: paddingBottom,

      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,

      width: width,
      height: height,

      color: backgroundColor,
      alignment: alignment
  );

  return result;
}

///
/// 快速的创建一个Text 以及边距
///
///
Widget quickTextWithContainer(String text,
    {double textSize = 14,
      Color color,
      bool isWeight = false,
      int maxLines = 99999,

      double paddingLeft = 0,
      double paddingTop = 0,
      double paddingRight = 0,
      double paddingBottom = 0,

      double marginLeft = 0,
      double marginTop = 0,
      double marginRight = 0,
      double marginBottom = 0,

      double width,
      double height,
      Color backgroundColor,
      AlignmentGeometry alignment,}) {
  if (text == null) text = "";
  if (color == null) color = Colors.black;

  return Container(
    child:
    quickText(text, textSize: textSize,
        color: color,
        isWeight: isWeight,
        maxLines: maxLines),
    padding: EdgeInsets.fromLTRB(
        paddingLeft, paddingTop, paddingRight, paddingBottom),
    margin:
    EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom),

    width: width,
    height: height,
    color: backgroundColor,
    alignment: alignment,
  );
}

///
/// 快速创建Container
///
Widget quickContainer(Widget content,
    {double paddingLeft = 0,
      double paddingTop = 0,
      double paddingRight = 0,
      double paddingBottom = 0,

      double marginLeft = 0,
      double marginTop = 0,
      double marginRight = 0,
      double marginBottom = 0,

      double width,
      double height,
      Color color,

      double borderRadius,
      AlignmentGeometry alignment,

      GestureTapCallback onTap,

    }) {



  BoxDecoration decoration = BoxDecoration(
//      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      color: color,

  );

  Widget result = Container(
    alignment: alignment,
    child: content,
    width: width,
    height: height,
    decoration: decoration,
    padding: EdgeInsets.fromLTRB(
        paddingLeft, paddingTop, paddingRight, paddingBottom),
    margin:EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom),
  );

  if (onTap != null) {
    result = GestureDetector(
      child: result,
      onTap: onTap,
    );
  }

  return result;
}

/// 快速创建一个小间隔
Widget quickGap({double width=0, double height =0}) {
  return SizedBox(width: width, height: height,);
}
