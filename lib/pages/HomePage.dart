import 'package:carsys/modules/StandartDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _user;
  String _userName = "Usuário";

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    if (_user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['nome'] ?? 'Usuário';
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCars() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('cars').get();
      List<Map<String, dynamic>> carsList = [];
      for (var doc in querySnapshot.docs) {
        carsList.add(doc.data() as Map<String, dynamic>);
      }
      return carsList;
    } catch (e) {
      print("Erro ao buscar carros: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página Inicial"),
      ),
      drawer: StandartDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCars(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Erro ao carregar carros'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nenhum carro cadastrado.'));
                  } else {
                    List<Map<String, dynamic>> cars = snapshot.data!;
                    return ListView.builder(
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        var car = cars[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(car['name'] ?? 'Nome desconhecido'),
                            subtitle: Text('Modelo: ${car['model'] ?? 'Desconhecido'}'),
                            trailing: Text(car['year'] ?? 'Ano desconhecido'),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
