import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/app/core/styles.dart';
import 'package:talent_flow/data/config/di.dart';
import 'package:talent_flow/features/setting/widgets/setting_app_bar.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import 'package:talent_flow/navigation/routes.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: CustomAppBar(
        title: 'settings_screen.dashboard'.tr(),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: TextButton.icon(
              onPressed: () {
                final isFreelancer =
                    sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ??
                        true;
                CustomNavigator.push(
                  isFreelancer ? Routes.addYourProject : Routes.addProject,
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة مشروع'),
              style: TextButton.styleFrom(
                foregroundColor: Styles.PRIMARY_COLOR,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceCell(
                          title: 'الرصيد الكلي',
                          value: '00.00',
                          subValue: '00.00 ريال',
                          titleColor: Styles.PRIMARY_COLOR,
                        ),
                      ),
                      _verticalDivider(),
                      Expanded(
                        child: _buildBalanceCell(
                          title: 'الرصيد القابل للسحب',
                          value: '00.00',
                          subValue: '00.00 ريال',
                          titleColor: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: Color(0xFFE8E8E8)),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSimpleBalance(
                          title: 'الرصيد المعلق',
                          value: '00.00',
                        ),
                      ),
                      _verticalDivider(),
                      Expanded(
                        child: _buildSimpleBalance(
                          title: 'الرصيد الناتج',
                          value: '00.00',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildCard(
              child: const Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _HeadText('مشاريعي')),
                      Expanded(child: _HeadText('الرسائل الجديدة')),
                      Expanded(child: _HeadText('الرسائل الواردة')),
                      Expanded(child: _HeadText('العقود')),
                    ],
                  ),
                  Divider(height: 20, color: Color(0xFFE8E8E8)),
                  Row(
                    children: [
                      Expanded(child: _CountText('0')),
                      Expanded(child: _CountText('0')),
                      Expanded(child: _CountText('0')),
                      Expanded(child: _CountText('0')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildCard(
              child: const Column(
                children: [
                  _StatusBarItem(title: 'مسودة', count: 0),
                  _StatusBarItem(title: 'مفتوحة', count: 0),
                  _StatusBarItem(title: 'مكتملة', count: 0),
                  _StatusBarItem(title: 'ملغاة', count: 0),
                  _StatusBarItem(title: 'قيد المراجعة', count: 0),
                  _StatusBarItem(title: 'قيد التنفيذ', count: 0),
                  _StatusBarItem(title: 'مغلقة', count: 0),
                  _StatusBarItem(title: 'مرفوضة', count: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFE8E8E8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildBalanceCell({
    required String title,
    required String value,
    required String subValue,
    required Color titleColor,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          subValue,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSimpleBalance({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ],
    );
  }
}

class _HeadText extends StatelessWidget {
  const _HeadText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }
}

class _CountText extends StatelessWidget {
  const _CountText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    );
  }
}

class _StatusBarItem extends StatelessWidget {
  const _StatusBarItem({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '0%',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0,
                    minHeight: 6,
                    color: Styles.PRIMARY_COLOR,
                    backgroundColor: Color(0xFFE5E5E5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$title $count',
                style: const TextStyle(
                  color: Color(0xFF5B5B5B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
