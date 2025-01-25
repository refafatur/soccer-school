import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';

class PointRatePage extends StatefulWidget {
  const PointRatePage({super.key});

  @override
  _PointRatePageState createState() => _PointRatePageState();
}

class _PointRatePageState extends State<PointRatePage>
    with SingleTickerProviderStateMixin {
  final String baseUrl = 'http://hayy.my.id/api/point_rate';
  List<dynamic> _points = [];
  late AnimationController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    fetchPointRates();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> fetchPointRates() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        setState(() {
          _points = jsonDecode(response.body);
          _points.sort((a, b) => b['point_rate'].compareTo(a['point_rate']));
        });
      } else {
        throw Exception('Gagal memuat data point rate');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> addPointRate(String pointRate, String rate) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'point_rate': pointRate,
          'rate': rate,
        }),
      );
      if (response.statusCode == 200) {
        fetchPointRates();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Point rate berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Gagal menambah point rate');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updatePointRate(
      int idPointRate, String pointRate, String rate) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$idPointRate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'point_rate': pointRate,
          'rate': rate,
        }),
      );
      if (response.statusCode == 200) {
        fetchPointRates();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Point rate berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Gagal memperbarui point rate');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deletePointRate(int idPointRate) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content:
            const Text('Apakah Anda yakin ingin menghapus point rate ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                final response =
                    await http.delete(Uri.parse('$baseUrl/$idPointRate'));
                if (response.statusCode == 200) {
                  fetchPointRates();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Point rate berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  throw Exception('Gagal menghapus point rate');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({Map<String, dynamic>? point}) {
    String pointRate = point != null ? point['point_rate'].toString() : '';
    String rate = point != null ? point['rate'].toString() : '';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_jhlaooj5.json',
                width: 40,
                height: 40,
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
              ),
              const SizedBox(width: 10),
              Text(
                point == null ? 'Tambah Point Rate' : 'Edit Point Rate',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: pointRate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Point rate tidak boleh kosong';
                    }
                    return null;
                  },
                  onChanged: (value) => pointRate = value,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      labelText: 'Point Rate',
                      labelStyle: const TextStyle(color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.star_rate, color: Colors.green)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: rate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Rate tidak boleh kosong';
                    }
                    return null;
                  },
                  onChanged: (value) => rate = value,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      labelText: 'Rate',
                      labelStyle: const TextStyle(color: Colors.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.green, width: 2),
                      ),
                      prefixIcon:
                          const Icon(Icons.rate_review, color: Colors.green)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.close),
              label: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Simpan"),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (point == null) {
                    addPointRate(pointRate, rate);
                  } else {
                    updatePointRate(point['id_point_rate'], pointRate, rate);
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.star_rate, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'SSB TIGER ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Lottie.network(
                  'https://assets3.lottiefiles.com/packages/lf20_p8bfn5to.json',
                  width: 200,
                  height: 200,
                ),
              )
            : RefreshIndicator(
                onRefresh: fetchPointRates,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_rate,
                                color: Colors.white, size: 30),
                            SizedBox(width: 10),
                            Text(
                              'Penilaian Pemain',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: AnimationLimiter(
                          child: ListView.builder(
                            itemCount: _points.length,
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Card(
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              Colors.green.shade700,
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          _points[index]['point_rate']
                                              .toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Rate: ${_points[index]['rate']}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit,
                                                  color: Colors.green.shade700),
                                              onPressed: () {
                                                _showAddEditDialog(
                                                    point: _points[index]);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                deletePointRate(_points[index]
                                                    ['id_point_rate']);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Tambah Point Rate Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        onPressed: () {
                          _showAddEditDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
