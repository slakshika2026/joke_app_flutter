import 'package:flutter/material.dart';
import 'services/joke_services.dart';
import 'models/jokes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Jokes App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      home: const JokesScreen(),
    );
  }
}

class JokesScreen extends StatefulWidget {
  const JokesScreen({super.key});

  @override
  State<JokesScreen> createState() => _JokesScreenState();
}

class _JokesScreenState extends State<JokesScreen> {
  final JokesService _jokesService = JokesService();
  List<Joke> _jokes = [];
  bool _isLoading = true;
  String _error = '';
  bool _isUsingCache = false;

  @override
  void initState() {
    super.initState();
    _initializeJokes();
  }

  Future<void> _initializeJokes() async {
    final cachedJokes = await _jokesService.getCachedJokes();
    if (cachedJokes.isNotEmpty) {
      setState(() {
        _jokes = cachedJokes;
        _isLoading = false;
        _isUsingCache = true;
      });
    }
    _loadJokes();
  }

  Future<void> _loadJokes() async {
    setState(() {
      _isLoading = _jokes.isEmpty;
      _error = '';
    });

    try {
      final jokes = await _jokesService.fetchJokes(forceRefresh: true);
      setState(() {
        _jokes = jokes;
        _isLoading = false;
        _isUsingCache = false;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isUsingCache = true;
        if (_jokes.isEmpty) {
          _error = 'No jokes available. Please check your connection.';
        } else {
          _error = 'Using cached jokes (offline mode)';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Fun facts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadJokes,
                  ),
                ],
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _jokes.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_jokes.isEmpty) {
      return Center(
        child: Text(
          _error,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jokes.length,
      itemBuilder: (context, index) {
        return JokeCard(joke: _jokes[index]);
      },
    );
  }
}

class JokeCard extends StatelessWidget {
  final Joke joke;

  const JokeCard({super.key, required this.joke});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              joke.setup,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              joke.punchline,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
