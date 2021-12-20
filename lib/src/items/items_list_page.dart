import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';
import '../widgets/asciimoji_shrug.dart';
import 'items_cubit.dart';
import 'items_filter_cubit.dart';
import 'items_list_view.dart';

class ItemsListPage extends StatelessWidget {
  const ItemsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => ItemsCubit(context.read<MyDatabase>().itemsDao),
      child: BlocListener<ItemsFilterCubit, List<Category>>(
        listener: (context, categoryFilters) {
          context.read<ItemsCubit>().filter(categoryFilters);
        },
        child: BlocBuilder<ItemsCubit, List<ItemWithCategory>?>(
          builder: (context, itemsWithCategory) {
            if (itemsWithCategory == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (itemsWithCategory.isEmpty) {
              return BlocSelector<ItemsFilterCubit, List<Category>, bool>(
                selector: (categoryFilters) => categoryFilters.isNotEmpty,
                builder: (context, isFiltered) {
                  return Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      Center(
                        child: AsciimojiShrug(
                          label: isFiltered
                              ? localizations.itemsEmptyListFiltered
                              : localizations.itemsEmptyList,
                        ),
                      ),
                      if (isFiltered)
                        Positioned(
                          bottom: 128,
                          child: TextButton(
                            onPressed: context.read<ItemsFilterCubit>().clear,
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
            return ItemsListView(itemsWithCategory: itemsWithCategory);
          },
        ),
      ),
    );
  }
}
