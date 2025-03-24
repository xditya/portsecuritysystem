import 'package:flutter/material.dart';
import 'package:portsecuritysystem/config/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.subtleTextColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Port Security System'),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('Faces'),
          _buildCard('View Faces', Icons.face_retouching_natural, () {
            Navigator.pushNamed(context, '/view-faces');
          }),
          _buildCard('Add Face', Icons.person_add_rounded, () {
            Navigator.pushNamed(context, '/add-face');
          }),
          _buildCard('Face Entry Log', Icons.history_rounded, () {
            Navigator.pushNamed(context, '/face-entry-log');
          }),
          _buildSectionTitle('Vehicles'),
          _buildCard('View Vehicles', Icons.directions_car_filled, () {
            Navigator.pushNamed(context, '/view-vehicles');
          }),
          _buildCard('Add Vehicle', Icons.add_circle_rounded, () {
            Navigator.pushNamed(context, '/add-vehicle');
          }),
          _buildCard('Vehicle Entry Log', Icons.article_rounded, () {
            Navigator.pushNamed(context, '/vehicle-entry-log');
          }),
        ],
      ),
    );
  }
}
