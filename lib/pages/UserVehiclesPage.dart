import 'package:carsys/modules/StandartDrawer.dart';
import 'package:carsys/pages/CarInfoPage.dart';
import 'package:carsys/pages/FuelHistoryPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserVehiclesPage extends StatefulWidget {
  const UserVehiclesPage({super.key});

  @override
  State<UserVehiclesPage> createState() => _UserVehiclesPageState();
}

class _UserVehiclesPageState extends State<UserVehiclesPage> {
  User? _currentUser;
  String _userDisplayName = "Usuário";

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    if (_currentUser != null) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userSnapshot.exists) {
          setState(() {
            _userDisplayName = userSnapshot.get('name') ?? "Usuário";
          });
        }
      } catch (error) {
        print("Erro ao buscar informações do usuário: $error");
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUserVehicles() async {
    if (_currentUser == null) {
      print("Nenhum usuário logado.");
      return [];
    }

    try {
      QuerySnapshot vehiclesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('mycars')
          .get();

      return vehiclesSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          'liters': data['liters'] ?? 0,
          'kilometrage': data['kilometrage'] ?? 0,
          'average': data['average'] ?? 0,
        };
      }).toList();
    } catch (error) {
      print("Erro ao buscar veículos: $error");
      return [];
    }
  }

  Future<void> _removeVehicle(String vehicleId) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('mycars')
          .doc(vehicleId)
          .delete();

      await FirebaseFirestore.instance.collection('cars').doc(vehicleId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo removido com sucesso.')),
      );

      setState(() {});
    } catch (error) {
      print("Erro ao remover veículo: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover veículo.')),
      );
    }
  }

  void _openEditVehicleDialog(BuildContext context, Map<String, dynamic> vehicle) {
    final nameController = TextEditingController(text: vehicle['name']);
    final modelController = TextEditingController(text: vehicle['model']);
    final litersController = TextEditingController(text: vehicle['liters'].toString());
    final kilometrageController = TextEditingController(text: vehicle['kilometrage'].toString());

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Editar Veículo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: litersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Litros'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: kilometrageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quilometragem'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedName = nameController.text.trim();
                final updatedModel = modelController.text.trim();
                final updatedLiters = double.tryParse(litersController.text.trim());
                final updatedKilometrage = int.tryParse(kilometrageController.text.trim());

                if (updatedLiters == null || updatedKilometrage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, insira valores válidos.")),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .collection('mycars')
                      .doc(vehicle['id'])
                      .update({
                    'name': updatedName,
                    'model': updatedModel,
                    'liters': updatedLiters,
                    'kilometrage': updatedKilometrage,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Veículo atualizado com sucesso.")),
                  );
                  Navigator.pop(context);
                  setState(() {});
                } catch (error) {
                  print("Erro ao atualizar veículo: $error");
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meus Veículos")),
      drawer: StandartDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar veículos."));
          }

          final vehicles = snapshot.data;

          if (vehicles == null || vehicles.isEmpty) {
            return const Center(child: Text("Você não possui veículos cadastrados."));
          }

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(vehicle['name'] ?? "Sem nome"),
                  subtitle: Text("Modelo: ${vehicle['model'] ?? 'Sem modelo'}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _openEditVehicleDialog(context, vehicle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeVehicle(vehicle['id']),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarInfoPage(car: vehicle),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
