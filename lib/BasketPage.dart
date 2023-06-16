import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'ProductList.dart';
import 'LoginPage.dart';

class BasketPage extends StatefulWidget {
  final String passwordHash;

  BasketPage({required this.passwordHash});

  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  late String userID = '';
  late String email = '';
  late String passwordHash;
  late String password;
  List<ProductList> productList = [];
  String? responseMessage;

  @override
  void initState() {
    super.initState();
    getUserData();
    loadUserBasket();
  }

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('userID') ?? '';
      email = prefs.getString('email') ?? '';
      passwordHash = prefs.getString('passwordHash') ?? '';
    });
    if (passwordHash.isNotEmpty) {
      loadUserBasket();
    }
  }

  Future<void> loadUserBasket() async {
    final url = Uri.parse('http://localhostbasket/$userID');
    final response = await http.post(
      url,
      body: jsonEncode({
        'email': email,
        'password': passwordHash,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == true) {
        var result = responseData['data'] as List<dynamic>;
        productList.clear();
        for (var item in result) {
          ProductList product = ProductList(
            productID: item['productID'] as int?,
            productName: item['productName'] as String?,
            unit: item['unit'] as int?,
          );
          productList.add(product);
        }
        setState(() {
          responseMessage = 'Sepet ekranına başarıyla geçildi.';
        });
      } else {
        setState(() {
          responseMessage = 'Sepette ürün bulunamadı.';
        });
      }
    } else {
      setState(() {
        responseMessage = 'Hata: ${response.statusCode}';
      });
    }
  }

  void displayProductDetails() {
    for (var product in productList) {
      print('Ürün Adı: ${product.productName}, Miktar: ${product.unit}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sepet',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.orangeAccent,
      ),
      body: productList.isEmpty
          ? Center(
        child: Text(
          'Sepetiniz boş.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                'Ürün Adı: ${productList[index].productName ?? ''}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Miktar: ${productList[index].unit ?? ''}',
                style: TextStyle(fontSize: 16),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      decreaseProductUnit(productList[index].productID);
                    },
                  ),
                  Text(
                    '${productList[index].unit ?? ''}',
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      increaseProductUnit(productList[index].productID);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: addToBasket,
      ),
      bottomNavigationBar: responseMessage != null
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          responseMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      )
          : null,
    );
  }

  Future<void> removeFromBasket(int? productID) async {
    if (productID == null) return;

    final url = Uri.parse('http://localhostbasket/update/$userID');
    final body = {
      'productID': productID.toString(),
      'processType': 'decrease',
    };
    final response = await http.put(
      url,
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$email:$passwordHash')),
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      productList.removeWhere((product) => product.productID == productID);
      setState(() {
        responseMessage = 'Ürün sepetten kaldırıldı.';
      });
    } else {
      setState(() {
        responseMessage = 'Hata: ${response.statusCode}';
      });
    }
  }

  Future<void> addToBasket() async {
    TextEditingController productIDController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sepete Ürün Ekle'),
          content: TextField(
            controller: productIDController,
            decoration: InputDecoration(
              labelText: 'Ürün ID',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal Et'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ekle'),
              onPressed: () async {
                String productID = productIDController.text;
                await addProductToBasket(productID);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> decreaseProductUnit(int? productID) async {
    if (productID == null) return;

    final url = Uri.parse('http://localhostbasket/update/$userID');
    final body = {
      'productID': productID.toString(),
      'processType': 'decrease',
    };
    final response = await http.put(
      url,
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$email:$passwordHash')),
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        final product =
        productList.firstWhere((product) => product.productID == productID);
        product.unit = product.unit != null ? product.unit! - 1 : null;
        if (product.unit == 0) {
          productList.remove(product);
        }
        responseMessage = 'Ürün miktarı güncellendi.';
      });
    } else {
      setState(() {
        responseMessage = 'Hata: ${response.statusCode}';
      });
    }
  }

  Future<void> increaseProductUnit(int? productID) async {
    if (productID == null) return;

    final url = Uri.parse('http://localhostbasket/update/$userID');
    final body = {
      'productID': productID.toString(),
      'processType': 'increase',
    };
    final response = await http.put(
      url,
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$email:$passwordHash')),
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        final product =
        productList.firstWhere((product) => product.productID == productID);
        product.unit = product.unit != null ? product.unit! + 1 : null;
        responseMessage = 'Ürün miktarı güncellendi.';
      });
    } else {
      setState(() {
        responseMessage = 'Error: ${response.statusCode}';
      });
    }
  }

  Future<void> addProductToBasket(String productID) async {
    final url = Uri.parse('http://localhostbasket/update/$userID');
    final body = {
      'productID': productID,
      'processType': 'increase',
    };
    final response = await http.put(
      url,
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$email:$passwordHash')),
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      ProductList product = ProductList(
        productID: result['productID'] as int?,
        productName: result['productName'] as String?,
        unit: result['unit'] as int?,
      );
      productList.add(product);
      setState(() {
        responseMessage = 'Ürün sepete eklendi.';
      });

      // Reload the user's basket
      await loadUserBasket();
    } else {
      setState(() {
        responseMessage = 'Error: ${response.statusCode}';
      });
    }
  }
}
