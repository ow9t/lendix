import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';
import '../widgets/asciimoji_shrug.dart';
import 'categories_cubit.dart';
import 'categories_list_view.dart';

class CategoriesListPage extends StatelessWidget {
  const CategoriesListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) =>
          CategoriesCubit(context.read<MyDatabase>().categoriesDao),
      child: BlocBuilder<CategoriesCubit, List<Category>?>(
        builder: (context, state) {
          if (state == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isEmpty) {
            return Center(
              child: AsciimojiShrug(label: localizations.categoriesEmptyList),
            );
          }
          return CategoriesListView(categories: state);
        },
      ),
    );
  }
}
