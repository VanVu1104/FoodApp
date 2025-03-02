class Favourite {
  final String favouriteId;
  final String productId;
  final String userId;

  Favourite({
    required this.favouriteId,
    required this.productId,
    required this.userId,
  });

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
        favouriteId: json["favouriteId"] ?? "",
        productId: json["productName"] ?? "",
        userId: json["productImg"] ?? "");
  }
}