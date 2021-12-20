import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormField extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  final DateTime? initialValue;
  final bool isRequired;
  final void Function(DateTime?)? onChanged;
  final void Function(DateTime?)? onSaved;
  final String? Function(DateTime?)? validator;

  const DateFormField({
    Key? key,
    required this.firstDate,
    required this.lastDate,
    this.decoration,
    this.focusNode,
    this.initialValue,
    this.isRequired = false,
    this.onChanged,
    this.onSaved,
    this.validator,
  }) : super(key: key);

  @override
  _DateFormFieldState createState() => _DateFormFieldState();
}

class _DateFormFieldState extends State<DateFormField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late DateTime? _value;

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return '';
    }
    final formattedDate = DateFormat.yMd().format(date);
    return formattedDate;
  }

  void _update(DateTime? value) {
    widget.onChanged?.call(value);
    _controller.text = _formatDateTime(value);
    setState(() {
      _value = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: _formatDateTime(widget.initialValue));
    _focusNode = widget.focusNode ?? FocusNode();
    _value = widget.initialValue;
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final suffixIcon = (widget.isRequired || _value == null)
        ? const Icon(Icons.event)
        : IconButton(
            onPressed: () => _update(null),
            icon: const Icon(Icons.event_busy),
          );
    final decoration = widget.decoration?.copyWith(suffixIcon: suffixIcon) ??
        InputDecoration(suffixIcon: suffixIcon);

    return TextFormField(
      controller: _controller,
      decoration: decoration,
      enableInteractiveSelection: false,
      focusNode: _focusNode,
      onSaved: (value) => widget.onSaved?.call(_value),
      onTap: () async {
        _focusNode.unfocus();
        final result = await showDatePicker(
          context: context,
          firstDate: widget.firstDate,
          initialDate: _value ?? DateTime.now(),
          lastDate: widget.lastDate,
        );
        if (result != null) {
          _update(result);
        }
      },
      readOnly: true,
      validator: (value) => widget.validator?.call(_value),
    );
  }
}
