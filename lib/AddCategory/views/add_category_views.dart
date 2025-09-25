import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../controller/add_category_controller.dart';
import '../model/add_category_model.dart';
class AddCategoryView extends StatefulWidget {
  const AddCategoryView({Key? key, required this.businessId}) : super(key: key);
  final String businessId;

  @override
  _AddCategoryViewState createState() => _AddCategoryViewState();
}

class _AddCategoryViewState extends State<AddCategoryView> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _businessIdController = TextEditingController();
  final AddCategoryController _controller = AddCategoryController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _businessIdController.text = widget.businessId; // Set initial businessId
  }
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final category = CategoryModel(
        categoryName: _categoryNameController.text,
        businessId: _businessIdController.text,
      );

      var response = await _controller.addCategory(category);

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'Success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        _categoryNameController.clear();
        _businessIdController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to add category')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _categoryNameController,
                  decoration: InputDecoration(
                    labelText: 'Category name',
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
                    prefixIcon: Icon(CupertinoIcons.rectangle_grid_1x2),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _businessIdController,
                  decoration: InputDecoration(
                    labelText: 'Business ID',
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
                    prefixIcon: Icon(Icons.business_center_outlined),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a business ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.black
                  ),
                  child: Text('Add Category'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _businessIdController.dispose();
    super.dispose();
  }
}