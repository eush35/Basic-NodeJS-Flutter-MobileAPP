import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:mobilprogramlama/BasketPage.dart';
import 'ProductList.dart';
import 'package:image_picker/image_picker.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}


class _ProductPageState extends State<ProductPage> {
  var _controller = ScrollController();
  TextEditingController _controllerProductName = new TextEditingController();
  TextEditingController _controllerProductDesc = new TextEditingController();
  TextEditingController _controllerProductUnit = new TextEditingController();
  TextEditingController _controllerProductPrice = new TextEditingController();

  PickedFile? pickedFile = null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Container(
            child : Scaffold(
              appBar: AppBar(
                  title: const Text(
                    'Ürünler',
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
                body:
                SingleChildScrollView(
                    controller:_controller,
                    padding: EdgeInsets.all(5),
                    child :
                    Container(
                        padding : EdgeInsets.all(20),
                        child:Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Ürünleri çağırmak içn butona basın!'),
                            TextButton(onPressed: (){
                              getProductList();
                            },
                                child: Text("Ürünleri Çek")),
                            if(pickedFile != null) Image.file(File(pickedFile!.path),height: 100,),

                            TextFormField(
                              controller : _controllerProductName,
                              decoration: const InputDecoration(
                                  labelText : 'Ürün Adı'
                              ),
                            ),
                            TextFormField(
                              controller : _controllerProductDesc,
                              decoration: const InputDecoration(
                                  labelText : 'Ürün Açıklaması'
                              ),
                            ),

                            TextFormField(
                              controller : _controllerProductPrice,
                              decoration: const InputDecoration(
                                  labelText : 'Ürün Fiyatı'
                              ),
                            ),
                            TextFormField(
                              controller : _controllerProductUnit,
                              decoration: const InputDecoration(
                                  labelText : 'Ürün Miktarı'
                              ),
                            ),

                            TextButton(onPressed: (){
                              _showPicker(context);
                            },
                                child: Text("Ürün Resmi Çek")),
                            TextButton(onPressed: (){
                              if(updatedProductID != 0) updateProduct();
                              else addNewProduct();
                            },
                                child: Text((updatedProductID == 0)?"Ürünü Kaydet":"Ürünü Güncelle")),
                            if(updatedProductID != 0)
                              TextButton(onPressed: (){
                                _controllerProductName.text = '';
                                _controllerProductDesc.text = '';
                                _controllerProductPrice.text = '';
                                _controllerProductUnit.text = '';
                                updatedProductID = 0;
                                setState(() {

                                });
                              },child: Text("Güncellemeyi İptal Et"),),



                            for(var i in productList)

                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(i.productID.toString(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                  Text(i.productName.toString(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                  Text(i.productDesc.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal),),
                                  Text("₺"+i.price.toString(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal),),
                                  Text(i.unit.toString()+" adet kaldı",style: TextStyle(fontSize: 15,fontWeight: FontWeight.normal),),
                                  Image.network(i!.image.toString()),

                                  TextButton(onPressed: (){
                                    deleteProduct(i.productID);
                                    getProductList();
                                  }, child: Text("Ürünü Sil")),
                                  TextButton(onPressed: (){
                                    _controllerProductName.text = i.productName.toString();
                                    _controllerProductDesc.text = i.productDesc.toString();
                                    _controllerProductPrice.text = i.price.toString();
                                    _controllerProductUnit.text = i.unit.toString();
                                    updatedProductID = i.productID!;
                                    setState(() {

                                    });
                                  }, child: Text("Ürünü Güncelle"))
                                ],

                              )
                          ],

                        )
                    )
                )
            )
        )
    );
  }

  void _showPicker(context){
    showModalBottomSheet(context: context,
        builder: (BuildContext bc){
          return SafeArea(
              child: Container(
                  child : new Wrap(
                    children: [
                      new ListTile(
                        leading:  new Icon(Icons.photo_library),
                        title: new Text("Gaeriden seç"),
                        onTap: (){
                          _imgFromGallery();
                          Navigator.of(context).pop();
                        },
                      ),
                      new ListTile(
                        leading:  new Icon(Icons.photo_camera),
                        title: new Text("Kamera ile çek"),
                        onTap: (){
                          _imgFromCamera();
                          Navigator.of(context).pop();
                        },
                      ),


                    ],
                  )
              )
          );
        }
    );
  }

  final _picker = ImagePicker();
  void _imgFromGallery() async {
    pickedFile = await _picker.getImage(source: ImageSource.gallery,imageQuality:70);
    setState(() {
    });
  }
  void _imgFromCamera() async {
    pickedFile = await _picker.getImage(source: ImageSource.camera,imageQuality:70);
    setState(() {
    });
  }



  int updatedProductID = 0;
  List<ProductList> productList = [];
  Future<void> getProductList() async {
    productList = [];
    final URL = Uri.parse('http://localhostproducts');
    Response response = await get(URL);
    var result = jsonDecode(response.body);
    print(response.body);
    for(var u in result["data"]){
      ProductList product = ProductList(
          productID:u["productID"],
          productName:u["productName"],
          productDesc:u["productDesc"],
          categoryID:u["categoryID"],
          unit:u["unit"],
          price: double.parse(u["price"].toString()),
          image:u["image"]
      );
      productList.add(product);
    }
    setState(() {

    });
  }

  Future<void> deleteProduct(int? productID) async{
    final URL = Uri.parse('http://localhostproduct/delete/'+productID.toString());
    Response response = await delete(URL);
    var result = jsonDecode(response.body);
  }

  Future<void> addNewProduct() async{

    String base64 = "";
    if(pickedFile != null){
      final byte = await File(pickedFile!.path).readAsBytes();
      base64 = base64Encode(byte);
    }


    final encoding = Encoding.getByName('utf-8');
    final URL = Uri.parse('http://localhostproduct/create');
    var body = {
      'productName' : _controllerProductName.text,
      'productDesc' : _controllerProductDesc.text,
      'productPrice' : _controllerProductPrice.text,
      'productUnit' : _controllerProductUnit.text,
      'productImage' : base64
    };

    Response response = await post(URL,body:body,encoding: encoding);
    var result = jsonDecode(response.body);
    _controllerProductName.text = '';
    _controllerProductDesc.text = '';
    _controllerProductPrice.text = '';
    _controllerProductUnit.text = '';
    pickedFile = null;
    getProductList();
  }

  Future<void> updateProduct() async{
    String base64 = "";
    if(pickedFile != null){
      final byte = await File(pickedFile!.path).readAsBytes();
      base64 = base64Encode(byte);
    }

    final encoding = Encoding.getByName('utf-8');
    final URL = Uri.parse('http://localhostproduct/update/'+updatedProductID.toString());
    var body = {
      'productName' : _controllerProductName.text,
      'productDesc' : _controllerProductDesc.text,
      'productPrice' : _controllerProductPrice.text,
      'productUnit' : _controllerProductUnit.text,
      'productImage' : base64
    };
    Response response = await put(URL,body:body,encoding: encoding);
    var result = jsonDecode(response.body);
    print(response.body);
    _controllerProductName.text = '';
    _controllerProductDesc.text = '';
    _controllerProductPrice.text = '';
    _controllerProductUnit.text = '';
    updatedProductID = 0;
    pickedFile = null;
    getProductList();

  }




}
