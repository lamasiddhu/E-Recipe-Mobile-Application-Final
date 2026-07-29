import 'package:flutter/material.dart';

class RecipeAccessBadge extends StatelessWidget {
  final String badge;

  const RecipeAccessBadge({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final normalized = badge.trim().isEmpty ? 'Free' : badge.trim();
    final isPro = normalized.toLowerCase() == 'pro';
    final isFree = normalized.toLowerCase() == 'free';
    final color = isPro
        ? const Color(0xFF25170E)
        : isFree
        ? const Color(0xFF26734D)
        : const Color(0xFFB84715);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 5),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPro) ...[
            const Icon(Icons.workspace_premium, size: 13, color: Colors.amber),
            const SizedBox(width: 4),
          ],
          Text(
            normalized.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
