import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _brandColor = Color(0xFFB84715);

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@erecipe.com',
      queryParameters: {'subject': 'E-Recipe support request'},
    );
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open your email app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2E9),
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFFF7F2E9),
        foregroundColor: _brandColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Frequently asked questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _faq(
            'How do I save a recipe?',
            'Open a recipe and tap the bookmark icon. It will appear in the Saved tab.',
          ),
          _faq(
            'What is E-Recipe Pro?',
            'Pro unlocks the complete recipe collection and exclusive content.',
          ),
          _faq(
            'How do I change my password?',
            'Open Profile, choose Change password, and enter your current and new passwords.',
          ),
          _faq(
            'How do I update my profile picture?',
            'Open Profile, tap the edit icon, then tap the camera button.',
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _contactSupport(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _brandColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.email_outlined),
            label: const Text('Contact support'),
          ),
        ],
      ),
    );
  }

  Widget _faq(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        title: Text(question),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(answer, style: const TextStyle(color: Colors.black54))],
      ),
    );
  }
}
