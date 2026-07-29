class RecipeEntity {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String category;
  final int? prepTime;
  final int? cookTime;
  final int totalTime;
  final String difficulty;
  final String image;
  final String videoUrl;
  final int price;
  final String badge;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecipeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.category,
    this.prepTime,
    this.cookTime,
    required this.totalTime,
    required this.difficulty,
    required this.image,
    this.videoUrl = '',
    this.price = 0,
    this.badge = 'Free',
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });
}
