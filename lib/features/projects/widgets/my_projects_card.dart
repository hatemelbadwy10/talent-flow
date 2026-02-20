import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:talent_flow/features/projects/model/my_projects_model.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';

import '../../../components/status_chip.dart';
import '../../../navigation/routes.dart';

class ProjectPortfolioCard extends StatelessWidget {
  final MyProjectsModel projectsModel;

  const ProjectPortfolioCard({
    super.key,
    required this.projectsModel,
  });

  @override
  Widget build(BuildContext context) {
    log("projectsModel.status ${projectsModel.status}");
    // 🔹 Convert string status from model to enum
    final ProjectStatus status = ProjectStatusHelper.fromString(projectsModel.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
              CustomNavigator.push(
                  Routes.singleProjectDetails, arguments: {"id": projectsModel.id});
            },
        child: Ink(
          
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  height: 120, // Added fixed height for consistency
                  child: Image.network(
                    projectsModel.specialization?.image ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF7DD3FC),
                              Color(0xFF0EA5E9),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.white, size: 40),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectsModel.title ?? "project_portfolio.default_title".tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff666568),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      projectsModel.specialization?.name ?? "project_portfolio.default_specialization".tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff666568),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatItem(Icons.thumb_up_alt_outlined, (projectsModel.proposalsCount ?? 0).toString()),
                        const SizedBox(width: 8),
                        _buildStatItem(Icons.visibility_outlined, (projectsModel.views ?? 0).toString()),
                        const Spacer(), // Push status chip to the right
                        StatusChip(status: status), // 🔹 Use converted status
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF9CA3AF), size: 10),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w200,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}