import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:week6_task/core/service_locator.dart';

import '../cubit/movie_cubit.dart';
import '../widgets/movie_body_view.dart';

class MoviesView extends StatelessWidget {
  const MoviesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MovieCubit>()..loadInitial(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Popular Movies'), centerTitle: true),
        body: MovieBodyView(),
      ),
    );
  }
}
