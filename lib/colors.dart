import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const JewelShopAppColors());
}

class JewelShopAppColors extends StatelessWidget {
  const JewelShopAppColors({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manu Gold Jewel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(255, 190, 10, 1), 
          primary: const Color.fromRGBO(57, 31, 31, 1),
          secondary: const Color.fromRGBO(255, 190, 10, 1),
          surface: Color.fromRGBO(255, 249, 233, 1),
          // selectedTileColor: const Color.fromRGBO(255, 227, 171, 1),
          // topname: color: Color.fromRGBO(255, 240, 198, 1),
        ),
        useMaterial3: true,
      ),
      home: null,
    );
  }
}
