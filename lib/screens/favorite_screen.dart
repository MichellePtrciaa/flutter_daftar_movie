import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_daftar_movie/models/movie.dart';
import 'package:flutter_daftar_movie/screens/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});
  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Movie> _favoriteMovies = [];

  Future<void> _loadFavoriteMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favoriteMovies') ?? [];
    final list = <Movie>[];
    for (final id in ids) {
      final jsonString = prefs.getString('movie_$id');
      if (jsonString != null && jsonString.isNotEmpty) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        list.add(Movie.fromJson(data));
      }
    }
    setState(() => _favoriteMovies = list);
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Movies')),
      body: _favoriteMovies.isEmpty
          ? const Center(
              child: Text(
                'No favorite movie',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = _favoriteMovies[index];
                return ListTile(
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    movie.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(movie: movie),
                      ),
                    );
                    await _loadFavoriteMovies();
                  },
                );
              },
            ),
    );
  }

  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }
}
