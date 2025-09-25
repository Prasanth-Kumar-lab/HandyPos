import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task/Add_Tax/controller/add_tax_controller.dart';
import 'package:task/Add_Tax/model/add_tax_model.dart';

class AddTaxView extends StatefulWidget {
  const AddTaxView({Key? key, required this.businessId}) : super(key: key);
  final String businessId;

  @override
  _AddtaxViewState createState() => _AddtaxViewState();
}

class _AddtaxViewState extends State<AddTaxView> {
  final _formKey = GlobalKey<FormState>();
  final _taxPercentageController = TextEditingController();
  final _taxTypeController = TextEditingController();
  final _businessIdController = TextEditingController();
  final AddTaxController _controller = AddTaxController();
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

      final addTax = AddTaxModel(
        taxType: _taxTypeController.text,
        taxPercentage: _taxPercentageController.text,
        businessId: _businessIdController.text,
      );

      var response = await _controller.addTaxMethod(addTax);

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == 'Success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        _taxPercentageController.clear();
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
        title: const Text('Add Tax'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _taxTypeController,
              decoration: InputDecoration(
                labelText: 'Tax type',
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
                prefixIcon: Icon(CupertinoIcons.money_pound_circle),
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
                controller: _taxPercentageController,
                decoration: InputDecoration(
                  labelText: 'Tax percentage',
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
                  prefixIcon: Icon(Icons.percent),
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
                  foregroundColor: Colors.black,
                ),
                child: Text('Add Tax'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _taxTypeController.dispose();
    _taxPercentageController.dispose();
    _businessIdController.dispose();
    super.dispose();
  }
}