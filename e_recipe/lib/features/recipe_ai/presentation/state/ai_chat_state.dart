import 'package:e_recipe/features/recipe_ai/domain/entities/generated_recipe.dart';

class AiChatState {
  final List<RecipeChatMessage> messages;
  final bool loading;

  const AiChatState({
    this.messages = const [
      RecipeChatMessage(
        text:
            'Hi! I’m E-Recipe AI. Ask me about cooking, ingredients, substitutions, food storage, cuisines, or what you should cook today.',
        isUser: false,
      ),
    ],
    this.loading = false,
  });

  AiChatState copyWith({List<RecipeChatMessage>? messages, bool? loading}) {
    return AiChatState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}
