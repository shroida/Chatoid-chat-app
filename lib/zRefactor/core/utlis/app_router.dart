import 'package:chatoid/presntation/screens/HomePageScreens/Home_Page.dart';
import 'package:chatoid/zRefactor/features/register/view/register.dart';
import 'package:chatoid/zRefactor/features/login/view/login.dart';
import 'package:chatoid/zRefactor/features/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const kLoginView = '/loginView';
  static const kRegisterScreen = '/RegisterScreen';
  static const kSearchView = '/searchView';
  static const kHomePage = '/homePage';
  static final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: kLoginView, builder: (context, state) => const LoginView()),
    GoRoute(path: kRegisterScreen, builder: (context, state) => const RegisterScreen()),
    GoRoute(path: kHomePage, builder: (context, state) => const HomePage()),
  ]);
}
