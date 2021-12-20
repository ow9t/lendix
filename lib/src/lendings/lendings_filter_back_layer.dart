import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../categories/categories_cubit.dart';
import '../database/database.dart';
import '../people/people_cubit.dart';
import '../widgets/choice_filter_chip_list.dart';
import '../widgets/entity_filter_chip_list.dart';
import 'lendings_filter_cubit/lendings_filter_cubit.dart';

class LendingsFilterBackLayer extends StatelessWidget {
  const LendingsFilterBackLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = context.read<MyDatabase>();
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CategoriesCubit(database.categoriesDao),
        ),
        BlocProvider(
          create: (context) => PeopleCubit(database.peopleDao),
        ),
      ],
      child: BlocBuilder<LendingsFilterCubit, LendingsFilterState>(
        builder: (context, filterState) {
          final cubit = context.read<LendingsFilterCubit>();
          return ListView(
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return theme.primaryTextTheme.button!.color!
                                .withOpacity(0.38);
                          }
                          return theme.colorScheme.secondary;
                        }),
                      ),
                      onPressed: filterState.isFiltered
                          ? () {
                              cubit.clearAll();
                              Backdrop.of(context).fling();
                            }
                          : null,
                      child: Text(localizations.clearAll.toUpperCase()),
                    ),
                  ),
                ],
              ),
              ChoiceFilterChipList<LendingsStatus>(
                choiceLabelAccessor: (choice) {
                  switch (choice) {
                    case LendingsStatus.all:
                      return localizations.all.toUpperCase();
                    case LendingsStatus.returned:
                      return localizations.lendingReturned.toUpperCase();
                    case LendingsStatus.notReturned:
                      return localizations.lendingNotReturned.toUpperCase();
                  }
                },
                choices: LendingsStatus.values,
                label: localizations.filterByStatus,
                onSelectedItem: cubit.selectStatus,
                value: filterState.status,
              ),
              ChoiceFilterChipList<LendingsType>(
                choiceLabelAccessor: (choice) {
                  switch (choice) {
                    case LendingsType.all:
                      return localizations.all.toUpperCase();
                    case LendingsType.lent:
                      return localizations.lendingLent.toUpperCase();
                    case LendingsType.borrowed:
                      return localizations.lendingBorrowed.toUpperCase();
                  }
                },
                choices: LendingsType.values,
                label: localizations.filterByBorrowed,
                onSelectedItem: cubit.selectType,
                value: filterState.type,
              ),
              BlocBuilder<CategoriesCubit, List<Category>?>(
                builder: (context, maybeCategories) {
                  final categories = maybeCategories ?? const [];
                  return EntityFilterChipList<Category>(
                    emptyText: localizations.categoriesEmptyList,
                    entities: categories,
                    label: localizations.filterByCategory,
                    entityLabelAccessor: (category) => category.name,
                    onClear: filterState.categoriesFiltered
                        ? cubit.clearCategories
                        : null,
                    onSelectedItem: cubit.selectCategory,
                    entitiesSelected: filterState.categories,
                  );
                },
              ),
              BlocBuilder<PeopleCubit, List<Person>?>(
                builder: (context, maybePeople) {
                  final people = maybePeople ?? const [];
                  return EntityFilterChipList<Person>(
                    emptyText: localizations.peopleEmptyList,
                    entities: people,
                    label: localizations.filterByPerson,
                    entityLabelAccessor: (person) => person.name,
                    onClear:
                        filterState.peopleFiltered ? cubit.clearPeople : null,
                    onSelectedItem: cubit.selectPerson,
                    entitiesSelected: filterState.people,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
