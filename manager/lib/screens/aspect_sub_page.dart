import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AspectSubPage extends StatefulWidget {
  final String aspect;
  final int idAspect;

  const AspectSubPage({super.key, required this.aspect, required this.idAspect});

  @override
  State<AspectSubPage> createState() => _AspectSubPageState();
}

class _AspectSubPageState extends State<AspectSubPage> with SingleTickerProviderStateMixin {
  final String baseUrl = 'http://hayy.my.id/api/aspect_sub';
  List<dynamic> subAspects = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    fetchSubAspects();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchSubAspects() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          subAspects = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat sub aspek');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addSubAspect(String nameAspectSub, String ketAspectSub) async {
    if (nameAspectSub.isEmpty || ketAspectSub.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final newSubAspect = {
      'id_aspect': widget.idAspect,
      'name_aspect_sub': nameAspectSub,
      'ket_aspect_sub': ketAspectSub
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newSubAspect),
      );
      if (response.statusCode == 200) {
        fetchSubAspects();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sub aspek berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Gagal menambahkan sub aspek');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> editSubAspect(int idAspectSub, String nameAspectSub, String ketAspectSub) async {
    if (nameAspectSub.isEmpty || ketAspectSub.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field harus diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final updatedSubAspect = {
      'id_aspect': widget.idAspect,
      'name_aspect_sub': nameAspectSub,
      'ket_aspect_sub': ketAspectSub
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$idAspectSub'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedSubAspect),
      );
      if (response.statusCode == 200) {
        fetchSubAspects();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sub aspek berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Gagal memperbarui sub aspek');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteSubAspect(int idAspectSub) async {
    setState(() => isLoading = true);
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$idAspectSub'));
      if (response.statusCode == 200) {
        fetchSubAspects();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sub aspek berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Gagal menghapus sub aspek');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showAddDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController ketController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.sports_soccer, color: Colors.green[700], size: 30),
              const SizedBox(width: 10),
              const Text(
                "Tambah Sub Aspek",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                labelText: "Nama Sub Aspek",
                labelStyle: TextStyle(color: Colors.green[700], fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                prefixIcon: Icon(Icons.sports_soccer, color: Colors.green[700]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ketController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                labelText: "Keterangan",
                labelStyle: TextStyle(color: Colors.green[700], fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                prefixIcon: Icon(Icons.description, color: Colors.green[700]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.close, size: 20),
            label: const Text("Batal", style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 20),
            label: const Text("Tambah", style: TextStyle(fontSize: 16)),
            onPressed: () async {
              await addSubAspect(nameController.text, ketController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showEditDialog(int idAspectSub, String currentName, String currentKet) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    final TextEditingController ketController = TextEditingController(text: currentKet);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.green[700], size: 30),
              const SizedBox(width: 10),
              const Text(
                "Edit Sub Aspek",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                labelText: "Nama Sub Aspek",
                labelStyle: TextStyle(color: Colors.green[700], fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                prefixIcon: Icon(Icons.sports_soccer, color: Colors.green[700]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: ketController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                labelText: "Keterangan",
                labelStyle: TextStyle(color: Colors.green[700], fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                ),
                prefixIcon: Icon(Icons.description, color: Colors.green[700]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.close, size: 20),
            label: const Text("Batal", style: TextStyle(fontSize: 16)),
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 20),
            label: const Text("Simpan", style: TextStyle(fontSize: 16)),
            onPressed: () async {
              await editSubAspect(idAspectSub, nameController.text, ketController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        title: Row(
          children: [
            Icon(Icons.sports_soccer, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              '${widget.aspect} - Sub Aspek',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton.extended(
          onPressed: showAddDialog,
          backgroundColor: Colors.green[700],
          icon: const Icon(Icons.add),
          label: const Text("Tambah Sub Aspek"),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green[700]!, Colors.green[900]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _animation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sports_soccer, color: Colors.green[700], size: 30),
                          const SizedBox(width: 10),
                          Text(
                            'Sub Aspek ${widget.aspect}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Kriteria penilaian untuk ${widget.aspect}:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green[700],
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : subAspects.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada sub aspek',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: subAspects.length,
                            itemBuilder: (context, index) {
                              final subAspect = subAspects[index];
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _controller,
                                  curve: Interval(
                                    index * 0.1,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                )),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.sports_soccer,
                                        color: Colors.green[700],
                                        size: 30,
                                      ),
                                    ),
                                    title: Text(
                                      subAspect['name_aspect_sub'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins'
                                      ),
                                    ),
                                    subtitle: Container(
                                      margin: const EdgeInsets.only(top: 8.0),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        subAspect['ket_aspect_sub'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                          fontFamily: 'Poppins'
                                        ),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, color: Colors.green[700]),
                                          onPressed: () => showEditDialog(
                                            subAspect['id_aspect_sub'],
                                            subAspect['name_aspect_sub'],
                                            subAspect['ket_aspect_sub'],
                                          ),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Konfirmasi Hapus'),
                                              content: const Text('Apakah Anda yakin ingin menghapus sub aspek ini?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Batal'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    deleteSubAspect(subAspect['id_aspect_sub']);
                                                    Navigator.pop(context);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          tooltip: 'Hapus',
                                        ),
                                      ],
                                    ),
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
    );
  }
}
