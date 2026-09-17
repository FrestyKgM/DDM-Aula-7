import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Treino de Tabuada',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TabuadaPage(),
    );
  }
}

class TabuadaPage extends StatefulWidget {
  const TabuadaPage({super.key});

  @override
  State<TabuadaPage> createState() => _TabuadaPageState();
}

class _TabuadaPageState extends State<TabuadaPage> {
  final TextEditingController controller = TextEditingController();

  int numero1 = 0;
  int numero2 = 0;
  int respostaCorreta = 0;
  int acertos = 0;

  bool? respostaCerta;

  @override
  void initState() {
    super.initState();
    novaOperacao();
  }

  void novaOperacao() {
    final random = Random();

    setState(() {
      numero1 = random.nextInt(10) + 1;
      numero2 = random.nextInt(10) + 1;

      respostaCorreta = numero1 * numero2;

      controller.clear();
      respostaCerta = null;
    });
  }

  void verificarResposta(String valor) {
    if (valor.isEmpty) {
      setState(() {
        respostaCerta = null;
      });
      return;
    }

    final respostaUsuario = int.tryParse(valor);

    setState(() {
      respostaCerta = respostaUsuario == respostaCorreta;
    });
  }

  void finalizarResposta() {
    if (respostaCerta == true) {
      setState(() {
        acertos++;
      });

      novaOperacao();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino de Tabuada'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Resolva a multiplicação',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                '$numero1 × $numero2 = ?',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Resposta',
                  ),
                  onChanged: verificarResposta,
                  onSubmitted: (_) {
                    finalizarResposta();
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (respostaCerta == true)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              if (respostaCerta == false)
                const Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 60,
                ),
              const SizedBox(height: 20),
              Text(
                'Acertos: $acertos',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: novaOperacao,
                child: const Text('Nova operação'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
