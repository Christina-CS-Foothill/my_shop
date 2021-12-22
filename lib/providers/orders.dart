import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;
  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    //essentially just returning a copy of the orders list
    //instead of the list itself, so you can't access/manipulate the
    //original list of orders
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https(
      'udemy-course-myshop-default-rtdb.firebaseio.com',
      '/orders/$userId.json',
      {'auth': '$authToken'},
    );
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(
            orderData['dateTime'],
          ),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ))
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
      'udemy-course-myshop-default-rtdb.firebaseio.com',
      '/orders/$userId.json',
      {'auth': '$authToken'},
    );
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((cartProd) => {
                      'id': cartProd.id,
                      'title': cartProd.title,
                      'quantity': cartProd.quantity,
                      'price': cartProd.price,
                    })
                .toList(),
          }));

      final newOrder = OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts,
      );
      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }
}
