import 'package:flutter/material.dart';

class AboutTalentFlowView extends StatelessWidget {
  const AboutTalentFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // A consistent background color.
      appBar: AppBar(
        // The AppBar uses the same style as the previous screen for consistency.
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        // The back button that allows users to return to the settings screen.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // The title of the screen, displayed on the right side.
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'ايه هو تلنت فلو',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Ensures the content is always scrollable.
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Directionality(
              // Ensures the entire layout within this widget is RTL.
              textDirection: TextDirection.rtl,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  // Aligns all children to the start (right side in RTL).
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ايه هو تلنت فلو ؟",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    // Using RichText to allow for specific styling, like making 'TalentFlow' bold.
                    RichText(
                      textAlign: TextAlign.start,
                      text: const TextSpan(
                        // Default style for the entire paragraph.
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.6, // Line height for better readability.
                          fontFamily: 'YourAppFont', // TODO: Use your app's font
                        ),
                        children: <TextSpan>[
                          TextSpan(text: 'منصة تلنت فلو '),
                          TextSpan(
                            text: '(TalentFlow)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text:
                              ' هي منصة للعمل الحر (فريلانس) ، وتركز على ربط أصحاب المشاريع مع المحترفين المستقلين في مجالات متعددة مثل التصميم، التطوير، التسويق، وكتابة المحتوى.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      "تهدف تلنت فلو إلى تسهيل عملية التوظيف المؤقت أو الجزئي من خلال توفير مساحة آمنة لإدارة المشاريع، التواصل بين الأطراف، وضمان الدفع مقابل العمل المنجز بجودة واحترافية.",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.6, // Consistent line height.
                        fontFamily: 'YourAppFont', // TODO: Use your app's font
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}