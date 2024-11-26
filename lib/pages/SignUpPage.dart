import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  bool _isPasswordHidden = true;

  final FirebaseAuth _authInstance = FirebaseAuth.instance;
  final FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;

  Future<void> _registerUser() async {
    String email = _emailCtrl.text.trim();
    String password = _passwordCtrl.text.trim();
    String name = _nameCtrl.text.trim();

    try {
      UserCredential credentials = await _authInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credentials.user;
      if (user != null) {
        await _firestoreInstance.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
        });
      }

      _showDialog('Cadastro bem-sucedido!', 'Sua conta foi criada com sucesso.');
    } on FirebaseAuthException catch (error) {
      String errorMessage = '';
      switch (error.code) {
        case 'weak-password':
          errorMessage = 'A senha fornecida é muito fraca.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Este e-mail já está em uso.';
          break;
        default:
          errorMessage = 'Erro desconhecido: ${error.message}';
      }
      _showDialog('Erro', errorMessage);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (title == 'Cadastro bem-sucedido!') {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nome do Usuário
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordHidden = !_isPasswordHidden;
                    });
                  },
                ),
              ),
              obscureText: _isPasswordHidden,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
