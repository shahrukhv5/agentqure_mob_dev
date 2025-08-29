// import 'package:agentqure/views/SplashScreen/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'models/CartModel/cart_model.dart';
// import 'models/UserModel/user_model.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => UserModel()),
//         ChangeNotifierProvider(
//           create:
//               (context) => CartModel(
//             userModel: Provider.of<UserModel>(context, listen: false),
//           ),
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(430, 1000),
//       builder: (_, child) {
//         return MaterialApp(
//           title: 'AQure',
//           theme: ThemeData(
//             primarySwatch: Colors.blue,
//             visualDensity: VisualDensity.adaptivePlatformDensity,
//           ),
//           home: SplashScreen(),
//           debugShowCheckedModeBanner: false,
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'models/CartModel/cart_model.dart';
import 'models/UserModel/user_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'views/PermissionsScreen/permissions_screen.dart';
import 'views/UserDashboard/HomeScreen/home_screen.dart';
import 'views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(
          create: (context) => CartModel(
            userModel: Provider.of<UserModel>(context, listen: false),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _initializeApp(UserModel userModel) async {
    final start = DateTime.now();
    await userModel.initialize();
    final elapsed = DateTime.now().difference(start);
    final remaining = const Duration(seconds: 3) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    return userModel.isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);

    return ScreenUtilInit(
      designSize: const Size(430, 1000),
      builder: (_, child) {
        return MaterialApp(
          title: 'AQure',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: FutureBuilder<bool>(
            future: _initializeApp(userModel),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                FlutterNativeSplash.remove();
              });

              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error initializing app: ${snapshot.error}'),
                  ),
                );
              }

              final isLoggedIn = snapshot.data ?? false;
              if (isLoggedIn) {
                return HomeScreen();
              } else {
                return PermissionHandlerScreen(nextScreen: LoginScreen());
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}