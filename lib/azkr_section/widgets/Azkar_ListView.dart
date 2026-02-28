import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app_new/azkr_section/logic/azkar_cubit.dart';
import 'package:test_app_new/azkr_section/logic/azkar_state.dart';

class AzkarListView extends StatelessWidget {
  const AzkarListView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final category = args is String ? args : 'defaultCategory';

    return BlocBuilder<AzkarCubit, AzkarState>(
      builder: (context, state) {
        final cubit = context.read<AzkarCubit>();

        if (state is! AzkarLoaded || (state.category != category)) {
          cubit.loadAzkar(category);
        }

        if (state is AzkarInitial || state is AzkarLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AzkarError) {
          return Center(child: Text(state.message));
        }

        if (state is AzkarLoaded && state.azkarList.isEmpty) {
          return const Center(child: Text('لا توجد أذكار حالياً'));
        }

        if (state is AzkarLoaded) {
          final azkarList = state.azkarList;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: azkarList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final zekr = azkarList[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => cubit.decrease(index),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            zekr.content.isNotEmpty ? zekr.content : zekr.text,
                            style: const TextStyle(fontSize: 18, height: 1.6),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 20,
                          child: Text(
                            zekr.currentCount.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
