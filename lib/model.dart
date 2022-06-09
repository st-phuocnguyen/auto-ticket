import 'dart:io';

class Model {
  final String text;
  final DateTime date;
  final File image;

  Model({required this.text, required this.date, required this.image});

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
        'date': date.toString(),
        'text': text,
      };
}
