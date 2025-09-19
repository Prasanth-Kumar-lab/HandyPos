// controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/product_model.dart';

class ProductController extends GetxController {
  RxList<Product> products = <Product>[
    Product(name: 'Laptop', price: 999.99, icon: Icons.laptop),
    Product(name: 'Phone', price: 499.99, icon: Icons.smartphone),
    Product(name: 'Headphones', price: 79.99, icon: Icons.headphones),
    Product(name: 'Tablet', price: 299.99, icon: Icons.tablet),
    Product(name: 'Watch', price: 149.99, icon: Icons.watch),
    Product(name: 'Camera', price: 849.50, icon: Icons.camera_alt),
    Product(name: 'Speaker', price: 199.99, icon: Icons.speaker),
    Product(name: 'Monitor', price: 229.49, icon: Icons.desktop_windows),
    Product(name: 'Keyboard', price: 89.99, icon: Icons.keyboard),
    Product(name: 'Mouse', price: 49.99, icon: Icons.mouse),
    Product(name: 'Printer', price: 159.75, icon: Icons.print),
    Product(name: 'Scanner', price: 139.99, icon: Icons.document_scanner),
    Product(name: 'TV', price: 599.00, icon: Icons.tv),
    Product(name: 'Projector', price: 379.99, icon: Icons.video_call),
    Product(name: 'Game Console', price: 449.99, icon: Icons.sports_esports),
    Product(name: 'Drone', price: 749.00, icon: Icons.flight),
    Product(name: 'Smart Light', price: 29.99, icon: Icons.lightbulb),
    Product(name: 'Power Bank', price: 39.99, icon: Icons.battery_charging_full),
    Product(name: 'VR Headset', price: 299.00, icon: Icons.vrpano),
    Product(name: 'Fitness Band', price: 59.99, icon: Icons.fitness_center),
    Product(name: 'Microphone', price: 109.99, icon: Icons.mic),
    Product(name: 'Webcam', price: 89.50, icon: Icons.videocam),
    Product(name: 'Smart Lock', price: 129.99, icon: Icons.lock),
    Product(name: 'Wi-Fi Router', price: 99.99, icon: Icons.router),
    Product(name: 'Smart Plug', price: 24.99, icon: Icons.power),
    Product(name: 'Flash Drive', price: 19.99, icon: Icons.usb),
    Product(name: 'Hard Drive', price: 89.99, icon: Icons.sd_storage),
    Product(name: 'SSD', price: 119.99, icon: Icons.storage),
    Product(name: 'Graphics Card', price: 499.00, icon: Icons.graphic_eq),
    Product(name: 'Motherboard', price: 189.99, icon: Icons.developer_board),
    Product(name: 'RAM', price: 79.99, icon: Icons.memory),
    Product(name: 'CPU', price: 329.99, icon: Icons.dns),
    Product(name: 'Cooling Fan', price: 49.99, icon: Icons.toys),
    Product(name: 'Power Supply', price: 99.49, icon: Icons.power_outlined),
    Product(name: 'Gaming Chair', price: 199.99, icon: Icons.event_seat),
    Product(name: 'Laptop Stand', price: 39.99, icon: Icons.laptop_chromebook),
    Product(name: 'Desk Lamp', price: 29.99, icon: Icons.light_mode),
    Product(name: 'Smart Thermostat', price: 159.99, icon: Icons.thermostat),
    Product(name: 'Bluetooth Adapter', price: 14.99, icon: Icons.bluetooth),
    Product(name: 'HDMI Cable', price: 12.99, icon: Icons.cable),
    Product(name: 'Ethernet Cable', price: 8.99, icon: Icons.settings_ethernet),
    Product(name: 'Wireless Charger', price: 34.99, icon: Icons.battery_full),
    Product(name: 'Smart Glasses', price: 279.99, icon: Icons.remove_red_eye),
    Product(name: 'Alarm Clock', price: 19.99, icon: Icons.access_alarm),
    Product(name: 'E-Reader', price: 129.00, icon: Icons.menu_book),
    Product(name: 'Smart Scale', price: 49.00, icon: Icons.monitor_weight),
    Product(name: 'Dash Cam', price: 99.00, icon: Icons.videocam_outlined),
    Product(name: 'Electric Scooter', price: 399.00, icon: Icons.electric_scooter),
    Product(name: 'Smart Doorbell', price: 149.99, icon: Icons.doorbell),
    Product(name: 'Photo Frame', price: 59.99, icon: Icons.photo),
  ].obs;


  /// Increment product quantity
  void incrementQuantity(int index) {
    products[index].quantity++;
    products.refresh();
  }

  /// Decrement product quantity
  void decrementQuantity(int index) {
    if (products[index].quantity > 0) {
      products[index].quantity--;
      products.refresh();
    }
  }

  /// Get selected products (with quantity > 0)
  List<Product> get selectedProducts =>
      products.where((p) => p.quantity > 0).toList();

  /// Check if cart is not empty
  bool get hasItemsInCart => selectedProducts.isNotEmpty;

  /// Get total amount
  double get totalAmount => selectedProducts.fold(
      0.0, (sum, p) => sum + (p.price * p.quantity));

  /// Clear cart (set quantity = 0)
  void clearCart() {
    for (var product in products) {
      product.quantity = 0;
    }
    products.refresh();
  }
}
