import 'package:flutter/material.dart';
import 'package:fuse/utils/constains.dart';

class AddLabel extends StatelessWidget {
  final String label;

  const AddLabel({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(color: hint_color),
    );
  }
}