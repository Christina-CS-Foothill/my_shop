import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'product.dart';

//a 'mix-in', a utility provider, very similar to inheritance 'extends'/interface
//'implements' but use when there's a less logical connection between the classes;
// you can have several mix-ins but only one parent class in dart;
class Products with ChangeNotifier {
  // ignore: prefer_final_fields
  List<Product> _items = [
    Product(
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
    ),
  ];

  //var _showFavoritesOnly = false;

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

  void addProduct(Product product) {
    //_items.add(value);
    final newProduct = Product(
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      id: DateTime.now()
          .toString(), //quick and dirty way to make a unique key/id
    );
    _items.add(newProduct);
    //_items.insert(0, newProduct); //to add to start of list
    notifyListeners();
  }

  void updateProduct(String id, Product newProduct) {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
