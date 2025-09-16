import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoints {
  static const bool isProductionEnv = false;
  static String domain ="";
  static String baseUrl =  "https://talentflowa.com/";
  static String apiKey ="";
  static String googleMapsBaseUrl =  "";
  static const String generalTopic = isProductionEnv ? 'talent_flow' : 't_talent_flow';
  static specificTopic(id) => isProductionEnv ? '$id' : 't_$id';

  ///Auth
  static const String socialMediaAuth = 'api/auth/social/login';
  static const String forgetPassword = 'api/auth/forgot-password';
  static const String resetPassword = 'reset-password';
  static const String changePassword = 'api/auth/reset-password';
  static const String register = 'api/auth/register';
  static const String logIn = 'api/auth/login';
  static const String resend = 'resend-code';
  static const String verifyRegister = "api/auth/verify-otp?register";
  static const String verifyOtp = 'api/auth/verify-otp';
  static const String deleteAccount = 'delete-account';
  static const String reactivateAccount = 'reactivate-account';
  static const String setLang = 'set-lang';

  ///User Profile
  static const String editProfile = 'update-profile';
  static const String profile = 'profile';

  ///Home
  static const String home = 'api/pages/home?top_limit=5&cat_limit=8';
  static const String categories = 'api/categories';
  static const String subCategories = 'api/categories/';
  static const String freelancers = 'api/freelancers';
  static const String freelancerDetails = 'api/freelancers/';

  ///Offers
  static const String offers = 'offers';
  static offerDetails(id) => 'offers/$id';

  ///News
  static const String news = 'our-news';
  static newsDetails(id) => 'our-news/$id';

  ///Courses
  static const String courses = 'courses';
  static const String myCourses = 'my-courses';
  static courseDetails(id) => 'courses/$id';

  ///Associations
  static const String associations = 'associations';
  static const String myAssociations = 'association-members';
  static joinAssociation(id) => 'association-members/$id';
  static associationDetails(id) => 'associations/$id';

  ///Conferences
  static const String conferences = 'conferences';
  static conferenceDetails(id) => 'conferences/$id';
  static joinConference(int id) => 'conference-members/$id';
  static const String myConferencesRequests = 'conference-members';

  ///Check-out

  static const String checkOut = 'check-out';

  ///Board Members
  static const String boardMembers = 'directors';

  ///Student Membership
  static getStudentMembership(id) => 'student-membership/$id';
  static const String studentMembership = 'student-membership';
  static updateStudentMembership(id) => 'student-membership/$id';

  ///Membership
  static const String membershipsInstructions = 'membership-data';
  static getMembership(id) => 'memberships/$id';
  static const String memberships = 'memberships';
  static updateMemberships(id) => 'memberships/$id';

  static addExtraMembershipData(id) => 'memberships/$id/extra-data';
  static completeMembership(id) => 'memberships/$id/upload-license';
  static deleteAddress(id) => 'delete-address/$id';

  ///Subscriptions
  static const String subscriptions = 'get-subscriptions';
  static const String subscribe = 'subscribe';

  ///Follow-up Membership
  static String experienceData = 'experience-details';
  static updateExperienceData(id) => 'experience-details${id != null ? "/$id" : ""}';

  static String educationalData = 'educational-details';
  static updateEducationalData(id) => 'educational-details${id != null ? "/$id" : ""}';

  ///Services && Partners
  static const String partners = 'partners';
  static const String services = 'services';
  static const String uploadFile = 'upload-file';

  ///Notification
  static const String notifications = 'notifications';
  static const String markAsRead = 'mark-as-read';
  static readNotification(id) => 'notifications/$id';
  static deleteNotification(id) => 'notifications/$id';

  ///Check Out
  static checkOutOrder(id) => 'check-out/$id';

  ///Setting
  static const String associationStatistics = 'important-numbers';
  static const String faqs = 'faqs';
  static const String privacyPolicy = 'privacy-policy';
  static const String termsConditions = 'api/pages/terms';
  static const String aboutUs = 'api/pages/about';
  static const String associationObjectives = 'goals';
  static const String whoUs = 'who-us';
  static const String contactUs = 'contact-us';

  ///Selectors
  static const String countries = 'countries';
  static const String birthPlaces = 'countries';
  static const String jobSectors = 'job-sectors';
  static const String pharmacy = 'pharmacy-masters';
  static const String department = 'departments';
  static const String jobGrade = 'job-grades';

  static const String governorates = 'governorates';
  static const String bloodTypes = 'blood-types';
  static const String qualificationTypes = 'qualification-types';

  ///Projects
static const String projects = 'api/projects';
static const String addProject ='api/projects';
static const String singleProject = '/api/projects/';
static const String addOffer ="api/projects/proposals";
static const String selectionOption ="api/select-options";
  ///Upload File Service
  static const String uploadFileService = 'store_attachment';
  static deleteFile(id) => 'delete-file/$id';

  /// maps
  static const String geoCodeUrl = '/maps/api/geocode/';
  static const String autoComplete = '/maps/api/place/autocomplete/';
//https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=AIzaSyB_l2x6zgnLTF4MKxX3S4Df9urLN6vLNP0
//'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=n,&key=AIzaSyB_l2x6zgnLTF4MKxX3S4Df9urLN6vLNP0
}
