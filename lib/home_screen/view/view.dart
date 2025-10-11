/*
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:task/profile/views/profile_page.dart';
import 'package:task/print/views/print_screen.dart';
import '../../print/controller/print_controller.dart';
import '../controller/controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
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
      printController.initializePrinterConnection(context);
    });
    Get.put(PrintController(
      initialProducts: [],
      initialTotal: 0.0,
      businessId: widget.businessId,
    ));
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hello ${widget.name}.', style: TextStyle(fontWeight: FontWeight.w600)),
          leading: IconButton(
            onPressed: () {
              Get.to(() => ProfilePage(
                businessId: widget.businessId,
                user_id: widget.user_id,
                role: widget.role,
              ));
            },
            icon: Icon(CupertinoIcons.profile_circled, size: 30, color: Colors.blueGrey.shade900),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
            duration: 2000.ms,
            color: Colors.white,
          ),
          backgroundColor: Colors.green.withOpacity(0.6),
          actions: [
            IconButton(onPressed: _controller.fetchProducts, icon: Icon(Icons.sync)),
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
                              child: Lottie.asset('assets/No Data found.json'),
                            ),
                          ),
                        )
                            : ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: MaterialStateProperty.all(Colors.green.shade300),
                            trackColor: MaterialStateProperty.all(Colors.grey[300]),
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
                                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7).copyWith(bottom:120),
                                  itemCount: grouped.length,
                                  itemBuilder: (context, categoryIndex) {
                                    final category = grouped.keys.elementAt(categoryIndex);
                                    final products = grouped[category]!;
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
                                        GridView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: products.length,
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.85,
                                            crossAxisSpacing: 3,
                                            mainAxisSpacing: 3,
                                          ),
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
                              })
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
                          color: Colors.green.shade300,
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
                                      color: Colors.white,
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
                                                color: Colors.white,
                                              ),
                                            ).animate(onPlay: (controller) => controller.repeat())
                                                .shimmer(
                                              duration: 2000.ms,
                                              color: Colors.red,
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
                                                  color: Colors.white,
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
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await printController.syncCartData(_controller);
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
                                        color: Colors.white,
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
                                                                child: Text(
                                                                  settings.firmName,
                                                                  style: GoogleFonts.merriweather(
                                                                    fontSize: 22,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Center(
                                                                child: Text(
                                                                  'CONTACT : ${settings.firmContact1} ${settings.firmContact2}',
                                                                  style:
                                                                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Center(
                                                                child: Text(
                                                                  settings.billAddress,
                                                                  style: GoogleFonts.merriweather(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Center(
                                                                child: Text(
                                                                  'GSTIN : ${settings.billGstinNum}',
                                                                  style: const TextStyle(fontSize: 15),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Obx(() => Text(
                                                                    'INVOICE ID : ${_controller.finalInvoiceId.value}',
                                                                    style: TextStyle(fontSize: 17),
                                                                  )),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Text('DATE: $formattedDate', style: TextStyle(fontSize: 17)),
                                                              const SizedBox(height: 6),
                                                              Obx(() {
                                                                final customerName = _controller.customerName.value;
                                                                final nameLines = splitText(customerName, 20);
                                                                return Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: nameLines.map((line) => Text(
                                                                    nameLines.first == line ? 'CUSTOMER NAME : $line' : line,
                                                                    style: const TextStyle(fontSize: 16),
                                                                  )).toList(),
                                                                );
                                                              }),
                                                              const SizedBox(height: 6),
                                                              Obx(() => Text(
                                                                'MOBILE : ${_controller.customerMobileNumber.value}',
                                                                style: const TextStyle(fontSize: 17),
                                                              )),
                                                              const SizedBox(height: 10),
                                                              Row(
                                                                children: const [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      '#',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 5,
                                                                    child: Text(
                                                                      'ITEMS',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      'AMOUNT',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      'QTY',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                      'TOTAL',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Divider(color: Colors.black),
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
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 5,
                                                                        child: Text(
                                                                          line,
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                          lineIdx == 0
                                                                              ? '${(product.sellingPrice ?? 0).toStringAsFixed(2)}(1Kg)'
                                                                              : '',
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: Text(
                                                                          lineIdx == 0 ? 'x${product.quantity}' : '',
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                          lineIdx == 0 ? itemTotal.toStringAsFixed(2) : '',
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                              }),
                                                              const Divider(color: Colors.black),
                                                              const SizedBox(height: 10),
                                                              const Text('Total', style: TextStyle(fontSize: 19)),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text('General Items:', style: TextStyle(fontSize: 16)),
                                                                  Text(
                                                                    '${cartItems.length}',
                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                  ),
                                                                  const Text(
                                                                    'TOTAL:',
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                                                                  ),
                                                                  Text(
                                                                    printController.totalAmount.value.toStringAsFixed(2),
                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 0),
                                                              const Divider(color: Colors.black),
                                                              const SizedBox(height: 5),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'Grand Total:',
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                                                                  ),
                                                                  Text(
                                                                    printController.totalAmount.value.toStringAsFixed(2),
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 20),
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
                                        color: Colors.white,
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
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await printController.selectBluetoothDevice(context);
                                      Get.snackbar(
                                        'Printer Selected',
                                        'Printer selection updated',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    child: Text(
                                      'Select Device',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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

  Widget buildProductCard(Product product, int originalIndex, bool isSearchMatch) {
    final isUnavailable = product.availabilityStatus?.toLowerCase() == 'un-available';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSearchMatch
            ? BorderSide(color: Colors.green, width: 1)
            : BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      color: isUnavailable ? Colors.grey[400] : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isUnavailable ? Colors.red.shade700 : Colors.green.shade700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              product.availabilityStatus ?? 'Not mentioned',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 2000.ms,
              color: Colors.black,
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                product.itemImage != null && product.itemImage!.isNotEmpty
                    ? Image.network(
                  product.itemImage!,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: isUnavailable ? Colors.grey : Colors.blueAccent,
                  ),
                )
                    : Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: isUnavailable ? Colors.grey : Colors.blueAccent,
                ),
                SizedBox(height: 8),
                Text(
                  product.itemName ?? 'No name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isUnavailable ? Colors.grey[600] : Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'} ',
                      style: TextStyle(
                        color: isUnavailable ? Colors.grey[600] : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${product.sellingUnit ?? 'N/A'})',
                      style: TextStyle(color: isUnavailable ? Colors.grey[600] : Colors.grey[700]),
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _controller.decrementQuantity(originalIndex),
                  child: CircleAvatar(
                    backgroundColor: Colors.red.shade700,
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
                    backgroundColor: isUnavailable ? Colors.grey : Colors.green.shade700,
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
          ),
        ],
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
}*/
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:task/profile/views/profile_page.dart';
import 'package:task/print/views/print_screen.dart';
import '../../print/controller/print_controller.dart';
import '../controller/controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
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
      printController.initializePrinterConnection(context);
    });
    Get.put(PrintController(
      initialProducts: [],
      initialTotal: 0.0,
      businessId: widget.businessId,
    ));
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hello ${widget.name}.', style: TextStyle(fontWeight: FontWeight.w600)),
          leading: IconButton(
            onPressed: () {
              Get.to(() => ProfilePage(
                businessId: widget.businessId,
                user_id: widget.user_id,
                role: widget.role,
              ));
            },
            icon: Icon(CupertinoIcons.profile_circled, size: 30, color: Colors.blueGrey.shade900),
          ).animate(onPlay: (controller) => controller.repeat()).shimmer(
            duration: 2000.ms,
            color: Colors.white,
          ),
          backgroundColor: Colors.green.withOpacity(0.6),
          actions: [
            IconButton(onPressed: _controller.fetchProducts, icon: Icon(Icons.sync)),
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
                              child: Lottie.asset('assets/No Data found.json'),
                            ),
                          ),
                        )
                            : ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: MaterialStateProperty.all(Colors.green.shade300),
                            trackColor: MaterialStateProperty.all(Colors.grey[300]),
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
                                      // First Row
                                      SizedBox(
                                        height: 220, // Adjust height based on your card size
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            children: firstRowProducts.asMap().entries.map((entry) {
                                              final index = entry.key;
                                              final product = entry.value;
                                              final originalIndex = _controller.products.indexOf(product);
                                              final isSearchMatch = _controller.searchQuery.value.isNotEmpty &&
                                                  (product.itemName != null &&
                                                      product.itemName!.toLowerCase().replaceAll(' ', '').contains(
                                                          _controller.searchQuery.value.toLowerCase().replaceAll(' ', '')));

                                              return Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 4),
                                                child: SizedBox(
                                                  width: 160, // Adjust width based on your card size
                                                  child: buildProductCard(product, originalIndex, isSearchMatch),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      // Second Row
                                      if (secondRowProducts.isNotEmpty)
                                        SizedBox(
                                          height: 220, // Adjust height based on your card size
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: secondRowProducts.asMap().entries.map((entry) {
                                                final index = entry.key;
                                                final product = entry.value;
                                                final originalIndex = _controller.products.indexOf(product);
                                                final isSearchMatch = _controller.searchQuery.value.isNotEmpty &&
                                                    (product.itemName != null &&
                                                        product.itemName!.toLowerCase().replaceAll(' ', '').contains(
                                                            _controller.searchQuery.value.toLowerCase().replaceAll(' ', '')));

                                                return Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                                  child: SizedBox(
                                                    width: 160, // Adjust width based on your card size
                                                    child: buildProductCard(product, originalIndex, isSearchMatch),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
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
                          color: Colors.green.shade300,
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
                                      color: Colors.white,
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
                                                color: Colors.white,
                                              ),
                                            ).animate(onPlay: (controller) => controller.repeat())
                                                .shimmer(
                                              duration: 2000.ms,
                                              color: Colors.red,
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
                                                  color: Colors.white,
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
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await printController.syncCartData(_controller);
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
                                        color: Colors.white,
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
                                                                child: Text(
                                                                  settings.firmName,
                                                                  style: GoogleFonts.merriweather(
                                                                    fontSize: 22,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Center(
                                                                child: Text(
                                                                  'CONTACT : ${settings.firmContact1} ${settings.firmContact2}',
                                                                  style:
                                                                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Center(
                                                                child: Text(
                                                                  settings.billAddress,
                                                                  style: GoogleFonts.merriweather(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 5),
                                                              Center(
                                                                child: Text(
                                                                  'GSTIN : ${settings.billGstinNum}',
                                                                  style: const TextStyle(fontSize: 15),
                                                                ),
                                                              ),
                                                              const SizedBox(height: 10),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Obx(() => Text(
                                                                    'INVOICE ID : ${_controller.finalInvoiceId.value}',
                                                                    style: TextStyle(fontSize: 17),
                                                                  )),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 6),
                                                              Text('DATE: $formattedDate', style: TextStyle(fontSize: 17)),
                                                              const SizedBox(height: 6),
                                                              Obx(() {
                                                                final customerName = _controller.customerName.value;
                                                                final nameLines = splitText(customerName, 20);
                                                                return Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: nameLines.map((line) => Text(
                                                                    nameLines.first == line ? 'CUSTOMER NAME : $line' : line,
                                                                    style: const TextStyle(fontSize: 16),
                                                                  )).toList(),
                                                                );
                                                              }),
                                                              const SizedBox(height: 6),
                                                              Obx(() => Text(
                                                                'MOBILE : ${_controller.customerMobileNumber.value}',
                                                                style: const TextStyle(fontSize: 17),
                                                              )),
                                                              const SizedBox(height: 10),
                                                              Row(
                                                                children: const [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      '#',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 5,
                                                                    child: Text(
                                                                      'ITEMS',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      'AMOUNT',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      'QTY',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                      'TOTAL',
                                                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const Divider(color: Colors.black),
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
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 5,
                                                                        child: Text(
                                                                          line,
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                          lineIdx == 0
                                                                              ? '${(product.sellingPrice ?? 0).toStringAsFixed(2)}(1Kg)'
                                                                              : '',
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: Text(
                                                                          lineIdx == 0 ? 'x${product.quantity}' : '',
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                          lineIdx == 0 ? itemTotal.toStringAsFixed(2) : '',
                                                                          style:
                                                                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                              }),
                                                              const Divider(color: Colors.black),
                                                              const SizedBox(height: 10),
                                                              const Text('Total', style: TextStyle(fontSize: 19)),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  const Text('General Items:', style: TextStyle(fontSize: 16)),
                                                                  Text(
                                                                    '${cartItems.length}',
                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                  ),
                                                                  const Text(
                                                                    'TOTAL:',
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                                                                  ),
                                                                  Text(
                                                                    printController.totalAmount.value.toStringAsFixed(2),
                                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 0),
                                                              const Divider(color: Colors.black),
                                                              const SizedBox(height: 5),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    'Grand Total:',
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                                                                  ),
                                                                  Text(
                                                                    printController.totalAmount.value.toStringAsFixed(2),
                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(height: 20),
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
                                        color: Colors.white,
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
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await printController.selectBluetoothDevice(context);
                                      Get.snackbar(
                                        'Printer Selected',
                                        'Printer selection updated',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    child: Text(
                                      'Select Device',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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

  Widget buildProductCard(Product product, int originalIndex, bool isSearchMatch) {
    final isUnavailable = product.availabilityStatus?.toLowerCase() == 'un-available';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSearchMatch
            ? BorderSide(color: Colors.green, width: 1)
            : BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      color: isUnavailable ? Colors.grey[400] : Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Availability Bar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isUnavailable ? Colors.red.shade700 : Colors.green.shade700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              product.availabilityStatus ?? 'Not mentioned',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
              duration: 2000.ms,
              color: Colors.black,
            ),
          ),

          // Image & Product Info
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (product.itemImage != null && product.itemImage!.isNotEmpty)
                  Image.network(
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
                  )
                else
                  Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[300],
                  ),
                SizedBox(height: 8),
                Text(
                  product.itemName ?? 'No name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isUnavailable ? Colors.grey[600] : Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹${product.sellingPrice?.toStringAsFixed(2) ?? 'N/A'} ',
                      style: TextStyle(
                        color: isUnavailable ? Colors.grey[600] : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${product.sellingUnit ?? 'N/A'})',
                      style: TextStyle(
                        color: isUnavailable ? Colors.grey[600] : Colors.grey[700],
                      ),
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
                GestureDetector(
                  onTap: () => _controller.decrementQuantity(originalIndex),
                  child: CircleAvatar(
                    backgroundColor: Colors.red.shade700,
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
                    backgroundColor: isUnavailable ? Colors.grey : Colors.green.shade700,
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
          ),
        ],
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