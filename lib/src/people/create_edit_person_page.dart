import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';
import '../widgets/name_form_field.dart';
import 'person_cubit.dart';

class CreateEditPersonPage extends StatefulWidget {
  const CreateEditPersonPage({Key? key, this.personId}) : super(key: key);

  static const routeName = '/person';

  final int? personId;

  @override
  State<CreateEditPersonPage> createState() => _CreateEditPersonPageState();
}

class _CreateEditPersonPageState extends State<CreateEditPersonPage> {
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  PersonCubit? _cubit;
  String? error;

  void initCubit() async {
    final dao = context.read<MyDatabase>().peopleDao;
    late final PeopleCompanion? maybeCompanion;
    if (widget.personId != null) {
      maybeCompanion =
          (await dao.getPersonById(widget.personId!))?.toCompanion(false);
    } else {
      maybeCompanion = null;
    }
    setState(() {
      _cubit = PersonCubit(dao, maybeCompanion);
    });
  }

  @override
  void initState() {
    super.initState();
    initCubit();
  }

  @override
  void dispose() {
    _cubit?.close();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmitted([String? value]) async {
    if (_cubit == null) {
      return;
    }
    final formState = _formKey.currentState!;
    formState.save();
    if (formState.validate()) {
      final localizations = AppLocalizations.of(context)!;
      final result = await _cubit!.submit();
      if (result == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.personId == null
                ? localizations.messagePersonCreateSuccess
                : localizations.messagePersonUpdateSuccess,
          ),
          duration: const Duration(seconds: 1),
        ));
        return;
      }
      if (result == DatabaseException.uniqueConstraint) {
        setState(() {
          error = localizations.errorPersonExists;
        });
        formState.validate();
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.personId == null
                ? localizations.messagePersonCreateFailure
                : localizations.messagePersonUpdateFailure,
          ),
          duration: const Duration(seconds: 1),
        ));
        return;
      }
    }
    FocusScope.of(context).requestFocus(_focusNode);
  }

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<PersonCubit, PeopleCompanion?>(
      bloc: _cubit,
      builder: (context, state) {
        final isLoading = state == null;
        return Scaffold(
          appBar: AppBar(
              title: Text(widget.personId == null
                  ? localizations.personTitleNew
                  : localizations.personTitleEdit)),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: NameFormField(
                      autofocus: true,
                      focusNode: _focusNode,
                      initialValue: state.name.value,
                      maxLength: personNameMaxLength,
                      onFieldSubmitted: _handleSubmitted,
                      onSaved: (value) {
                        _cubit!.save(value ?? '');
                        setState(() {
                          error = null;
                        });
                      },
                      validator: (_) => error,
                    ),
                  ),
                ),
          floatingActionButton: isLoading
              ? null
              : FloatingActionButton(
                  onPressed: _handleSubmitted,
                  child: const Icon(Icons.save),
                ),
        );
      },
    );
  }
}
