import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../categories/create_edit_category_page.dart';
import '../database/database.dart';
import '../widgets/entity_search/entity_search_delegate.dart';
import '../widgets/name_form_field.dart';
import 'item_cubit.dart';

class CreateEditItemPage extends StatefulWidget {
  const CreateEditItemPage({
    Key? key,
    this.itemId,
    this.initialName,
  }) : super(key: key);

  static const routeName = '/item';

  final int? itemId;
  final String? initialName;

  @override
  State<CreateEditItemPage> createState() => _CreateEditItemPageState();
}

class _CreateEditItemPageState extends State<CreateEditItemPage>
    with RestorationMixin {
  final _categoryController = TextEditingController();
  final _categoryFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  ItemCubit? _cubit;
  String? error;
  late RestorableRouteFuture<Map<String, dynamic>?> _createCategoryRoute;

  @override
  String? get restorationId => 'createEditItem';

  void _handleSubmitted([String? value]) async {
    if (_cubit == null) {
      return;
    }
    final formState = _formKey.currentState!;
    formState.save();
    if (formState.validate()) {
      final localizations = AppLocalizations.of(context)!;
      final result = await _cubit!.submit();
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      if (result == null) {
        final currentState = _cubit!.state;
        Navigator.pop(context, {
          'itemId': currentState.id.value,
          'itemName': currentState.name.value,
          'categoryId': currentState.categoryId.value,
          'categoryName': _categoryController.text.isEmpty
              ? null
              : _categoryController.text,
        });
        scaffoldMessenger.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.itemId == null
                ? localizations.messageItemCreateSuccess
                : localizations.messageItemUpdateSuccess,
          ),
          duration: const Duration(seconds: 1),
        ));
        return;
      }
      if (result == DatabaseException.uniqueConstraint) {
        setState(() {
          error = localizations.errorItemWithCategoryExists;
        });
        formState.validate();
      } else {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.itemId == null
                ? localizations.messageItemCreateFailure
                : localizations.messageItemUpdateFailure,
          ),
          duration: const Duration(seconds: 1),
        ));
        return;
      }
    }
    FocusScope.of(context).requestFocus(_nameFocusNode);
  }

  void _handleTapCategory() async {
    _categoryFocusNode.unfocus();
    final localizations = AppLocalizations.of(context)!;
    final result = await showSearch(
      context: context,
      delegate: EntitySearchDelegate<Category>(
        buildListTile: (value, onTap) => ListTile(
          onTap: onTap,
          title: Text(value.name),
        ),
        emptyLabel: localizations.categoriesEmptyList,
        onCreate: (query) => _createCategoryRoute.present({'name': query}),
        searchFieldLabel: localizations.searchCategory,
        textInputAction: TextInputAction.done,
      ),
    );
    if (result != null) {
      _cubit!.saveCategory(result.id);
      _categoryController.text = result.name;
      setState(() {
        error = null;
      });
      _formKey.currentState!.validate();
    }
  }

  void _initCubit() async {
    final dao = context.read<MyDatabase>().itemsDao;
    late final ItemsCompanion? maybeCompanion;
    if (widget.itemId != null) {
      final itemWithCategory =
          await dao.getItemWithCategoryById(widget.itemId!);
      maybeCompanion = itemWithCategory?.item.toCompanion(false);
      _categoryController.text = itemWithCategory?.category?.name ?? '';
    } else {
      maybeCompanion = null;
    }
    setState(() {
      _cubit = ItemCubit(dao, maybeCompanion);
    });
  }

  @override
  void initState() {
    super.initState();
    _createCategoryRoute = RestorableRouteFuture<Map<String, dynamic>?>(
      onPresent: (navigator, arguments) => navigator.restorablePush(
        _createCategoryRouteBuilder,
        arguments: arguments,
      ),
      onComplete: (categoryMap) {
        final categoryId = categoryMap?['id'] as int?;
        final name = categoryMap?['name'] as String?;
        if (categoryId != null && name != null) {
          _cubit?.saveCategory(categoryId);
          _categoryController.text = name;
        }
      },
    );
    _initCubit();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_createCategoryRoute, 'createCategoryRoute');
  }

  @override
  void dispose() {
    _cubit?.close();
    _categoryController.dispose();
    _categoryFocusNode.dispose();
    _nameFocusNode.dispose();
    _createCategoryRoute.dispose();
    super.dispose();
  }

  static Route<Map<String, dynamic>?> _createCategoryRouteBuilder(
      BuildContext context, Object? arguments) {
    arguments as Map<String, dynamic>?;
    final name = arguments?['name'] as String?;
    return MaterialPageRoute<Map<String, dynamic>?>(
      builder: (context) => CreateEditCategoryPage(initialName: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final localizations = AppLocalizations.of(context)!;
    return BlocBuilder<ItemCubit, ItemsCompanion?>(
      bloc: _cubit,
      builder: (context, state) {
        final isLoading = state == null;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.itemId == null
                ? localizations.itemTitleNew
                : localizations.itemTitleEdit),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: NameFormField(
                          autofocus: true,
                          focusNode: _nameFocusNode,
                          initialValue: widget.initialName ?? state.name.value,
                          onSaved: (value) {
                            _cubit!.saveName(value ?? '');
                            setState(() {
                              error = null;
                            });
                          },
                          validator: (_) => error,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: TextFormField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: localizations.labelCategory,
                            suffixIcon: state.categoryId.value == null
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _cubit!.saveCategory(null);
                                      _categoryController.text = '';
                                    },
                                    icon: const Icon(Icons.cancel),
                                  ),
                          ),
                          enableInteractiveSelection: false,
                          focusNode: _categoryFocusNode,
                          keyboardType: TextInputType.name,
                          maxLines: 2,
                          minLines: 1,
                          onTap: _handleTapCategory,
                          readOnly: true,
                          validator: (_) => error,
                        ),
                      ),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _handleSubmitted,
            child: const Icon(Icons.save),
          ),
        );
      },
    );
  }
}
