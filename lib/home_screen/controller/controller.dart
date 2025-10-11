/*
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:task/api_endpoints.dart';
import 'package:uuid/uuid.dart';
import '../model/product_model.dart';

class ProductController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  RxList<Product> filteredProducts = <Product>[].obs;
  RxList<Product> cartItems = <Product>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString searchQuery = ''.obs;
  RxString cartId = '1'.obs;
  RxInt cartItemCount = 0.obs;
  RxString customerName = ''.obs;
  RxString customerMobileNumber = ''.obs;
  RxString finalInvoiceId = '0'.obs;

  final String businessId;
  final String billerId;
  final StreamController<int> _cartCountStreamController = StreamController<int>.broadcast();

  Stream<int> get cartCountStream => _cartCountStreamController.stream;

  ProductController({required this.businessId, required this.billerId});

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    // Listen to cartItemCount changes and broadcast to stream
    ever(cartItemCount, (int count) {
      _cartCountStreamController.add(count);
    });
  }

  @override
  void onClose() {
    _cartCountStreamController.close();
    super.onClose();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.productsEndPoint),
        body: {'business_id': businessId},
      );

      print('Fetch Products Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          products.assignAll(data.map((item) => Product.fromJson(item)).toList());
          filteredProducts.assignAll(products);
          isLoading.value = false;
          await fetchCartItems();
        } else {
          errorMessage.value = 'Unexpected response format';
          isLoading.value = false;
        }
      } else {
        errorMessage.value = 'Failed to load products: ${response.statusCode}';
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error fetching products: $e';
      isLoading.value = false;
    }
  }

  Future<void> fetchCartCount() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.cartCountEndPoint),
        body: {
          'business_id': businessId,
          'biller_id': billerId,
        },
      );

      print('Fetch Cart Count Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final serverCount = int.tryParse(response.body.trim()) ?? 0;
        // Update only if significantly different to avoid unnecessary UI updates
        if ((serverCount - cartItemCount.value).abs() > 1) {
          cartItemCount.value = serverCount;
        }
        print('Updated cartItemCount from server: ${cartItemCount.value}');
      } else {
        errorMessage.value = 'Failed to fetch cart count: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching cart count: $e';
    }
  }

  Future<void> fetchCartItems() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getCartItemsEndPoint),
        body: {
          'business_id': businessId,
          'biller_id': billerId,
        },
      );

      print('Fetch Cart Items Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded JSON: $data');

        if (data is Map<String, dynamic> && data['status'] == 'success') {
          cartId.value = data['cart_id']?.toString() ?? '1';
          customerName.value = data['customer_name']?.toString() ?? 'Customer';
          customerMobileNumber.value = data['customer_mobile_number']?.toString() ?? '0';

          String serverInvoiceId = data['final_invoice_id']?.toString() ?? '';
          if (serverInvoiceId.isEmpty || serverInvoiceId == '0') {
            serverInvoiceId = '';
          }
          finalInvoiceId.value = serverInvoiceId;

          final items = data['items'] as List? ?? [];
          cartItems.assignAll(items.map((item) => Product.fromCartJson(item)).toList());

          // Sync quantities and cartItemId with local products
          for (var product in products) {
            product.quantity = 0;
            product.cartItemId = null;
          }
          for (var cartItem in cartItems) {
            final matchingProduct = products.firstWhere(
                  (p) => p.productId == cartItem.productId || p.itemName == cartItem.itemName,
              orElse: () => Product(),
            );
            if (matchingProduct.productId != null || matchingProduct.itemName != null) {
              matchingProduct.quantity = cartItem.quantity;
              matchingProduct.cartItemId = cartItem.cartItemId;
              if (cartItem.sellingPrice == null || cartItem.sellingPrice == 0.0) {
                cartItem.sellingPrice = matchingProduct.sellingPrice;
              }
              if (cartItem.itemImage == null) {
                cartItem.itemImage = matchingProduct.itemImage;
              }
            }
          }
          cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
          print('Updated cartItemCount after fetchCartItems: ${cartItemCount.value}');
          products.refresh();
          filteredProducts.refresh();
        } else {
          errorMessage.value = 'Failed to fetch cart items: ${data['message'] ?? 'Invalid response format'}';
        }
      } else {
        errorMessage.value = 'Failed to fetch cart items: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching cart items: $e';
      print('Exception during fetchCartItems: $e');
    }
  }

  Future<void> incrementQuantity(int index) async {
    final product = products[index];
    final previousQuantity = product.quantity;
    product.quantity++;

    // Update cartItems locally
    final cartItemIndex = cartItems.indexWhere((item) => item.productId == product.productId || item.itemName == product.itemName);
    if (cartItemIndex != -1) {
      cartItems[cartItemIndex].quantity = product.quantity;
    } else {
      cartItems.add(Product(
        productId: product.productId,
        itemName: product.itemName,
        sellingPrice: product.sellingPrice,
        itemImage: product.itemImage,
        quantity: product.quantity,
        cartItemId: product.cartItemId,
      ));
    }
    cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    products.refresh();
    filteredProducts.refresh();

    // Sync with server in the background
    _syncWithServer('Increment', product, previousQuantity);
  }

  Future<void> decrementQuantity(int index) async {
    final product = products[index];
    if (product.quantity > 0) {
      final previousQuantity = product.quantity;
      product.quantity--;

      // Update cartItems locally
      final cartItemIndex = cartItems.indexWhere((item) => item.productId == product.productId || item.itemName == product.itemName);
      if (cartItemIndex != -1) {
        cartItems[cartItemIndex].quantity = product.quantity;
        if (product.quantity == 0) {
          cartItems.removeAt(cartItemIndex);
        }
      }
      cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
      products.refresh();
      filteredProducts.refresh();

      // Sync with server in the background
      _syncWithServer('Decrement', product, previousQuantity);
    }
  }

  Future<void> _syncWithServer(String transactionType, Product product, int previousQuantity) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.ordersEndPoint),
        body: {
          'business_id': businessId,
          'biller_id': billerId,
          'status': 'Pending',
          'transaction_type': transactionType,
          'product_id': product.productId ?? product.itemName,
          'gst_type': 'NO_GST',
        },
      );

      print('$transactionType Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'Success' ||
              (responseData['message'] != null &&
                  (responseData['message'].toString().contains('Item Added') ||
                      responseData['message'].toString().contains('Item Updated')))) {
            if (responseData['cart_id'] != null) {
              cartId.value = responseData['cart_id'].toString();
            }
            if (responseData['cart_item_id'] != null) {
              product.cartItemId = responseData['cart_item_id'].toString();
              final cartItemIndex = cartItems.indexWhere((item) => item.productId == product.productId || item.itemName == product.itemName);
              if (cartItemIndex != -1) {
                cartItems[cartItemIndex].cartItemId = product.cartItemId;
              }
            }
            await fetchCartItems(); // Full sync to ensure consistency
          } else {
            _revertQuantity(product, previousQuantity, transactionType);
          }
        } catch (e) {
          if (response.body.contains('Item Added') || response.body.contains('Item Updated')) {
            await fetchCartItems();
          } else {
            _revertQuantity(product, previousQuantity, transactionType);
          }
        }
      } else {
        _revertQuantity(product, previousQuantity, transactionType);
      }
    } catch (e) {
      _revertQuantity(product, previousQuantity, transactionType);
    }
  }

  void _revertQuantity(Product product, int previousQuantity, String transactionType) {
    errorMessage.value = 'Failed to $transactionType quantity: ${product.itemName}';
    product.quantity = previousQuantity;
    final cartItemIndex = cartItems.indexWhere((item) => item.productId == product.productId || item.itemName == product.itemName);
    if (cartItemIndex != -1) {
      cartItems[cartItemIndex].quantity = previousQuantity;
      if (previousQuantity == 0) {
        cartItems.removeAt(cartItemIndex);
      }
    } else if (previousQuantity > 0) {
      cartItems.add(Product(
        productId: product.productId,
        itemName: product.itemName,
        sellingPrice: product.sellingPrice,
        itemImage: product.itemImage,
        quantity: previousQuantity,
        cartItemId: product.cartItemId,
      ));
    }
    cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    products.refresh();
    filteredProducts.refresh();
    Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> removeItemFromCart(int index) async {
    final product = products[index];
    final previousQuantity = product.quantity;
    product.quantity = 0;
    products.refresh();
    filteredProducts.refresh();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.ordersEndPoint),
        body: {
          'business_id': businessId,
          'biller_id': billerId,
          'status': 'Pending',
          'transaction_type': 'Decrement',
          'product_id': product.productId ?? product.itemName,
        },
      );

      print('Remove Item Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'Success' ||
              (responseData['message'] != null &&
                  (responseData['message'].toString().contains('Item Added') ||
                      responseData['message'].toString().contains('Item Updated')))) {
            if (responseData['cart_id'] != null) {
              cartId.value = responseData['cart_id'].toString();
              print('Updated cart_id: ${cartId.value}');
            }
            Get.snackbar('Success', '${product.itemName} removed from cart',
                snackPosition: SnackPosition.BOTTOM);
          } else {
            errorMessage.value = 'Failed to remove item: ${responseData['message'] ?? 'Unknown error'}';
            product.quantity = previousQuantity;
            products.refresh();
            filteredProducts.refresh();
            Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
          }
        } catch (e) {
          if (response.body.contains('Item Added') || response.body.contains('Item Updated')) {
            Get.snackbar('Success', '${product.itemName} removed from cart',
                snackPosition: SnackPosition.BOTTOM);
          } else {
            errorMessage.value = 'Failed to remove item: ${response.body}';
            product.quantity = previousQuantity;
            products.refresh();
            filteredProducts.refresh();
            Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
          }
        }
      } else {
        errorMessage.value = 'Failed to remove item: ${response.statusCode} - ${response.body}';
        product.quantity = previousQuantity;
        products.refresh();
        filteredProducts.refresh();
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage.value = 'Error removing item: $e';
      product.quantity = previousQuantity;
      products.refresh();
      filteredProducts.refresh();
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      fetchCartCount();
    }
  }

  Future<void> clearCart() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.ordersEndPoint),
        body: {
          'delete_cart_id': cartId.value,
          'business_id': businessId,
          'transaction_type': 'Delete_Order',
        },
      );

      print('Delete Order Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'Success' ||
              (responseData['message'] != null &&
                  (responseData['message'].toString().contains('Item Added') ||
                      responseData['message'].toString().contains('Item Updated')))) {
            for (var product in products) {
              product.quantity = 0;
              product.cartItemId = null;
            }
            cartId.value = '1';
            customerName.value = '';
            customerMobileNumber.value = '';
            finalInvoiceId.value = '';
            products.refresh();
            filteredProducts.refresh();
            Get.snackbar('Success', 'Cart cleared successfully', snackPosition: SnackPosition.BOTTOM);
          } else {
            errorMessage.value = 'Failed to delete order: ${responseData['message'] ?? 'Unknown error'}';
            Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
          }
        } catch (e) {
          if (response.body.contains('Item Added') || response.body.contains('Item Updated')) {
            for (var product in products) {
              product.quantity = 0;
              product.cartItemId = null;
            }
            cartId.value = '1';
            customerName.value = 'Customer';
            customerMobileNumber.value = '0';
            finalInvoiceId.value = '1';
            products.refresh();
            filteredProducts.refresh();
            Get.snackbar('Success', 'Cart cleared successfully', snackPosition: SnackPosition.BOTTOM);
          } else {
            errorMessage.value = 'Failed to delete order: ${response.body}';
            Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
          }
        }
      } else {
        errorMessage.value = 'Failed to delete order: ${response.statusCode} - ${response.body}';
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage.value = 'Error deleting order: $e';
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      fetchCartCount();
    }
  }

  List<Product> get selectedProducts => products.where((p) => p.quantity > 0).toList();

  bool get hasItemsInCart => selectedProducts.isNotEmpty;

  double get totalAmount => selectedProducts.fold(
      0.0, (sum, p) => sum + (p.sellingPrice! * p.quantity));


  void filterProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      final lowercaseQuery = query.toLowerCase().replaceAll(' ', '');
      filteredProducts.assignAll(
        products.where((product) {
          final lowercaseProductName =
              product.itemName?.toLowerCase().replaceAll(' ', '') ?? '';
          return lowercaseProductName.contains(lowercaseQuery);
        }).toList(),
      );
    }
  }
}*/
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:task/api_endpoints.dart';
import 'package:uuid/uuid.dart';
import '../model/product_model.dart';

class ProductController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  RxList<Product> filteredProducts = <Product>[].obs;
  RxList<Product> cartItems = <Product>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString searchQuery = ''.obs;
  RxString cartId = '1'.obs;
  RxInt cartItemCount = 0.obs;
  RxString customerName = ''.obs;
  RxString customerMobileNumber = ''.obs;
  RxString finalInvoiceId = '0'.obs;

  final String businessId;
  final String billerId;
  final StreamController<int> _cartCountStreamController = StreamController<int>.broadcast();

  Stream<int> get cartCountStream => _cartCountStreamController.stream;

  ProductController({required this.businessId, required this.billerId});

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    ever(cartItemCount, (int count) {
      _cartCountStreamController.add(count);
    });
  }

  @override
  void onClose() {
    _cartCountStreamController.close();
    super.onClose();
  }
  Map<String, List<Product>> get productsGroupedByCategory {
    final Map<String, List<Product>> grouped = {};

    for (var product in filteredProducts) {
      final category = product.productCategory ?? 'Uncategorized';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(product);
    }

    return grouped;
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.productsEndPoint),
        body: {'business_id': businessId},
      );

      print('Fetch Products Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          products.assignAll(data.map((item) => Product.fromJson(item)).toList());
          filteredProducts.assignAll(products);
          isLoading.value = false;
          await fetchCartItems();
        } else {
          errorMessage.value = 'Unexpected response format';
          isLoading.value = false;
        }
      } else {
        errorMessage.value = 'Failed to load products: ${response.statusCode}';
        isLoading.value = false;
      }
    } catch (e) {
      errorMessage.value = 'Error fetching products: $e';
      isLoading.value = false;
    }
  }

  Future<void> fetchCartCount() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.cartCountEndPoint),
        body: {
          'business_id': businessId,
          'biller_id': billerId,
        },
      );

      print('Fetch Cart Count Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final serverCount = int.tryParse(response.body.trim()) ?? 0;
        if ((serverCount - cartItemCount.value).abs() > 1) {
          cartItemCount.value = serverCount;
        }
        print('Updated cartItemCount from server: ${cartItemCount.value}');
      } else {
        errorMessage.value = 'Failed to fetch cart count: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching cart count: $e';
    }
  }

  Future<void> fetchCartItems() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getCartItemsEndPoint),
        body: {
          'business_id': businessId,
          'biller_id': billerId,
        },
      );

      print('Fetch Cart Items Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded JSON: $data');

        if (data is Map<String, dynamic> && data['status'] == 'success') {
          cartId.value = data['cart_id']?.toString() ?? '1';
          customerName.value = data['customer_name']?.toString() ?? 'Customer';
          customerMobileNumber.value = data['customer_mobile_number']?.toString() ?? '0';

          String serverInvoiceId = data['final_invoice_id']?.toString() ?? '';
          if (serverInvoiceId.isEmpty || serverInvoiceId == '0') {
            serverInvoiceId = '';
          }
          finalInvoiceId.value = serverInvoiceId;

          final items = data['items'] as List? ?? [];
          cartItems.assignAll(items.map((item) => Product.fromCartJson(item)).toList());

          for (var product in products) {
            product.quantity = 0;
            product.cartItemId = null;
          }
          for (var cartItem in cartItems) {
            final matchingProduct = products.firstWhere(
                  (p) => p.productId == cartItem.productId || p.itemName == cartItem.itemName,
              orElse: () => Product(),
            );
            if (matchingProduct.productId != null || matchingProduct.itemName != null) {
              matchingProduct.quantity = cartItem.quantity;
              matchingProduct.cartItemId = cartItem.cartItemId;
              if (cartItem.sellingPrice == null || cartItem.sellingPrice == 0.0) {
                cartItem.sellingPrice = matchingProduct.sellingPrice;
              }
              if (cartItem.itemImage == null) {
                cartItem.itemImage = matchingProduct.itemImage;
              }
            }
          }
          cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
          print('Updated cartItemCount after fetchCartItems: ${cartItemCount.value}');
          products.refresh();
          filteredProducts.refresh();
        } else {
          errorMessage.value = 'Failed to fetch cart items: ${data['message'] ?? 'Invalid response format'}';
        }
      } else {
        errorMessage.value = 'Failed to fetch cart items: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      errorMessage.value = 'Error fetching cart items: $e';
      print('Exception during fetchCartItems: $e');
    }
  }

  Future<void> incrementQuantity(int index) async {
    final product = products[index];
    final previousQuantity = product.quantity;
    product.quantity++;

    final cartItemIndex = cartItems.indexWhere((item) => item.productId == product.productId || item.itemName == product.itemName);
    if (cartItemIndex != -1) {
      cartItems[cartItemIndex].quantity = product.quantity;
    } else {
      cartItems.add(Product(
        productId: product.productId,
        itemName: product.itemName,
        sellingPrice: product.sellingPrice,
        itemImage: product.itemImage,
        quantity: product.quantity,
        cartItemId: product.cartItemId,
      ));
    }
    cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    products.refresh();
    filteredProducts.refresh();

    _syncWithServer('Increment', product, previousQuantity);
  }

  Future<void> decrementQuantity(int index) async {
    final product = products[index];
    if (product.quantity > 0) {
      final previousQuantity = product.quantity;
      product.quantity--;

      final cartItemIndex = cartItems.indexWhere((item) => item.productId == product.productId || item.itemName == product.itemName);
      if (cartItemIndex != -1) {
        cartItems[cartItemIndex].quantity = product.quantity;
        if (product.quantity == 0) {
          cartItems.removeAt(cartItemIndex);
        }
      }
      cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
      products.refresh();
      filteredProducts.refresh();

      _syncWithServer('Decrement', product, previousQuantity);
    }
  }

  Future<void> _syncWithServer(String transactionType, Product product, int previousQuantity) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.ordersEndPoint),
        body: {
          'business_id': businessId,
          'biller_id': billerId,
          'status': 'Pending',
          'transaction_type': transactionType,
          'product_id': product.productId ?? product.itemName,
          'gst_type': 'NO_GST',
        },
      );

      print('$transactionType Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'Success' ||
              (responseData['message'] != null &&
                  (responseData['message'].toString().contains('Item Added') ||
                      responseData['message'].toString().contains('Item Updated')))) {
            if (responseData['cart_id'] != null) {
              cartId.value = responseData['cart_id'].toString();
            }
            if (responseData['cart_item_id'] != null) {
              product.cartItemId = responseData['cart_item_id'].toString();
              final cartItemIndex = cartItems.indexWhere((item) => item.productId == product.productId || item.itemName == product.itemName);
              if (cartItemIndex != -1) {
                cartItems[cartItemIndex].cartItemId = product.cartItemId;
              }
            }
            await fetchCartItems();
          } else {
            _revertQuantity(product, previousQuantity, transactionType);
          }
        } catch (e) {
          if (response.body.contains('Item Added') || response.body.contains('Item Updated')) {
            await fetchCartItems();
          } else {
            _revertQuantity(product, previousQuantity, transactionType);
          }
        }
      } else {
        _revertQuantity(product, previousQuantity, transactionType);
      }
    } catch (e) {
      _revertQuantity(product, previousQuantity, transactionType);
    }
  }

  void _revertQuantity(Product product, int previousQuantity, String transactionType) {
    errorMessage.value = 'Failed to $transactionType quantity: ${product.itemName}';
    product.quantity = previousQuantity;
    final cartItemIndex = cartItems.indexWhere((item) => item.productId == product.productId || item.itemName == product.itemName);
    if (cartItemIndex != -1) {
      cartItems[cartItemIndex].quantity = previousQuantity;
      if (previousQuantity == 0) {
        cartItems.removeAt(cartItemIndex);
      }
    } else if (previousQuantity > 0) {
      cartItems.add(Product(
        productId: product.productId,
        itemName: product.itemName,
        sellingPrice: product.sellingPrice,
        itemImage: product.itemImage,
        quantity: previousQuantity,
        cartItemId: product.cartItemId,
      ));
    }
    cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    products.refresh();
    filteredProducts.refresh();
    Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> removeItemFromCart(int index) async {
    final product = products[index];
    final previousQuantity = product.quantity;
    product.quantity = 0;
    products.refresh();
    filteredProducts.refresh();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.ordersEndPoint),
        body: {
          'business_id': businessId,
          'biller_id': billerId,
          'status': 'Pending',
          'transaction_type': 'Decrement',
          'product_id': product.productId ?? product.itemName,
        },
      );

      print('Remove Item Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['status'] == 'Success' ||
              (responseData['message'] != null &&
                  (responseData['message'].toString().contains('Item Added') ||
                      responseData['message'].toString().contains('Item Updated')))) {
            if (responseData['cart_id'] != null) {
              cartId.value = responseData['cart_id'].toString();
              print('Updated cart_id: ${cartId.value}');
            }
            Get.snackbar('Success', '${product.itemName} removed from cart',
                snackPosition: SnackPosition.BOTTOM);
          } else {
            errorMessage.value = 'Failed to remove item: ${responseData['message'] ?? 'Unknown error'}';
            product.quantity = previousQuantity;
            products.refresh();
            filteredProducts.refresh();
            Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
          }
        } catch (e) {
          if (response.body.contains('Item Added') || response.body.contains('Item Updated')) {
            Get.snackbar('Success', '${product.itemName} removed from cart',
                snackPosition: SnackPosition.BOTTOM);
          } else {
            errorMessage.value = 'Failed to remove item: ${response.body}';
            product.quantity = previousQuantity;
            products.refresh();
            filteredProducts.refresh();
            Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
          }
        }
      } else {
        errorMessage.value = 'Failed to remove item: ${response.statusCode} - ${response.body}';
        product.quantity = previousQuantity;
        products.refresh();
        filteredProducts.refresh();
        Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      errorMessage.value = 'Error removing item: $e';
      product.quantity = previousQuantity;
      products.refresh();
      filteredProducts.refresh();
      Get.snackbar('Error', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      fetchCartCount();
    }
  }

  void resetUICart() {
    for (var product in products) {
      product.quantity = 0;
      product.cartItemId = null;
    }
    cartItems.clear();
    cartItemCount.value = 0;
    cartId.value = '1';
    customerName.value = 'Customer';
    customerMobileNumber.value = '0';
    finalInvoiceId.value = '';
    products.refresh();
    filteredProducts.refresh();
    //Get.snackbar('Success', 'Cart cleared in UI', snackPosition: SnackPosition.BOTTOM);
  }

  List<Product> get selectedProducts => products.where((p) => p.quantity > 0).toList();

  bool get hasItemsInCart => selectedProducts.isNotEmpty;

  double get totalAmount => selectedProducts.fold(
      0.0, (sum, p) => sum + (p.sellingPrice! * p.quantity));

  void filterProducts(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredProducts.assignAll(products);
    } else {
      final lowercaseQuery = query.toLowerCase().replaceAll(' ', '');
      filteredProducts.assignAll(
        products.where((product) {
          final lowercaseProductName =
              product.itemName?.toLowerCase().replaceAll(' ', '') ?? '';
          return lowercaseProductName.contains(lowercaseQuery);
        }).toList(),
      );
    }
  }
}