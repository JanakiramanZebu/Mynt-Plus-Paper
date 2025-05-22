import 'package:flutter/material.dart';
import '../../res/res.dart';

//It serves to display information to the user.

SnackBar error(BuildContext context, String error) => SnackBar(
    content: Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.error_outline, size: 20, color: Colors.red),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            error,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    dismissDirection: DismissDirection.horizontal,
    duration: const Duration(seconds: 4),
    backgroundColor: const Color(0xFF2C2C2E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    elevation: 4);

SnackBar successMessage(BuildContext context, String success) => SnackBar(
    content: Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.check_circle_outline, size: 20, color: Color(0xFF4CAF50)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            success,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    dismissDirection: DismissDirection.horizontal,
    duration: const Duration(seconds: 4),
    backgroundColor: const Color(0xFF2C2C2E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    elevation: 4);

SnackBar warningMessage(BuildContext context, String warning) => SnackBar(
    content: Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC107),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.warning_amber_outlined, size: 20, color: Color(0xFFFFC107)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            warning,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    dismissDirection: DismissDirection.horizontal,
    duration: const Duration(seconds: 4),
    backgroundColor: const Color(0xFF2C2C2E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    elevation: 4);

void warningToaster(BuildContext context, String warningtoaster) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC107),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.warning_amber_outlined, size: 20, color: Color(0xFFFFC107)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            warningtoaster,
            style: const TextStyle(
              fontSize: 14, 
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
    dismissDirection: DismissDirection.horizontal,
    duration: const Duration(seconds: 4),
    backgroundColor: const Color(0xFF2C2C2E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    margin: const EdgeInsets.all(12),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    elevation: 4);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
