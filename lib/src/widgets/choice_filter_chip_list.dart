import 'package:flutter/material.dart';

class ChoiceFilterChipList<T> extends StatelessWidget {
  final String Function(T) choiceLabelAccessor;
  final Iterable<T> choices;
  final String label;
  final void Function(T, bool) onSelectedItem;
  final T value;

  const ChoiceFilterChipList({
    Key? key,
    required this.choiceLabelAccessor,
    required this.choices,
    required this.label,
    required this.onSelectedItem,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.primaryTextTheme.button!.color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Text(
            '$label:',
            style: TextStyle(color: onPrimary, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Wrap(
            children: [
              for (final choice in choices)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    backgroundColor: theme.colorScheme.primaryVariant,
                    elevation: 2,
                    label: Text(choiceLabelAccessor(choice)),
                    labelStyle: TextStyle(color: onPrimary),
                    selected: choice == value,
                    selectedColor: theme.colorScheme.secondary,
                    onSelected: (value) => onSelectedItem(choice, value),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
