import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../models/aspect.dart';
import '../models/aspect_sub.dart';

class AspectScreen extends StatefulWidget {
  const AspectScreen({super.key});

  @override
  State<AspectScreen> createState() => _AspectScreenState();
}

class _AspectScreenState extends State<AspectScreen> {
  final ApiService _apiService = ApiService();
  List<Aspect> _aspects = [];
  List<AspectSub> _aspectSubs = [];
  bool _isLoading = true;

  final Color tigerOrange = const Color(0xFFFF5722);
  final Color tigerBlack = const Color(0xFF212121);
  final Color jungleGreen = const Color(0xFF2E7D32);
  final Color goldAccent = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final aspects = await _apiService.getAspects();
      final aspectSubs = await _apiService.getAspectSubs();
      setState(() {
        _aspects = aspects;
        _aspectSubs = aspectSubs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  List<AspectSub> getSubAspects(int aspectId) {
    return _aspectSubs.where((sub) => sub.idAspect == aspectId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tigerBlack,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(tigerOrange),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: tigerOrange,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 80,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      itemCount: _aspects.length,
                      itemBuilder: (context, index) {
                        final aspect = _aspects[index];
                        final subAspects = getSubAspects(aspect.idAspect!);

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
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              colorScheme: ColorScheme.dark(
                                primary: tigerOrange,
                              ),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                aspect.nameAspect ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                              children: subAspects.map((sub) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  title: Text(
                                    sub.nameAspectSub,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    sub.ketAspectSub,
                                    style: TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  leading: Icon(
                                    Icons.subdirectory_arrow_right,
                                    color: goldAccent,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            // Tambahkan header
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
                        'Aspects',
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