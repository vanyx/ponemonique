import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/users_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPage extends StatefulWidget {
  UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserDataService _userDataService = UserDataService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;
  late String _name;
  late String _email;
  late String _biography;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String? userId = await _userDataService.getUserId();
    String? name = await _userDataService.getUserName(userId);
    String? email = await _userDataService.getUserEmail();
    String? biography = await _userDataService.getUserBiography(userId);

    if (userId != null && name != null && email != null && biography != null) {
      setState(() {
        _userId = userId;
        _name = name;
        _email = email;
        _biography = biography;
      });
    }
  }

  Future<void> _showEditProfileDialog() async {
    TextEditingController nameController = TextEditingController(text: _name);
    TextEditingController biographyController =
        TextEditingController(text: _biography);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: biographyController,
                decoration: InputDecoration(labelText: 'Biographie'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                String newBiography = biographyController.text.trim();

                await _userDataService.updateUser(_userId,
                    name: newName, biography: newBiography);
                _loadUserData(); // Rafraîchir les données après la mise à jour
                Navigator.pop(context);
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pop(context); // Retour à la page précédente après la déconnexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nom: $_name',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Email: $_email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Biographie: $_biography',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showEditProfileDialog,
              child: Text('Modifier le profil'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}
