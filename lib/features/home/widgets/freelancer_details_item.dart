import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';

class FreelancerListDetailItem extends StatelessWidget {
  final String name;
  final String title;
  final double rating;
  final String description;
  final String? imageUrl;
  final String? phoneNumber;

  const FreelancerListDetailItem({
    super.key,
    required this.name,
    required this.title,
    required this.rating,
    required this.description,
    this.imageUrl,
    this.phoneNumber,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically in the middle
            children: [
              // Profile image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Styles.PRIMARY_COLOR, width: 2), // Example border color
                ),
                child: CircleAvatar(
                  radius: 30, // Adjusted radius for a slightly smaller look
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: imageUrl != null && Uri.parse(imageUrl!).isAbsolute
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: imageUrl == null || !Uri.parse(imageUrl!).isAbsolute
                      ? const Icon(Icons.person, size: 30, color: Styles.PRIMARY_COLOR)
                      : null,
                ),
              ),
              SizedBox(width: 12.w),
              // Name, Title, and Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17, // Slightly smaller font
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13, // Slightly smaller font
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        SizedBox(width: 4.w),
                        Text(
                          rating.toStringAsFixed(1), // Display rating with one decimal
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Description
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}