import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/tempo_repository.dart';
import 'features/layout/app_shell.dart';
import 'features/library/cubit/library_cubit.dart';
import 'features/player/cubit/player_cubit.dart';

class TempoApp extends StatelessWidget {
  const TempoApp({super.key, required this.repository});

  final TempoRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PlayerCubit(repository)),
        BlocProvider(create: (_) => LibraryCubit(repository)),
      ],
      child: MaterialApp(
        title: 'Tempo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const AppShell(),
      ),
    );
  }
}
