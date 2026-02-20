import 'package:flutter/material.dart';
import 'package:zylix/main.dart';
import 'package:zylix/presentation/shared/color.dart';

void showGlobalSnackBar(String msg, {bool isError = false}) {
  messageKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(
        msg,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: isError ? Colors.red : AppColor.primaryColor,
    ),
  );
}
