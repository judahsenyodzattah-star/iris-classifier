import 'package:go_router/go_router.dart';
import '../features/screens.dart';

final appRouter = GoRouter(initialLocation: '/splash', routes: [
  GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
  GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen()),
  StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/home', builder: (context, state) => const HomeScreen())
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/classify',
              builder: (context, state) => const ClassificationScreen())
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen())
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen())
        ]),
      ]),
  GoRoute(
      path: '/species/:id',
      builder: (context, state) =>
          SpeciesDetailScreen(speciesId: state.pathParameters['id']!)),
  GoRoute(
      path: '/result',
      builder: (context, state) =>
          ResultScreen(payload: state.extra! as ResultPayload)),
  GoRoute(
      path: '/settings', builder: (context, state) => const SettingsScreen()),
]);
