import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilprogramlama/BasketPage.dart';
import 'CategoryList.dart';
import 'LoginPage.dart';
import 'RegisterPage.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  TextEditingController _controllerCategoryName = TextEditingController();
  TextEditingController _controllermainCategoryID = TextEditingController();

  @override
  void dispose() {
    _controllerCategoryName.dispose();
    _controllermainCategoryID.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Kategoriler',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orangeAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BasketPage(passwordHash: '')),
                );
              },
              backgroundColor: Colors.green,
              child: Icon(Icons.shopping_basket),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(5),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Kategorileri çağırmak için butona basın!'),
                TextButton(
                  onPressed: getCategoryList,
                  child: Text("Kategorileri Çek"),
                ),
                TextFormField(
                  controller: _controllerCategoryName,
                  decoration: const InputDecoration(
                    labelText: 'Kategori Adı',
                  ),
                ),
                TextFormField(
                  controller: _controllermainCategoryID,
                  decoration: const InputDecoration(
                    labelText: 'Ana Kategori ID',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (updatedCategoryID == 0) {
                      addNewCategory();
                    } else {
                      updateCategory();
                    }
                  },
                  child: Text(updatedCategoryID == 0 ? "Kategoriyi Kaydet" : "Kategori Güncelle"),
                ),
                if (updatedCategoryID != 0)
                  TextButton(
                    onPressed: () {
                      _controllerCategoryName.text = '';
                      updatedCategoryID = 0;
                      setState(() {});
                    },
                    child: Text("Güncellemeyi İptal Et"),
                  ),
                for (var i in categoryList)
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${i.categoryName.toString()} ${i.mainCategoryID.toString()}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteCategory(i.categoryID);
                        },
                        child: Text("Kategori Sil"),
                      ),
                      TextButton(
                        onPressed: () {
                          _controllerCategoryName.text = i.categoryName.toString();
                          _controllermainCategoryID.text = i.mainCategoryID.toString();
                          updatedCategoryID = i.categoryID!;
                          setState(() {});
                        },
                        child: Text("Kategori Güncelle"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int updatedCategoryID = 0;
  List<CategoryList> categoryList = [];

  Future<void> getCategoryList() async {
    final URL = Uri.parse('http://localhostcategories');
    final response = await http.get(URL);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print(response.body);
      categoryList.clear();
      for (var u in result["data"]) {
        CategoryList category = CategoryList(
          mainCategoryID: u["mainCategoryID"],
          categoryID: u["categoryID"],
          categoryName: u["categoryName"],
        );
        categoryList.add(category);
      }
      setState(() {});
    }
  }

  Future<void> deleteCategory(int? categoryID) async {
    final URL = Uri.parse('http://localhostcategory/delete/$categoryID');
    final response = await http.delete(URL);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print(response.body);
      getCategoryList();
    }
  }

  Future<void> addNewCategory() async {
    final URL = Uri.parse('http://localhostcategory/create');
    final body = {
      'categoryName': _controllerCategoryName.text,
      'mainCategoryID': _controllermainCategoryID.text,
    };
    final response = await http.post(URL, body: body);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print(response.body);
      _controllerCategoryName.text = '';
      _controllermainCategoryID.text = '';
      getCategoryList();
    }
  }

  Future<void> updateCategory() async {
    final URL = Uri.parse('http://localhostcategory/update/$updatedCategoryID');
    final body = {
      'categoryName': _controllerCategoryName.text,
      'mainCategoryID': _controllermainCategoryID.text,
    };
    final response = await http.put(URL, body: body);
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      print(response.body);
      _controllerCategoryName.text = '';
      _controllermainCategoryID.text = '';
      updatedCategoryID = 0;
      getCategoryList();
    }
  }
}
