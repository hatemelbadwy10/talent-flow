import 'package:equatable/equatable.dart';

import '../model/entrepreneur_profile_model.dart';
import '../model/freelancer_profile_model.dart';
import '../model/freelancers_model.dart';
import '../model/home_model.dart';
import '../model/work_details_model.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeFailure extends HomeState {
  const HomeFailure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class HomeFeedLoaded extends HomeState {
  const HomeFeedLoaded(this.home);

  final HomeModel home;

  @override
  List<Object?> get props => [home];
}

class HomeCategoriesLoaded extends HomeState {
  const HomeCategoriesLoaded(this.categories);

  final List<Category> categories;

  @override
  List<Object?> get props => [categories];
}

class HomeFreelancersLoaded extends HomeState {
  const HomeFreelancersLoaded(this.freelancers);

  final List<FreelancersModel> freelancers;

  @override
  List<Object?> get props => [freelancers];
}

class FreelancerProfileLoaded extends HomeState {
  const FreelancerProfileLoaded(this.profile);

  final FreelancerProfileModel profile;

  @override
  List<Object?> get props => [profile];
}

class EntrepreneurProfileLoaded extends HomeState {
  const EntrepreneurProfileLoaded(this.profile);

  final EntrepreneurProfileModel profile;

  @override
  List<Object?> get props => [profile];
}

class WorkDetailsLoaded extends HomeState {
  const WorkDetailsLoaded(this.work);

  final WorkDetailsModel work;

  @override
  List<Object?> get props => [work];
}
