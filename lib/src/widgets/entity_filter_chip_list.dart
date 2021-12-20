import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EntityFilterChipList<T> extends StatelessWidget {
  final String emptyText;
  final Iterable<T> entities;
  final Iterable<T> entitiesSelected;
  final String Function(T) entityLabelAccessor;
  final String label;
  final VoidCallback? onClear;
  final void Function(T, bool) onSelectedItem;

  const EntityFilterChipList({
    Key? key,
    required this.emptyText,
    required this.entities,
    required this.entitiesSelected,
    required this.entityLabelAccessor,
    required this.label,
    required this.onClear,
    required this.onSelectedItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final onPrimary = theme.primaryTextTheme.button!.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label:',
                style: TextStyle(color: onPrimary, fontSize: 16),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return theme.primaryTextTheme.button!.color!
                          .withOpacity(0.38);
                    }
                    return theme.colorScheme.secondary;
                  }),
                ),
                onPressed: onClear,
                child: Text(localizations.clear.toUpperCase()),
              ),
            ],
          ),
        ),
        if (entities.isEmpty)
          ListTile(
            dense: true,
            title: Text(
              emptyText,
              style: TextStyle(color: theme.primaryTextTheme.caption!.color),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Wrap(
              children: [
                for (final item in entities)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FilterChip(
                      backgroundColor: theme.colorScheme.primaryVariant,
                      checkmarkColor: onPrimary,
                      elevation: 2,
                      label: Text(entityLabelAccessor(item)),
                      labelStyle: TextStyle(color: onPrimary),
                      selected: entitiesSelected.contains(item),
                      selectedColor: theme.colorScheme.secondary,
                      onSelected: (value) => onSelectedItem(item, value),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
