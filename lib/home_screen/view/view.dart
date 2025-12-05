import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_thermal_printer_plus/flutter_thermal_printer_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:task/Constants/constants.dart';
import 'package:task/profile/views/profile_page.dart';
import 'package:task/print/views/print_screen.dart';
import '../../print/controller/print_controller.dart';
import '../controller/controller.dart';
import '../model/product_model.dart';
class HomeScreen extends StatefulWidget {
  final String name;
  final String username;
  final String mobileNumber;
  final String businessId;
  final String role;
  final String user_id;

  const HomeScreen({
    Key? key,
    required this.name,
    required this.username,
    required this.mobileNumber,
    required this.businessId,
    required this.role,
    required this.user_id,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final ProductController _controller;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final printController = Get.find<PrintController>();
    });
    Get.put(PrintController(
      businessId: widget.businessId,
      initialProducts: [],
      initialTotal: 0.0,
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoConnectToPrinter();
    });
    _controller = Get.put(ProductController(
      businessId: widget.businessId,
      billerId: widget.user_id,
    ));
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
  void _autoConnectToPrinter() async {
    await Future.delayed(Duration(milliseconds: 500)); // Small delay for stability
    final printController = Get.find<PrintController>();

    final isConnected = await FlutterThermalPrinterPlus.isConnected();
    if (!isConnected) {
      // Show toast message
      /*Fluttertoast.showToast(
        msg: "Connecting to saved printer...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );*/
    }
  }
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: Tooltip(
            message: '${widget.name}', // The text to display in the tooltip
            child: Text(
              '${widget.name}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: TextColors.majorTextColor,
              ),
            ),
          ),
            leading: IconButton(
            onPressed: () {
              Get.to(() => ProfilePage(
                businessId: widget.businessId,
                user_id: widget.user_id,
                role: widget.role,
              ));
            },
            icon: Icon(CupertinoIcons.profile_circled, size: 30, color: IconsColors.profileIcon.shade900),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
            duration: 2000.ms,
            color: AnimateShimmerColors.shimmerColor,
          ),
          backgroundColor: AppBarIcons.appBarBg.withOpacity(0.6),
          actions: [
            IconButton(onPressed: _controller.fetchProducts, icon: Icon(Icons.sync)),
            // Add this in your Positioned widget or somewhere visible
            Obx(() {
              final printController = Get.find<PrintController>();
              final status = printController.connectionStatus.value;
              final isConnected = status == "Connected";

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isConnected ? Colors.green : Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isConnected ? Icons.print : Icons.print_disabled,
                      color: isConnected ? Colors.white : Colors.orange,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: isConnected ? Colors.black : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            })
          ],
        ),
        body: Stack(
          children: [
            Container(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SafeArea(
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
                              child: Lottie.asset(LottieAssets.noDataFound),
                            ),
                          ),
                        )
                            : ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: MaterialStateProperty.all(ScrollBarTheme.scrollBarThumbColor.shade300),
                            trackColor: MaterialStateProperty.all(ScrollBarTheme.scrollBarTrackColor[300]),
                            thickness: MaterialStateProperty.all(6),
                            radius: Radius.circular(8),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            radius: Radius.circular(10),
                            thickness: 5,
                            child: Obx(() {
                              final grouped = _controller.productsGroupedByCategory;

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3).copyWith(bottom: 120),
                                itemCount: grouped.length,
                                itemBuilder: (context, categoryIndex) {
                                  final category = grouped.keys.elementAt(categoryIndex);
                                  final products = grouped[category]!;
                                  // Split products into two rows
                                  final firstRowProducts = products.length > 1 ? products.sublist(0, (products.length / 2).ceil()) : products;
                                  final secondRowProducts = products.length > 1 ? products.sublist((products.length / 2).ceil()) : [];

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                        child: Text(
                                          '$category:',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      // Grid with 2 columns and dynamic rows
                                      GridView.builder(
                                        physics: NeverScrollableScrollPhysics(), // Prevent independent scroll
                                        shrinkWrap: true, // Take only necessary height
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2, // 2 columns
                                          mainAxisSpacing: 8,
                                          crossAxisSpacing: 8,
                                          childAspectRatio: 160 / 210, // width / height ratio of your cards 220
                                        ),
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          final originalIndex = _controller.products.indexOf(product);
                                          final isSearchMatch = _controller.searchQuery.value.isNotEmpty &&
                                              (product.itemName != null &&
                                                  product.itemName!.toLowerCase().replaceAll(' ', '').contains(
                                                      _controller.searchQuery.value.toLowerCase().replaceAll(' ', '')));
                                          return buildProductCard(product, originalIndex, isSearchMatch);
                                        },
                                      ),
                                    ],
                                  );

                                },
                              );
                            }),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Obx(() {
                  if (_controller.cartItemCount.value > 0) {
                    final cartTotal = _controller.cartItems.fold(
                      0.0,
                          (sum, p) => sum + ((p.sellingPrice ?? 0.0) * p.quantity),
                    );
                    final printController = Get.find<PrintController>();
                    return Builder(
                      builder: (context) => Container(
                        height: 107,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: CurvedContainer.curvedContainer.shade300,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Items: ${_controller.cartItemCount.value}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: TextColors.majorTextColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: RichText(
                                      textAlign: TextAlign.end,
                                      text: TextSpan(
                                        children: [
                                          WidgetSpan(
                                            alignment: PlaceholderAlignment.baseline,
                                            baseline: TextBaseline.alphabetic,
                                            child: Text(
                                              'Total: ',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: TextColors.majorTextColor,
                                              ),
                                            ).animate(onPlay: (controller) => controller.repeat())
                                                .shimmer(
                                              duration: 2000.ms,
                                              color: AnimateShimmerColors.shimmerColor,
                                            ),
                                          ),
                                          WidgetSpan(
                                              alignment: PlaceholderAlignment.baseline,
                                              baseline: TextBaseline.alphabetic,
                                              child: Text(
                                                '₹${cartTotal.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: TextColors.majorTextColor,
                                                ),
                                              )
                                          ),
                                        ],
                                      ),
                                    )
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: /*ElevatedButton(
                                    onPressed: () async {
                                      await printController.syncCartData(_controller);
                                      await _controller.fetchCartItems();
                                      Get.to(() => PrintScreen(
                                        initialProducts: _controller.cartItems.toList(),
                                        initialTotal: cartTotal,
                                        businessId: widget.businessId,
                                      ));
                                    },
                                    child: Text(
                                      'Preview & Print',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: TextColors.buttonTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),*/
                                  ElevatedButton(
                                    onPressed: () async {
                                      final printController = Get.find<PrintController>();
                                      final productController = Get.find<ProductController>();
                                      await printController.fetchSystemSettings();
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        barrierColor: Colors.black.withOpacity(0.4),
                                        builder: (context) => AlertDialog(
                                          backgroundColor: Colors.transparent,
                                          content: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(color: Colors.white),
                                                SizedBox(height: 20),
                                                Text(
                                                  "Completing order...",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );

                                      try {
                                        final bool orderCompleted =
                                        await printController.completeOrder(productController.cartId.value);

                                        Navigator.of(context).pop(); // Close loading dialog

                                        if (!orderCompleted) {
                                          Get.snackbar(
                                            'Error',
                                            'Failed to complete order. Cannot preview.',
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          Fluttertoast.showToast(
                                            msg: 'Error, Failed to complete order. Cannot preview.',
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          return;
                                        }

                                        await productController.fetchCartItems();
                                        await printController.syncCartData(productController);

                                        Get.to(() => PrintScreen(
                                          initialProducts: productController.cartItems.toList(),
                                          initialTotal: productController.computedGrandTotal,
                                          businessId: widget.businessId,
                                        ));
                                      } catch (e) {
                                        Navigator.of(context).pop(); // Ensure dialog closes
                                        Fluttertoast.showToast(
                                          msg: 'Error, An Unexpected error occurred',
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Preview & Print',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: TextColors.buttonTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    /*onPressed: () async {
                                      final printCtrl = Get.find<PrintController>();
                                      final prodCtrl = Get.find<ProductController>();

                                      // Prevent double tap
                                      if (printCtrl.isPrinting.value) return;
                                      printCtrl.isPrinting.value = true;

                                      try {
                                        // Show "Completing Order..." toast
                                        Fluttertoast.showToast(
                                          msg: "Completing Order please wait...",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                        // Complete order on server
                                        final orderSuccess = await printCtrl.completeOrder(prodCtrl.cartId.value);
                                        if (!orderSuccess) throw Exception("Failed to complete order");

                                        await prodCtrl.fetchCartItems(); // refresh cart

                                        // Show "Printing Receipt..." toast
                                        Fluttertoast.showToast(
                                          msg: "Printing Receipt.....",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );

                                        // Print
                                        final printSuccess = await printCtrl.printCurrentReceipt();

                                        // Show result toast
                                        if (printSuccess) {
                                          Fluttertoast.showToast(
                                            msg: "Printed Successfully\nReceipt sent to printer",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.green.shade900,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          // Clear cart and go back to home if needed
                                          prodCtrl.resetUICart();
                                          await Future.delayed(const Duration(milliseconds: 600));
                                          if (Get.routing.current == '/print' || Get.routing.previous == '/cart') {
                                            Get.back(); // or Get.offAllNamed('/home')
                                          }
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "Order Saved, No printer connected, but order completed",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        }
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: "Failed: to print ",  //${e.toString()}
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      } finally {
                                        printCtrl.isPrinting.value = false;
                                      }
                                    },*/
                                    onPressed: () async {
                                      final printCtrl = Get.find<PrintController>();
                                      final prodCtrl = Get.find<ProductController>();

                                      // Prevent double tap
                                      if (printCtrl.isPrinting.value) return;
                                      printCtrl.isPrinting.value = true;

                                      try {
                                        Fluttertoast.showToast(
                                          msg: "Completing Order please wait...",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white,
                                        );

                                        final orderSuccess = await printCtrl.completeOrder(prodCtrl.cartId.value);
                                        if (!orderSuccess) throw Exception("Failed to complete order");

                                        await prodCtrl.fetchCartItems();

                                        Fluttertoast.showToast(
                                          msg: "Printing Receipt.....",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white,
                                        );

                                        final printSuccess = await printCtrl.printCurrentReceipt();

                                        // CRITICAL: Reset cart BEFORE showing success toast
                                        // AND do it in a microtask so rebuild happens cleanly
                                        await Future.microtask(() {
                                          prodCtrl.resetUICart(); // This now works reliably
                                        });

                                        // Small delay to let UI settle (optional but smooth)
                                        await Future.delayed(const Duration(milliseconds: 300));

                                        if (printSuccess) {
                                          Fluttertoast.showToast(
                                            msg: "Printed Successfully\nReceipt sent to printer",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.green.shade900,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        } else {
                                          Fluttertoast.showToast(
                                            msg: "Order Saved\nNo printer connected",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                          );
                                        }

                                        // Optional: Navigate away if needed
                                        // Get.offAllNamed('/home');
                                      } catch (e) {
                                        Fluttertoast.showToast(
                                          msg: "Print failed",//: ${e.toString()}
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.CENTER,
                                          backgroundColor: Colors.red.shade700,
                                          textColor: Colors.white,
                                        );
                                      } finally {
                                        printCtrl.isPrinting.value = false;
                                      }
                                    },
                                    label: const Text(
                                      "Print",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                /*Expanded(                            //YESTERDAY
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await printController.syncCartData(_controller);
                                      await printController.fetchSystemSettings();
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (dialogContext) => Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          insetPadding: EdgeInsets.only(top: 100),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                            child: Scaffold(
                                              body: Column(
                                                children: [
                                                  Obx(() {
                                                    final printer = printController.selectedPrinter.value;
                                                    if (printer == null) {
                                                      return const SizedBox.shrink();
                                                    }
                                                    return FutureBuilder<bool>(
                                                      future: FlutterBluetoothPrinter.connect(printer.address),
                                                      builder: (context, snapshot) {
                                                        bool isConnected = snapshot.data ?? false;
                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                height: 40,
                                                                width: 40,
                                                                child: Lottie.asset(
                                                                  isConnected ? 'assets/active.json' : 'assets/inactive.json',
                                                                  fit: BoxFit.contain,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Expanded(
                                                                child: Text(
                                                                  'Selected Printer: ${printer.name ?? printer.address}',
                                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }),
                                                  Obx(() {
                                                    if (printController.isLoadingSettings.value) {
                                                      return const Padding(
                                                        padding: EdgeInsets.all(16.0),
                                                        child: Center(child: CircularProgressIndicator()),
                                                      );
                                                    }
                                                    if (printController.errorMessage.value.isNotEmpty) {
                                                      return Padding(
                                                        padding: const EdgeInsets.all(16.0),
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                'Error: ${printController.errorMessage.value}',
                                                                style: const TextStyle(color: Colors.red),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: printController.fetchSystemSettings,
                                                                child: const Text('Retry'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox.shrink();
                                                  }),
                                                  Expanded(
                                                    child: Obx(() {
                                                      final settings = printController.systemSettings.value;
                                                      final cartItems = _controller.cartItems;
                                                      if (settings == null) {
                                                        return const Center(child: Text('Loading receipt data...'));
                                                      }
                                                      return Receipt(
                                                        builder: (context) {
                                                          var now = DateTime.now();
                                                          var formatter = DateFormat('dd/MM/yyyy hh:mm:ss a');
                                                          String formattedDate = formatter.format(now);
                                                          double discountAmt =
                                                          (printController.totalAmount.value * 0.1).ceilToDouble();
                                                          double grandAmt = printController.totalAmount.value - discountAmt;
                                                          double givenAmount = 700.00;
                                                          double returnAmount = givenAmount - grandAmt;

                                                          List<String> splitText(String text, int maxLength) {
                                                            List<String> lines = [];
                                                            if (text.length <= maxLength) {
                                                              lines.add(text);
                                                              return lines;
                                                            }
                                                            while (text.isNotEmpty) {
                                                              if (text.length <= maxLength) {
                                                                lines.add(text);
                                                                break;
                                                              }
                                                              int splitIndex = text.substring(0, maxLength).lastIndexOf(' ');
                                                              if (splitIndex == -1 || splitIndex < maxLength ~/ 2) {
                                                                splitIndex = maxLength;
                                                              }
                                                              lines.add(text.substring(0, splitIndex));
                                                              text = text.substring(splitIndex).trim();
                                                            }
                                                            return lines;
                                                          }

                                                          return Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Center(
                                                                child: Image(
                                                                  image: CachedNetworkImageProvider(
                                                                    '${settings.billLogo}',
                                                                  ),
                                                                  height: 80,
                                                                  width: 200,
                                                                  fit: BoxFit.contain,
                                                                  errorBuilder: (_, __, ___) => Container(
                                                                    height: 150,
                                                                    width: 200,
                                                                    color: Colors.grey[200],
                                                                    child: const Icon(Icons.broken_image, size: 50),
                                                                  ),
                                                                ),
                                                              ),
                                                              Center(
                                                                child: Text(
                                                                  settings.firmName,
                                                                  style: GoogleFonts.merriweather(
                                                                    fontSize: 20,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Center(
                                                                child: Text(
                                                                  'CONTACT : ${settings.firmContact1} ${settings.firmContact2}',
                                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                              ),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Center(
                                                                child: Text(
                                                                  settings.billAddress?.isNotEmpty == true
                                                                      ? settings.billAddress!
                                                                      : 'Not mentioned bill address',
                                                                  style: GoogleFonts.merriweather(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Center(
                                                                child: Text(
                                                                  'GSTIN : ${settings.billGstinNum}',
                                                                  style: PrintConstants.mainDetailsTextStyle,
                                                                ),
                                                              ),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Obx(() => Text(
                                                                    'INVOICE ID : ${_controller.finalInvoiceId.value}',
                                                                      style: PrintConstants.mainDetailsTextStyle,
                                                                  )),
                                                                ],
                                                              ),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Text('DATE: $formattedDate', style: PrintConstants.mainDetailsTextStyle),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Obx(() {
                                                                final customerName = _controller.customerName.value;
                                                                final nameLines = splitText(customerName, 20);
                                                                return Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: nameLines.map((line) => Text(
                                                                    nameLines.first == line ? 'CUSTOMER NAME : $line' : line,
                                                                    style: PrintConstants.mainDetailsTextStyle,
                                                                  )).toList(),
                                                                );
                                                              }),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Obx(() => Text(
                                                                'MOBILE : ${_controller.customerMobileNumber.value}',
                                                                style: PrintConstants.mainDetailsTextStyle,
                                                              )),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Row(
                                                                children: const [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      '#',
                                                                      style: PrintConstants.itemsTextStyle,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 5,
                                                                    child: Text(
                                                                      'ITEMS',
                                                                      style: PrintConstants.itemsTextStyle,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      'AMOUNT',
                                                                      style: PrintConstants.itemsTextStyle,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      'QTY',
                                                                      style: PrintConstants.itemsTextStyle,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                      'TOTAL',
                                                                      style: PrintConstants.itemsTextStyle,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Divider(color: FormTextColors.dividerColor),
                                                              ...cartItems.asMap().entries.expand((entry) {
                                                                int idx = entry.key;
                                                                Product product = entry.value;
                                                                double itemTotal = (product.sellingPrice ?? 0) * product.quantity;
                                                                final itemName = product.itemName ?? 'Unknown';
                                                                final itemNameLines = splitText(itemName, 20);
                                                                return itemNameLines.asMap().entries.map((lineEntry) {
                                                                  int lineIdx = lineEntry.key;
                                                                  String line = lineEntry.value;
                                                                  return Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                          lineIdx == 0 ? '${idx + 1}' : '',
                                                                          style: PrintConstants.itemsTextStyle,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 5,
                                                                        child: Text(
                                                                          '$line', //${product.sellingUnit!}
                                                                          style: PrintConstants.itemsTextStyle,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                          lineIdx == 0
                                                                              ? '${(product.sellingPrice ?? 0).toStringAsFixed(2)}'
                                                                              : '',
                                                                          style: PrintConstants.itemsTextStyle,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: Text(
                                                                          lineIdx == 0 ? 'x${product.quantity}' : '',
                                                                          style: PrintConstants.itemsTextStyle,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                          lineIdx == 0 ? itemTotal.toStringAsFixed(2) : '',
                                                                          style: PrintConstants.itemsTextStyle,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                              }),
                                                              const Divider(color: Colors.black),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end, // aligns text to the right
                                                                children: [
                                                                  Text(
                                                                    'Sub-Total: ${_controller.totalAmount.value.toStringAsFixed(2)}',
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Divider(color: FormTextColors.dividerColor),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'General Items: ${cartItems.length}',
                                                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                  ),
                                                                  // Column for all amounts
                                                                  /*Column(
                                                                     crossAxisAlignment: CrossAxisAlignment.end, // aligns text to the right
                                                                     children: [
                                                                              Text(
                                                                              'GST: ${productController.gstAmount.value.toStringAsFixed(2)}',
                                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                                 ),
                                                                               SizedBox(height: 3,),
                                                                               Text(
                                                                              'Round-Off: ${productController.roundOff.value.toStringAsFixed(2)}',
                                                                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                               ),
                                                                              ],
                                                                             ),*/
                                                                ],
                                                              ),
                                                              const Divider(color: FormTextColors.dividerColor),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                    children: [
                                                                      Text(
                                                                        'GST: ${_controller.gstAmount.value.toStringAsFixed(2)}',
                                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                      ),
                                                                      SizedBox(height: 3),
                                                                      Text(
                                                                        'Round-Off: ${_controller.roundOff.value.toStringAsFixed(2)}',
                                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                      ),
                                                                      SizedBox(height: 3,),
                                                                      Text(
                                                                        'Grand Total: ${_controller.totalAmount.value + _controller.gstAmount.value + _controller.roundOff.value}',//${productController.computeGrandTotal}
                                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              Divider(color: Colors.black,),
                                                              PrintConstants.spaceBetweenWidgets,
                                                              /*Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text(
                                                                    'Grand Total:',
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                  ),
                                                                  Text(
                                                                    '${_controller.grandTotal.value.toStringAsFixed(2)}',
                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                  ),
                                                                ],
                                                              ),*/
                                                              const SizedBox(height: 15),
                                                              const Center(
                                                                child: Text(
                                                                  'Thank You.. Visit Again..!',
                                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                            ],
                                                          );
                                                        },
                                                        onInitialized: (controller) {
                                                          printController.setReceiptController(controller);
                                                          WidgetsBinding.instance.addPostFrameCallback((_) async {
                                                            await printController.printReceipt(dialogContext, _controller);
                                                            _controller.resetUICart();
                                                          });
                                                        },
                                                      );
                                                    }),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Print',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: TextColors.buttonTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                ),*/
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await printController.selectBluetoothDevice(context);
                                      /*Fluttertoast.showToast(
                                        msg: 'Printer Selected, printer selection updated',
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );*/
                                    },
                                    child: Text(
                                      'Select Device',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: TextColors.buttonTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProductCard(Product product, int originalIndex, bool isSearchMatch) {
    final isUnavailable = product.availabilityStatus?.toLowerCase() == 'un-available';

    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth;
        double cardHeight = constraints.maxHeight;

        // Responsive sizes with minimum limits
        double imageSize = (cardWidth * 0.25).clamp(60, 120); // min 60, max 120
        double fontSizeTitle = (cardWidth * 0.06).clamp(14, 20);
        double fontSizePrice = (cardWidth * 0.045).clamp(12, 18);
        double buttonRadius = (cardWidth * 0.07).clamp(14, 22);
        double spacing = (cardWidth * 0.05).clamp(12, 20);

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSearchMatch
                ? BorderSide(color: ProductsCardColors.activeBorderSideColor, width: 1)
                : BorderSide(color: ProductsCardColors.borderSideColor[300]!, width: 1),
          ),
          color: isUnavailable
              ? ProductsCardColors.UnavailableProductCardColor[400]
              : ProductsCardColors.availableProductCardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Availability Bar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: (cardHeight * 0.03).clamp(6, 12),
                  horizontal: (cardWidth * 0.03).clamp(6, 12),
                ),
                decoration: BoxDecoration(
                  color: isUnavailable
                      ? ProductsCardColors.unavailableBorderColor.shade700
                      : ProductsCardColors.availableBorderColor.shade700,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  product.availabilityStatus ?? 'Not mentioned',
                  style: TextStyle(
                    color: ProductsCardColors.productStatus,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizePrice,
                  ),
                  textAlign: TextAlign.center,
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                  duration: 2000.ms,
                  color: ProductsCardColors.productStatusShimmerColor,
                ),
              ),
              // Image & Product Info
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (product.itemImage != null && product.itemImage!.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _showFullScreenImage(
                            context,
                            product.itemImage!,
                            product.itemName ?? "Unnamed Product",
                            product.sellingPrice,        // <-- new
                            product.sellingUnit,
                          );
                        },
                        child: Hero(
                          tag: 'product-image-${product.itemImage}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image(
                              image: CachedNetworkImageProvider(product.itemImage!),
                              height: imageSize,
                              width: imageSize,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: imageSize,
                                width: imageSize,
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: imageSize,
                                  width: imageSize,
                                  color: Colors.grey[300],
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: imageSize,
                        width: imageSize,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    SizedBox(height: spacing / 2),
                    Padding(
                      padding: EdgeInsets.all(spacing / 2),
                      child: Text(
                        product.itemName ?? 'No name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSizeTitle,
                          color: isUnavailable
                              ? TextColors.minorTextColor
                              : TextColors.majorTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '₹${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'} ',
                          style: TextStyle(
                            color: isUnavailable
                                ? TextColors.minorTextColor
                                : TextColors.majorTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizePrice,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '(${product.sellingUnit ?? 'N/A'})',
                          style: TextStyle(
                            color: isUnavailable
                                ? TextColors.minorTextColor
                                : TextColors.majorTextColor,
                            fontSize: fontSizePrice,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Quantity Selector
              Padding(
                padding: EdgeInsets.only(bottom: spacing / 1.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrement Button
                    GestureDetector(
                      onTap: () => _controller.decrementQuantity(originalIndex),
                      child: CircleAvatar(
                        backgroundColor: ProductsCardColors.productDecrementBg.shade700,
                        radius: buttonRadius + 2, // <-- increased size
                        child: Icon(Icons.remove, color: Colors.white, size: buttonRadius + 8),
                      ),
                    ),
                    SizedBox(width: spacing),
                    // Animated Quantity
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.4),
                            end: Offset(0, 0),
                          ).animate(animation),
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Text(
                        product.quantity.toString(),
                        key: ValueKey(product.quantity),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(width: spacing),
                    // Increment Button
                    GestureDetector(
                      onTap: isUnavailable ? null : () => _controller.incrementQuantity(originalIndex),
                      child: CircleAvatar(
                        backgroundColor: isUnavailable
                            ? Colors.grey
                            : ProductsCardColors.productIncrementBg.shade700,
                        radius: buttonRadius + 2, // <-- increased size
                        child: Icon(Icons.add, color: Colors.white, size: buttonRadius + 8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showFullScreenImage(
      BuildContext context,
      String imageUrl,
      String productName,
      // Add the price (and optionally unit) so we can show it
      double? sellingPrice,
      String? sellingUnit,
      ) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Full-screen zoomable image
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 0.5,
                          maxScale: 4.0,
                          child: Hero(
                            tag: 'product-image-$imageUrl',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image(
                                image: CachedNetworkImageProvider(imageUrl),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.black38,
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white70, size: 80),
                                ),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.black38,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.white70),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Close button
                    Positioned(
                      top: 60,
                      right: 20,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 30),
                        ),
                      ),
                    ),

                    // Product name + price overlay at the bottom
                    Positioned(
                      bottom: 0,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Product name
                            Text(
                              productName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Price + unit
                            Text(
                              sellingPrice != null
                                  ? '₹${sellingPrice.toStringAsFixed(2)}' //${sellingUnit ?? ''}
                                  : 'Price not available',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.75, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }
  /*
  Widget buildProductCard(Product product, int originalIndex, bool isSearchMatch) {
  final isUnavailable = product.availabilityStatus?.toLowerCase() == 'un-available';

  return LayoutBuilder(
    builder: (context, constraints) {
      double cardWidth = constraints.maxWidth;
      double cardHeight = constraints.maxHeight;

      // Responsive sizes with minimum limits
      double imageSize = (cardWidth * 0.25).clamp(60, 120); // min 60, max 120
      double fontSizeTitle = (cardWidth * 0.06).clamp(14, 20);
      double fontSizePrice = (cardWidth * 0.045).clamp(12, 18);
      double buttonRadius = (cardWidth * 0.07).clamp(14, 22);
      double spacing = (cardWidth * 0.05).clamp(12, 20);

      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSearchMatch
              ? BorderSide(color: ProductsCardColors.activeBorderSideColor, width: 1)
              : BorderSide(color: ProductsCardColors.borderSideColor[300]!, width: 1),
        ),
        color: isUnavailable
            ? ProductsCardColors.UnavailableProductCardColor[400]
            : ProductsCardColors.availableProductCardColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Availability Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: (cardHeight * 0.03).clamp(6, 12),
                horizontal: (cardWidth * 0.03).clamp(6, 12),
              ),
              decoration: BoxDecoration(
                color: isUnavailable
                    ? ProductsCardColors.unavailableBorderColor.shade700
                    : ProductsCardColors.availableBorderColor.shade700,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                product.availabilityStatus ?? 'Not mentioned',
                style: TextStyle(
                  color: ProductsCardColors.productStatus,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizePrice,
                ),
                textAlign: TextAlign.center,
              ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                duration: 2000.ms,
                color: ProductsCardColors.productStatusShimmerColor,
              ),
            ),
            // Image & Product Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (product.itemImage != null && product.itemImage!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        image: CachedNetworkImageProvider(product.itemImage!),
                        height: imageSize,
                        width: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: imageSize,
                            width: imageSize,
                            color: Colors.grey[300],
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      height: imageSize,
                      width: imageSize,
                      color: Colors.grey[300],
                    ),
                  SizedBox(height: spacing / 2),
                  Padding(
                    padding: EdgeInsets.all(spacing / 2),
                    child: Text(
                      product.itemName ?? 'No name',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeTitle,
                        color: isUnavailable
                            ? TextColors.minorTextColor
                            : TextColors.majorTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'} ',
                        style: TextStyle(
                          color: isUnavailable
                              ? TextColors.minorTextColor
                              : TextColors.majorTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: fontSizePrice,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '(${product.sellingUnit ?? 'N/A'})',
                        style: TextStyle(
                          color: isUnavailable
                              ? TextColors.minorTextColor
                              : TextColors.majorTextColor,
                          fontSize: fontSizePrice,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Quantity Selector
            Padding(
              padding: EdgeInsets.only(bottom: spacing / 1.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrement Button
                  GestureDetector(
                    onTap: () => _controller.decrementQuantity(originalIndex),
                    child: CircleAvatar(
                      backgroundColor: ProductsCardColors.productDecrementBg.shade700,
                      radius: buttonRadius + 2, // <-- increased size
                      child: Icon(Icons.remove, color: Colors.white, size: buttonRadius + 8),
                    ),
                  ),
                  SizedBox(width: spacing),
                  // Animated Quantity
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.4),
                          end: Offset(0, 0),
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Text(
                      product.quantity.toString(),
                      key: ValueKey(product.quantity),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(width: spacing),
                  // Increment Button
                  GestureDetector(
                    onTap: isUnavailable ? null : () => _controller.incrementQuantity(originalIndex),
                    child: CircleAvatar(
                      backgroundColor: isUnavailable
                          ? Colors.grey
                          : ProductsCardColors.productIncrementBg.shade700,
                      radius: buttonRadius + 2, // <-- increased size
                      child: Icon(Icons.add, color: Colors.white, size: buttonRadius + 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
  Widget buildProductCard(Product product, int originalIndex, bool isSearchMatch) {
    final isUnavailable = product.availabilityStatus?.toLowerCase() == 'un-available';
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSearchMatch
            ? BorderSide(color: ProductsCardColors.activeBorderSideColor, width: 1)
            : BorderSide(color: ProductsCardColors.borderSideColor[300]!, width: 1),
      ),
      color: isUnavailable ? ProductsCardColors.UnavailableProductCardColor[400] : ProductsCardColors.availableProductCardColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Availability Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isUnavailable ? ProductsCardColors.unavailableBorderColor.shade700 : ProductsCardColors.availableBorderColor.shade700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              product.availabilityStatus ?? 'Not mentioned',
              style: TextStyle(
                color: ProductsCardColors.productStatus,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 2000.ms,
              color: ProductsCardColors.productStatusShimmerColor,
            ),
          ),
          // Image & Product Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (product.itemImage != null && product.itemImage!.isNotEmpty)
                  /*Image.network(
                    product.itemImage!,
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Just return an empty Container when image fails
                      return Container(
                        height: 80,
                        width: 80,
                        color: Colors.grey[300],
                      );
                    },
                  )*/
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // adjust radius as needed
                    child: Image(
                      image: CachedNetworkImageProvider(product.itemImage!),
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 80,
                          width: 80,
                          color: Colors.grey[300],
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[300],
                  ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    product.itemName ?? 'No name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isUnavailable ? TextColors.minorTextColor : TextColors.majorTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'} ',
                      style: TextStyle(
                        color: isUnavailable ? TextColors.minorTextColor : TextColors.majorTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '(${product.sellingUnit ?? 'N/A'})',
                      style: TextStyle(
                        color: isUnavailable ? TextColors.minorTextColor : TextColors.majorTextColor,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )
              ],
            ),
          ),

          // Quantity Selector
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Decrement Button ---
                GestureDetector(
                  onTap: () => _controller.decrementQuantity(originalIndex),
                  child: CircleAvatar(
                    backgroundColor: ProductsCardColors.productDecrementBg.shade700,
                    radius: 14,
                    child: Icon(Icons.remove, color: Colors.white, size: 20),
                  ),
                ),

                SizedBox(width: 16),  //12

                // --- Animated Quantity Number ---
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.4),   // slides from bottom
                        end: Offset(0, 0),
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    product.quantity.toString(),
                    key: ValueKey(product.quantity), // IMPORTANT
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                SizedBox(width: 16), //12

                // --- Increment Button ---
                GestureDetector(
                  onTap: isUnavailable ? null : () => _controller.incrementQuantity(originalIndex),
                  child: CircleAvatar(
                    backgroundColor: isUnavailable
                        ? Colors.grey
                        : ProductsCardColors.productIncrementBg.shade700,
                    radius: 14,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          )
          /*Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _controller.decrementQuantity(originalIndex),
                  child: CircleAvatar(
                    backgroundColor: ProductsCardColors.productDecrementBg.shade700,
                    radius: 14,
                    child: Icon(Icons.remove, color: Colors.white, size: 20),
                  ),
                ),
                SizedBox(width: 12),
                Text(product.quantity.toString(), style: TextStyle(fontSize: 16)),
                SizedBox(width: 12),
                GestureDetector(
                  onTap: isUnavailable ? null : () => _controller.incrementQuantity(originalIndex),
                  child: CircleAvatar(
                    backgroundColor: isUnavailable ? Colors.grey : ProductsCardColors.productIncrementBg.shade700,
                    radius: 14,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),*/
          /*
          adding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decrement Button
                InkWell(
                  borderRadius: BorderRadius.circular(50), // Important for circular ripple
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.white.withOpacity(0.1),
                  onTap: () => _controller.decrementQuantity(originalIndex),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: ProductsCardColors.productDecrementBg.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 28,   // 2 × radius
                      height: 28,
                      child: Icon(Icons.remove, color: Colors.white, size: 20),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  product.quantity.toString(),
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(width: 12),

                // Increment Button (with disabled state)
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  splashColor: isUnavailable ? null : Colors.white.withOpacity(0.3),
                  highlightColor: isUnavailable ? null : Colors.white.withOpacity(0.1),
                  onTap: isUnavailable ? null : () => _controller.incrementQuantity(originalIndex),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: isUnavailable
                          ? Colors.grey
                          : ProductsCardColors.productIncrementBg.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
           */
        ],
      ),
    );
  }
   */


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