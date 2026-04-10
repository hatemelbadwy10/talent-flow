import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/features/home/model/partner_model.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class PartnerProfileView extends StatelessWidget {
  const PartnerProfileView({super.key, this.arguments});

  final Map<String, dynamic>? arguments;

  Future<void> _launchPartnerUrl() async {
    final partner =
        PartnerModel.fromJson(arguments ?? const <String, dynamic>{});
    final uri = Uri.tryParse(partner.url);
    if (uri == null) return;
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final partner =
        PartnerModel.fromJson(arguments ?? const <String, dynamic>{});

    if (partner.name.trim().isEmpty) {
      return Scaffold(
        appBar: CustomAppBar(title: 'partner_profile.title'.tr()),
        body: Center(
          child: Text('partner_profile.unavailable'.tr()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: CustomAppBar(
        title: partner.name,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0E8A8F),
                    Color(0xFF0A6E72),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Container(
                    width: 104.w,
                    height: 104.w,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _PartnerImage(image: partner.image),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    partner.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (partner.url.trim().isNotEmpty)
                    Text(
                      partner.url,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _PartnerSectionCard(
              title: 'partner_profile.about'.tr(),
              child: partner.description.trim().isEmpty
                  ? Text(
                      'partner_profile.no_description'.tr(),
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 14,
                      ),
                    )
                  : Html(data: partner.description),
            ),
            if (partner.url.trim().isNotEmpty) ...[
              SizedBox(height: 16.h),
              _PartnerSectionCard(
                title: 'partner_profile.website'.tr(),
                child: InkWell(
                  onTap: _launchPartnerUrl,
                  child: Text(
                    partner.url,
                    style: const TextStyle(
                      color: Styles.PRIMARY_COLOR,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
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

class _PartnerSectionCard extends StatelessWidget {
  const _PartnerSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}
