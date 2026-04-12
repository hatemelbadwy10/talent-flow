import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/components/status_chip.dart';
import 'package:talent_flow/features/new_projects/widgets/skills_section.dart';
import 'package:talent_flow/features/projects/model/single_project_model.dart';

class ProjectDetailsCard extends StatelessWidget {
  const ProjectDetailsCard({super.key, this.singleProjectModel});
  final SingleProjectModel? singleProjectModel;

  @override
  Widget build(BuildContext context) {
    if (singleProjectModel == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(singleProjectModel!),
          const SizedBox(height: 16.0),
          if (singleProjectModel!.status != null ||
              singleProjectModel!.budget != null ||
              singleProjectModel!.duration != null)
            _buildProjectInfo(singleProjectModel!),
          if (singleProjectModel!.skills.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            SkillsSection(skills: singleProjectModel!.skills),
          ],
          if (singleProjectModel!.owner != null) ...[
            const Divider(height: 32.0),
            _buildUserInfo(singleProjectModel!.owner!),
          ],
          const Divider(height: 32.0),
          _buildStats(singleProjectModel!),
        ],
      ),
    );
  }

  /// Header
  Widget _buildHeader(SingleProjectModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (model.title ?? '').trim().isEmpty
              ? 'untitled_project'.tr()
              : model.title!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildHeaderMetaItem(
              icon: Icons.access_time,
              value: model.since ?? '',
            ),
            _buildHeaderMetaItem(
              icon: Icons.visibility_outlined,
              value: '${model.views ?? 0}',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderMetaItem({
    required IconData icon,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// Project info
  Widget _buildProjectInfo(SingleProjectModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (model.status != null)
          Row(
            children: [
              Text('project_card_offer.status'.tr(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black)),
              const SizedBox(width: 46),
              _projectStatus(_localizedStatusText(model.status))
            ],
          ),
        if (model.budget != null) ...[
          const SizedBox(height: 8),
          _buildKeyValueRow(
              'project_card_offer.budget'.tr(), Text(model.budget!)),
        ],
        if (model.duration != null) ...[
          const SizedBox(height: 8),
          _buildKeyValueRow(
            'project_card_offer.duration'.tr(),
            Text(
              'project_card_offer.duration_value'.tr(
                namedArgs: {'count': '${model.duration}'},
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Owner info
  Widget _buildUserInfo(Owner owner) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: owner.image != null
                  ? NetworkImage(owner.image!)
                  : const AssetImage('assets/images/profile.jpg')
                      as ImageProvider,
            ),
            const SizedBox(width: 12.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    (owner.name ?? '').trim().isEmpty
                        ? 'no_name'.tr()
                        : owner.name!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                    (owner.jobTitle ?? '').trim().isEmpty
                        ? 'no_job_title'.tr()
                        : owner.jobTitle!,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (owner.signupDate != null)
          _buildKeyValueRow('project_card_offer.registration_date'.tr(),
              Text(owner.signupDate!)),
      ],
    );
  }

  /// Stats
  Widget _buildStats(SingleProjectModel model) {
    final owner = model.owner;
    if (owner == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (owner.employmentRate != null)
          _buildKeyValueRow(
            'project_card_offer.hiring_rate'.tr(),
            _projectStatus(_formatEmploymentRate(owner.employmentRate)),
          ),
        if (owner.openProjectsCount != null) ...[
          const SizedBox(height: 12),
          _buildKeyValueRow(
              'project_card_offer.open_projects'.tr(),
              Text("${owner.openProjectsCount}",
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
        if (owner.underImplementationCount != null) ...[
          const SizedBox(height: 12),
          _buildKeyValueRow(
              'project_card_offer.projects_in_progress'.tr(),
              Text("${owner.underImplementationCount}",
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
        if (owner.ongoingCommunications != null) ...[
          const SizedBox(height: 12),
          _buildKeyValueRow(
              'project_card_offer.ongoing_communications'.tr(),
              Text("${owner.ongoingCommunications}",
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ],
    );
  }

  /// key-value row
  Widget _buildKeyValueRow(String key, Widget valueWidget) {
    return Row(
      children: [
        Text(key, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        const SizedBox(width: 46),
        valueWidget,
      ],
    );
  }

  Widget _projectStatus(String status) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xff00AC25),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
          child: Text(
        status,
        style: const TextStyle(color: Colors.white),
      )),
    );
  }

  String _localizedStatusText(String? status) {
    final normalizedStatus = (status ?? '').trim();
    if (normalizedStatus.isEmpty) {
      return '';
    }

    final statusKey =
        switch (ProjectStatusHelper.fromString(normalizedStatus)) {
      ProjectStatus.completed => 'project_status.completed',
      ProjectStatus.draft => 'project_status.draft',
      ProjectStatus.rejected => 'project_status.rejected',
      ProjectStatus.canceled => 'project_status.canceled',
      ProjectStatus.open => 'project_status.open',
      ProjectStatus.inProgress => 'project_status.in_progress',
      ProjectStatus.underReview => 'project_status.under_review',
      ProjectStatus.closed => 'project_status.closed',
    };

    final translated = statusKey.tr();
    return translated == statusKey ? normalizedStatus : translated;
  }
  String _formatEmploymentRate(String? value) {
    final numericValue = double.tryParse((value ?? '').trim());
    if (numericValue == null) {
      return value ?? '';
    }

    return numericValue.toStringAsFixed(1);
  }
}
