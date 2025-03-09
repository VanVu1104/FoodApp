// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class Food {
//   String? foodId;
//   String? nameFood;
//   String? imageFood;
//   String? descriptionfood;
//   int? calo;
//   int? preparationTime;
//   String? note;
//   bool? status;
//   String? categoryId;

//   Food({
//     required this.foodId,
//     required this.nameFood,
//     required this.imageFood,
//     required this.descriptionfood,
//     required this.calo,
//     required this.preparationTime,
//     this.note,
//     this.status,
//     required this.categoryId,
//   });
//   factory Food.fromFirestore(Map<String, dynamic> json, String foodId) {
//     return Food(
//       foodId: foodId,
//       nameFood: json["nameFood"],
//       imageFood: json["imageFood"],
//       descriptionfood: json["descriptionfood"],
//       calo : json["calo"],
//       preparationTime: json["preparationTime"],
//       note: json["note"],
//       status : json["status"],
//       categoryId: json["categoryId"],

//     )
//   }
// }
