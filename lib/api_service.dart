import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchMovies(int page, [String query = '']) async {
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
