class OrderModel {
  String item;
  int price;
  String status;

  OrderModel({
    required this.item,
    required this.price,
    this.status = "Preparing",
  });

  Map<String, dynamic> toMap() {
    return {'item': item, 'price': price, 'status': status};
  }
}
