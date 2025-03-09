class FoodCategory {
  String? key;
  FoodCategoryData? foodCategoryData;

  FoodCategory({this.key, this.foodCategoryData});
}

class FoodCategoryData {
  String? IdFoodCategory;
  String? NameFoodCategory;

  FoodCategoryData({this.IdFoodCategory, this.NameFoodCategory});

  FoodCategoryData.fromJson(Map<dynamic, dynamic> json) {
    IdFoodCategory = json["FoodCategoryId"];
    NameFoodCategory = json["NameFoodCategoryId"];
  }
}
