import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Reports/model/reports_model.dart';

class BillerList extends StatefulWidget {
  final String businessId;

  const BillerList({Key? key, required this.businessId}) : super(key: key);

  @override
  _BillerListState createState() => _BillerListState();
}

class _BillerListState extends State<BillerList> {
  final ReportModel _reportModel = ReportModel();
  late Future<List<String>> _billerFuture;

  @override
  void initState() {
    super.initState();
    _billerFuture = _reportModel.fetchBillerIds(widget.businessId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billers List', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green.shade300,
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: _billerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Failed to load billers.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No billers found.'));
          } else {
            final billers = snapshot.data!;
            return ListView.separated(
              itemCount: billers.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text('${billers[index]}', style: TextStyle(fontWeight: FontWeight.bold),),
                  onTap: () {
                    // You can handle tap event here
                    Get.snackbar(
                      'Biller Selected',
                      billers[index],
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
