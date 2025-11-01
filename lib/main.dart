import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:week6_task/core/theme/cubit/theme_state.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/cubit/theme_cubit.dart';
import 'features/movies/presentation/view/movie_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();
  runApp(
    BlocProvider(create: (_) => di.sl<ThemeCubit>(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeState.themeData,
          home: const MoviesView(),
        );
      },
    );
  }
}
