import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/towers_data_service.dart';
import 'tower_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class TowersPage extends StatefulWidget {
  const TowersPage({Key? key}) : super(key: key);

  @override
  _TowersPageState createState() => _TowersPageState();
}

class _TowersPageState extends State<TowersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TowerDataService _towerService = TowerDataService();
  final TextEditingController _towerNameController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  late Future<Map<String, String>> _towerNamesFuture;
  late QRViewController _controller;
  bool _isScanning = false;

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
                  setState(() {
                    _isScanning = !_isScanning;
                  });
                },
                icon: Icon(_isScanning ? Icons.stop : Icons.qr_code_scanner),
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
          child: _isScanning ? _buildQrScanner() : _buildTowersList(),
        ),
      ],
    );
  }

  Widget _buildQrScanner() {
    return QRView(
      key: _qrKey,
      onQRViewCreated: (controller) {
        _controller = controller;
        controller.scannedDataStream.listen((scanData) {
          if (scanData != null && scanData.code != null) {
            _addUserToTower(scanData.code!);
            setState(() {
              _isScanning = false;
            });
          }
        });
      },
      overlay: QrScannerOverlayShape(
        borderColor: Colors.purple,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      ),
    );
  }

  Widget _buildTowersList() {
    return FutureBuilder<Map<String, String>>(
      future: _towerNamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else {
          Map<String, String> towerNames = snapshot.data ?? {};

          if (towerNames.isEmpty) {
            return Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Cliquez sur ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.qr_code,
                    size: 24,
                  ),
                  Text(
                    " pour ajouter une tour",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildTowerCardsList(towerNames);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
