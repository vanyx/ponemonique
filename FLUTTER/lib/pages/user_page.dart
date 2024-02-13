import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/users_data_service.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserDataService _userDataService = UserDataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: FutureBuilder<String?>(
        future: _userDataService.getUserId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            String? userId = snapshot.data;
            return Center(child: _buildUserInfo(userId));
          }
        },
      ),
    );
  }

  Widget _buildUserInfo(String? userId) {
    return FutureBuilder<String?>(
      future: _userDataService.getUserName(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else {
          String? userName = snapshot.data;
          return _buildUserContent(userName);
        }
      },
    );
  }

  Widget _buildUserContent(String? userName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Nom de l\'utilisateur : $userName'),
        SizedBox(height: 20),

        // Bouton de déconnexion
        ElevatedButton(
          onPressed: _handleLogout,
          child: Text('Déconnexion'),
        ),
      ],
    );
  }

  void _handleLogout() async {
    try {
      await _userDataService.logout();
      // Naviguez vers votre écran de connexion ou une autre page appropriée.
      // Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Gérez l'erreur lors de la déconnexion
      print('Erreur lors de la déconnexion : $e');
      // Affichez un message d'erreur ou prenez d'autres mesures nécessaires.
    }
  }
}
