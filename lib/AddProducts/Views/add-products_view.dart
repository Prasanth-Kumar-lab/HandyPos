import 'dart:io'; // Added for File handling
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart'; // Added for image picker
import '../Controller/add_product_controller.dart';
import 'custom_tab_bar.dart';
import 'edit_products_page.dart';

class AddProductsPage extends StatefulWidget {
  final String businessId;

  const AddProductsPage({super.key, required this.businessId});

  @override
  _AddProductsPageState createState() => _AddProductsPageState();
}

class _AddProductsPageState extends State<AddProductsPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _productCodeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _unitsController = TextEditingController();
  final _availabilityStatusController = TextEditingController();
  final _businessIdController = TextEditingController();
  late final AddProductsController controller;
  String? _selectedCategory;
  String? _selectedCgst;
  String? _selectedSgst;
  String? _selectedIgst;
  String? _selectedAvailabilityStatus;
  File? _selectedImage; // Added for image picking
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _businessIdController.text = widget.businessId;
    controller = Get.put(AddProductsController(businessId: widget.businessId));
    _availabilityStatusController.text = 'Available';
    _selectedAvailabilityStatus = 'Available';
  }

  @override
  void dispose() {
    _productCodeController.dispose();
    _itemNameController.dispose();
    _sellingPriceController.dispose();
    _unitsController.dispose();
    _availabilityStatusController.dispose();
    _businessIdController.dispose();
    super.dispose();
  }

  // Function to pick image
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        if (fileSize > 500 * 1024) {
          Get.snackbar('Error', 'Image size must be less than 500KB');
          return;
        }
        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Error picking image: $e');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final params = {
        'product_code': _productCodeController.text,
        'product_cat': _selectedCategory ?? '',
        'item_name': _itemNameController.text,
        'selling_price': _sellingPriceController.text,
        'units': _unitsController.text,
        'cgst': _selectedCgst ?? '',
        'sgst': _selectedSgst ?? '',
        'igst': _selectedIgst ?? '',
        'availability_status': _selectedAvailabilityStatus ?? '',
        'business_id': _businessIdController.text,
      };
      controller.addProduct(params, _selectedImage);
      _clearForm();
    }
  }

  void _clearForm() {
    _productCodeController.clear();
    _selectedCategory = null;
    _itemNameController.clear();
    _sellingPriceController.clear();
    _unitsController.clear();
    _selectedCgst = null;
    _selectedSgst = null;
    _selectedIgst = null;
    _selectedAvailabilityStatus = 'Available';
    _availabilityStatusController.text = 'Available';
    _businessIdController.text = widget.businessId;
    _selectedImage = null; // Clear selected image
    setState(() {});
  }

  Widget _buildTaxDropdown({
    required String label,
    required String taxType,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Obx(() {
      final filteredTaxes = controller.taxes
          .where((tax) => tax.taxType.toLowerCase() == taxType.toLowerCase())
          .toList();
      final uniqueTaxPercentages = filteredTaxes
          .map((tax) => tax.taxPercentage)
          .toSet()
          .toList();

      return DropdownButtonFormField2<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        value: selectedValue,
        hint: Text('Select $label'),
        items: uniqueTaxPercentages.map((taxPercentage) {
          return DropdownMenuItem<String>(
            value: taxPercentage,
            child: SizedBox(
              height: 40,
              child: Text(taxPercentage),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(6),
            thumbColor: MaterialStateProperty.all(Colors.grey),
          ),
        ),
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 30,
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
        ),
      );
    });
  }

  Widget buildCircularBorderTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Product Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildCircularBorderTextField(
              controller: _productCodeController,
              label: 'Product Code',
              icon: Icons.qr_code,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField2<String>(
              decoration: InputDecoration(
                labelText: 'Product Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              value: _selectedCategory,
              hint: const Text('Select a category'),
              items: controller.categories
                  .map((cat) => cat.catName)
                  .toSet()
                  .toList()
                  .map((catName) {
                return DropdownMenuItem<String>(
                  value: catName,
                  child: Text(catName),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              validator: (value) => value == null ? 'Please select a category' : null,
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbColor: MaterialStateProperty.all(Colors.grey),
                ),
              ),
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 26,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
              ),
            )),
            const SizedBox(height: 24),
            const Text(
              'Item Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildCircularBorderTextField(
              controller: _itemNameController,
              label: 'Item Name',
              icon: Icons.inventory,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            buildCircularBorderTextField(
              controller: _sellingPriceController,
              label: 'Selling Price',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            buildCircularBorderTextField(
              controller: _unitsController,
              label: 'Units',
              icon: Icons.confirmation_number,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Tax Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTaxDropdown(
              label: 'CGST',
              taxType: 'CGST',
              selectedValue: _selectedCgst,
              onChanged: (value) {
                setState(() {
                  _selectedCgst = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTaxDropdown(
              label: 'SGST',
              taxType: 'SGST',
              selectedValue: _selectedSgst,
              onChanged: (value) {
                setState(() {
                  _selectedSgst = value;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTaxDropdown(
              label: 'IGST',
              taxType: 'IGST',
              selectedValue: _selectedIgst,
              onChanged: (value) {
                setState(() {
                  _selectedIgst = value;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Product Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedImage != null
                        ? 'Image Selected: ${_selectedImage!.path.split('/').last}'
                        : 'No image selected',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Choose Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade100,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              Image.file(
                _selectedImage!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField2<String>(
              decoration: InputDecoration(
                labelText: 'Availability Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                prefixIcon: const Icon(Icons.check_circle_outline),
              ),
              value: _selectedAvailabilityStatus,
              hint: const Text('Select Availability'),
              items: [
                DropdownMenuItem<String>(
                  value: 'Available',
                  child: SizedBox(
                    height: 40,
                    child: Text('Available'),
                  ),
                ),
                DropdownMenuItem<String>(
                  value: 'Un-Available',
                  child: SizedBox(
                    height: 40,
                    child: Text('Un-Available'),
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedAvailabilityStatus = newValue;
                  _availabilityStatusController.text = newValue ?? '';
                });
              },
              validator: (value) => value == null ? 'Please select availability status' : null,
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all(6),
                  thumbColor: MaterialStateProperty.all(Colors.grey),
                ),
              ),
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16),
                height: 26,
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: Icon(Icons.add_circle, color: Colors.blueGrey.shade900),
              label: Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.products.isEmpty) {
        return const Center(child: Text('No products added yet.'));
      }

      return ListView.builder(
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return ListTile(
            leading: product.imagePath != null && product.imagePath!.isNotEmpty
                ? Image.network(
              product.imagePath!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
            )
                : const Icon(Icons.image_not_supported, size: 50),
            title: Text(product.itemName),
            subtitle: Text(
              'Price: ₹${product.sellingPrice} | Category: ${product.productCat}',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductPage(product: product),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => controller.deleteProduct(product.productId),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Manager'),
          bottom: CustomTabBar(),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TabBarView(
              children: [
                SingleChildScrollView(child: _buildFormFields()),
                _buildProductList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}