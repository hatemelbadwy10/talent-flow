import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/app/core/svg_images.dart';
import 'package:talent_flow/components/custom_button.dart';
import 'package:talent_flow/features/setting/model/contract_model.dart';
import 'package:talent_flow/features/setting/model/contract_status.dart';

final BoxDecoration contractDetailsCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
);

class ContractDetailsSummaryCard extends StatelessWidget {
  const ContractDetailsSummaryCard({
    super.key,
    required this.contract,
    required this.statusLabel,
    required this.statusStyle,
  });

  final ContractModel contract;
  final String statusLabel;
  final ContractDetailsStatusStyle statusStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: contractDetailsCardDecoration,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Styles.PRIMARY_COLOR.withValues(alpha: 0.1),
            ),
            child: Center(
              child: SvgPicture.asset(
                SvgImages.contract,
                width: 26,
                height: 26,
                colorFilter: const ColorFilter.mode(
                  Styles.PRIMARY_COLOR,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.title ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF171717),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID #${contract.id ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF88878B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusStyle.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusStyle.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContractDetailsActionButton extends StatelessWidget {
  const ContractDetailsActionButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onTap,
    this.backgroundColor = Styles.PRIMARY_COLOR,
    this.textColor = Colors.white,
    this.borderColor,
    this.withBorder = false,
  });

  final String text;
  final bool isLoading;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final bool withBorder;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      height: 52,
      radius: 14,
      isLoading: isLoading,
      onTap: onTap,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
      withBorderColor: withBorder,
    );
  }
}

class ContractDetailsInfoCard extends StatelessWidget {
  const ContractDetailsInfoCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: contractDetailsCardDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class ContractDetailsInfoRow extends StatelessWidget {
  const ContractDetailsInfoRow({
    super.key,
    required this.title,
    this.value,
  });

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E7683),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value?.trim().isNotEmpty == true ? value! : '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222222),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ContractDetailsTextCard extends StatelessWidget {
  const ContractDetailsTextCard({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: contractDetailsCardDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.trim().isNotEmpty ? value : '-',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF222222),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ContractDetailsMessageCard extends StatelessWidget {
  const ContractDetailsMessageCard({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9CCFF)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF7347D6),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3E2A7A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContractDetailsHtmlCard extends StatelessWidget {
  const ContractDetailsHtmlCard({
    super.key,
    required this.title,
    this.htmlContent,
  });

  final String title;
  final String? htmlContent;

  @override
  Widget build(BuildContext context) {
    final hasData = htmlContent?.trim().isNotEmpty == true;

    return Container(
      decoration: contractDetailsCardDecoration,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF171717),
            ),
          ),
          const SizedBox(height: 8),
          if (!hasData)
            const Text(
              '-',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF222222),
              ),
            )
          else
            Html(
              data: htmlContent,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: const Color(0xFF222222),
                  fontSize: FontSize(14),
                  lineHeight: const LineHeight(1.5),
                ),
                'p': Style(margin: Margins.zero),
              },
            ),
        ],
      ),
    );
  }
}

class ContractDetailsStatusStyle {
  const ContractDetailsStatusStyle({
    required this.textColor,
    required this.backgroundColor,
  });

  final Color textColor;
  final Color backgroundColor;
}

ContractDetailsStatusStyle contractDetailsStatusStyle(ContractStatus status) {
  switch (status) {
    case ContractStatus.accepted:
    case ContractStatus.closed:
      return const ContractDetailsStatusStyle(
        textColor: Color(0xFF209370),
        backgroundColor: Color(0xFFEAF8F1),
      );
    case ContractStatus.pending:
    case ContractStatus.waitToPayFreelancer:
    case ContractStatus.hasNotes:
      return const ContractDetailsStatusStyle(
        textColor: Color(0xFFB56700),
        backgroundColor: Color(0xFFFFF4E4),
      );
    case ContractStatus.inProgress:
    case ContractStatus.workUnderReview:
      return const ContractDetailsStatusStyle(
        textColor: Color(0xFF2859C5),
        backgroundColor: Color(0xFFEAF0FF),
      );
    case ContractStatus.disagreement:
      return const ContractDetailsStatusStyle(
        textColor: Color(0xFF7347D6),
        backgroundColor: Color(0xFFF3F0FF),
      );
    case ContractStatus.rejected:
      return const ContractDetailsStatusStyle(
        textColor: Color(0xFFDB5353),
        backgroundColor: Color(0xFFFFECEC),
      );
  }
}
