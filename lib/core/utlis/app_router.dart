import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/home_page/view/home_page.dart';
import 'package:chatoid/features/login/view/login.dart';
import 'package:chatoid/features/profile/view/profile.dart';
import 'package:chatoid/features/register/view/register.dart';
import 'package:chatoid/features/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kLoginView = '/loginView';
  static const kRegisterScreen = '/RegisterScreen';
  static const kSearchView = '/searchView';
  static const kHomePage = '/homePage';
  static const kProfile = '/profile';
  static final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: kLoginView, builder: (context, state) => const LoginView()),
    GoRoute(
        path: kRegisterScreen,
        builder: (context, state) => const RegisterScreen()),
    GoRoute(path: kHomePage, builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final userProfile = state.extra as UserData;
        return Profile(userProfile: userProfile);
      },
    ),
  ]);
}
