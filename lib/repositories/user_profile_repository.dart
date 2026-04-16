import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/address.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'firestore_mappers.dart';
import 'firestore_paths.dart';

class UserProfileRepository {
  UserProfileRepository({
    FirebaseFirestore? firestore,
    DatabaseService? databaseService,
    SyncService? syncService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _databaseService = databaseService ?? DatabaseService.instance,
       _syncService =
           syncService ??
           SyncService(
             firestore: firestore,
             databaseService: databaseService,
           );

  final FirebaseFirestore _firestore;
  final DatabaseService _databaseService;
  final SyncService _syncService;

  Future<UserProfileSnapshot> loadLocalProfile(
    firebase_auth.User authUser,
  ) async {
    final email = _normalizedEmail(authUser.email);
    final storedProfile = await _databaseService.getUserProfile(email);

    return UserProfileSnapshot(
      uid: authUser.uid,
      email: email,
      displayName:
          storedProfile?.displayName ??
          authUser.displayName ??
          _fallbackDisplayName(email),
      phone: storedProfile?.phone ?? authUser.phoneNumber,
      photoUrl: authUser.photoURL,
      localProfileImagePath: storedProfile?.profileImagePath,
      addresses: storedProfile?.addresses ?? const <Address>[],
    );
  }

  Future<UserProfileSnapshot?> fetchRemoteProfile(
    firebase_auth.User authUser,
  ) async {
    final userSnapshot = await _firestore.doc(FirestorePaths.user(authUser.uid)).get();
    if (!userSnapshot.exists) {
      return null;
    }

    final addressesSnapshot = await _firestore
        .collection('${FirestorePaths.user(authUser.uid)}/addresses')
        .get();

    final localProfile = await _databaseService.getUserProfile(
      _normalizedEmail(authUser.email),
    );

    return FirestoreMappers.profileFromRemote(
      authUser: authUser,
      userData: userSnapshot.data(),
      addresses: addressesSnapshot.docs
          .map(
            (doc) => FirestoreMappers.addressFromFirestore(
              doc.data(),
              fallbackId: doc.id,
            ),
          )
          .toList(growable: false),
      localProfileImagePath: localProfile?.profileImagePath,
    );
  }

  Future<UserProfileSnapshot> syncFromRemote(
    firebase_auth.User authUser,
  ) async {
    final remoteProfile = await fetchRemoteProfile(authUser);
    if (remoteProfile == null) {
      final localProfile = await loadLocalProfile(authUser);
      await saveProfile(
        authUser: authUser,
        displayName: localProfile.displayName,
        phone: localProfile.phone,
        localProfileImagePath: localProfile.localProfileImagePath,
        addresses: localProfile.addresses,
      );
      return localProfile;
    }

    await _databaseService.saveUserProfile(
      userEmail: remoteProfile.email,
      displayName: remoteProfile.displayName,
      phone: remoteProfile.phone,
      profileImagePath: remoteProfile.localProfileImagePath,
      addresses: remoteProfile.addresses,
    );
    return remoteProfile;
  }

  Future<void> saveProfile({
    required firebase_auth.User authUser,
    String? displayName,
    String? phone,
    String? localProfileImagePath,
    List<Address>? addresses,
  }) async {
    final email = _normalizedEmail(authUser.email);
    final existing = await _databaseService.getUserProfile(email);
    final mergedAddresses = addresses ?? existing?.addresses ?? const <Address>[];

    await _databaseService.saveUserProfile(
      userEmail: email,
      displayName: displayName ?? existing?.displayName ?? authUser.displayName,
      phone: phone ?? existing?.phone ?? authUser.phoneNumber,
      profileImagePath: localProfileImagePath ?? existing?.profileImagePath,
      addresses: mergedAddresses,
    );

    await _syncService.writeThroughSet(
      documentPath: FirestorePaths.user(authUser.uid),
      data: FirestoreMappers.userDocument(
        authUser: authUser,
        localProfile: await _databaseService.getUserProfile(email),
      ),
      userUid: authUser.uid,
      merge: true,
    );

    await _syncAddresses(authUser, mergedAddresses);
  }

  Future<void> _syncAddresses(
    firebase_auth.User authUser,
    List<Address> addresses,
  ) async {
    final desiredIds = addresses.map((address) => address.id).toSet();

    try {
      final remoteSnapshot = await _firestore
          .collection('${FirestorePaths.user(authUser.uid)}/addresses')
          .get();
      for (final document in remoteSnapshot.docs) {
        if (!desiredIds.contains(document.id)) {
          await _syncService.writeThroughDelete(
            documentPath: FirestorePaths.address(authUser.uid, document.id),
            userUid: authUser.uid,
          );
        }
      }
    } catch (_) {}

    for (final address in addresses) {
      await _syncService.writeThroughSet(
        documentPath: FirestorePaths.address(authUser.uid, address.id),
        data: FirestoreMappers.addressDocument(address),
        userUid: authUser.uid,
      );
    }
  }

  String _normalizedEmail(String? email) => (email ?? '').trim().toLowerCase();

  String _fallbackDisplayName(String normalizedEmail) {
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return '';
    }
    return normalizedEmail.split('@').first;
  }
}
