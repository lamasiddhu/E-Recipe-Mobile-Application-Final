import 'package:e_recipe/app/providers/dependency_providers.dart';
import 'package:e_recipe/features/recipe_ai/domain/entities/generated_recipe.dart';
import 'package:e_recipe/features/recipe_ai/domain/usecases/generate_recipe_usecase.dart';
import 'package:e_recipe/features/recipe_ai/presentation/state/ai_chat_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiChatViewModelProvider = NotifierProvider<AiChatViewModel, AiChatState>(
  AiChatViewModel.new,
);

class AiChatViewModel extends Notifier<AiChatState> {
  late final GenerateRecipeUseCase _generateRecipeUseCase;

  @override
  AiChatState build() {
    _generateRecipeUseCase = ref.read(generateRecipeUseCaseProvider);
    return const AiChatState();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.loading) return;

    final history = List<RecipeChatMessage>.from(state.messages);
    state = state.copyWith(
      messages: [
        ...state.messages,
        RecipeChatMessage(text: trimmed, isUser: true),
      ],
      loading: true,
    );

    try {
      final response = await _generateRecipeUseCase(trimmed, history: history);
      state = state.copyWith(
        messages: [
          ...state.messages,
          RecipeChatMessage(
            text: response.message,
            isUser: false,
            recommendations: response.recommendations,
          ),
        ],
      );
    } catch (error) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          RecipeChatMessage(
            text: 'I couldn’t answer that right now. ${error.toString()}',
            isUser: false,
          ),
        ],
      );
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}
