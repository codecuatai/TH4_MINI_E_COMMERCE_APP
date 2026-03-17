import 'package:flutter/material.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.grey[200],
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.grey[200],
          ),
        ],
      ),
    );
  }
}
