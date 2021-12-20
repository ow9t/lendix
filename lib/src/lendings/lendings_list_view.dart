import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lendix/src/database/database.dart';

import '../widgets/delete_background.dart';
import 'create_edit_lending_page.dart';
import 'lending_list_tile.dart';
import 'lendings_cubit.dart';

class LendingsListView extends StatelessWidget {
  const LendingsListView({
    Key? key,
    required this.lendingsWithData,
  }) : super(key: key);

  final List<LendingWithData> lendingsWithData;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ListView.builder(
      restorationId: 'lendingsListView',
      itemCount: lendingsWithData.length,
      itemBuilder: (context, index) {
        final lendingWithData = lendingsWithData.elementAt(index);

        return Dismissible(
          key: ValueKey(lendingWithData.lending.id),
          background: Container(
            color: Theme.of(context).colorScheme.secondary,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
                Text(
                  localizations.returned.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: const DeleteBackground(),
          child: LendingListTile(
            lendingWithData: lendingWithData,
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                CreateEditLendingPage.routeName,
                arguments: lendingWithData.lending.id,
              );
            },
          ),
          confirmDismiss: (direction) async {
            final cubit = context.read<LendingsCubit>();
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            if (direction == DismissDirection.endToStart) {
              final result = await cubit.delete(lendingWithData);
              if (result == null) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  action: SnackBarAction(
                    onPressed: () async {
                      final undoSuccessful =
                          await cubit.undoDelete(lendingWithData);
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
                  content: Text(localizations.messageLendingDeleteSuccess),
                ));
                return true;
              }
              scaffoldMessenger.showSnackBar(SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(localizations.messageLendingDeleteFailure),
                duration: const Duration(seconds: 1),
              ));
            }
            if (direction == DismissDirection.startToEnd) {
              final result = await cubit.markReturned(lendingWithData);
              if (result == null) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  action: SnackBarAction(
                    onPressed: () async {
                      final undoSuccessful =
                          await cubit.undoReturn(lendingWithData);
                      if (!undoSuccessful) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(localizations.errorReturnUndoFailure),
                        ));
                      }
                    },
                    label: localizations.undo,
                  ),
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messageLendingReturnSuccess),
                ));
              } else {
                scaffoldMessenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messageLendingReturnFailure),
                  duration: const Duration(seconds: 1),
                ));
              }
            }
            return false;
          },
          direction: lendingWithData.lending.returnDate == null
              ? DismissDirection.horizontal
              : DismissDirection.endToStart,
        );
      },
    );
  }
}
