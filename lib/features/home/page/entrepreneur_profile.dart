import 'package:flutter/material.dart';

class EntrepreneurProfile extends StatelessWidget {
  const EntrepreneurProfile({super.key});

  @override
  Widget build(BuildContext context) {
    // Static dummy data
    final projects = [
      {"status": "مسودة", "count": 0},
      {"status": "قيد المراجعة", "count": 0},
      {"status": "مفتوحة", "count": 1},
      {"status": "قيد التنفيذ", "count": 0},
      {"status": "مكتملة", "count": 0},
      {"status": "مغلقة", "count": 0},
      {"status": "ملغاة", "count": 0},
      {"status": "مرفوض", "count": 0},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text("الملف الشخصي"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile section
            CircleAvatar(
              radius: 50,
              backgroundImage: const NetworkImage(
                "https://talentflowa.com/public/storage/public/user/hd6GPphr1W2I66rZwyUMxiqoxRQX5izLXaMbse4E.png",
              ),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 12),
            Text(
              "Mohammed Maha",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              "المحامي سامي سامح،",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),

            // Projects grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final project = projects[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        project["status"].toString(),
                        style: TextStyle(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project["count"].toString(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
