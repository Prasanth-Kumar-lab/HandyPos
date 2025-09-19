// home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controller/controller.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ProductController _controller = Get.put(ProductController());

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: Icon(Icons.menu),
        backgroundColor: Colors.blueAccent,
      ),
      body: Obx(() {
        // Animate cart visibility
        if (_controller.hasItemsInCart) {
          _animationController?.forward();
        } else {
          _animationController?.reverse();
        }

        return Stack(
          children: [
            GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _controller.products.length,
              itemBuilder: (context, index) {
                final product = _controller.products[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.grey[200],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(product.icon ?? Icons.image_not_supported,
                                size: 50, color: Colors.blueAccent),
                            SizedBox(height: 8),
                            Text(product.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('₹${product.price.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _controller.decrementQuantity(index),
                              child: CircleAvatar(
                                backgroundColor: Colors.red.shade700,
                                radius: 14,
                                child:
                                Icon(Icons.remove, color: Colors.white, size: 20),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(product.quantity.toString(),
                                style: TextStyle(fontSize: 16)),
                            SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => _controller.incrementQuantity(index),
                              child: CircleAvatar(
                                backgroundColor: Colors.green.shade700,
                                radius: 14,
                                child:
                                Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            FadeTransition(
              opacity: _fadeAnimation!,
              child: DraggableScrollableSheet(
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return Obx(() {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              controller: scrollController,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 70,
                                            height: 70,
                                            child: Lottie.asset(
                                                'assets/Shopping Cart.json'),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Cart Items',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orangeAccent
                                                      .shade700)),
                                        ],
                                      ),
                                      CircleAvatar(
                                        backgroundColor:Colors.cyanAccent.withOpacity(0.3),
                                        child: IconButton(
                                          icon: Icon(Icons.close),
                                          onPressed: () {
                                            Get.dialog(AlertDialog(
                                              title: Text('Close Cart'),
                                              content: Text(
                                                  'Are you sure you want to close the cart?'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Get.back(), // close dialog
                                                    child: Text('Cancel')),
                                                TextButton(
                                                    onPressed: () {
                                                      _controller.clearCart();
                                                      Get.back();
                                                    },
                                                    child: Text('Close')),
                                              ],
                                            ));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ..._controller.selectedProducts
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final product = entry.value;
                                  final index = _controller.products
                                      .indexOf(entry.value);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                      Colors.blueAccent.withOpacity(0.1),
                                      child: Icon(product.icon,
                                          color: Colors.blueAccent),
                                    ),
                                    title: Text(product.name),
                                    subtitle: Text(
                                        '₹${product.price} x ${product.quantity} = ₹${(product.price * product.quantity).toStringAsFixed(2)}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _controller
                                              .decrementQuantity(index),
                                          child: CircleAvatar(
                                            backgroundColor:
                                            Colors.red.shade700,
                                            radius: 14,
                                            child: Icon(Icons.remove,
                                                color: Colors.white, size: 20),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(product.quantity.toString()),
                                        SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () => _controller
                                              .incrementQuantity(index),
                                          child: CircleAvatar(
                                            backgroundColor:
                                            Colors.green.shade700,
                                            radius: 14,
                                            child: Icon(Icons.add,
                                                color: Colors.white, size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                Divider(),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Total Amount',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                      Text(
                                        '₹${_controller.totalAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color:
                                          Colors.orangeAccent.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: ElevatedButton(
                                    onPressed: _controller.totalAmount > 0
                                        ? () {
                                      Get.snackbar(
                                        'Checkout',
                                        'Proceeding to checkout...',
                                        snackPosition:
                                        SnackPosition.BOTTOM,
                                      );
                                    }
                                        : null,
                                    child: Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor:Colors.white,
                                      padding:
                                      EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  });
                },
              ),
            )
          ],
        );
      }),
    );
  }
}
