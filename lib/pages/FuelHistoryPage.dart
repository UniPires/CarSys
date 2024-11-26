import 'package:carsys/modules/StandartDrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FuelHistoryPage extends StatefulWidget {
  const FuelHistoryPage({Key? key}) : super(key: key);

  @override
  State<FuelHistoryPage> createState() => _FuelHistoryPageState();
}

class _FuelHistoryPageState extends State<FuelHistoryPage> {
  late Stream<QuerySnapshot> _historyStream;

  @override
  void initState() {
    super.initState();
    _historyStream = _fetchFuelHistory();
  }

  Stream<QuerySnapshot> _fetchFuelHistory() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('historico')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico de Combustível"),
      ),
      drawer: StandartDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _historyStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Erro ao carregar o histórico."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum registro encontrado."));
          }

          final history = snapshot.data!.docs;

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final record = history[index].data() as Map<String, dynamic>;
              return _buildFuelRecordCard(record);
            },
          );
        },
      ),
    );
  }

  Widget _buildFuelRecordCard(Map<String, dynamic> record) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${record['carName'] ?? 'Nome desconhecido'} (${record['carModel'] ?? 'Modelo desconhecido'})",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text("Ano: ${record['carYear'] ?? 'Desconhecido'}"),
            Text("Placa: ${record['carPlaca'] ?? 'Indisponível'}"),
            const Divider(),
            Text("Litros abastecidos: ${record['liters']?.toStringAsFixed(2) ?? '0.00'} L"),
            Text("Quilometragem: ${record['kilometrage'] ?? 0} km"),
            if (record['timestamp'] != null)
              Text(
                "Data: ${_formatTimestamp(record['timestamp'])}",
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
