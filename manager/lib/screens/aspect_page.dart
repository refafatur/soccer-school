import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AspectPage extends StatefulWidget {
  const AspectPage({super.key});

  @override
  _AspectPageState createState() => _AspectPageState();
}

class _AspectPageState extends State<AspectPage> {
  final String baseUrl = 'http://hayy.my.id/api/aspect';
  List<dynamic> aspects = [];

  @override
  void initState() {
    super.initState();
    fetchAspects();
  }

  Future<void> fetchAspects() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          aspects = jsonDecode(response.body);
        });
      } else {
        throw Exception('Gagal memuat aspek penilaian');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> addAspect(String nameAspect) async {
    final newAspect = {'name_aspect': nameAspect};
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newAspect),
      );
      if (response.statusCode == 200) {
        fetchAspects();
      } else {
        throw Exception('Gagal menambahkan aspek');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> editAspect(int idAspect, String nameAspect) async {
    final updatedAspect = {'name_aspect': nameAspect};
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$idAspect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedAspect),
      );
      if (response.statusCode == 200) {
        fetchAspects();
      } else {
        throw Exception('Gagal memperbarui aspek');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteAspect(int idAspect) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$idAspect'));
      if (response.statusCode == 200) {
        fetchAspects();
      } else {
        throw Exception('Gagal menghapus aspek');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void showAddDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.add_chart, color: Colors.green[700]),
            const SizedBox(width: 10),
            const Text(
              "Aspek Penilaian",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            labelText: "Nama Aspek",
            labelStyle: TextStyle(color: Colors.green[700]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.green[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
            ),
            prefixIcon: Icon(Icons.sports_soccer, color: Colors.green[700]),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Tambah"),
            onPressed: () async {
              await addAspect(nameController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEditDialog(int idAspect, String currentName) {
    final TextEditingController nameController = TextEditingController();
    nameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.green[700]),
            const SizedBox(width: 10),
            const Text(
              "Edit Aspek Penilaian",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            labelText: "Nama Aspek",
            labelStyle: TextStyle(color: Colors.green[700]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.green[700]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
            ),
            prefixIcon: Icon(Icons.sports_soccer, color: Colors.green[700]),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Simpan"),
            onPressed: () async {
              await editAspect(idAspect, nameController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[100]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        'https://example.com/logo.png', // Ganti dengan URL logo SSB
                        height: 40,
                        width: 40,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.sports_soccer, color: Colors.green[700], size: 40),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'SSB TIGER SOCCER SCHOOL',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Aspek Penilaian',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          IconButton(
                            onPressed: showAddDialog,
                            icon: Icon(Icons.add_circle, color: Colors.green[700], size: 30),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      aspects.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.sports_soccer,
                                      size: 80, color: Colors.grey[300]),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Belum ada aspek penilaian',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Expanded(
                              child: ListView.builder(
                                itemCount: aspects.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 15),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green[50]!,
                                          Colors.white,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      leading: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.green[700],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          aspects[index]['id_aspect'].toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        aspects[index]['name_aspect'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.green[700]),
                                            onPressed: () {
                                              showEditDialog(
                                                aspects[index]['id_aspect'],
                                                aspects[index]['name_aspect'],
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Konfirmasi'),
                                                  content: const Text(
                                                      'Apakah Anda yakin ingin menghapus aspek ini?'),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        deleteAspect(aspects[index]
                                                            ['id_aspect']);
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                      child:
                                                          const Text('Hapus'),
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
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
