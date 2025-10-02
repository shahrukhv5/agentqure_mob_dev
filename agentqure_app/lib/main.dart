import 'package:agentqure/services/ApiService/api_service.dart';
import 'package:agentqure/services/NotificationService/notification_service.dart';
import 'package:agentqure/utils/FormFieldUtils/form_field_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WelcomeScreen/welcome_screen.dart';
import 'models/CartModel/cart_model.dart';
import 'models/UserModel/user_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'views/PermissionsScreen/permissions_screen.dart';
import 'views/UserDashboard/HomeScreen/home_screen.dart';
import 'views/SignInAndSignUpScreens/LoginScreen/login_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final notificationService = NotificationService();
  await notificationService.initialize();
  await dotenv.load(fileName: ".env");
  ApiService().configureDio();
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
    _validateEnvironment();
  }

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
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink.toString());
      }
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
    if ((uri.scheme == "labapp" && uri.host == "invite") ||
        (uri.scheme.startsWith("http") && uri.pathSegments.contains("invite"))) {
      String? code = params["code"];
      if (code != null && code.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_referral_code', code);
        setState(() {
          _pendingReferralCode = code;
        });
        print("Referral code stored: $code");
      }
    }
  }

  Future<Widget> _getInitialScreen(UserModel userModel) async {
    print('Getting initial screen...');
    await userModel.initialize();
    final prefs = await SharedPreferences.getInstance();
    final hasShownPermissions = prefs.getBool('hasShownPermissions') ?? false;
    final hasShownWelcome = prefs.getBool('hasShownWelcome') ?? false;
    print('Initial state: isLoggedIn=${userModel.isLoggedIn}, hasShownPermissions=$hasShownPermissions, hasShownWelcome=$hasShownWelcome');

    if (userModel.isLoggedIn) {
      print('User is logged in, navigating to HomeScreen');
      return HomeScreen();
    } else if (!hasShownPermissions) {
      print('Permissions not shown, navigating to PermissionHandlerScreen');
      return PermissionHandlerScreen(
        nextScreen: WelcomeScreen(
          nextScreen: LoginScreen(pendingReferralCode: _pendingReferralCode),
          pendingReferralCode: _pendingReferralCode,
        ),
        pendingReferralCode: _pendingReferralCode,
      );
    } else if (!hasShownWelcome) {
      print('Welcome screen not shown, navigating to WelcomeScreen');
      return WelcomeScreen(
        nextScreen: LoginScreen(pendingReferralCode: _pendingReferralCode),
        pendingReferralCode: _pendingReferralCode,
      );
    } else {
      print('Navigating to LoginScreen');
      return LoginScreen(pendingReferralCode: _pendingReferralCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);

    return ScreenUtilInit(
      designSize: const Size(430, 1000),
      builder: (_, child) {
        return MaterialApp(
          title: 'AgentQure',
          theme: ThemeData(
            textSelectionTheme: FormFieldUtils.selectionTheme,
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: FutureBuilder<Widget>(
            future: _getInitialScreen(userModel),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                FlutterNativeSplash.remove();
              });

              if (snapshot.hasError) {
                print('Error in _getInitialScreen: ${snapshot.error}');
                return Scaffold(
                  body: Center(
                    child: Text('Error initializing app: ${snapshot.error}'),
                  ),
                );
              }

              return snapshot.data ?? Container();
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}