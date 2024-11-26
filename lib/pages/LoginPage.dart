import 'package:carsys/pages/HomePage.dart';
import 'package:carsys/pages/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _hidePassword = true;

  final FirebaseAuth _authInstance = FirebaseAuth.instance;

  Future<void> _handleLogin() async {
    String email = _emailCtrl.text.trim();
    String password = _passwordCtrl.text.trim();

    try {
      await _authInstance.signInWithEmailAndPassword(email: email, password: password);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (error) {
      String errorMsg = '';
      switch (error.code) {
        case 'user-not-found':
          errorMsg = 'Usuário não encontrado.';
          break;
        case 'wrong-password':
          errorMsg = 'Senha incorreta.';
          break;
        default:
          errorMsg = 'Erro desconhecido: ${error.message}';
      }
      _displayErrorDialog(errorMsg);
    }
  }

  Future<void> _requestPasswordReset() async {
    String email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      _displayErrorDialog("Por favor, insira seu e-mail para recuperar a senha.");
      return;
    }

    try {
      await _authInstance.sendPasswordResetEmail(email: email);
      _displayInfoDialog("E-mail de recuperação enviado com sucesso!");
    } catch (e) {
      _displayErrorDialog("Falha ao enviar e-mail de recuperação: $e");
    }
  }

  void _displayErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _displayInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informação'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Carsys'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordCtrl,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                ),
              ),
              obscureText: _hidePassword,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _handleLogin,
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text(
                'Criar uma nova conta',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _requestPasswordReset,
              child: const Text(
                'Esqueceu sua senha?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
