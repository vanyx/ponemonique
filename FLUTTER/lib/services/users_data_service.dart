import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserId() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<String?> getUserEmail() async {
    User? user = _auth.currentUser;
    return user?.email;
  }

  Future<String?> getUserName(String? userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        return snapshot.get('name') as String?;
      } else {
        return null;
      }
    } catch (e) {
      print(
          'Erreur lors de la récupération de la biographie de l\'utilisateur : $e');
      return null;
    }
  }

  Future<String?> getUserBiography(String? userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        return snapshot.get('biography') as String?;
      } else {
        return null;
      }
    } catch (e) {
      print(
          'Erreur lors de la récupération de la biographie de l\'utilisateur : $e');
      return null;
    }
  }

  Future<void> updateUser(String userId,
      {String? name, String? biography}) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
        'biography': biography,
      });
    } catch (e) {
      print(
          'Erreur lors de la mise à jour des informations de l\'utilisateur : $e');
      throw Exception(
          'Échec de la mise à jour des informations de l\'utilisateur.');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
      throw Exception('Échec de la déconnexion.');
    }
  }
}
