// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:test_app/Api/Azkar_API.dart';
// import 'package:test_app/cubit/azkar_cubit.dart';
// import 'package:test_app/models/azkar_model.dart';
// import 'package:test_app/widgets/Azkar_ListView.dart';

// class AzkarElsabahScreen extends StatelessWidget {
//   final String title;
//   AzkarElsabahScreen({super.key, required this.title});
//   final List<ZekrItem> azkar = [
//     ZekrItem(text: '  ', content: '', count: 1, description: ''),
//     ZekrItem(text: '   ', content: '', count: 3, description: ''),
//     ZekrItem(text: '  ', content: '', count: 3, description: ''),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) {
//         final cubit = AzkarCubit(AzkarApi());
//         cubit.loadAzkar('أذكار الصباح');
//         return cubit;
//       },
//       child: Scaffold(
//         appBar: AppBar(title: Text(title), centerTitle: true),
//         body: AzkarListView(),
//       ),
//     );
//   }
// }
