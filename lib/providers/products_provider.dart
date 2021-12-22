import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';
import 'dart:convert';

import 'product.dart';

//a 'mix-in', a utility provider, very similar to inheritance 'extends'/interface
//'implements' but use when there's a less logical connection between the classes;
// you can have several mix-ins but only one parent class in dart;
class Products with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Product> _items = [
    /*Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
    Product(
      id: 'p5',
      title: 'A Table',
      description: 'Set any meal you want.',
      price: 149.99,
      imageUrl:
          'http://www.ana-white.com/sites/default/files/round%20farmhouse%20table%20anawhite%20plans%20diy01.jpg',
    ),
    Product(
      id: 'p6',
      title: 'A Rug',
      description: 'So soft!',
      price: 39.99,
      imageUrl:
          'https://ksassets.timeincuk.net/wp/uploads/sites/56/2018/03/Very-new-collection-rug.jpg',
    ),*/
  ];

  //var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    /*if (_showFavoritesOnly) {
      return _items.where((productItem) => productItem.isFavorite).toList();
    }*/
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((productItem) => productItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  /*void showFavoritesOnly() {
    _showFavoritesOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoritesOnly = false;
    notifyListeners();
  }*/

  //square brackets around a parameter make it optional, but make sure
  //to provide a default value
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterMap = filterByUser
        ? {
            'auth': '$authToken',
            'orderBy': '"creatorId"',
            'equalTo': '"$userId"',
          }
        : {
            'auth': '$authToken',
          };

    var url = Uri.https(
      'udemy-course-myshop-default-rtdb.firebaseio.com',
      '/products.json',
      filterMap,
    );

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.https(
        'udemy-course-myshop-default-rtdb.firebaseio.com',
        '/userFavorites/$userId.json',
        {'auth': '$authToken'},
      );
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      //print(favoriteData);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
            imageUrl: prodData['imageUrl']));
      });
      _items = loadedProducts;
      notifyListeners();
      //print(json.decode(response.body));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
      'udemy-course-myshop-default-rtdb.firebaseio.com',
      '/products.json',
      {'auth': '$authToken'},
    );
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
        }),
      );
      //_items.add(value);
      //print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      //_items.insert(0, newProduct); //to add to start of list
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
    /*  .then((response) {*/

    /*}) .catchError((error) {
      print(error);
      throw error;
    });*/
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        'udemy-course-myshop-default-rtdb.firebaseio.com',
        '/products/$id.json',
        {'auth': '$authToken'},
      );
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https(
      'udemy-course-myshop-default-rtdb.firebaseio.com',
      '/products/$id.json',
      {'auth': '$authToken'},
    );

    //called an 'optimistic updating' approach, readds to local memory the product
    //if deleting from the server fails
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
