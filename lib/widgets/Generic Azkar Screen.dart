import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/azkar_cubit.dart';
import '../Api/Azkar_API.dart';
import '../widgets/azkar_listview.dart';

class AzkarScreen extends StatelessWidget {
  final String title;
  final String category;

  const AzkarScreen({super.key, required this.title, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AzkarCubit(AzkarApi())..loadAzkar(category),
      child: Scaffold(
        appBar: AppBar(title: Text(title), centerTitle: true),
        body: AzkarListView(),
      ),
    );
  }
}
