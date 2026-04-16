import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Checks if Firestore is empty and uploads local products if necessary.
  Future<void> syncLocalProducts(List<Product> localProducts) async {
    try {
      final snapshot = await _firestore.collection('products').limit(1).get();
      
      // Only upload if the collection is currently empty
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        for (var product in localProducts) {
          final docRef = _firestore.collection('products').doc();
          batch.set(docRef, product.toFirestore());
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error syncing products: $e');
    }
  }

  // Fetch all products from the 'products' collection
  Future<List<Product>> getProducts() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }
}
