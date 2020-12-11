import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/providers/user_provider.dart';
import 'package:ecommerce/utils/price_utils.dart';
import 'package:ecommerce/widgets/order/products_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider _userProvider = Provider.of<UserProvider>(context);

    String _buildProductsText(DocumentSnapshot snapshot) {
      String text = "Descrição:\n";
      for (LinkedHashMap p in snapshot["products"]) {
        text +=
            "${p["quantity"]}x ${p["product"]["name"]} R\$ ${PriceUtils.convertPriceBRL(p["product"]["price"])}\n";
      }
      text +=
          "Total: R\$ ${PriceUtils.convertPriceBRL(snapshot["totalPrice"])}";
      return text;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pedidos",
          style: TextStyle(
            color: Colors.grey[500],
          ),
        ),
        brightness: Brightness.light,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[500]),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection("users")
            .doc(_userProvider.user.id)
            .collection("orders")
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView(
              children: snapshot.data.docs
                  .map((doc) {
                    return Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("orders")
                              .doc(doc.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Código do pedido: ${snapshot.data.id}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  Text(_buildProductsText(snapshot.data))
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    );
                  })
                  .toList()
                  .reversed
                  .toList(),
            );
          }
        },
      ),
    );
  }
}
