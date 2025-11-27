import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _login() async {
    FocusScope.of(context).unfocus(); //cerrar teclado

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrese usuario y contraseña'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    //llamar al servicio de la api para login
    final result = await _apiService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      final username = result['data']['username'] ?? '';
      final email = result['data']['email'] ?? '';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(username: username, email: email)),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('No se pudo ingresar'),
          content: Text(result['error'] ?? 'Error desconocido'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Intentar de nuevo'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text("Bienvenido", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 40),
              
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person)
                ),
              ),
              SizedBox(height: 20),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key)
                ),
              ),
              SizedBox(height: 30),

              _isLoading 
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: Text("INGRESAR", style: TextStyle(color: Colors.white)),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}