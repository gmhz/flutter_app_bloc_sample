import 'package:flutter/material.dart';
import 'package:flutter_app_bloc_sample/blocs/movie_detail_bloc.dart';
import 'package:flutter_app_bloc_sample/blocs/movie_detail_bloc_provider.dart';
import 'package:flutter_app_bloc_sample/models/trailer_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetail extends StatefulWidget {
  final posterUrl;
  final description;
  final releaseDate;
  final String title;
  final double voteAverage;
  final int movieId;

  MovieDetail(this.posterUrl, this.description, this.releaseDate, this.title,
      this.voteAverage, this.movieId);

  @override
  MovieDetailState createState() => MovieDetailState(
      posterUrl, description, releaseDate, title, voteAverage, movieId);
}

class MovieDetailState extends State<MovieDetail> {
  final posterUrl;
  final description;
  final releaseDate;
  final String title;
  final double voteAverage;
  final int movieId;

  MovieDetailBloc bloc;

  MovieDetailState(this.posterUrl, this.description, this.releaseDate,
      this.title, this.voteAverage, this.movieId);

  @override
  void didChangeDependencies() {
    bloc = MovieDetailBlocProvider.of(context);
    bloc.fetchTrailersById(movieId);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  "https://image.tmdb.org/t/p/w500$posterUrl",
                  fit: BoxFit.cover,
                ),
              ),
            )
          ];
        },
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(margin: EdgeInsets.only(top: 5)),
                Text(
                  title,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 1, right: 1),
                    ),
                    Text(
                      "$voteAverage",
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                    ),
                    Text(
                      releaseDate,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                ),
                Text(
                  description,
                ),
                Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                ),
                Text(
                  "Trailer",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                ),
                StreamBuilder(
                  stream: bloc.movieTrailers,
                  builder:
                      (context, AsyncSnapshot<Future<TrailerModel>> snapshot) {
                    if (snapshot.hasData) {
                      return FutureBuilder(
                        future: snapshot.data,
                        builder: (context,
                            AsyncSnapshot<TrailerModel> itemSnapshot) {
                          if (itemSnapshot.hasData) {
                            if (itemSnapshot.data.results.length > 0)
                              return trailerLayout(itemSnapshot.data);
                            else
                              return noTrailerLayout();
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Widget noTrailerLayout() {
    return Center(
      child: Text("No trailer available"),
    );
  }

  Widget trailerLayout(TrailerModel data) {
    return Container(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: data.results
            .map((r) => trailerItem(data, data.results.indexOf(r)))
            .toList(),
      ),
    );
  }

  Widget trailerItem(TrailerModel data, int index) {
    var item = data.results[index];
    var url = "https://www.youtube.com/watch?v=${item.key}";
    if (item.site.toLowerCase() == "youtube") {
      var imgUrl = 'http://i3.ytimg.com/vi/${item.key}/hqdefault.jpg';
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        width: 260,
        child: Column(
          children: <Widget>[
            Stack(children: <Widget>[
              Image.network(
                imgUrl,
                height: 145,
                width: 260,
                fit: BoxFit.fitWidth,
              ),
              Positioned(
                width: 260,
                height: 145,
                child: InkWell(
                  onTap: () => _launchURL(url),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              )
            ]),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      );
    }
    return Container();
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
