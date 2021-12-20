import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../categories/categories_cubit.dart';
import '../database/database.dart';
import '../widgets/entity_filter_chip_list.dart';
import 'items_filter_cubit.dart';

class ItemsFilterBackLayer extends StatelessWidget {
  const ItemsFilterBackLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CategoriesCubit(
        context.read<MyDatabase>().categoriesDao,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          BlocBuilder<CategoriesCubit, List<Category>?>(
            builder: (context, maybeCategories) {
              final categories = maybeCategories ?? const [];
              return BlocBuilder<ItemsFilterCubit, List<Category>>(
                builder: (context, selectedCategories) {
                  final cubit = context.read<ItemsFilterCubit>();
                  return EntityFilterChipList<Category>(
                    emptyText: localizations.categoriesEmptyList,
                    entities: categories,
                    entitiesSelected: selectedCategories,
                    entityLabelAccessor: (category) => category.name,
                    label: localizations.filterByCategory,
                    onClear: selectedCategories.isEmpty
                        ? null
                        : () {
                            cubit.clear();
                            Backdrop.of(context).fling();
                          },
                    onSelectedItem: cubit.select,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
