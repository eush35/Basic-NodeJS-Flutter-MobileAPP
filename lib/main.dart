import 'package:flutter/material.dart';
import 'package:mobilprogramlama/CategoryPage.dart';
import 'package:mobilprogramlama/BasketPage.dart';
import 'package:mobilprogramlama/HomePage.dart';
import 'package:mobilprogramlama/RegisterPage.dart';
import 'package:mobilprogramlama/LoginPage.dart';
import 'package:mobilprogramlama/ProductPage.dart';
import 'package:mobilprogramlama/SuccessLogin.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/successlogin': (context) => SuccessLogin(),
      '/categories': (context) => CategoryPage(),
      '/register': (context) => RegisterPage(),
      '/login': (context) => LoginPage(),
      '/product': (context) => ProductPage(),
      '/basket': (context) => BasketPage(passwordHash: ''),
    },
  ));
}