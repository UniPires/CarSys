import 'package:carsys/modules/StandartDrawer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _litersController = TextEditingController();
  final _kilometrageController = TextEditingController();
  final _averageController = TextEditingController();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showSnackBar('Usuário não autenticado!');
        return;
      }

      final carData = {
        'name': _nameController.text.trim(),
        'model': _modelController.text.trim(),
        'year': _yearController.text.trim(),
        'plate': _plateController.text.trim(),
        'liters': double.tryParse(_litersController.text) ?? 0.0,
        'kilometrage': int.tryParse(_kilometrageController.text) ?? 0,
        'average': double.tryParse(_averageController.text) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final carRef = await FirebaseFirestore.instance.collection('cars').add(carData);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('mycars')
          .doc(carRef.id)
          .set(carData);

      _showSnackBar('Veículo cadastrado com sucesso!');
      _clearForm();
    } catch (e) {
      _showSnackBar('Erro ao cadastrar o veículo: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearForm() {
    _nameController.clear();
    _modelController.clear();
    _yearController.clear();
    _plateController.clear();
    _litersController.clear();
    _kilometrageController.clear();
    _averageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Veículo'),
      ),
      drawer: const StandartDrawer(),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildTextField('Nome', _nameController, 'Informe o nome'),
                const SizedBox(height: 16),
                _buildTextField('Modelo', _modelController, 'Informe o modelo'),
                const SizedBox(height: 16),
                _buildTextField('Ano', _yearController, 'Informe o ano'),
                const SizedBox(height: 16),
                _buildTextField('Placa', _plateController, 'Informe a placa'),
                const SizedBox(height: 16),
                _buildTextField(
                  'Litros Iniciais',
                  _litersController,
                  'Informe os litros',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Quilometragem Inicial',
                  _kilometrageController,
                  'Informe a quilometragem',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Média Inicial',
                  _averageController,
                  'Informe a média',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Cadastrar'),
        icon: const Icon(Icons.add),
        onPressed: _submitForm,
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller,
      String validationMessage, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? validationMessage : null,
    );
  }
}
