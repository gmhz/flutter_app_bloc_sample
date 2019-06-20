import 'package:flutter_app_bloc_sample/models/item_model.dart';
import 'package:flutter_app_bloc_sample/models/trailer_model.dart';
import 'movie_api_provider.dart';

class MoviesRepository {
  final moviesApiProvider = MovieApiProvider();

  Future<ItemModel> fetchAllMovies() => moviesApiProvider.fetchMovieList();

  Future<TrailerModel> fetchTrailers(int movieId) => moviesApiProvider.fetchTrailers(movieId);
}