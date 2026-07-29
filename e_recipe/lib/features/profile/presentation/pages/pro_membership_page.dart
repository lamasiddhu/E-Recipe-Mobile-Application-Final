import 'package:flutter/material.dart';

const _brandColor = Color(0xFFB84715);

class ProMembershipPage extends StatelessWidget {
  const ProMembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E9),
      appBar: AppBar(
        title: const Text('E-Recipe Pro'),
        backgroundColor: const Color(0xFFF7F2E9),
        foregroundColor: _brandColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_brandColor, Color(0xFFE47B3C)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                Icon(Icons.workspace_premium, color: Colors.white, size: 52),
                SizedBox(height: 12),
                Text(
                  'Cook without limits',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Unlock the complete E-Recipe experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _benefit(Icons.menu_book, 'Unlimited recipe access'),
          _benefit(Icons.star_outline, 'Exclusive Pro recipes'),
          _benefit(Icons.folder_outlined, 'Custom recipe collections'),
          _benefit(Icons.block, 'Ad-free experience'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('e-Sewa payment will be connected next.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text('GET PRO'),
          ),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: _brandColor),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
