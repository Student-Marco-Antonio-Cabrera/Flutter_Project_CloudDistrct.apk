import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/products.dart';
import '../models/product.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

class ProductRepository {
  ProductRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<Product>> loadCatalog({bool preferRemote = true}) async {
    if (!preferRemote) {
      return List<Product>.unmodifiable(mockProducts);
    }

    try {
      final snapshot = await _firestore.collection('products').get();
      if (snapshot.docs.isEmpty) {
        return List<Product>.unmodifiable(mockProducts);
      }
      return snapshot.docs
          .map(
            (doc) => FirestoreMappers.productFromFirestore(
              doc.data(),
              documentId: doc.id,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return List<Product>.unmodifiable(mockProducts);
    }
  }

  Future<void> seedRemoteCatalogIfEmpty({
    List<Product>? seedProducts,
  }) async {
    final catalog = seedProducts ?? mockProducts;
    final snapshot = await _firestore.collection('products').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final product in catalog) {
      batch.set(
        _firestore.doc(FirestorePaths.product(product.id)),
        FirestoreMappers.productDocument(product),
      );
    }
    await batch.commit();
  }
}
