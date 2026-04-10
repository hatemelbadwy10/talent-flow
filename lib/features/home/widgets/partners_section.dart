import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/home/model/partner_model.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class PartnersSection extends StatelessWidget {
  const PartnersSection({
    super.key,
    this.partners = const <PartnerModel>[],
  });

  final List<PartnerModel> partners;

  @override
  Widget build(BuildContext context) {
    if (partners.isEmpty) {
      return const SizedBox.shrink();
    }

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
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    CustomNavigator.push(
                      Routes.brands,
                      arguments: partner.toJson(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 60.h,
                          width: 80.w,
                          child: _PartnerImage(image: partner.image),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            partner.name,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
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

class _PartnerImage extends StatelessWidget {
  const _PartnerImage({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(image);
    final isNetworkImage = uri?.isAbsolute ?? false;

    if (isNetworkImage) {
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 36),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 36),
    );
  }
}
