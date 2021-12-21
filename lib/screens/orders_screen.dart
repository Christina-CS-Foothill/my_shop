import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

/*class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}*/

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  const OrdersScreen({Key key}) : super(key: key);

  /*var _isLoading = false;

  @override
  void initState() {
    /*Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
      setState(() {
        _isLoading = false;
      });
    });

    super.initState();*/
  }*/

  @override
  Widget build(BuildContext context) {
    print('building orders');
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Your Orders',
          ),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              //a way to have a loading spinner without managing it yourself? uses
              // flutter class ConnectionState and thus you don't have to use
              // a stateful widget 
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (dataSnapshot.error != null) {
              //error handling stuff
              return const Center(
                child: Text('An error occured!'),
              );
            } else {
              return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, i) => OrderItem(
                          order: orderData.orders[i],
                        ),
                      ));
            }
          },
        ));
  }
}
