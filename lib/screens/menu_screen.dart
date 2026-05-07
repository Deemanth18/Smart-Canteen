import 'package:flutter/material.dart';
import 'cart_screen.dart';
import '../cart_data.dart';
import '../models/cart_item.dart';

class MenuScreen extends StatelessWidget {
  MenuScreen({super.key});

  final List<Map<String, dynamic>> menuItems = [
    {"name": "Burger", "price": 80, "icon": "🍔"},
    {"name": "Pizza", "price": 120, "icon": "🍕"},
    {"name": "Sandwich", "price": 60, "icon": "🥪"},
    {"name": "Cold Coffee", "price": 50, "icon": "☕"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),

        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),

            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: menuItems.length,

        itemBuilder: (context, index) {
          String itemName = menuItems[index]["name"];
          int itemPrice = menuItems[index]["price"];
          String itemIcon = menuItems[index]["icon"];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),

            child: ListTile(
              contentPadding: const EdgeInsets.all(12),

              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange.shade100,

                child: Text(itemIcon, style: const TextStyle(fontSize: 24)),
              ),

              title: Text(
                itemName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                "₹$itemPrice",
                style: const TextStyle(fontSize: 16),
              ),

              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: const Text("Add"),

                onPressed: () {
                  bool itemExists = false;

                  for (var item in cart) {
                    if (item.name == itemName) {
                      item.quantity++;
                      itemExists = true;
                      break;
                    }
                  }

                  if (!itemExists) {
                    cart.add(CartItem(name: itemName, price: itemPrice));
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$itemName added to cart")),
                  );
                },
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.shopping_cart),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CartScreen()),
          );
        },
      ),
    );
  }
}
