import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';
import '../widgets/name_form_field.dart';
import 'category_cubit.dart';

class CreateEditCategoryPage extends StatefulWidget {
  const CreateEditCategoryPage({
    Key? key,
    this.categoryId,
    this.initialName,
  }) : super(key: key);

  static const routeName = '/category';

  final int? categoryId;
  final String? initialName;

  @override
  State<CreateEditCategoryPage> createState() => _CreateEditCategoryPageState();
}

class _CreateEditCategoryPageState extends State<CreateEditCategoryPage> {
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  CategoryCubit? _cubit;
  String? error;

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
        final currentState = _cubit!.state;
        Navigator.pop(context, {
          'id': currentState.id.value,
          'name': currentState.name.value,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.categoryId == null
                ? localizations.messageCategoryCreateSuccess
                : localizations.messageCategoryUpdateSuccess,
          ),
          duration: const Duration(seconds: 1),
        ));
        return;
      }
      if (result == DatabaseException.uniqueConstraint) {
        setState(() {
          error = localizations.errorCategoryExists;
        });
        formState.validate();
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.categoryId == null
                ? localizations.messageCategoryCreateFailure
                : localizations.messageCategoryUpdateFailure,
          ),
          duration: const Duration(seconds: 1),
        ));
        return;
      }
    }
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void _initCubit() async {
    final dao = context.read<MyDatabase>().categoriesDao;
    late final CategoriesCompanion? maybeCompanion;
    if (widget.categoryId != null) {
      maybeCompanion =
          (await dao.getCategoryById(widget.categoryId!))?.toCompanion(false);
    } else {
      maybeCompanion = null;
    }
    setState(() {
      _cubit = CategoryCubit(dao, maybeCompanion);
    });
  }

  @override
  void initState() {
    super.initState();
    _initCubit();
  }

  @override
  void dispose() {
    _cubit?.close();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<CategoryCubit, CategoriesCompanion?>(
      bloc: _cubit,
      builder: (context, state) {
        final isLoading = state == null;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.categoryId == null
                ? localizations.categoryTitleNew
                : localizations.categoryTitleEdit),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: NameFormField(
                      autofocus: true,
                      focusNode: _focusNode,
                      initialValue: widget.initialName ?? state.name.value,
                      maxLength: categoryNameMaxLength,
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
