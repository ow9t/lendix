import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';

class LendingListTile extends StatelessWidget {
  const LendingListTile({
    Key? key,
    required this.lendingWithData,
    this.onTap,
  }) : super(key: key);

  final LendingWithData lendingWithData;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final lending = lendingWithData.lending;
    final isReturned = lending.returnDate != null;
    final item = lendingWithData.item;
    final category = lendingWithData.category;
    final person = lendingWithData.person;

    final dateDifference =
        DateTime.now().difference(lending.returnDate ?? lending.date);
    final timeAgo = localizations.timeAgo(dateDifference.inDays);

    return ListTile(
      isThreeLine: true,
      onTap: onTap,
      subtitle: Text.rich(
        TextSpan(
            text: lending.isBorrowed
                ? localizations.lendingBorrowedFrom
                : localizations.lendingLentTo,
            children: [
              const TextSpan(text: ' '),
              TextSpan(
                text: person.name,
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                  height: 1.6,
                ),
              ),
              const TextSpan(text: '\n'),
              TextSpan(
                text: isReturned
                    ? localizations.lendingReturnedTimeAgo(timeAgo)
                    : timeAgo,
                style: const TextStyle(height: 1.6),
              ),
            ]),
      ),
      title: Text.rich(
        TextSpan(
          text: item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: ' (${category?.name ?? localizations.categoryNone})',
              style: TextStyle(
                color: theme.textTheme.caption!.color,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        softWrap: false,
      ),
      trailing: isReturned
          ? const SizedBox(height: double.infinity, child: Icon(Icons.check))
          : null,
    );
  }
}
