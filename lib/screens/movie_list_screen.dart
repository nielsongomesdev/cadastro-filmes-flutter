import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../helpers/database_helper.dart';
import '../models/movie.dart';
import 'movie_form_screen.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> movies;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshMovies();
  }

  Future refreshMovies() async {
    setState(() => isLoading = true);
    movies = DatabaseHelper.instance.readAllMovies();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filmes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showGroupAlert,
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: movies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return const Center(child: Text('Erro ao carregar filmes'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return const Center(child: Text('Nenhum filme cadastrado.'));
          }

          final moviesData = snapshot.data!;

          return ListView.builder(
            itemCount: moviesData.length,
            itemBuilder: (context, index) {
              final movie = moviesData[index];
              return _buildMovieItem(movie);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const MovieFormScreen()),
          );
          if (mounted) {
             refreshMovies();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMovieItem(Movie movie) {
    return Dismissible(
      key: Key(movie.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
         return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Tem certeza?'),
            content: const Text('Quer mesmo apagar este filme?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Não'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sim'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await DatabaseHelper.instance.delete(movie.id!);
        refreshMovies();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filme deletado!'))
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Image.network(
              movie.urlImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
            ),
          ),
          title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('${movie.genre} • ${movie.duration}'),
               RatingBarIndicator(
                 rating: movie.score,
                 itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                 itemCount: 5,
                 itemSize: 20.0,
                 direction: Axis.horizontal,
               ),
            ],
          ),
          onTap: () {
             _showOptionsDialog(context, movie);
          },
        ),
      ),
    );
  }

  void _showGroupAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Equipe:'),
        // Nomes da equipe atualizados:
        content: const Text('Nielson\nAnderson\nDavi'), 
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context, Movie movie) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Opções'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Exibir Dados'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie)),
                  );
                },
              ),
              ListTile(
                 leading: const Icon(Icons.edit),
                title: const Text('Alterar'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MovieFormScreen(movie: movie)),
                  );
                  if (mounted) {
                      refreshMovies();
                  }
                },
              ),
            ],
          ),
        ),
      );
  }
}