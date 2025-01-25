import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PointRateScreen extends StatefulWidget {
  const PointRateScreen({super.key});

  @override
  State<PointRateScreen> createState() => _PointRateScreenState();
}

class _PointRateScreenState extends State<PointRateScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pointRates = [];
  bool _isLoading = true;

  final Color tigerOrange = const Color(0xFFFF5722);
  final Color tigerBlack = const Color(0xFF212121);
  final Color goldAccent = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _loadPointRates();
  }

  Future<void> _loadPointRates() async {
    try {
      final response = await _apiService.getPointRate();
      setState(() {
        _pointRates = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tigerBlack,
      ),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(tigerOrange),
              ),
            )
          : Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _loadPointRates,
                    color: tigerOrange,
                    child: ListView.builder(
                      itemCount: _pointRates.length,
                      padding: const EdgeInsets.only(
                        top: 80,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      itemBuilder: (context, index) {
                        final rate = _pointRates[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: tigerOrange.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [tigerOrange, goldAccent],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              rate['rate'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: tigerOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Point: ${rate['point_rate']}',
                                style: TextStyle(
                                  color: goldAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: tigerBlack,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: tigerOrange,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              'Point Rate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}