import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/cupertino.dart';
import 'package:task/home_screen/view/print-screen.dart';
import 'package:task/profile/views/profile_buttons.dart';
import '../../print/views/print_screen.dart';
import '../controller/controller.dart';

class HomeScreen extends StatefulWidget {
  final String name;
  final String username;
  final String mobileNumber;

  const HomeScreen({
    Key? key,
    required this.name,
    required this.username,
    required this.mobileNumber,
  }) : super(key: key);
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
    _controller.fetchProducts();
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
        title: Text('Hello ${widget.name}', style: TextStyle(fontWeight: FontWeight.w600, )),
        // In HomeScreen's AppBar
        leading: IconButton(
          onPressed: () {
            Get.to(() => ProfileButtons(
              name: widget.name,
              username: widget.username,
              mobileNumber: widget.mobileNumber,
            ));
          },
          icon: Icon(CupertinoIcons.profile_circled, size: 30, color: Colors.blueGrey.shade900),
        ),
        backgroundColor: Colors.orange.withOpacity(0.6),
        actions: [
          IconButton(onPressed: _controller.fetchProducts, icon: Icon(Icons.sync))
        ],
      ),
      bottomSheet: Obx(() {
        if (_controller.hasItemsInCart) {
          _animationController?.forward();
        } else {
          _animationController?.reverse();
        }
        return FadeTransition(
          opacity: _fadeAnimation!,
          child: _controller.hasItemsInCart
              ? BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.35,
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
                      child: Obx(() {
                        return ListView(
                          children: [
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 16),
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
                                      Text(
                                        'Cart Items',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .orangeAccent.shade700),
                                      ),
                                    ],
                                  ),
                                  CircleAvatar(
                                    backgroundColor:
                                    Colors.cyanAccent.withOpacity(0.3),
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.grey),
                                      onPressed: () {
                                        Get.dialog(
                                          AlertDialog(
                                            title: const Text(
                                              'Confirm Cart Closure',
                                              style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            content: const Text(
                                              'Are you sure you want to close the cart? All items will be removed.',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                            backgroundColor: Colors.white,
                                            elevation: 8,
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Get.back(),
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.blueGrey,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _controller.clearCart();
                                                  Get.back();
                                                },
                                                child: const Text(
                                                  'Confirm',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color:
                                                    Colors.redAccent,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          barrierDismissible: false,
                                        );
                                      },
                                      tooltip: 'Close Cart',
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
                              // Log parameters for cart items
                              print('Cart Item at index $index: '
                                  'itemName: ${product.itemName != null ? "Displayed (${product.itemName})" : "Not Displayed"}, '
                                  'sellingPrice: ${product.sellingPrice != null ? "Displayed (${product.sellingPrice})" : "Not Displayed"}, '
                                  'itemImage: ${product.itemImage != null && product.itemImage!.isNotEmpty ? "Displayed (${product.itemImage})" : "Not Displayed"}');
                              return Slidable(
                                key: ValueKey(product),
                                startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        _controller.decrementQuantity(index,
                                        );
                                        Get.snackbar(
                                          'Removed',
                                          '${product.itemName} removed from cart',
                                          snackPosition:
                                          SnackPosition.BOTTOM,
                                        );
                                      },
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        _controller.decrementQuantity(index,
                                        );
                                        Get.snackbar(
                                          'Removed',
                                          '${product.itemName} removed from cart',
                                          snackPosition:
                                          SnackPosition.BOTTOM,
                                        );
                                      },
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                    Colors.blueAccent.withOpacity(0.1),
                                    child: product.itemImage != null &&
                                        product.itemImage!.isNotEmpty
                                        ? ClipOval(
                                      child: Image.network(
                                        product.itemImage!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                            stackTrace) =>
                                            Icon(
                                                Icons
                                                    .image,
                                                color: Colors
                                                    .blueAccent),
                                      ),
                                    )
                                        : Icon(Icons.image,
                                        color: Colors.blueAccent),
                                  ),
                                  /*
                                  leading: product.itemImage != null && product.itemImage!.isNotEmpty
                                      ? CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                                    child: ClipOval(
                                      child: Image.network(
                                        product.itemImage!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // If image fails to load, return an empty SizedBox (i.e. show nothing)
                                          return SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  )
                                      : SizedBox.shrink(),
                                   */
                                  title:
                                  Text(product.itemName ?? 'No name'),
                                  subtitle: Text(
                                      '₹${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'} x ${product.quantity} = ₹${(product.sellingPrice != null ? product.sellingPrice! * product.quantity : 0).toStringAsFixed(2)}'),
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
                                              color: Colors.white,
                                              size: 20),
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
                                              color: Colors.white,
                                              size: 20),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
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
                                /*onPressed: _controller.totalAmount > 0
                                    ? () {
                                  Get.snackbar(
                                    'Checkout',
                                    'Proceeding to checkout....',
                                    snackPosition:
                                    SnackPosition.BOTTOM,
                                  );
                                }
                                    : null,*/
                                onPressed: _controller.totalAmount > 0
                                    ? () {
                                  Get.to(() => PrintScreen(
                                    name: widget.name,
                                    mobileNumber: widget.mobileNumber,
                                    selectedProducts: _controller.selectedProducts.toList(),
                                    totalAmount: _controller.totalAmount,
                                  ));
                                  Get.snackbar(
                                    'Checkout',
                                    'Proceeding to checkout....',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                                    : null,
                                child: Text(
                                  'Checkout',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding:
                                  EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          )
              : SizedBox.shrink(),
        );
      }),
      body: Container(
        color: Colors.orange.withOpacity(0.4),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  onChanged: (value) => _controller.filterProducts(value),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() => _controller.isLoading.value
                    ? _buildShimmerGrid()
                    : _controller.errorMessage.isNotEmpty
                    ? Center(child: Text(_controller.errorMessage.value))
                    : _controller.filteredProducts.isEmpty
                    ? Container(
                  color: Colors.white,
                  child: Center(
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Lottie.asset('assets/No Data found.json'),
                    ),
                  ),
                )
                    : Scrollbar(
                  thumbVisibility: true,
                  radius: Radius.circular(10),
                  thickness: 6,
                  child: GridView.builder(
                    padding: EdgeInsets.all(7),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                    ),
                    itemCount: _controller.filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product =
                      _controller.filteredProducts[index];
                      final originalIndex =
                      _controller.products.indexOf(product);
                      // Log parameters for grid items
                      print('Grid Item at index $index: '
                          'itemName: ${product.itemName != null ? "Displayed (${product.itemName})" : "Not Displayed"}, '
                          'sellingPrice: ${product.sellingPrice != null ? "Displayed (${product.sellingPrice})" : "Not Displayed"}, '
                          'itemImage: ${product.itemImage != null && product.itemImage!.isNotEmpty ? "Displayed (${product.itemImage})" : "Not Displayed"}');
                      final isSearchMatch = _controller
                          .searchQuery.value.isNotEmpty &&
                          (product.itemName != null &&
                              product.itemName!
                                  .toLowerCase()
                                  .replaceAll(' ', '')
                                  .contains(_controller.searchQuery
                                  .value
                                  .toLowerCase()
                                  .replaceAll(' ', '')));
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isSearchMatch
                              ? BorderSide(
                              color: Colors.green, width: 1)
                              : BorderSide(
                              color: Colors.grey[300]!,
                              width: 1),
                        ),
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  product.itemImage != null &&
                                      product
                                          .itemImage!.isNotEmpty
                                      ? Image.network(
                                    product.itemImage!,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context,
                                        error,
                                        stackTrace) =>
                                        Icon(
                                            Icons
                                                .image_not_supported,
                                            size: 50,
                                            color: Colors
                                                .blueAccent),
                                  )
                                      : Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.blueAccent),
                                  SizedBox(height: 8),
                                  Text(
                                      product.itemName ?? 'No name',
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 16)),
                                  Text(
                                      '₹${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'}',
                                      style: TextStyle(
                                          color: Colors.grey[700])),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => _controller
                                        .decrementQuantity(
                                        originalIndex),
                                    child: CircleAvatar(
                                      backgroundColor:
                                      Colors.red.shade700,
                                      radius: 14,
                                      child: Icon(Icons.remove,
                                          color: Colors.white,
                                          size: 20),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(product.quantity.toString(),
                                      style:
                                      TextStyle(fontSize: 16)),
                                  SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _controller
                                        .incrementQuantity(
                                        originalIndex),
                                    child: CircleAvatar(
                                      backgroundColor:
                                      Colors.green.shade700,
                                      radius: 14,
                                      child: Icon(Icons.add,
                                          color: Colors.white,
                                          size: 20),
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
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 16,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 14,
                      ),
                      SizedBox(width: 12),
                      Container(
                        width: 20,
                        height: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}