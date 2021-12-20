import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lendix/src/database/database.dart';

import '../widgets/delete_background.dart';
import 'create_edit_item_page.dart';
import 'items_cubit.dart';

class ItemsListView extends StatelessWidget {
  const ItemsListView({
    Key? key,
    required this.itemsWithCategory,
  }) : super(key: key);

  final List<ItemWithCategory> itemsWithCategory;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ListView.builder(
      restorationId: 'itemsListView',
      itemCount: itemsWithCategory.length,
      itemBuilder: (context, index) {
        final itemWithCategory = itemsWithCategory.elementAt(index);

        return Dismissible(
          key: ValueKey(itemWithCategory.item.id),
          background: const DeleteBackground(),
          child: ListTile(
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                CreateEditItemPage.routeName,
                arguments: itemWithCategory.item.id,
              );
            },
            subtitle: itemWithCategory.category == null
                ? Text(AppLocalizations.of(context)!.categoryNone)
                : Text(itemWithCategory.category!.name),
            title: Text(itemWithCategory.item.name),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final cubit = context.read<ItemsCubit>();
              final result = await cubit.delete(itemWithCategory);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (result == null) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  action: SnackBarAction(
                    onPressed: () async {
                      final undoSuccessful = await cubit.undo(itemWithCategory);
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
                  content: Text(localizations.messageItemDeleteSuccess),
                ));
                return true;
              }
              if (result == DatabaseException.foreignKeyConstraint) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messageItemDeleteProhibited),
                  duration: const Duration(seconds: 1),
                ));
              } else {
                scaffoldMessenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messageItemDeleteFailure),
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
