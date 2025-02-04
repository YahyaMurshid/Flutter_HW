import 'package:flutter/material.dart';


ThemeData lightTheme ({Color? bkColor, sfBkColor,btmNvBkColor,btmNvUnSItColor,btmNvSItColor,appBrColor,txtColor}){
  return ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: sfBkColor,
canvasColor: appBrColor,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: btmNvBkColor,
    unselectedItemColor: btmNvUnSItColor,
    selectedItemColor: btmNvSItColor,
    elevation: 0,
  ),
  bottomAppBarTheme: BottomAppBarTheme(
    color: appBrColor
  ),

    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.normal, //  <-- this auto selects the right color

    ),  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  appBarTheme: AppBarTheme(
    color: appBrColor,
    elevation: 0, toolbarTextStyle: TextTheme(
      titleLarge: TextStyle(
        color: txtColor,
        fontSize: 20,
      ),
     ).bodyLarge, titleTextStyle: TextTheme(
      titleLarge: TextStyle(
        color: txtColor,
        fontSize: 20,
      ),
     ).titleLarge,

  ),
    textTheme: TextTheme(
        bodyLarge:TextStyle(
          color: txtColor,
          fontSize: 20,
        ) ,
        titleLarge:TextStyle(
          color: txtColor,
          fontSize: 20,
        )),
);}
