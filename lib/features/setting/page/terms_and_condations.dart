import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                'الشروط والاحكام',
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 24.0),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "الشروط والاحكام",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    _buildSection(
                      "1. التسجيل واستخدام الحساب",
                      [
                        "يجب أن يكون المستخدم فوق 18 عامًا.",
                        "يجب إدخال معلومات صحيحة وكاملة عند إنشاء الحساب.",
                        "لا يسمح بامتلاك أكثر من حساب واحد إلا بموافقة إدارية.",
                      ],
                    ),
                    _buildSection(
                      "2. طبيعة الخدمة",
                      [
                        "تلنت فلو هي وسيط بين أصحاب المشاريع والمستقلين ولا تضمن نجاح المشروع أو جودة العمل، بل توفر أدوات لإدارة العلاقة بين الطرفين.",
                        "يتحمل كل طرف مسؤولية التحقق من الطرف الآخر قبل البدء.",
                      ],
                    ),
                    _buildSection(
                      "3. الدفع والعمولات",
                      [
                        "يتم الاتفاق على قيمة المشروع بين المستقل وصاحب العمل.",
                        "تقتطع المنصة عمولة (%) تحددها الإدارة مثل 10% مثلاً من كل عملية ناجحة.",
                      ],
                    ),
                    _buildSection(
                      "4. سلوك ممنوع",
                      [
                        "يُمنع نشر محتوى مخالف للقوانين أو مسيء.",
                        "يُمنع التواصل خارج المنصة بشأن المشاريع بهدف التهرب من العمولة.",
                      ],
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

  /// A helper widget to build a section with a title and a list of points.
  Widget _buildSection(String title, List<String> points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8.0),
          // Creates a list item for each point in the list.
          ...points.map((point) => _buildListItem(point)).toList(),
        ],
      ),
    );
  }

  /// A helper widget to build a single list item with a bullet point.
  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.5, // Line height for readability.
              ),
            ),
          ),
        ],
      ),
    );
  }
}
