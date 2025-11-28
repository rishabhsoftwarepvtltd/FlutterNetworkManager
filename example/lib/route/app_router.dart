import 'package:example/profile/presentation/profile_page.dart';
import 'package:example/login/presentation/ui/login_page.dart';
import 'package:example/route/route_names.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
