import 'package:flutter/material.dart';
import 'package:my_location_traker_app/view/common/custom_image.dart';
import 'package:my_location_traker_app/view_model/common_data_viewmodel.dart';
import 'package:provider/provider.dart';

class IconCard extends StatelessWidget {
  final Color? color;
  final Widget? child;

  const IconCard({super.key, this.color, this.child});

  @override
  Widget build(BuildContext context) {
    final size = context.watch<CommonDataViewmodel>().size;
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: size,
        width: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        padding: EdgeInsets.all(20),
        child: child);
  }
}
