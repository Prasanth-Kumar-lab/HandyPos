import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      color: Colors.white,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey.shade700,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          indicator: BoxDecoration(
            color: Colors.blueAccent.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              icon: Icon(Icons.add_circle_outline, size: 20),
              text: 'Add Product',
              iconMargin: EdgeInsets.only(bottom: 2),
            ),
            Tab(
              icon: Icon(Icons.list_alt_outlined, size: 20),
              text: 'Product List',
              iconMargin: EdgeInsets.only(bottom: 2),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
