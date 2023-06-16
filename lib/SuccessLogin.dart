import 'package:flutter/material.dart';
import 'CategoryPage.dart';
import 'ProductPage.dart';
import 'HomePage.dart';

void main() {
  runApp(MobilApp());
}

class MobilApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anasayfa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SuccessLogin(),
    );
  }
}

class SuccessLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigasyon', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
        actions: [
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            icon: Icon(Icons.logout_sharp),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Buton rengi
                onPrimary: Colors.white, // Buton yazı rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Buton kenar yuvarlatma
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Buton içi boşluk
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductPage()),
                );
              },
              child: Text('Ürünlere git', style: TextStyle(fontSize: 18.0)),
            ),
            SizedBox(height: 20), // Boşluk eklemek için SizedBox kullanıyoruz
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green, // Buton rengi
                onPrimary: Colors.white, // Buton yazı rengi
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Buton kenar yuvarlatma
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Buton içi boşluk
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoryPage()),
                );
              },
              child: Text('Kategorilere git', style: TextStyle(fontSize: 18.0)),
            ),
          ],
        ),
      ),
    );
  }
}
