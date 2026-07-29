import 'package:e_recipe/app/routes/app_routes.dart';
import 'package:e_recipe/features/recipe_ai/domain/entities/generated_recipe.dart';
import 'package:e_recipe/features/recipe/presentation/widgets/recipe_access_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_recipe/app/providers/dependency_providers.dart';

class AiRecipePage extends ConsumerStatefulWidget {
  const AiRecipePage({super.key});

  @override
  ConsumerState<AiRecipePage> createState() => _AiRecipePageState();
}

class _AiRecipePageState extends ConsumerState<AiRecipePage> {
  static const _brand = Color(0xFFB84715);
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<RecipeChatMessage> _messages = [
    const RecipeChatMessage(
      text:
          'Hi! I’m E-Recipe AI. Ask me about cooking, ingredients, substitutions, food storage, cuisines, or what you should cook today.',
      isUser: false,
    ),
  ];
  bool _loading = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _loading) return;
    final history = List<RecipeChatMessage>.from(_messages);
    setState(() {
      _messages.add(RecipeChatMessage(text: text, isUser: true));
      _input.clear();
      _loading = true;
    });
    _scrollToBottom();

    try {
      final response = await ref.read(generateRecipeUseCaseProvider)(
        text,
        history: history,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(
          RecipeChatMessage(
            text: response.message,
            isUser: false,
            recommendations: response.recommendations,
          ),
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          RecipeChatMessage(
            text: 'I couldn’t answer that right now. ${error.toString()}',
            isUser: false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: _brand,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            SizedBox(width: 10),
            Text('E-Recipe AI'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const _TypingBubble();
                }
                return _MessageBubble(message: _messages[index]);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Ask anything about food...',
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _loading ? null : _send,
                    style: IconButton.styleFrom(backgroundColor: _brand),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final RecipeChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFB84715);
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.84,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isUser ? brand : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : null,
            bottomLeft: !message.isUser ? const Radius.circular(4) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : null,
                height: 1.4,
              ),
            ),
            for (final item in message.recommendations) ...[
              const SizedBox(height: 10),
              _RecipeLink(recommendation: item),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecipeLink extends StatelessWidget {
  final RecipeRecommendation recommendation;

  const _RecipeLink({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final recipe = recommendation.recipe;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.recipeDetail,
          arguments: recipe.id,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  RecipeAccessBadge(badge: recipe.badge),
                ],
              ),
              const SizedBox(height: 4),
              Text(recommendation.reason, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '${recipe.totalTime} min • ${recipe.difficulty}  ›',
                style: const TextStyle(
                  color: Color(0xFFB84715),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
