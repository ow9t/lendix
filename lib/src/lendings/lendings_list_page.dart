import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';
import '../widgets/asciimoji_shrug.dart';
import 'lendings_cubit.dart';
import 'lendings_filter_cubit/lendings_filter_cubit.dart';
import 'lendings_list_view.dart';

class LendingsListPage extends StatelessWidget {
  const LendingsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) =>
          LendingsCubit(context.read<MyDatabase>().lendingsDao),
      child: BlocListener<LendingsFilterCubit, LendingsFilterState>(
        listener: (context, filterState) {
          context.read<LendingsCubit>().filter(filterState);
        },
        child: BlocBuilder<LendingsCubit, List<LendingWithData>?>(
          builder: (context, lendingsWithData) {
            if (lendingsWithData == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (lendingsWithData.isEmpty) {
              return BlocSelector<LendingsFilterCubit, LendingsFilterState,
                  bool>(
                selector: (filterState) => filterState.isFiltered,
                builder: (context, isFiltered) {
                  return Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      Center(
                        child: AsciimojiShrug(
                          label: isFiltered
                              ? localizations.lendingsEmptyListFiltered
                              : localizations.lendingsEmptyList,
                        ),
                      ),
                      if (isFiltered)
                        Positioned(
                          bottom: 128,
                          child: TextButton(
                            onPressed:
                                context.read<LendingsFilterCubit>().clearAll,
                            child: Text(
                              localizations.clearFilters.toUpperCase(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            }
            return LendingsListView(lendingsWithData: lendingsWithData);
          },
        ),
      ),
    );
  }
}
