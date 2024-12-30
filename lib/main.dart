import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon & Dog Finder ',
      theme: ThemeData(primarySwatch: Colors.red),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pokémon & Dog Finder'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.catching_pokemon), text: 'Pokémon'),
              Tab(icon: Icon(Icons.pets), text: 'Perros'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PokemonSearchScreen(),
            DogImageScreen(),
          ],
        ),
      ),
    );
  }
}

class PokemonSearchScreen extends StatefulWidget {
  const PokemonSearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PokemonSearchScreenState createState() => _PokemonSearchScreenState();
}

class _PokemonSearchScreenState extends State<PokemonSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? pokemonData;
  bool isLoading = false;

  Future<void> fetchPokemon(String name) async {
    setState(() {
      isLoading = true;
      pokemonData = null;
    });

    try {
      final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'));
      if (response.statusCode == 200) {
        setState(() {
          pokemonData = json.decode(response.body);
        });
      } else {
        setState(() {
          pokemonData = null;
        });
      }
    } catch (e) {
      setState(() {
        pokemonData = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRandomPokemon() async {
    final random = Random();
    final randomId = random.nextInt(898) + 1;  // Total Pokémon in the PokeAPI
    fetchPokemon(randomId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Pokémon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre del Pokémon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ejemplo: pikachu',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) fetchPokemon(value.toLowerCase());
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : pokemonData != null
                    ? PokemonCard(data: pokemonData!)
                    : Center(child: Text('No se encontró el Pokémon')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchRandomPokemon,
        child: Icon(Icons.catching_pokemon),
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const PokemonCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['name'].toString().toUpperCase(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Image.network(
              data['sprites']['front_default'],
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
            Text('Peso: ${data['weight']}'),
            Text('Altura: ${data['height']}'),
          ],
        ),
      ),
    );
  }
}

class DogImageScreen extends StatefulWidget {
  const DogImageScreen({super.key});

  @override
  DogImageScreenState createState() => DogImageScreenState();
}

class DogImageScreenState extends State<DogImageScreen> {
  String? dogImageUrl;
  bool isLoading = false;

  Future<void> fetchDogImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          dogImageUrl = data['message'];
        });
      } else {
        setState(() {
          dogImageUrl = null;
        });
      }
    } catch (e) {
      log('Error al obtener la imagen de perro: $e');
      setState(() {
        dogImageUrl = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : dogImageUrl != null
                  ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            dogImageUrl!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      'Presiona el botón para cargar una imagen',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchDogImage,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
