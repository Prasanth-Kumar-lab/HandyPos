import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../Controller/add_product_controller.dart';
import '../model/add_product_model.dart';
import 'package:flutter/material.dart';
class EditProductPage extends StatefulWidget {
  final AddProductsAPI product;

  const EditProductPage({super.key, required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productCodeController = TextEditingController();
  final _productCatController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _unitsController = TextEditingController();
  final _cgstController = TextEditingController();
  final _sgstController = TextEditingController();
  final _igstController = TextEditingController();
  final _availabilityStatusController = TextEditingController();
  final AddProductsController controller = Get.find<AddProductsController>();

  @override
  void initState() {
    super.initState();
    _productCodeController.text = widget.product.productCode;
    _productCatController.text = widget.product.productCat;
    _itemNameController.text = widget.product.itemName;
    _sellingPriceController.text = widget.product.sellingPrice;
    _unitsController.text = widget.product.units;
    _cgstController.text = widget.product.cgst;
    _sgstController.text = widget.product.sgst;
    _igstController.text = widget.product.igst;
    _availabilityStatusController.text = widget.product.availabilityStatus;
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate()) {
      final params = {
        'product_code': _productCodeController.text,
        'product_cat': _productCatController.text,
        'item_name': _itemNameController.text,
        'selling_price': _sellingPriceController.text,
        'units': _unitsController.text,
        'cgst': _cgstController.text,
        'sgst': _sgstController.text,
        'igst': _igstController.text,
        'availability_status': _availabilityStatusController.text,
      };
      controller.updateProduct(widget.product.productCode, params);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _productCatController.dispose();
    _itemNameController.dispose();
    _sellingPriceController.dispose();
    _unitsController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    _igstController.dispose();
    _availabilityStatusController.dispose();
    super.dispose();
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextFormField(
          controller: _productCodeController,
          decoration: const InputDecoration(labelText: 'Product Code'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: _productCatController,
          decoration: const InputDecoration(labelText: 'Product Category'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: _itemNameController,
          decoration: const InputDecoration(labelText: 'Item Name'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: _sellingPriceController,
          decoration: const InputDecoration(labelText: 'Selling Price'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: _unitsController,
          decoration: const InputDecoration(labelText: 'Units'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: _cgstController,
          decoration: const InputDecoration(labelText: 'CGST'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: _sgstController,
          decoration: const InputDecoration(labelText: 'SGST'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: _igstController,
          decoration: const InputDecoration(labelText: 'IGST'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: _availabilityStatusController,
          decoration: const InputDecoration(labelText: 'Availability Status'),
          validator: (value) => value!.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _updateProduct,
              child: const Text('Update'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(child: _buildFormFields()),
        ),
      ),
    );
  }
}