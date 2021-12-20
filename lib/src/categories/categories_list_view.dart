import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';
import '../widgets/delete_background.dart';
import 'categories_cubit.dart';
import 'create_edit_category_page.dart';

class CategoriesListView extends StatelessWidget {
  const CategoriesListView({
    Key? key,
    required this.categories,
  }) : super(key: key);

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ListView.builder(
      restorationId: 'categoriesListView',
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories.elementAt(index);

        return Dismissible(
          key: ValueKey(category.id),
          background: const DeleteBackground(),
          child: ListTile(
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                CreateEditCategoryPage.routeName,
                arguments: category.id,
              );
            },
            title: Text(category.name),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final cubit = context.read<CategoriesCubit>();
              final result = await cubit.delete(category);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (result == null) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  action: SnackBarAction(
                    onPressed: () async {
                      final undoSuccessful = await cubit.undo(category);
                      if (!undoSuccessful) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(localizations.errorDeleteUndoFailure),
                        ));
                      }
                    },
                    label: localizations.undo,
                  ),
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messageCategoryDeleteSuccess),
                ));
                return true;
              }
              if (result == DatabaseException.foreignKeyConstraint) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messageCategoryDeleteProhibited),
                  duration: const Duration(seconds: 1),
                ));
              } else {
                scaffoldMessenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messageCategoryDeleteFailure),
                  duration: const Duration(seconds: 1),
                ));
              }
            }
            return false;
          },
          direction: DismissDirection.endToStart,
        );
      },
    );
  }
}
