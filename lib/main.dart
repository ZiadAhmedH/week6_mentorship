import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:week6_task/core/config/sentry/sentry_service.dart';
import 'package:week6_task/core/theme/cubit/theme_state.dart';
import 'core/config/connectivity/connectivity_service.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/cubit/theme_cubit.dart';
import 'features/movies/presentation/view/movie_view.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();

  final sentryDsn = dotenv.env['SENTRY_DSN'];

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;
      options.tracesSampleRate = 0.01;
      options.profilesSampleRate = 0.01;
    },
    appRunner: () => runApp(
      SentryWidget(
        child: BlocProvider(
          create: (_) => di.sl<ThemeCubit>(),
          child: const MyApp(),
        ),
      ),
    ),
  );

  await SentryService().captureException(
    SentryException(
      type: 'AppStart',
      value: 'Application has started successfully',
    ),
  );

  // initialize connectivity AFTER runApp / plugin registration
  await di.sl<ConnectivityService>().initialize();
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
