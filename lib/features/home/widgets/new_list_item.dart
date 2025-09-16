import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:cached_network_image/cached_network_image.dart'; // For network images
import 'package:shimmer/shimmer.dart'; // Import shimmer

class NewListItem extends StatelessWidget {
  final String? title;
  final String? imageUrl;
  const NewListItem({super.key, this.title, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 171.h,
      width: 300.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        // Use CachedNetworkImage for network images
        image: imageUrl != null && Uri.parse(imageUrl!).isAbsolute
            ? DecorationImage(
          image: CachedNetworkImageProvider(imageUrl!),
          fit: BoxFit.cover,
        )
            : const DecorationImage(
          image: AssetImage("assets/images/new_item.jpg"), // Fallback
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              title?.tr() ?? "talent_flow_core".tr(), // Use actual title
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// Shimmer version for NewListItem
class NewListItemShimmer extends StatelessWidget {
  const NewListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 171.h,
        width: 300.w,
        decoration: BoxDecoration(
          color: Colors.white, // Shimmer effect on a white background
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 150.w, // Placeholder for text
              height: 20.h,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}