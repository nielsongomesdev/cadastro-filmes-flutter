import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/movie.dart';
import '../helpers/database_helper.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie;

  const MovieFormScreen({super.key, this.movie});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _urlImageController = TextEditingController();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _durationController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedAgeRating = 'Livre';
  double _currentScore = 3.0;

  final List<String> _ageRatings = ['Livre', '10', '12', '14', '16', '18'];

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _urlImageController.text = widget.movie!.urlImage;
      _titleController.text = widget.movie!.title;
      _genreController.text = widget.movie!.genre;
      _durationController.text = widget.movie!.duration;
      _yearController.text = widget.movie!.year.toString();
      _descriptionController.text = widget.movie!.description;
      _selectedAgeRating = widget.movie!.ageRating;
      _currentScore = widget.movie!.score;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Cadastrar Filme' : 'Alterar Filme'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _urlImageController,
                decoration: const InputDecoration(labelText: 'Url Imagem'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Gênero'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Faixa Etária: ', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedAgeRating,
                    items: _ageRatings.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedAgeRating = newValue!;
                      });
                    },
                  ),
                ],
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duração'),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 10),
              const Text('Nota:'),
              RatingBar.builder(
                initialRating: _currentScore,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _currentScore = rating;
                  });
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _saveMovie,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }

  void _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      final movie = Movie(
        id: widget.movie?.id,
        urlImage: _urlImageController.text,
        title: _titleController.text,
        genre: _genreController.text,
        ageRating: _selectedAgeRating,
        duration: _durationController.text,
        score: _currentScore,
        description: _descriptionController.text,
        year: int.parse(_yearController.text),
      );

      if (widget.movie == null) {
        await DatabaseHelper.instance.create(movie);
      } else {
        await DatabaseHelper.instance.update(movie);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}