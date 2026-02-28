// import 'package:flutter/material.dart';
// import 'package:hive_flutter/adapters.dart';

// class FavoritesScreen extends StatelessWidget {
//   const FavoritesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final box = Hive.box('favoritesBox');

//     return Scaffold(
//       appBar: AppBar(title: const Text("المفضلة"), centerTitle: true),
//       body: ValueListenableBuilder(
//         valueListenable: box.listenable(),
//         builder: (context, Box box, _) {
//           if (box.isEmpty) {
//             return const Center(child: Text("لا يوجد آيات مفضلة"));
//           }

//           return ListView.builder(
//             itemCount: box.length,
//             itemBuilder: (context, index) {
//               final key = box.keyAt(index);
//               final ayah = box.get(key);

//               return Dismissible(
//                 key: Key(key.toString()),
//                 direction: DismissDirection.endToStart,
//                 background: Container(
//                   alignment: Alignment.centerRight,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   color: Colors.red,
//                   child: const Icon(Icons.delete, color: Colors.white),
//                 ),
//                 onDismissed: (direction) {
//                   box.delete(key);

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("تم حذف الآية من المفضلة")),
//                   );
//                 },
//                 child: Card(
//                   margin: const EdgeInsets.all(12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Text(
//                       "${ayah['text']} ﴿${ayah['ayahNumber']}﴾",
//                       textAlign: TextAlign.right,
//                       textDirection: TextDirection.rtl,
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
