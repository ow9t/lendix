import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NameFormField extends StatelessWidget {
  final bool autofocus;
  final FocusNode? focusNode;
  final String? initialValue;
  final int? maxLength;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;

  const NameFormField({
    Key? key,
    this.autofocus = false,
    this.focusNode,
    this.initialValue,
    this.maxLength,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return TextFormField(
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: '${localizations.labelName}*',
        helperText: '*${localizations.helperTextRequired}',
      ),
      focusNode: focusNode,
      initialValue: initialValue,
      keyboardType: TextInputType.name,
      maxLength: maxLength,
      maxLengthEnforcement:
          maxLength == null ? null : MaxLengthEnforcement.enforced,
      maxLines: 2,
      minLines: 1,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      validator: (value) {
        final maybeError = validator?.call(value);
        if (maybeError != null) {
          return maybeError;
        }
        if (value == null || value.trim().isEmpty) {
          return localizations.errorEmptyName;
        }
        return null;
      },
    );
  }
}
