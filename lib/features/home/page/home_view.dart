import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/features/home/widgets/new_list_item.dart';
import 'package:talent_flow/features/home/widgets/service_widget.dart';
import 'package:talent_flow/navigation/custom_navigation.dart';
import '../../../app/core/styles.dart';
import '../../../components/custom_text_form_field.dart';
import '../../../navigation/routes.dart';
import '../widgets/service_category_grid.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const CustomTextField(
                  hint: "ابحث عن خدمة",
                  sufSvgIcon: "assets/svgs/search.svg",
                  sIconColor: Colors.grey,
                ),
                SizedBox(height: 24.h),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   GestureDetector (
                     onTap: (){
  CustomNavigator.push(Routes.allCategories);
                     },
                      child: const Text(
                        "مشاهدة الكل",
                        style:
                            TextStyle(color: Styles.PRIMARY_COLOR, fontSize: 14),
                      ),
                    ),
                    const Text(
                      "فئة الخدمة",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                const ServiceCategoriesGrid(),
                SizedBox(height: 24.h),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "ما الجديد على تلنت فلو؟",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 200.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 12.w),
                        child: const NewListItem(),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 70.h,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const HomeHeader({super.key, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  "assets/images/Talent Flow logo 1 1.png",
                  height: 30,
                ),
                SizedBox(width: 8.w),
                const Text(
                  "مرحبا بك",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.black54,
                size: 28,
              ),
              onPressed: onNotificationTap,
            ),
          ],
        ),
      ),
    );
  }
}
