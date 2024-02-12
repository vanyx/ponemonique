import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/towers_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TowerDataService _towerService = TowerDataService();
  late Future<Map<String, String>> _towerNamesFuture;
  String? selectedTowerId;

  @override
  void initState() {
    super.initState();
    _towerNamesFuture = _towerService.getTowersNamesWithIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Text(
                'Ponemonique !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              FutureBuilder<Map<String, String>>(
                future: _towerNamesFuture,
                builder:
                    (context, AsyncSnapshot<Map<String, String>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    Map<String, String>? towerNames = snapshot.data;
                    List<String> items = towerNames?.values.toList() ?? [];

                    if (items.isEmpty) {
                      items = ['Aucune tour appairée'];
                    }

                    return Column(
                      children: [
                        DropdownButtonFormField<String>(
                          items: items.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedTowerId = towerNames?.keys.firstWhere(
                                (key) => towerNames[key] == newValue,
                              );
                            });
                          },
                          value: items.first,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                            border: OutlineInputBorder(),
                            labelText: 'Sélectionnez une tour',
                          ),
                        ),
                        SizedBox(height: 20),
                        selectedTowerId != null
                            ? Column(
                                children: [
                                  Container(
                                    width: double
                                        .infinity, // Prend toute la largeur de l'écran
                                    child: StreamBuilder<bool>(
                                      stream: _towerService
                                          .getTowerStatusStreamById(
                                              selectedTowerId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          bool isTowerOn =
                                              snapshot.data ?? false;
                                          return onOffCard(
                                            title: 'Power On/Off',
                                            isOn: isTowerOn,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: double
                                        .infinity, // Prend toute la largeur de l'écran
                                    child: StreamBuilder<double?>(
                                      stream: _towerService
                                          .getCo2StreamById(selectedTowerId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          double? eauTemperature =
                                              snapshot.data;
                                          return co2Card(
                                            title: 'Niveau de CO2',
                                            value: eauTemperature,
                                            color: Color.fromARGB(
                                                255, 139, 190, 232),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: double
                                        .infinity, // Prend toute la largeur de l'écran
                                    child: StreamBuilder<double?>(
                                      stream: _towerService
                                          .getTemperatureAirStreamById(
                                              selectedTowerId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          double? airTemperature =
                                              snapshot.data;
                                          return temperatureAirCard(
                                            title: 'Température air',
                                            value: airTemperature,
                                            color: Color.fromARGB(
                                                255, 176, 184, 176),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: double
                                        .infinity, // Prend toute la largeur de l'écran
                                    child: StreamBuilder<double?>(
                                      stream:
                                          _towerService.getNiveauEauStreamById(
                                              selectedTowerId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          double? niveauEau = snapshot.data;
                                          return niveauEauCard(
                                            title: 'Niveau eau',
                                            value: niveauEau,
                                            color: Color.fromARGB(
                                                255, 192, 173, 255),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    width: double
                                        .infinity, // Prend toute la largeur de l'écran
                                    child: StreamBuilder<double?>(
                                      stream:
                                          _towerService.getLuminositeStreamById(
                                              selectedTowerId!),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          double? airTemperature =
                                              snapshot.data;
                                          return luminositeCard(
                                            title: 'Luminosité',
                                            value: airTemperature,
                                            color: Color.fromARGB(
                                                255, 246, 199, 69),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : Text('Aucune tour sélectionnée'),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget co2Card({
    required String title,
    required double? value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.waves,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              value != null ? '$value ppm' : 'N/A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget temperatureAirCard({
    required String title,
    required double? value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.thermostat,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              value != null ? '$value°C' : 'N/A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget niveauEauCard({
    required String title,
    required double? value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  SizedBox(
                      width: 10), // Ajoute un espace entre l'icône et le texte
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              value != null ? '$value cm' : 'N/A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget luminositeCard({
    required String title,
    required double? value,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              value != null ? '$value lm' : 'N/A',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget onOffCard({
    required String title,
    required bool isOn,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Color.fromARGB(255, 243, 90, 90),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Switch(
              value: isOn,
              onChanged: (value) {
                // Appelle changeOnOffStateById
                _towerService.changeOnOffStateById(
                  selectedTowerId!,
                  value,
                );
              },
              trackColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
                  // Utilise la couleur verte si le switch est activé (ON), sinon gris
                  return isOn
                      ? Colors.green
                      : Color.fromARGB(255, 234, 234, 234);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
