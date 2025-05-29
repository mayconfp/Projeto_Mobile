import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = '';
  String password = '';

  bool _senhaVisivel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/imagens/bg.jpeg', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(width: 1.5, color: Colors.white70),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (text) => email = text,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 254, 250, 255),
                          fontSize: 20,
                        ),
                        suffixIcon: Icon(
                          Icons.email_outlined,
                          color: const Color.fromARGB(227, 239, 239, 239),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),

                    SizedBox(height: 50),
                    TextField(
                      onChanged: (text) => password = text,
                      obscureText: !_senhaVisivel,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: const Color.fromARGB(255, 240, 238, 240),
                          fontSize: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _senhaVisivel = !_senhaVisivel;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.pinkAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          final url = Uri.parse(
                            'https://ef9d-2804-5dc-315-d900-b56a-da70-e0f3-6e07.ngrok-free.app/authenticate',
                          ); // ou localhost/teste no navegador
                          final response = await http.post(
                            url,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'email': email,
                              'password': password,
                            }),
                          );

                          if (response.statusCode == 200) {
                            final body = jsonDecode(response.body);
                            final token = body['token'];

                            // Salvar token localmente
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('jwt_token', token);

                            // Redirecionar
                            Navigator.of(context).pushReplacementNamed('/home');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Login inválido')),
                            );
                          }
                        },

                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cadastro');
                      },
                      child: Text("Não possui conta? Cadastre-se"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
