class Category {
  final String categoryId;
  final String categoryName;
  final String categoryColor;

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json["categoryId"],
      categoryName: json["categoryName"],
      categoryColor: json["categoryColor"],
    );
  }
}