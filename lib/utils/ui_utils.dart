import 'package:flutter/material.dart';

Widget addHorizontalSpace(width) {
  return SizedBox(
    width: width,
  );
}

Widget addVerticalSpace(height) {
  return SizedBox(
    height: height,
  );
}

double baseHeight = 640;

screenAwareSize(size, context) {
  return size * MediaQuery.of(context).size.height / baseHeight;
}