import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/towers_data_service.dart';
import 'package:flutter_application_1/services/users_data_service.dart';

class TowerDetailsPage extends StatefulWidget {
  final String towerId;
  final TowerDataService _towerService = TowerDataService();

  TowerDetailsPage({Key? key, required this.towerId}) : super(key: key);

  @override
  _TowerDetailsPageState createState() => _TowerDetailsPageState();
}

class _TowerDetailsPageState extends State<TowerDetailsPage> {
  late Stream<double?> _temperatureStream;
  final TextEditingController _renameController = TextEditingController();
  String? towerName;

  @override
  void initState() {
    super.initState();
    _temperatureStream =
        widget._towerService.getTemperatureAirStreamById(widget.towerId);
    _fetchTowerName();
  }

  Future<void> _fetchTowerName() async {
    String? name = await widget._towerService.getNameById(widget.towerId);
    setState(() {
      towerName = name;
    });
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Renommer la tour'),
          content: TextField(
            controller: _renameController,
            decoration: InputDecoration(
              hintText: 'Nouveau nom',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Valider'),
              onPressed: () async {
                String newName = _renameController.text;
                await widget._towerService.updateTowerName(
                  widget.towerId,
                  newName,
                );
                _fetchTowerName();
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) async {
    UserDataService userDataService = UserDataService();
    String? userId =
        await userDataService.getUserId(); // Obtenez l'ID de l'utilisateur

    if (userId != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Êtes-vous sûr de vouloir supprimer la tour ?'),
            actions: <Widget>[
              TextButton(
                child: Text('Confirmer'),
                onPressed: () async {
                  await widget._towerService.removeUserFromTower(
                    widget.towerId,
                    userId,
                  );
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text('Annuler'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          towerName ?? 'Détails de la tour',
          style: TextStyle(color: Colors.grey[800]),
        ),
        elevation: 1.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[800]),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<double?>(
              stream: _temperatureStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else {
                  double? temperature = snapshot.data;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showRenameDialog(context);
                        },
                        child: Text('Renommer la tour'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteConfirmation(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red, // Couleur de fond du bouton
                        ),
                        child: Text(
                          'Supprimer la tour',
                          style: TextStyle(
                              color:
                                  Colors.white), // Couleur du texte du bouton
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
