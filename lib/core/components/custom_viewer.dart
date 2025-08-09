import 'package:flutter/material.dart';

class CustomInteractiveViewer extends StatelessWidget {
  const CustomInteractiveViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 400,
        width: double.infinity,
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(42),
          panEnabled: true,
          scaleEnabled: true,
          constrained: false,
          minScale: 0.3,
          maxScale: 4,
          child: Image.asset('images/q4.jpg', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
