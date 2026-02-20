import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_flow/app/core/app_storage_keys.dart';
import 'package:talent_flow/features/projects/model/my_projects_model.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/styles.dart';
import '../../../data/config/di.dart';
import '../../../navigation/routes.dart';
import 'package:easy_localization/easy_localization.dart';


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/features/new_projects/bloc/new_projects_bloc.dart'; // Import your Bloc
import '../../../app/core/app_state.dart'; // Import AppState for BlocListener

class ProjectCard extends StatefulWidget {
  final MyProjectsModel projectsModel;
  const ProjectCard({super.key, required this.projectsModel});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late MyProjectsModel _currentProjectModel;

  @override
  void initState() {
    super.initState();
    _currentProjectModel = widget.projectsModel;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewProjectsBloc, AppState>(
      listener: (context, state) {
        if (state is Done && state.list == null) {
          // Assuming a successful favorite toggle returns a 'Done' state
          // and if 'list' is null, it's not a project list update
          // You might refine this check based on your AppState implementation
          setState(() {
            _currentProjectModel = _currentProjectModel.copyWith(
              isInFavorites: !(_currentProjectModel.isInFavorites ?? false),
            );
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        _currentProjectModel.owner?.image ??
                            "https://via.placeholder.com/150",
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentProjectModel.owner?.name ??
                              "project_card.user_name".tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _currentProjectModel.owner?.jobTitle ??
                              "project_card.user_job".tr(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    (_currentProjectModel.isInFavorites ?? false)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: (_currentProjectModel.isInFavorites ?? false)
                        ? Colors.red
                        : Colors.grey,
                  ),
                  onPressed: () {
                    if (_currentProjectModel.id != null) {
                      // Optimistic update
                      setState(() {
                        _currentProjectModel = _currentProjectModel.copyWith(
                          isInFavorites:
                          !(_currentProjectModel.isInFavorites ?? false),
                        );
                      });
                      context
                          .read<NewProjectsBloc>()
                          .add(Update(arguments: _currentProjectModel.id!));
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Section 2: Metadata (Time, Views, Offers)
            Row(
              children: [
                _buildMetaInfo(
                  icon: Icons.access_time,
                  text:
                  _currentProjectModel.since ?? "project_card.posted_ago".tr(),
                ),
                const SizedBox(width: 16),
                _buildMetaInfo(
                  icon: Icons.visibility_outlined,
                  text: _currentProjectModel.views?.toString() ?? "0",
                ),
                const SizedBox(width: 16),
                _buildMetaInfo(
                  icon: Icons.cases_outlined,
                  text: _currentProjectModel.proposalsCount?.toString() ?? "0",
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Section 3: Project Description
            Text(
              _currentProjectModel.description ?? "",
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF444444),
                height: 1.5,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 16.0),

            Divider(
              height: 1,
              thickness: 2,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 16.0),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final isFreelancer =
                      sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false;

                  if (isFreelancer) {
                    // Freelancer → Add Offer
                    CustomNavigator.push(
                      Routes.addOffer,
                      arguments: {"id": _currentProjectModel.id},
                    );
                  } else {
                    // Not Freelancer → Read Project Data
                    CustomNavigator.push(
                      Routes.addOffer,
                      arguments: {"id": _currentProjectModel.id},
                    );
                  }
                },
                icon: Icon(
                  sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false
                      ? Icons.add
                      : Icons.description,
                  color: Colors.white,
                ),
                label: Text(
                  sl<SharedPreferences>().getBool(AppStorageKey.isFreelancer) ?? false
                      ? "project_card.add_offer".tr()
                      : "project_card.read_project".tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Styles.PRIMARY_COLOR,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 6.0),
        Text(
          text,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}
extension MyProjectsModelExtension on MyProjectsModel {
  MyProjectsModel copyWith({
    int? id,
    Owner? owner,
    String? title,
    String? description,
    int? views,
    String? since,
    int? proposalsCount,
    String? status,
    int? isPaid,
    Specialization? specialization,
    bool? isInFavorites,
  }) {
    return MyProjectsModel(
      id: id ?? this.id,
      owner: owner ?? this.owner,
      title: title ?? this.title,
      description: description ?? this.description,
      views: views ?? this.views,
      since: since ?? this.since,
      proposalsCount: proposalsCount ?? this.proposalsCount,
      status: status ?? this.status,
      isPaid: isPaid ?? this.isPaid,
      specialization: specialization ?? this.specialization,
      isInFavorites: isInFavorites ?? this.isInFavorites,
    );
  }
}

