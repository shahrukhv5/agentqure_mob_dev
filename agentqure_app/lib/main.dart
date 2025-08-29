import 'package:agentqure/views/SplashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/CartModel/cart_model.dart';
import 'models/UserModel/user_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(
          create:
              (context) => CartModel(
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 1000),
      builder: (_, child) {
        return MaterialApp(
          title: 'AQure',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}