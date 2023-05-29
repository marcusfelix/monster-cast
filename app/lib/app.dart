import 'package:app/controllers/app_controller.dart';
import 'package:app/includes/hex_color.dart';
import 'package:app/views/auth.dart';
import 'package:app/views/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatelessWidget {
  const App({
    super.key
  });

  // Setting up theme
  ThemeData theme(Map<String, dynamic> configs) {
    ThemeData data = ThemeData.from(
      textTheme: GoogleFonts.interTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: HexColor(configs["seed_color"]),
      ),
    );

    return data.copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: data.colorScheme.onPrimary
        ),
        iconTheme: IconThemeData(
          color: data.colorScheme.onPrimary
        ),
        elevation: 0
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder()
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: data.colorScheme.tertiaryContainer,
        foregroundColor: data.colorScheme.onTertiaryContainer,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
      ),
    );
  } 

  @override
  Widget build(BuildContext context) {    
    final controller = AppContext.of(context).controller;

    return ValueListenableBuilder(
      valueListenable: controller.configs,
      builder: (context, configs, _) {
        return MaterialApp(
          title: configs["app_name_string"],
          debugShowCheckedModeBanner: false,
          theme: theme(configs),
          home: ValueListenableBuilder(
            valueListenable: controller.user,
            builder: (context, user, _) {
              // Determine if check for user auth based on config
              if(configs["require_auth_bool"]){
                if(user != null){
                  return Home(
                    user: user,
                  );
                } else {
                  return Auth();
                }
              } else {
                return Home(
                  user: user,
                );
              }
            }
          ),
        );
      }
    );
  }

}