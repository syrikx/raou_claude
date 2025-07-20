// Firebase stub for when Firebase is disabled
// This file provides empty implementations when Firebase packages are not available

class FirebaseAuth {
  static FirebaseAuth get instance => FirebaseAuth();
  Stream<User?> authStateChanges() => Stream.value(null);
  Future<UserCredential> signInWithCredential(dynamic credential) async {
    throw UnsupportedError('Firebase is disabled');
  }
  Future<void> signOut() async {
    throw UnsupportedError('Firebase is disabled');
  }
  User? get currentUser => null;
}

class FirebaseFirestore {
  static FirebaseFirestore get instance => FirebaseFirestore();
  CollectionReference collection(String path) {
    throw UnsupportedError('Firebase is disabled');
  }
}

class CollectionReference {
  DocumentReference doc(String path) {
    throw UnsupportedError('Firebase is disabled');
  }
}

class DocumentReference {
  Future<DocumentSnapshot> get() async {
    throw UnsupportedError('Firebase is disabled');
  }
  Future<void> set(Map<String, dynamic> data) async {
    throw UnsupportedError('Firebase is disabled');
  }
  Future<void> update(Map<String, dynamic> data) async {
    throw UnsupportedError('Firebase is disabled');
  }
}

class DocumentSnapshot {
  bool get exists => false;
  Map<String, dynamic>? data() => null;
}

class User {
  String get uid => '';
  String? get email => null;
  String? get displayName => null;
}

class UserCredential {
  User? get user => null;
}

class AuthCredential {}

class GoogleAuthCredential extends AuthCredential {}

class OAuthCredential extends AuthCredential {}