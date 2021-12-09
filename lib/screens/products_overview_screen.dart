//import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';
//import 'package:http/http.dart' as http;

//import 'package:my_shop/providers/products_provider.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products_provider.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/product-overview-screen';

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavoritesOnly = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    //Provider.of<Products>(context).fetchAndSetProducts(); // WON'T WORK!
    /*Future.delayed(Duration.zero).then((_) {
      Provider.of<Products>(context).fetchAndSetProducts();
    });*/ // This works but is considered a "hack" or something idk
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //yet another approach for loading products that works
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //final productsContainer = Provider.of<Products>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  //productsContainer.showFavoritesOnly();
                  _showFavoritesOnly = true;
                } else {
                  //productsContainer.showAll();
                  _showFavoritesOnly = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              const PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              child: ch,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(
              showFavs: _showFavoritesOnly,
            ),
    );
  }
}
