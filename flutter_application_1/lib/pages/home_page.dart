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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
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
                                    stream:
                                        _towerService.getTowerStatusStreamById(
                                            selectedTowerId!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        bool isTowerOn = snapshot.data ?? false;
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
                                        .getTemperatureEauStreamById(
                                            selectedTowerId!),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        double? eauTemperature = snapshot.data;
                                        return temperatureCard(
                                          title: 'Température eau',
                                          value: eauTemperature,
                                          color: Colors.blue,
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
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        double? airTemperature = snapshot.data;
                                        return temperatureCard(
                                          title: 'Température air',
                                          value: airTemperature,
                                          color: Colors.green,
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
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        double? niveauEau = snapshot.data;
                                        return niveauEauCard(
                                          title: 'Niveau eau',
                                          value: niveauEau,
                                          color:
                                              Color.fromARGB(255, 103, 61, 240),
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
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        double? airTemperature = snapshot.data;
                                        return luminositeCard(
                                          title: 'Luminosité',
                                          value: airTemperature,
                                          color: Color.fromARGB(
                                              255, 255, 113, 179),
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
    );
  }

  Widget temperatureCard({
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
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
      color: const Color.fromRGBO(255, 152, 0, 1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
            ),
          ],
        ),
      ),
    );
  }
}
