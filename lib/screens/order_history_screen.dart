import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryScreen extends StatelessWidget {
  OrderHistoryScreen({super.key});

  final DatabaseReference ref = FirebaseDatabase.instance.ref("orders");

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),

      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No Order History"));
          }

          Map data = snapshot.data!.snapshot.value as Map;
          List orders = data.entries.toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].value;

              // show only this user's completed orders
              if (order["userId"] != userId || order["status"] != "Completed") {
                return const SizedBox();
              }

              String orderTime = "Unknown";

              if (order["time"] != null) {
                DateTime time = DateTime.fromMillisecondsSinceEpoch(
                  order["time"],
                );
                orderTime = "${time.hour}:${time.minute}";
              }

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Order ID: ${orders[index].key}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text("Total: ₹${order["total"] ?? 0}"),

                      Text("Ordered at: $orderTime"),

                      const SizedBox(height: 10),

                      const Text(
                        "Items:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      if (order["items"] != null)
                        Column(
                          children: (order["items"] as Map).entries.map((item) {
                            var value = item.value;

                            return ListTile(
                              title: Text(value["name"] ?? "Item"),
                              subtitle: Text(
                                "₹${value["price"] ?? 0} x ${value["quantity"] ?? 0}",
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
