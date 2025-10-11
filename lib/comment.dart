import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _businessIdController = TextEditingController();
  List<dynamic> _products = [];
  bool _isLoading = false;

  Future<void> fetchProducts() async {
    final businessId = _businessIdController.text.trim();
    if (businessId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _products.clear();
    });

    final url = Uri.parse(
        'https://erpapp.in/mart_print/mart_print_apis/list_products_api.php');

    try {
      final response = await http.post(
        url,
        body: {'business_id': businessId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildProductCard(dynamic product) {
    return Card(
      child: ListTile(
        leading: Image.network(
          product['image_path'] ?? '',
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.image),
        ),
        title: Text(product['item_name'] ?? 'No Name'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selling Price: ₹${product['selling_price']}'),
            Text('Available Quantity: ${product['available_quantity']}'),
            Text('Category: ${product['product_cat']}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _businessIdController,
              decoration: InputDecoration(
                labelText: 'Enter Business ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: fetchProducts,
              child: Text('Submit'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : _products.isEmpty
                ? Text('No products found.')
                : Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) =>
                    buildProductCard(_products[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
