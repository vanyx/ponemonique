import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/towers_data_service.dart';
import 'tower_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TowersPage extends StatefulWidget {
  const TowersPage({Key? key}) : super(key: key);

  @override
  _TowersPageState createState() => _TowersPageState();
}

class _TowersPageState extends State<TowersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TowerDataService _towerService = TowerDataService();
  final TextEditingController _towerNameController = TextEditingController();
  final TextEditingController _scanController = TextEditingController();
  late Future<Map<String, String>> _towerNamesFuture;

  @override
  void initState() {
    super.initState();
    _towerNamesFuture = _towerService.getTowersNamesWithIds();
  }

  Widget _buildTowerCardsList(Map<String, String> towerNames) {
    return ListView(
      children: towerNames.entries.map((entry) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TowerDetailsPage(towerId: entry.key),
              ),
            );
          },
          child: Card(
            child: ListTile(
              title: Text(entry.value),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _addUserToTower(String scanCode) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _towerService.addUserToTowerByScan(scanCode, currentUser.uid);
        setState(() {
          _towerNamesFuture = _towerService.getTowersNamesWithIds();
        });
      } else {
        throw Exception('Aucun utilisateur actuellement connecté');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'utilisateur à la tour : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30),
        Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Mes tours',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Ajouter un utilisateur à une tour'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _scanController,
                              decoration: InputDecoration(
                                labelText: 'Code de scan de la tour',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              BuildContext currentContext = context;
                              String scanCode = _scanController.text.trim();
                              if (scanCode.isNotEmpty) {
                                await _addUserToTower(scanCode);
                              }
                              Navigator.pop(currentContext);
                            },
                            child: Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              String scanCode = _scanController.text.trim();
                              if (scanCode.isNotEmpty) {
                                await _addUserToTower(scanCode);
                              }
                              Navigator.pop(context);
                            },
                            child: Text('Ajouter'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.purple.shade200,
        ),
        Expanded(
          child: FutureBuilder<Map<String, String>>(
            future: _towerNamesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              } else {
                Map<String, String> towerNames = snapshot.data ?? {};

                if (towerNames.isEmpty) {
                  // Aucune tour appairée, afficher le message
                  return Center(
                    child: Text(
                      "Cliquez sur l'icône + pour ajouter une tour",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return _buildTowerCardsList(towerNames);
              }
            },
          ),
        ),
      ],
    );
  }
}
