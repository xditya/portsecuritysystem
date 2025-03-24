import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:portsecuritysystem/config/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _counts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCounts();
  }

  Future<void> _fetchCounts() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/counts'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        setState(() {
          _counts = data;
          _isLoading = false;
        });
      } else {
        throw 'Failed to load counts';
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.15),
            AppTheme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.security,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Port Security System',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsCard(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_isLoading) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (_counts == null) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text(
          'Failed to load statistics',
          style: TextStyle(color: AppTheme.subtleTextColor),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.subtleTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      _counts!['today']['face_detections'].toString(),
                      'Faces',
                      Icons.face_retouching_natural,
                    ),
                    _buildStatItem(
                      _counts!['today']['vehicle_entries'].toString(),
                      'Vehicles',
                      Icons.directions_car,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.subtleTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      _counts!['total']['registered_faces'].toString(),
                      'Detections',
                      Icons.face,
                    ),
                    _buildStatItem(
                      _counts!['total']['registered_vehicles'].toString(),
                      'Entries',
                      Icons.directions_car,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ],
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.subtleTextColor,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildFeatureCard(
            context,
            'View Faces',
            'Browse registered faces',
            Icons.face_retouching_natural,
            '/view-faces',
            [const Color(0xFF6E5FF8), const Color(0xFF9D94FF)],
          ),
          _buildFeatureCard(
            context,
            'Add Face',
            'Register a new face',
            Icons.person_add_rounded,
            '/add-face',
            [const Color(0xFF4CAF50), const Color(0xFF81C784)],
          ),
          _buildFeatureCard(
            context,
            'View Vehicles',
            'Browse vehicles',
            Icons.directions_car_filled,
            '/view-vehicles',
            [const Color(0xFF2196F3), const Color(0xFF64B5F6)],
          ),
          _buildFeatureCard(
            context,
            'Add Vehicle',
            'Register vehicle',
            Icons.add_circle_rounded,
            '/add-vehicle',
            [const Color(0xFFF44336), const Color(0xFFE57373)],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
    List<Color> gradientColors,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(
                'Face Log',
                Icons.history_rounded,
                '/face-entry-log',
              ),
              _buildQuickActionButton(
                'Vehicle Log',
                Icons.article_rounded,
                '/vehicle-entry-log',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, String route) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            _buildHeader(),
            _buildSectionTitle('Main Features', Icons.dashboard),
            _buildFeatureGrid(context),
            _buildQuickActions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
