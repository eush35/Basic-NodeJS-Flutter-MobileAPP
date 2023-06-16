import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilprogramlama/SuccessLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'Users.dart';
import 'SuccessLogin.dart';
import 'BasketPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static String passwordHash = '';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  String passwordHash = '';

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Giriş Yap',
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
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            TextField(
              controller: _controllerPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Parola',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            ElevatedButton(
              onPressed: loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Giriş Yap'),

            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginUser() async {
    final URL = Uri.parse('http://localhostuser/login');
    final body = {
      'email': _controllerEmail.text,
      'password': _controllerPassword.text,
    };

    final response = await http.post(URL, body: body);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print(response.body);

      if (result != null && result['desc'] == "Giriş başarılı") {
        Users user = Users(
          userID: result['user']['userID'],
          userName: result['user']['name'],
          userSurname: result['user']['surname'],
          userEmail: result['user']['email'],
          userPassword: result['user']['password'],
          userGender: result['user']['gender'],
          userDate: result['user']['date'],
        );

        final passwordHash = sha1.convert(utf8.encode(user.userPassword!)).toString();
        print('Password Hash: $passwordHash');
        saveCurrentUser(
          user.userID.toString(),
          user.userEmail.toString(),
          user.userPassword.toString(),
        );

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Giriş Başarılı'),
              content: Text('Giriş başarılı!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessLogin(),
                      ),
                    );
                  },
                  child: Text('Tamam'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Giriş Hatası'),
              content: Text('Giriş işlemi başarısız.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Tamam'),
                ),
              ],
            );
          },
        );
      }
    }
  }
  void _navigateToBasketPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BasketPage(passwordHash: passwordHash),
      ),
    );
  }

  Future<void> saveCurrentUser(String userID, String email, String passwordHash) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userID', userID);
    await prefs.setString('email', email);
    await prefs.setString('passwordHash', passwordHash);
  }

  void checkCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userID = prefs.getString('userID');
    String? email = prefs.getString('email');
    String? passwordHash = prefs.getString('passwordHash');
    print('Password Hash: $passwordHash');

    if (userID != null && email != null && passwordHash != null) {
      final URL = Uri.parse('http://localhostuser/check');
      final body = {
        'userID': userID,
        'email': email,
        'passwordHash': passwordHash,
      };
      final response = await http.post(URL, body: body);
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        print(response.body);

        Users user = Users(
          userID: result['userID'],
          userName: result['userName'],
          userSurname: result['userSurname'],
          userEmail: result['userEmail'],
          userPassword: result['userPassword'],
          userGender: result['userGender'],
          userDate: result['userDate'],
        );
        print('Password Hash: $passwordHash');
        if (result['desc'] == 'Giriş başarılı') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Giriş Başarılıdır!.'),
              duration: const Duration(seconds: 3),
            ),
          );
          await Future.delayed(const Duration(seconds: 3));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BasketPage(passwordHash: passwordHash)),
          );
        } else {
          await prefs.remove('userID');
          await prefs.remove('email');
          await prefs.remove('passwordHash');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Giriş Hatası'),
                content: Text('Giriş işlemi başarısız.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Tamam'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }
}
