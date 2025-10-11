import 'dart:io'; // Added for File handling
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart'; // Added for image picker
import '../Controller/add_product_controller.dart';
import '../model/add_product_model.dart';
import '../model/list_product_category_fetch.dart';
import '../model/list_tax_model.dart';

class EditProductPage extends StatefulWidget {
  final AddProductsAPI product;

  const EditProductPage({super.key, required this.product});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _productIdController = TextEditingController();
  final _productCodeController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _unitsController = TextEditingController();
  final _availabilityStatusController = TextEditingController();
  final _businessIdController = TextEditingController();
  final AddProductsController controller = Get.find<AddProductsController>();
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
    // Initialize text controllers
    _productIdController.text = widget.product.productId ?? '';
    _productCodeController.text = widget.product.productCode ?? '';
    _itemNameController.text = widget.product.itemName ?? '';
    _sellingPriceController.text = widget.product.sellingPrice ?? '';
    _unitsController.text = widget.product.units ?? '';
    _availabilityStatusController.text = widget.product.availabilityStatus ?? '';
    _businessIdController.text = controller.businessId ?? '';

    // Initialize dropdown values and ensure they are valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final categoryNames = controller.categories
            .map((cat) => cat.catName)
            .toSet()
            .toList();
        _selectedCategory = categoryNames.contains(widget.product.productCat)
            ? widget.product.productCat
            : (categoryNames.isNotEmpty ? categoryNames.first : null);

        final cgstValues = controller.taxes
            .where((tax) => tax.taxType.toLowerCase() == 'cgst')
            .map((tax) => tax.taxPercentage)
            .toSet()
            .toList();
        _selectedCgst = cgstValues.contains(widget.product.cgst)
            ? widget.product.cgst
            : (cgstValues.isNotEmpty ? cgstValues.first : null);

        final sgstValues = controller.taxes
            .where((tax) => tax.taxType.toLowerCase() == 'sgst')
            .map((tax) => tax.taxPercentage)
            .toSet()
            .toList();
        _selectedSgst = sgstValues.contains(widget.product.sgst)
            ? widget.product.sgst
            : (sgstValues.isNotEmpty ? sgstValues.first : null);

        final igstValues = controller.taxes
            .where((tax) => tax.taxType.toLowerCase() == 'igst')
            .map((tax) => tax.taxPercentage)
            .toSet()
            .toList();
        _selectedIgst = igstValues.contains(widget.product.igst)
            ? widget.product.igst
            : (igstValues.isNotEmpty ? igstValues.first : null);

        _selectedAvailabilityStatus = widget.product.availabilityStatus == 'Available' || widget.product.availabilityStatus == 'Available'
            ? 'Available'
            : widget.product.availabilityStatus == 'Un-Available' || widget.product.availabilityStatus == 'Un-Available'
            ? 'Un-Available'
            : 'Available';
        _availabilityStatusController.text = _selectedAvailabilityStatus ?? 'Available';
      });
    });
  }

  @override
  void dispose() {
    _productIdController.dispose();
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

  void _updateProduct() {
    if (_formKey.currentState!.validate()) {
      final params = {
        'product_id': _productIdController.text,
        'product_code': _productCodeController.text,
        'product_cat': _selectedCategory ?? '',
        'item_name': _itemNameController.text,
        'selling_price': _sellingPriceController.text,
        'selling_unit': _unitsController.text,
        'cgst': _selectedCgst ?? '',
        'sgst': _selectedSgst ?? '',
        'igst': _selectedIgst ?? '',
        'availability_status': _selectedAvailabilityStatus ?? '',
        'business_id': _businessIdController.text,
      };
      controller.updateProduct(widget.product.productCode, params, _selectedImage);
      Navigator.pop(context);
    }
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
          prefixIcon: const Icon(Icons.account_balance_wallet),
        ),
        value: uniqueTaxPercentages.contains(selectedValue) ? selectedValue : null,
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
        onChanged: (value) {
          onChanged(value);
          setState(() {});
        },
        validator: (value) => value == null ? 'Please select $label' : null,
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
          height: 30,
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.arrow_drop_down),
          iconSize: 24,
        ),
      );
    });
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
                controller: _productIdController,
                label: 'Product ID',
                icon: Icons.abc,
                validator: (value) => value!.isEmpty ? 'Required' : null,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              buildCircularBorderTextField(
                controller: _productCodeController,
                label: 'Product Code',
                icon: Icons.qr_code,
                validator: (value) => value!.isEmpty ? 'Required' : null,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Obx(() {
                final categoryNames = controller.categories
                    .map((cat) => cat.catName)
                    .toSet()
                    .toList();

                return DropdownButtonFormField2<String>(
                  decoration: InputDecoration(
                    labelText: 'Product Category',
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
                    prefixIcon: const Icon(Icons.category),
                  ),
                  value: categoryNames.contains(_selectedCategory) ? _selectedCategory : null,
                  hint: const Text('Select a category'),
                  items: categoryNames.map((catName) {
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
                    height: 30,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                  ),
                );
              }),
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
                keyboardType: TextInputType.text,
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
                          : widget.product.imagePath != null && widget.product.imagePath!.isNotEmpty
                          ? 'Current Image: ${widget.product.imagePath!.split('/').last}'
                          : 'No image selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Replace Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade100,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              widget.product.imagePath != null && widget.product.imagePath!.isNotEmpty && _selectedImage == null
                  ? Image.network(
                widget.product.imagePath!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
              )
                  : _selectedImage != null
                  ? Image.file(
                _selectedImage!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image_not_supported, size: 100),
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
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.check_circle_outline),
                ),
                value: _selectedAvailabilityStatus,
                hint: const Text('Select Availability'),
                items: const [
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
                  height: 30,
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _updateProduct,
                    icon: Icon(Icons.update, color: Colors.blueGrey.shade900),
                    label: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(150, 50),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.cancel, color: Colors.blueGrey.shade900),
                    label: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(150, 50),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildFormFields(),
        ),
      ),
    );
  }
}