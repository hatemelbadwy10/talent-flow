import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';

class FreelancerListDetailItem extends StatelessWidget {
  final String name;
  final String title;
  final double rating;
  final String description;
  final String? imageUrl;

  const FreelancerListDetailItem({
    super.key,
    required this.name,
    required this.title,
    required this.rating,
    required this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Styles.PRIMARY_COLOR.withOpacity(0.2),
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                  child: imageUrl == null
                      ? const Icon(Icons.person, size: 30, color: Styles.PRIMARY_COLOR)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4.w),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "(0)", // Placeholder for number of reviews
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // "Contact Me" Button
                SizedBox(
                  height: 35.h,
                  child: ElevatedButton(
                    onPressed: () {
                      print('Contact $name tapped!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.PRIMARY_COLOR,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                    ),
                    child: Text(
                      "freelancers.contact_me".tr(), // "Contact Me"
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}