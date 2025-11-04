import 'package:flutter/material.dart';

class NoDataFOund extends StatelessWidget {
  final void Function()? onRefresh;
  final String? text;
  const NoDataFOund({super.key, this.onRefresh, this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // const Image.Asset(
          //   imageName: "assets/images/no_data.png",
          //   height: 60,
          //   width: 60,
          // ),
          const SizedBox(height: 20),
          Text(
            text ?? "No Data Found",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.black),
          ),
          if (onRefresh != null)
            IconButton(
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 30,
                ))
        ],
      ),
    );
  }
}
