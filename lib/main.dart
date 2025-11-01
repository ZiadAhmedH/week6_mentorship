import 'package:flutter/material.dart';
import 'package:week6_task/features/movies/presentation/view/movie_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MoviesView(),
    );
  }
}
