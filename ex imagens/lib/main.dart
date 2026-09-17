import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Imagens da Wikipedia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> imagens = [];
  int imagemAtual = 0;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    buscarImagens();
  }

  Future<void> buscarImagens() async {
    setState(() {
      carregando = true;
    });

    final url = Uri.parse(
      'https://pt.wikipedia.org/w/api.php'
      '?action=query'
      '&generator=random'
      '&grnnamespace=0'
      '&grnlimit=10'
      '&prop=pageimages'
      '&piprop=thumbnail'
      '&pithumbsize=400'
      '&format=json'
      '&origin=*',
    );

    try {
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);

        final paginas = dados['query']['pages'];

        List<Map<String, dynamic>> lista = [];

        for (var pagina in paginas.values) {
          if (pagina['thumbnail'] != null) {
            lista.add({
              'titulo': pagina['title'],
              'imagem': pagina['thumbnail']['source'],
              'gostei': false,
            });
          }

          if (lista.length == 5) {
            break;
          }
        }

        setState(() {
          imagens = lista;
          imagemAtual = 0;
          carregando = false;
        });
      } else {
        throw Exception('Erro ao buscar imagens');
      }
    } catch (erro) {
      setState(() {
        carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar as imagens.'),
        ),
      );
    }
  }

  void proximaImagem() {
    if (imagemAtual < imagens.length - 1) {
      setState(() {
        imagemAtual++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você chegou à última imagem.'),
        ),
      );
    }
  }

  void marcarGostei() {
    setState(() {
      imagens[imagemAtual]['gostei'] = !imagens[imagemAtual]['gostei'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imagens da Wikipedia'),
        centerTitle: true,
      ),
      body: Center(
        child: carregando
            ? const CircularProgressIndicator()
            : imagens.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nenhuma imagem encontrada.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: buscarImagens,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Imagem ${imagemAtual + 1} de ${imagens.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.network(
                          imagens[imagemAtual]['imagem'],
                          width: 200,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              size: 80,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: Text(
                          imagens[imagemAtual]['titulo'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: marcarGostei,
                            icon: Icon(
                              imagens[imagemAtual]['gostei']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            label: Text(
                              imagens[imagemAtual]['gostei']
                                  ? 'Gostei'
                                  : 'Marcar como gostei',
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: proximaImagem,
                            child: const Text('Próxima'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Imagens marcadas: ${imagens.where((imagem) => imagem['gostei']).length}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
