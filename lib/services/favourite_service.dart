import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favourite.dart';

class FavouriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Favourite>> getFavourites() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection("favourites").get();
      return snapshot.docs.map((doc) => Favourite.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print("Error fetching favourites: $e");
      return [];
    }
  }
}