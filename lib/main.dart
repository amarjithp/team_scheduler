// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:team_scheduler/data/repositories/auth_repository.dart';
import 'package:team_scheduler/presentation/cubits/auth/auth_cubit.dart';
import 'package:team_scheduler/presentation/pages/onboarding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AFTER
    return RepositoryProvider(
      create: (context) => AuthRepository(), 
      child: MaterialApp(
        title: 'Team Scheduler',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
        home: BlocProvider(
          create: (context) => AuthCubit(context.read<AuthRepository>()),
          child: const OnboardingPage(),
        ),
      ),
    );
  }
}