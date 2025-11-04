import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? isReload;
  // final String title;
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? bgcolor;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.leading,
      this.actions,
      this.bgcolor,
      this.isReload = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0.5,
      // title: title,
      centerTitle: true,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      backgroundColor: bgcolor ?? Colors.white,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const SizedBox(
          child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
