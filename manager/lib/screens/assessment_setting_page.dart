import 'package:flutter/material.dart';

class AssessmentSettingPage extends StatelessWidget {
  const AssessmentSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Penilaian'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengaturan Penilaian',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.settings, color: Colors.green),
                      ),
                      title: const Text('Pengaturan Umum'),
                      subtitle: const Text('Atur parameter penilaian dasar'),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                      onTap: () {
                        // Tambahkan navigasi ke pengaturan umum
                      },
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.aspect_ratio, color: Colors.green),
                      ),
                      title: const Text('Pengaturan Aspek'),
                      subtitle: const Text('Atur aspek-aspek penilaian'),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                      onTap: () {
                        // Tambahkan navigasi ke pengaturan aspek
                      },
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 6,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.category, color: Colors.green),
                      ),
                      title: const Text('Kategori Penilaian'),
                      subtitle: const Text('Atur kategori penilaian'),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                      onTap: () {
                        // Tambahkan navigasi ke pengaturan kategori
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
