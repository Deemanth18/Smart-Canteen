import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

  final DatabaseReference ref = FirebaseDatabase.instance.ref("orders");

  // SEND NOTIFICATION TO NODE SERVER
  Future<void> sendNotification(String token) async {
    try {
      await http.post(
        Uri.parse("http://10.55.144.102:3000/sendNotification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );
    } catch (e) {
      print("Notification error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),

      body: StreamBuilder<DatabaseEvent>(
        stream: ref.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text("No Orders Yet", style: TextStyle(fontSize: 18)),
            );
          }

          Map data = snapshot.data!.snapshot.value as Map;
          List orders = data.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,

            itemBuilder: (context, index) {
              var order = orders[index].value;

              String status = order["status"] ?? "Pending";
              int total = order["total"] ?? 0;

              String orderTime = "Unknown";

              if (order["time"] != null) {
                DateTime time = DateTime.fromMillisecondsSinceEpoch(
                  order["time"],
                );

                orderTime = "${time.hour}:${time.minute}";
              }

              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ORDER HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order #${orders[index].key}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: status == "Ready"
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,

                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: Text(
                              status,
                              style: TextStyle(
                                color: status == "Ready"
                                    ? Colors.green
                                    : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// STUDENT DETAILS
                      Row(
                        children: [
                          const Icon(Icons.person, size: 18),
                          const SizedBox(width: 6),
                          Text("Student: ${order["phone"] ?? "Unknown"}"),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 6),
                          Text("Ordered at: $orderTime"),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(Icons.currency_rupee, size: 18),
                          const SizedBox(width: 6),
                          Text("Total: ₹$total"),
                        ],
                      ),

                      const Divider(height: 20),

                      /// ITEMS TITLE
                      const Text(
                        "Items",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// ITEM LIST
                      if (order["items"] != null)
                        Column(
                          children: (order["items"] as Map).entries.map((item) {
                            var value = item.value;

                            String name = value["name"] ?? "Item";
                            int price = value["price"] ?? 0;
                            int quantity = value["quantity"] ?? 0;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),

                              padding: const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  Text("₹$price x $quantity"),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 12),

                      /// READY BUTTON
                      status == "Ready"
                          ? const Text(
                              "Ready",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,

                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                child: const Text(
                                  "Mark Ready",
                                  style: TextStyle(fontSize: 16),
                                ),

                                onPressed: () async {
                                  String orderId = orders[index].key;

                                  // UPDATE ORDER STATUS
                                  await ref.child(orderId).update({
                                    "status": "Ready",
                                  });

                                  String userId = order["userId"];

                                  // GET USER TOKEN
                                  DatabaseReference userRef = FirebaseDatabase
                                      .instance
                                      .ref("users")
                                      .child(userId);

                                  DatabaseEvent event = await userRef.once();

                                  if (event.snapshot.value != null) {
                                    Map userData = event.snapshot.value as Map;

                                    String token = userData["token"] ?? "";

                                    if (token.isNotEmpty) {
                                      await sendNotification(token);
                                    }
                                  }
                                },
                              ),
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
