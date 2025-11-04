import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class UtilFunctions {
  static String formatDateTimeString(String dateString) {
    if (dateString.isNotEmpty) {
      DateTime dateTime = DateTime.parse(dateString);
      // Example format: 11 Sep 2025, 03:30 PM
      final DateFormat formatter = DateFormat('d MMM yyyy, hh:mm a');
      return formatter.format(dateTime);
    } else {
      return "";
    }
  }

  static loaderPopup(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      useSafeArea: false,
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Center(
            child: Card(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            child: CupertinoActivityIndicator(
                animating: true, radius: 15, color: Colors.deepPurple),
          ),
        ));
      },
    );
  }
}

void toast(msg, BuildContext? context, {bool? isError = false}) {
  Fluttertoast.showToast(
      timeInSecForIosWeb: 3,
      gravity: ToastGravity.CENTER_RIGHT,
      backgroundColor: isError! ? Colors.red : Colors.green,
      textColor: Colors.white,
      msg: msg ?? "Something went wrong",
      toastLength: Toast.LENGTH_LONG);
}
