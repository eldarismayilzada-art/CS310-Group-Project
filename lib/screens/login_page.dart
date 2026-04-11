import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Loginscreen()));

class Loginscreen extends StatelessWidget {
  const Loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Defining the custom color for "HUB"
    const Color hubColor = Color(0xFF6A11CB); // A nice purple-blue

    return Scaffold(
      appBar: AppBar(title: const Text('Log in Page')),
      body: Center(
              
          child: 
            
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "CLUB",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 50),
                  ),
                  const Text(
                    "HUB",
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: hubColor, 
                      fontSize: 50,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Username',
                    icon: Icon(Icons.person),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Password',
                    icon: Icon(Icons.lock),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              GestureDetector( //CHATGPT Helped with THIS
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue,
                        Color(0xFF6A11CB), // Purple-blue
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16, //somce its UI implentation i wont be doing the backend and checking if password is right or not
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        
      ),
    );
  }
}