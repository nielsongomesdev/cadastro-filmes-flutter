class Movie {
  int? id;
  String urlImage;
  String title;
  String genre;
  String ageRating;
  String duration;
  double score;
  String description;
  int year;

  Movie({
    this.id,
    required this.urlImage,
    required this.title,
    required this.genre,
    required this.ageRating,
    required this.duration,
    required this.score,
    required this.description,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'urlImage': urlImage,
      'title': title,
      'genre': genre,
      'ageRating': ageRating,
      'duration': duration,
      'score': score,
      'description': description,
      'year': year,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      urlImage: map['urlImage'],
      title: map['title'],
      genre: map['genre'],
      ageRating: map['ageRating'],
      duration: map['duration'],
      score: map['score'],
      description: map['description'],
      year: map['year'],
    );
  }
}