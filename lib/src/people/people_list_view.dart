import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lendix/src/database/database.dart';

import '../widgets/delete_background.dart';
import 'people_cubit.dart';
import 'create_edit_person_page.dart';

class PeopleListView extends StatelessWidget {
  const PeopleListView({
    Key? key,
    required this.people,
  }) : super(key: key);

  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ListView.builder(
      restorationId: 'peopleListView',
      itemCount: people.length,
      itemBuilder: (context, index) {
        final person = people.elementAt(index);

        return Dismissible(
          key: ValueKey(person.id),
          background: const DeleteBackground(),
          child: ListTile(
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                CreateEditPersonPage.routeName,
                arguments: person.id,
              );
            },
            title: Text(person.name),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              final cubit = context.read<PeopleCubit>();
              final result = await cubit.delete(person);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (result == null) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  action: SnackBarAction(
                    onPressed: () async {
                      final undoSuccessful = await cubit.undo(person);
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
                  content: Text(localizations.messagePersonDeleteSuccess),
                ));
                return true;
              }
              if (result == DatabaseException.foreignKeyConstraint) {
                scaffoldMessenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messagePersonDeleteProhibited),
                  duration: const Duration(seconds: 1),
                ));
              } else {
                scaffoldMessenger.showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(localizations.messagePersonDeleteFailure),
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
