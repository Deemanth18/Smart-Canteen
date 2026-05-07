import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../cart_data.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("orders");

  int calculateTotal() {
    int total = 0;
    for (var item in cart) {
      total += item.price * item.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),

      body: cart.isEmpty
          ? const Center(
              child: Text("Your Cart is Empty", style: TextStyle(fontSize: 18)),
            )
          : Column(
              children: [
                /// CART ITEMS
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: cart.length,

                    itemBuilder: (context, index) {
                      CartItem item = cart[index];

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),

                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.orange,
                            ),
                          ),

                          title: Text(
                            item.name ?? "Item",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          subtitle: Text(
                            "₹${item.price ?? 0}",
                            style: const TextStyle(fontSize: 16),
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,

                                onPressed: () {
                                  setState(() {
                                    item.quantity--;

                                    if (item.quantity <= 0) {
                                      cart.removeAt(index);
                                    }
                                  });
                                },
                              ),

                              Text(
                                item.quantity.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),

                              IconButton(
                                icon: const Icon(Icons.add_circle),
                                color: Colors.green,

                                onPressed: () {
                                  setState(() {
                                    item.quantity++;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// TOTAL + ORDER SECTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5),
                    ],
                  ),

                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            "₹${calculateTotal()}",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      /// PLACE ORDER BUTTON
                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 14),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          child: const Text(
                            "Place Order",
                            style: TextStyle(fontSize: 18),
                          ),

                          onPressed: () async {
                            if (cart.isEmpty) return;

                            final user = FirebaseAuth.instance.currentUser;

                            String userId = user?.uid ?? "unknown";
                            String phone = user?.phoneNumber ?? "Unknown";

                            int total = calculateTotal();

                            DatabaseReference orderRef = ref.push();

                            await orderRef.set({
                              "userId": userId,
                              "phone": phone,
                              "status": "Pending",
                              "total": total,
                              "time": ServerValue.timestamp,
                            });

                            for (var item in cart) {
                              await orderRef.child("items").push().set({
                                "name": item.name ?? "Item",
                                "price": item.price ?? 0,
                                "quantity": item.quantity ?? 1,
                              });
                            }

                            setState(() {
                              cart.clear();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Order Placed Successfully"),
                              ),
                            );

                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
    );
  }
}
