import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';

class NewListItem extends StatelessWidget {
  const NewListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 171.h,
      width: 300.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        image: const DecorationImage(
          image: AssetImage("assets/images/new_item.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,

            colors: [
              const Color(0xFF0C7D81).withOpacity(0.8), // #0C7D81
              const Color(0xFF063E40).withOpacity(0.7), // #063E40
            ],
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                'مكان واحد يضم الفريلانسر والباحثين عن تنفيذ خدماتهم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}