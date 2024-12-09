import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'db_data.dart';
import 'product_info.dart';
import 'favorite_products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: db_url,
    anonKey: db_anonKey,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
        scaffoldBackgroundColor: Color.fromRGBO(51, 51, 51, 1.0),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageScreen();
}

class HomePageScreen extends State<HomePage> {
  final TextEditingController productController = TextEditingController();
  SupabaseClient client = Supabase.instance.client;
  List<dynamic> products_list = [];
  bool filter = false;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SupabaseClient supabase = Supabase.instance.client;
    final response = await supabase.from('products').select();

    setState(() {
      products_list = (response as List<dynamic>)
        ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    });
  }

  Future<void> _filterFood() async {
    if (filter) {
      final SupabaseClient supabase = Supabase.instance.client;
      final response = await supabase.from('products').select().eq('isFavorite', 'TRUE');

      setState(() {
        products_list = (response as List<dynamic>)
          ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));

        filter = !filter;
      });
    }
    else {
      fetchData();
      setState(() {
        filter = !filter;
      });
    }
  }

  Future<void> _searchFood() async {
    final SupabaseClient supabase = Supabase.instance.client;
    String searchText = productController.text.trim();

    final responseProducts = await supabase
        .from('products')
        .select()
        .ilike('name', '%$searchText%');

    if (responseProducts.isNotEmpty) {
      setState(() {
        products_list = (responseProducts as List<dynamic>)
          ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
      });
    }
    else {
      final responseCategories = await supabase
          .from('categories')
          .select()
          .ilike('cate_name', '%$searchText%');

      if (responseCategories.isNotEmpty) {
        List<int> categoryIds = (responseCategories as List<dynamic>)
            .map((category) => category['id'] as int)
            .toList();
        final responseProductsByCategory = await supabase
            .from('products')
            .select()
            .inFilter('category', categoryIds);

        setState(() {
          products_list = (responseProductsByCategory as List<dynamic>)
            ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
        });
      } else {
        setState(() {
          products_list = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.fromLTRB(40, 38, 10, 20),
          decoration: BoxDecoration(
            color: Color.fromRGBO(218, 119, 14, 1.0),
          ),
          child: Text(
            'Product Assistant',
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'Times New Roman',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.visible,
          ),
        ),
        elevation: 5.0,
        shadowColor: Colors.black,
        toolbarHeight: 70,
        actions: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 0, 25, 0),
            child: IconButton(
              onPressed: () async {
                await _filterFood();
              },
              color: Colors.white,
              icon: filter ? Icon(Icons.favorite_border) : Icon(Icons.favorite),
              iconSize: 35,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
            decoration: BoxDecoration(
              color: Color.fromRGBO(13, 191, 28, 1.0),
              borderRadius: BorderRadius.circular(12),
            ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: productController,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Times New Roman',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                    ),
                    labelText: 'Введите название или категорию',
                    labelStyle: TextStyle(
                      color: Colors.white, // Цвет текста метки
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: IconButton(
                  onPressed: () async {
                    await _searchFood();
                  },
                  color: Colors.white,
                  icon: Icon(Icons.search_rounded),
                  iconSize: 40,
                ),
              ),
            ],
          ),),
          Expanded(
            child: ListView.builder(
              itemCount: products_list.length,
              itemBuilder: (context, index) {
                final product = products_list[index];
                return _buildMainEvent(context, product);
              },
            ),
          )
        ],
      )
    );
  }
  Widget _buildMainEvent(BuildContext context, product) {
    int category = product['category'];
    Color blockColor = getColor(product);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductInfoScreen(product: product),
        ));
      },
      child: Container(
        margin: EdgeInsets.only(top: 20, right: 15, left: 15),
        padding: EdgeInsets.all(5),
        width: 390,
        height: 320,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: blockColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Image.asset(
                'food_photo/${product['id']}.jpg',
                height: 210,
              ),
            ),
            Expanded(
              child: Text(
                '${product['name']}',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Times New Roman',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decorationColor: Color.fromRGBO(13, 191, 28, 1.0),
                  decorationThickness: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Color getColor(product) {
    int category = product['category'];
    Color blockColor = Color.fromRGBO(218, 119, 14, 1.0);
    switch (category) {
      case 1: {
        blockColor = Color.fromRGBO(218, 119, 14, 1.0);
        break;
      }
      case 2: {
        blockColor = Color.fromRGBO(218, 177, 14, 1.0);
        break;
      }
      case 3: {
        blockColor = Color.fromRGBO(113, 218, 14, 1.0);
        break;
      }
      case 4: {
        blockColor = Color.fromRGBO(14, 201, 218, 1.0);
        break;
      }
      case 5: {
        blockColor = Color.fromRGBO(14, 79, 218, 1.0);
        break;
      }
      case 6: {
        blockColor = Color.fromRGBO(113, 14, 218, 1.0);
        break;
      }
      case 7: {
        blockColor = Color.fromRGBO(218, 14, 177, 1.0);
        break;
      }
      case 8: {
        blockColor = Color.fromRGBO(218, 14, 31, 1.0);
        break;
      }
      case 9: {
        blockColor = Color.fromRGBO(14, 218, 187, 1.0);
        break;
      }
      case 10: {
        blockColor = Color.fromRGBO(14, 218, 164, 1.0);
        break;
      }
    }
    return blockColor;
  }
}