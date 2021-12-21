import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token) async {
    final url = Uri.https(
      'udemy-course-myshop-default-rtdb.firebaseio.com',
      '/products/$id.json',
      {'auth': '$token'},
    );
    var prevFavoriteStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.patch(url,
        body: json.encode({
          'isFavorite': isFavorite,
        }));
    if (response.statusCode >= 400) {
      isFavorite = prevFavoriteStatus;
      notifyListeners();
      throw HttpException('Could not favorite this product.');
    }
    prevFavoriteStatus = null;
  }
}
