import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'db_data.dart';
import 'main.dart';

class ProductInfoScreen extends StatefulWidget {
  final product;

  ProductInfoScreen({required this.product});
  @override
  ProductInfo createState() => ProductInfo();
}

class ProductInfo extends State<ProductInfoScreen> {
  bool check = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> setFavoriteFood() async {
    final SupabaseClient supabase = Supabase.instance.client;
    final response = await supabase
        .from('products')
        .select('isFavorite')
        .eq('id', widget.product['id']);

    check = response[0]['isFavorite'];
    await supabase
        .from('products')
        .update({'isFavorite': !check})
        .eq('id', widget.product['id']);

    setState(() {
      check = !check;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color blockColor = getColor();
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 20, right:  25),
          decoration: BoxDecoration(
            color: Color.fromRGBO(218, 119, 14, 1.0),
          ),
          child: Text(
            'Описание продукта',
            style: TextStyle(
              fontSize: 27,
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
            margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
            child: IconButton(
              onPressed: () async {
                setFavoriteFood();
              },
              color: Colors.white,
              icon: !check ? Icon(Icons.favorite_border) : Icon(Icons.favorite),
              iconSize: 35,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 20, right: 15, left: 15),
          padding: EdgeInsets.only(right: 5, left: 5),
          width: 390,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.fromRGBO(147, 146, 146, 0.6137254901960784),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildImageBlock(widget.product['id']),
              _buildInfoBlock('description',widget.product['description'].toString()),
              _buildStructureBlock('calorie',widget.product['calorie'].toString(),
                  'structure', widget.product['structure'].toString()),
              _buildInfoBlock('contraindications', widget.product['contraindications'].toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String chapter, String value) {
    double textSize= 15;
    if (chapter == 'contraindications') {
      value = 'Противопоказания: \n' + value;
      textSize = 20;
    }
    Color blockColor = getColor();
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(top: 15, right: 10, left: 10),
        padding: EdgeInsets.only(top:10, bottom: 10, right: 15, left: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:blockColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),],
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: textSize,
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildImageBlock(int value) {
    Color blockColor = getColor();
    return Container(
      margin: EdgeInsets.only(top: 15, right: 10, left: 10),
      padding: EdgeInsets.only(bottom: 10, right: 15, left: 15),
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
      child:  Column(
          children: [
            Image.asset(
              'food_photo/${widget.product['id']}.jpg',
              height: 280,
            ),
            Text(
              '${widget.product['name']}',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ]
      ),
    );
  }

  Widget _buildStructureBlock(String chapter1, String value1, String chapter2, String value2) {
    Color blockColor = getColor();
    return Container(
      margin: EdgeInsets.only(top: 15, right: 10, left: 10),
      padding: EdgeInsets.only(top:10, bottom: 10, right: 15, left: 15),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Состав: \n' + value2,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
          Expanded(
            child: Text(
              'Ккал: \n' + value1,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          )
        ]
      ),
    );
  }
  Color getColor() {
    int category = widget.product['category'];
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