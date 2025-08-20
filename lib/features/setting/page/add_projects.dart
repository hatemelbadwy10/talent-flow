import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talent_flow/app/core/dimensions.dart';

import '../bloc/portofilo_form_bloc.dart';
import '../widgets/protofilo_form.dart';

class AddYourProjects extends StatelessWidget {
  const AddYourProjects({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Image.asset(
          "assets/images/Talent Flow logo 1 1.png",
          height: 35,
        ),

        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'الاشعارات',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        // If you need a back button, Flutter automatically adds one.
        // To customize it, you can use the 'leading' property.
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),

      body: SafeArea(
        child: Padding(
          padding:
          EdgeInsetsGeometry.symmetric(horizontal: 20.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const PortfolioInfoCard(),
                BlocProvider(
                  create: (context) => PortfolioFormBloc(),
                  child: const PortfolioUploadForm(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PortfolioInfoCard extends StatelessWidget {
  const PortfolioInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        decoration: BoxDecoration(
          color: Color(0xFFFAFAFA),
          // The rounded corners.
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            const Text(
              'أضف معرض أعمالك',
              style: TextStyle(
                fontWeight: FontWeight.w500, // Using bold for emphasis
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8.0),
            const Divider(
              color: Color(0xFFEEEEEE),
              thickness: 1.0,
            ),
            const SizedBox(height: 8.0), // Spacing above the paragraph.

            const Text(
              "أضف أفضل 3 أعمال حديثة تظهر بها خبرتك في مجال عملك سيراجع الفريق تلنت فلو الاعمال قبل القبول طلب الانضمام",
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8.0),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListItem(
                    "أضف أعمال نفذتها بنفسك وليست منقوله أو منسوخة."),
                _buildListItem("تأكد أن الاعمال مميزة و ذات جودة عالية."),
                _buildListItem("اكتب عنوان واضح ووصف دقيق يوضح ميزات العملز."),
                _buildListItem("لا ترسل أعمال فارغة أو مكررة."),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
