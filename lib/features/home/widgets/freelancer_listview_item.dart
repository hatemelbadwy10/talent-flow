import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talent_flow/app/core/extensions.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../app/core/styles.dart';
import '../../../navigation/routes.dart';

class FreelancerListItem extends StatelessWidget {
  final String name;
  final double? rating;
  final String? jopTitle;
  final String? imageUrl;
  final int id;
  final double? cardWidth;

  const FreelancerListItem(
      {super.key,
      required this.name,
      required this.id,
      this.rating,
      this.imageUrl,
      this.jopTitle,
      this.cardWidth});

  @override
  Widget build(BuildContext context) {
    const freelancerPlaceholder = 'assets/images/freelancer_place_holder.png';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(8.0)),
          child: imageUrl != null && imageUrl!.trim().isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl!.trim(),
                  height: 100.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Image.asset(
                    freelancerPlaceholder,
                    height: 100.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  freelancerPlaceholder,
                  height: 100.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    constraints:
                        BoxConstraints(maxWidth: 80.w, minWidth: 50.w),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 50.w),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          rating != null
                              ? rating!.toStringAsFixed(1)
                              : 'N/A',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 4.h),
              Visibility(
                visible: jopTitle != null && jopTitle!.isNotEmpty,
                child: Text(
                  jopTitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              CustomButton(
                height: 40,
                width: 140,
                text: "freelancers.contact_me".tr(),
                onTap: () {
                  CustomNavigator.push(
                    Routes.chat,
                    arguments: {"freelancerId": id},
                  );
                },
              )
            ],
          ),
        ),
      ],
    ).onTap((){
       CustomNavigator.push(Routes.freeLancerView,
            arguments: {"freelancerId": id});
      
    },
    borderRadius: BorderRadius.circular(8)
    ).setContainerToView(
      borderColor: Styles.GREY_BORDER,
       width: cardWidth ?? 150.w,
        radius: 8,
      
    );
  }
}

class FreelancerListItemShimmer extends StatelessWidget {
  const FreelancerListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 150.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100.h,
              width: double.infinity,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100.w,
                    height: 14,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 70.w,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
