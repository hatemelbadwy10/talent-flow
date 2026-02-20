import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';

class PartnersSection extends StatelessWidget {
  const PartnersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final partners = [
      {
        "image": "assets/images/Talent Flow logo 1 1.png",
        "title": "Talent Flow"
      },
      {
        "image": "assets/images/Talent Flow logo 1 1.png",
        "title": "Partner 2"
      },
      {
        "image": "assets/images/Talent Flow logo 1 1.png",
        "title": "Partner 3"
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "home.partners".tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 120.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: partners.length,
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                final partner = partners[index];
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        partner["image"]!,
                        height: 80.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        partner["title"]!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
