import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTS Movies App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  MovieListScreenState createState() => MovieListScreenState();
}

class MovieListScreenState extends State<MovieListScreen> {
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<String> movieTitles = [];
  int currentPage = 1;
  bool isLoading = false;
  bool isSearchActive = false;

  @override
  void initState() {
    super.initState();
    loadMovies();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent == scrollController.offset) {
        loadMoreMovies();
      }
    });
  }

  Future<void> loadMovies() async {
    setState(() => isLoading = true);
    var movies = await fetchMovies(currentPage, isSearchActive ? searchController.text : '');
    setState(() {
      if (currentPage == 1) {
        movieTitles.clear();
      }
      movieTitles.addAll(movies);
      isLoading = false;
    });
  }

  Future<void> loadMoreMovies() async {
    if (!isLoading && !isSearchActive) {
      setState(() => currentPage++);
      await loadMovies();
    }
  }

  void handleSearch() {
    setState(() {
      isSearchActive = searchController.text.isNotEmpty;
      currentPage = 1;
    });
    loadMovies();
  }

  Future<List<String>> fetchMovies(int page, String query) async {
    var url = Uri.parse('https://yts.mx/api/v2/list_movies.json?page=$page&limit=50&query_term=$query');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var movies = data['data']['movies'] as List;
      return movies.map((movie) => movie['title'] as String).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YTS Movies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Movies',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: handleSearch,
                ),
              ),
              onSubmitted: (_) => handleSearch(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: movieTitles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(movieTitles[index]),
                );
              },
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
