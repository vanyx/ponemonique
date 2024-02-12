import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TowerDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, String>> getTowersNamesWithIds() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        QuerySnapshot querySnapshot = await _firestore
            .collection('towers')
            .where('usersIds', arrayContains: currentUser.uid)
            .get();

        return Map.fromEntries(querySnapshot.docs.map((doc) {
          String towerId = doc.id; // Récupérer l'ID de la tour
          String towerName =
              doc.get('name') as String; // Récupérer le nom de la tour
          return MapEntry(towerId, towerName); // Créer une entrée dans la Map
        }));
      } else {
        throw Exception('Aucun utilisateur actuellement connecté');
      }
    } catch (e) {
      print('Erreur lors de la récupération des tours: $e');
      return {}; // Retourner une Map vide en cas d'erreur
    }
  }

  Future<void> updateTowerName(String towerId, String newName) async {
    try {
      await _firestore.collection('towers').doc(towerId).update({
        'name': newName,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du nom de la tour : $e');
      throw Exception('Échec de la mise à jour du nom de la tour.');
    }
  }

  Future<void> addUserToTowerByScan(String scanCode, String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('towers')
          .where('scan', isEqualTo: scanCode)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          List<String> usersId = List.from(doc.get('usersIds') ?? []);
          if (!usersId.contains(userId)) {
            usersId.add(userId);
            await doc.reference.update({'usersIds': usersId});
          }
        }
      } else {
        throw Exception('Aucune tour trouvée avec ce code de scan.');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'utilisateur à la tour : $e');
      // Gérer les erreurs éventuelles lors de l'ajout de l'utilisateur à la tour
    }
  }

//TODO: remove this and use stream
  Future<String?> getNameById(String towerId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('towers').doc(towerId).get();
      if (snapshot.exists) {
        return snapshot.get('name') as String?;
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom : $e');
      return null;
    }
  }

  Stream<String?> getNameStreamById(String towerId) {
    return _firestore
        .collection('towers')
        .doc(towerId)
        .snapshots()
        .map((snapshot) => snapshot.get('name') as String?);
  }

  Stream<double?> getCo2StreamById(String towerId) {
    return _firestore
        .collection('towers')
        .doc(towerId)
        .snapshots()
        .map((snapshot) => snapshot.get('co2') as double?);
  }

  Stream<double?> getTemperatureAirStreamById(String towerId) {
    return _firestore
        .collection('towers')
        .doc(towerId)
        .snapshots()
        .map((snapshot) => snapshot.get('temperatureAir') as double?);
  }

  Stream<double?> getNiveauEauStreamById(String towerId) {
    return _firestore
        .collection('towers')
        .doc(towerId)
        .snapshots()
        .map((snapshot) => snapshot.get('niveauEau') as double?);
  }

  Stream<bool> getTowerStatusStreamById(String towerId) {
    return _firestore
        .collection('towers')
        .doc(towerId)
        .snapshots()
        .map((snapshot) => snapshot.get('onOff') as bool? ?? false);
  }

  Stream<double?> getLuminositeStreamById(String towerId) {
    return _firestore
        .collection('towers')
        .doc(towerId)
        .snapshots()
        .map((snapshot) => snapshot.get('luminosite') as double?);
  }

  Future<void> removeUserFromTower(String towerId, String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('towers').doc(towerId).get();

      if (snapshot.exists) {
        List<String> usersIds = List.from(snapshot.get('usersIds') ?? []);
        usersIds.remove(userId);

        await _firestore
            .collection('towers')
            .doc(towerId)
            .update({'usersIds': usersIds});
      } else {
        throw Exception('La tour n\'existe pas');
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur de la tour : $e');
      // Gérer les erreurs éventuelles lors de la suppression de l'utilisateur de la tour
      throw Exception('Échec de la suppression de l\'utilisateur de la tour');
    }
  }

  Future<void> changeOnOffStateById(String towerId, bool newState) async {
    try {
      await _firestore
          .collection('towers')
          .doc(towerId)
          .update({'onOff': newState});
    } catch (e) {
      print('Erreur lors de la modification de l\'état On/Off : $e');
      throw Exception('Échec de la modification de l\'état On/Off.');
    }
  }
}
