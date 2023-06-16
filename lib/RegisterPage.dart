import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerSurname = TextEditingController();
  TextEditingController _controllerGender = TextEditingController();
  TextEditingController _controllerDate = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    _controllerName.dispose();
    _controllerSurname.dispose();
    _controllerGender.dispose();
    _controllerDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kaydol',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controllerEmail,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            TextField(
              controller: _controllerPassword,
              decoration: const InputDecoration(
                labelText: 'Parola',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            TextField(
              controller: _controllerName,
              decoration: const InputDecoration(
                labelText: 'İsim',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: _controllerSurname,
              decoration: const InputDecoration(
                labelText: 'Soyisim',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: _controllerGender,
              decoration: const InputDecoration(
                labelText: 'Cinsiyet',
                prefixIcon: Icon(Icons.people),
              ),
            ),
            TextField(
              controller: _controllerDate,
              decoration: const InputDecoration(
                labelText: 'Doğum Tarihi',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            ElevatedButton(
              onPressed: registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Kaydol'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> registerUser() async {
    final URL = Uri.parse('http://localhostuser/create');
    final body = {
      'email': _controllerEmail.text,
      'password': _controllerPassword.text,
      'name': _controllerName.text,
      'surname': _controllerSurname.text,
      'gender': _controllerGender.text,
      'date': _controllerDate.text,
    };
    final response = await http.post(URL, body: body);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print(response.body);
      // Kayıt başarılı ise işlemler yapılabilir
      if (result['desc'] == 'Üye başarıyla eklendi.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kayıt başarılıdır.'),
            duration: const Duration(seconds: 3),
          ),
        );
        saveCurrentUser(
            result['userID'], _controllerEmail.text, _controllerPassword.text);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: const Text('Kayıt Hatası'),
                content: const Text('Kayıt işlemi başarısız.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tamam'),
                  ),
                ],
              ),
        );
      }
    }
  }

  Future<void> saveCurrentUser(String userID, String email,
      String password) async {
    String passwordHash = sha1.convert(utf8.encode(password)).toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userID', userID);
    await prefs.setString('email', email);
    await prefs.setString('password', passwordHash);
    print('Password Hash: $passwordHash');

    // Ek olarak, aşağıdaki satırı ekleyerek passwordHash değerini ekrana yazdırabilirsiniz.
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Password Hash'),
            content: Text('Password Hash: $passwordHash'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }
}
