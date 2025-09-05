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
// import 'package:agentqure/utils/FormFieldUtils/form_field_utils.dart';
// import 'package:agentqure/views/SignInAndSignUpScreens/InsertProfileScreen/insert_profile_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'models/CartModel/cart_model.dart';
// import 'models/UserModel/user_model.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'views/PermissionsScreen/permissions_screen.dart';
// import 'views/UserDashboard/HomeScreen/home_screen.dart';
// import 'views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
// import 'package:app_links/app_links.dart';
// void main() async {
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
// SystemChrome.setPreferredOrientations([
//   DeviceOrientation.portraitUp,
//   DeviceOrientation.portraitDown
// ]);
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => UserModel()),
//         ChangeNotifierProvider(
//           create: (context) => CartModel(
//             userModel: Provider.of<UserModel>(context, listen: false),
//           ),
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late AppLinks _appLinks;
//   String? _pendingReferralCode;
//
//   @override
//   void initState() {
//     super.initState();
//     _initAppLinks();
//   }
//
//   Future<void> _initAppLinks() async {
//     _appLinks = AppLinks();
//
//     try {
//       // Handle cold start (app opened from link)
//       final initialLink = await _appLinks.getInitialLink();
//       if (initialLink != null) {
//         _handleLink(initialLink.toString());
//       }
//
//       // Handle when app is already running
//       _appLinks.uriLinkStream.listen((Uri uri) {
//         _handleLink(uri.toString());
//       }, onError: (err) {
//         print("Error listening to app links: $err");
//       });
//     } catch (e) {
//       print("Error reading link: $e");
//     }
//   }
//
//   void _handleLink(String link) async {
//     Uri uri = Uri.parse(link);
//     final params = uri.queryParameters;
//
//     // Check if this is an invite link with a referral code
//     if ((uri.scheme == "labapp" && uri.host == "invite") ||
//         (uri.scheme.startsWith("http") && uri.pathSegments.contains("invite"))) {
//       String? code = params["code"];
//
//       if (code != null && code.isNotEmpty) {
//         // Store the referral code in SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('pending_referral_code', code);
//
//         setState(() {
//           _pendingReferralCode = code;
//         });
//
//         print("Referral code stored: $code");
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userModel = Provider.of<UserModel>(context, listen: false);
//
//     return ScreenUtilInit(
//       designSize: const Size(430, 1000),
//       builder: (_, child) {
//         return MaterialApp(
//           title: 'AQure',
//           theme: ThemeData(
//             textSelectionTheme: FormFieldUtils.selectionTheme,
//             primarySwatch: Colors.blue,
//             visualDensity: VisualDensity.adaptivePlatformDensity,
//           ),
//           home: FutureBuilder<bool>(
//             future: _initializeApp(userModel),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Container();
//               }
//
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 FlutterNativeSplash.remove();
//               });
//
//               if (snapshot.hasError) {
//                 return Scaffold(
//                   body: Center(
//                     child: Text('Error initializing app: ${snapshot.error}'),
//                   ),
//                 );
//               }
//
//               final isLoggedIn = snapshot.data ?? false;
//               if (isLoggedIn) {
//                 return HomeScreen();
//               } else {
//                 return PermissionHandlerScreen(
//                   nextScreen: LoginScreen(),
//                   // nextScreen: InsertProfileScreen(phoneNumber: '',),
//                   pendingReferralCode: _pendingReferralCode,
//                 );
//               }
//             },
//           ),
//           debugShowCheckedModeBanner: false,
//         );
//       },
//     );
//   }
//
//   Future<bool> _initializeApp(UserModel userModel) async {
//     final start = DateTime.now();
//     await userModel.initialize();
//
//     // Check for any pending referral code
//     final prefs = await SharedPreferences.getInstance();
//     final pendingCode = prefs.getString('pending_referral_code');
//     if (pendingCode != null) {
//       setState(() {
//         _pendingReferralCode = pendingCode;
//       });
//     }
//
//     final elapsed = DateTime.now().difference(start);
//     final remaining = const Duration(seconds: 3) - elapsed;
//     if (remaining > Duration.zero) {
//       await Future.delayed(remaining);
//     }
//     return userModel.isLoggedIn;
//   }
// }
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   Future<bool> _initializeApp(UserModel userModel) async {
//     final start = DateTime.now();
//     await userModel.initialize();
//     final elapsed = DateTime.now().difference(start);
//     final remaining = const Duration(seconds: 3) - elapsed;
//     if (remaining > Duration.zero) {
//       await Future.delayed(remaining);
//     }
//     return userModel.isLoggedIn;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final userModel = Provider.of<UserModel>(context, listen: false);
//
//     return ScreenUtilInit(
//       designSize: const Size(430, 1000),
//       builder: (_, child) {
//         return MaterialApp(
//           title: 'AQure',
//           theme: ThemeData(
//             primarySwatch: Colors.blue,
//             visualDensity: VisualDensity.adaptivePlatformDensity,
//           ),
//           home: FutureBuilder<bool>(
//             future: _initializeApp(userModel),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Container();
//               }
//
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 FlutterNativeSplash.remove();
//               });
//
//               if (snapshot.hasError) {
//                 return Scaffold(
//                   body: Center(
//                     child: Text('Error initializing app: ${snapshot.error}'),
//                   ),
//                 );
//               }
//
//               final isLoggedIn = snapshot.data ?? false;
//               if (isLoggedIn) {
//                 return HomeScreen();
//               } else {
//                 return PermissionHandlerScreen(nextScreen: LoginScreen());
//               }
//             },
//           ),
//           debugShowCheckedModeBanner: false,
//         );
//       },
//     );
//   }
// }
import 'package:agentqure/utils/FormFieldUtils/form_field_utils.dart';
import 'package:agentqure/views/SignInAndSignUpScreens/InsertProfileScreen/insert_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/CartModel/cart_model.dart';
import 'models/UserModel/user_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'views/PermissionsScreen/permissions_screen.dart';
import 'views/UserDashboard/HomeScreen/home_screen.dart';
import 'views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this import

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load environment variables before anything else
  await dotenv.load(fileName: ".env");

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  String? _pendingReferralCode;

  @override
  void initState() {
    super.initState();
    _initAppLinks();
    _validateEnvironment(); // Validate environment variables
  }

  // Validate that required environment variables are present
  void _validateEnvironment() {
    final requiredKeys = ['GOOGLE_MAPS_API_KEY', 'RAZORPAY_KEY'];

    for (final key in requiredKeys) {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        print('⚠️  WARNING: Missing environment variable: $key');
      }
    }
  }

  Future<void> _initAppLinks() async {
    _appLinks = AppLinks();

    try {
      // Handle cold start (app opened from link)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink.toString());
      }

      // Handle when app is already running
      _appLinks.uriLinkStream.listen((Uri uri) {
        _handleLink(uri.toString());
      }, onError: (err) {
        print("Error listening to app links: $err");
      });
    } catch (e) {
      print("Error reading link: $e");
    }
  }

  void _handleLink(String link) async {
    Uri uri = Uri.parse(link);
    final params = uri.queryParameters;

    // Check if this is an invite link with a referral code
    if ((uri.scheme == "labapp" && uri.host == "invite") ||
        (uri.scheme.startsWith("http") && uri.pathSegments.contains("invite"))) {
      String? code = params["code"];

      if (code != null && code.isNotEmpty) {
        // Store the referral code in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_referral_code', code);

        setState(() {
          _pendingReferralCode = code;
        });

        print("Referral code stored: $code");
      }
    }
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
            textSelectionTheme: FormFieldUtils.selectionTheme,
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
                return PermissionHandlerScreen(
                  nextScreen: LoginScreen(),
                  // nextScreen: InsertProfileScreen(phoneNumber: '',),
                  pendingReferralCode: _pendingReferralCode,
                );
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  Future<bool> _initializeApp(UserModel userModel) async {
    final start = DateTime.now();
    await userModel.initialize();

    // Check for any pending referral code
    final prefs = await SharedPreferences.getInstance();
    final pendingCode = prefs.getString('pending_referral_code');
    if (pendingCode != null) {
      setState(() {
        _pendingReferralCode = pendingCode;
      });
    }

    final elapsed = DateTime.now().difference(start);
    final remaining = const Duration(seconds: 3) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
    return userModel.isLoggedIn;
  }
}