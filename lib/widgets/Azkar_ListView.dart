import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/azkar_cubit.dart';
import '../models/azkar_model.dart';

class AzkarListView extends StatelessWidget {
  const AzkarListView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final category = args is String ? args : 'defaultCategory';

    return BlocBuilder<AzkarCubit, List<ZekrItem>>(
      builder: (context, state) {
        final cubit = context.read<AzkarCubit>();

        if (!cubit.isLoadedFor(category)) {
          cubit.loadAzkar(category);
        }
        if (cubit.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cubit.error != null) {
          return Center(child: Text(cubit.error!));
        }

        if (state.isEmpty) {
          return const Center(child: Text('لا توجد أذكار حالياً'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final zekr = state[index];
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
      },
    );
  }
}
