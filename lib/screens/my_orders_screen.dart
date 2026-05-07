import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatelessWidget {
  final DatabaseReference ref = FirebaseDatabase.instance.ref("orders");

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),

      body: StreamBuilder(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No Orders Yet"));
          }

          Map data = snapshot.data!.snapshot.value as Map;

          List orders = data.entries.toList();

          return ListView.builder(
            itemCount: orders.length,

            itemBuilder: (context, index) {
              var order = orders[index].value;

              // show only current user's orders
              if (order["userId"] != userId) {
                return const SizedBox();
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

                      const SizedBox(height: 6),

                      Text("Total: ₹${order["total"]}"),

                      Text("Status: ${order["status"]}"),
                      Text(
                        order["time"] != null
                            ? "Ordered at: ${DateTime.fromMillisecondsSinceEpoch(order["time"]).hour}:${DateTime.fromMillisecondsSinceEpoch(order["time"]).minute}"
                            : "Ordered at: Unknown",
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        "Items:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      if (order["items"] != null)
                        Column(
                          children: (order["items"] as Map).entries.map((item) {
                            var value = item.value;

                            return ListTile(
                              title: Text(value["name"]),
                              subtitle: Text(
                                "₹${value["price"]} x ${value["quantity"]}",
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
