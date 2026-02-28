import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/azkr_section/data/Azkar_API.dart';
import 'package:test_app_new/azkr_section/logic/azkar_cubit.dart';
import 'package:test_app_new/azkr_section/widgets/Azkar_ListView.dart';

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
