import 'package:carsys/pages/AddVehiclePage.dart';
import 'package:carsys/pages/FuelHistoryPage.dart';
import 'package:carsys/pages/HomePage.dart';
import 'package:carsys/pages/LoginPage.dart';
import 'package:carsys/pages/ProfilePage.dart';
import 'package:carsys/pages/UserVehiclesPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StandartDrawer extends StatefulWidget {
  const StandartDrawer({super.key});

  @override
  State<StandartDrawer> createState() => _StandartDrawerState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _StandartDrawerState extends State<StandartDrawer> {

  User? _user;
  String _userName = "Usuário";

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
    setState(() {
      _userName = userDoc['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_user?.email ?? "user@email.com", style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text("Home"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
          ListTile(
            title: const Text("Meus veículos"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const UserVehiclesPage()),
              );
            },
          ),
          ListTile(
            title: const Text("Adicionar veículos"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddVehiclePage()),
              );
            },
          ),
          ListTile(
            title: const Text("Histórico de abastecimentos"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const FuelHistoryPage()),
              );
            },
          ),
          ListTile(
            title: const Text("Perfil"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            title: const Text("Logout"),
            onTap: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
