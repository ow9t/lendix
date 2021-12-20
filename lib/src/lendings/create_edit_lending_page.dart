import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lendix/constants.dart';

import '../database/database.dart';
import '../items/create_edit_item_page.dart';
import '../people/create_edit_person_page.dart';
import '../widgets/date_form_field.dart';
import '../widgets/entity_search/entity_search_delegate.dart';
import 'lending_cubit.dart';

class CreateEditLendingPage extends StatefulWidget {
  const CreateEditLendingPage({Key? key, this.lendingId}) : super(key: key);

  static const routeName = '/lending';

  final int? lendingId;

  @override
  State<CreateEditLendingPage> createState() => _CreateEditLendingPageState();
}

class _CreateEditLendingPageState extends State<CreateEditLendingPage>
    with RestorationMixin {
  final _categoryController = TextEditingController();
  final _categoryFocusNode = FocusNode();
  final _itemController = TextEditingController();
  final _itemFocusNode = FocusNode();
  final _personController = TextEditingController();
  final _personFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final DateTime _firstDate =
      DateTime.now().subtract(const Duration(days: daysBack));
  DateTime _lastDate = DateTime.now();
  LendingCubit? _cubit;
  String? _error;
  DateTime _date = DateTime.now();
  DateTime? _returnDate;
  bool _isBorrowed = false;
  late RestorableRouteFuture<Map<String, dynamic>?> _createItemRoute;
  late RestorableRouteFuture<Map<String, dynamic>?> _createPersonRoute;

  @override
  String? get restorationId => 'createEditLending';

  void _handleSubmitted([String? value]) async {
    if (_cubit == null) {
      return;
    }
    final formState = _formKey.currentState!;
    formState.save();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final localizations = AppLocalizations.of(context)!;
    if (formState.validate()) {
      final result = await _cubit!.submit();
      if (result == null) {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.lendingId == null
                ? localizations.messageLendingCreateSuccess
                : localizations.messageLendingUpdateSuccess,
          ),
          duration: const Duration(seconds: 1),
        ));
        return;
      }
      if (result == DatabaseException.uniqueConstraint) {
        scaffoldMessenger.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(localizations.errorLendingWithDataExistsLong),
          duration: const Duration(seconds: 2),
        ));
        setState(() {
          _error = localizations.errorLendingWithDataExistsShort;
        });
        formState.validate();
      } else {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            widget.lendingId == null
                ? localizations.messageLendingCreateFailure
                : localizations.messageLendingUpdateFailure,
          ),
          duration: const Duration(seconds: 1),
        ));
        return;
      }
    }
  }

  void _handleTapItem() async {
    _itemFocusNode.unfocus();
    final localizations = AppLocalizations.of(context)!;
    final result = await showSearch(
      context: context,
      delegate: EntitySearchDelegate<ItemWithCategory>(
        buildListTile: (value, onTap) => ListTile(
          onTap: onTap,
          title: Text(value.item.name),
          subtitle: Text(value.category?.name ?? localizations.categoryNone),
        ),
        emptyLabel: localizations.itemsEmptyList,
        onCreate: (query) => _createItemRoute.present({'name': query}),
        searchFieldLabel: localizations.searchItem,
        textInputAction: TextInputAction.done,
      ),
    );
    if (result != null) {
      _cubit!.saveItem(result.item.id);
      _categoryController.text =
          result.category?.name ?? localizations.categoryNone;
      _itemController.text = result.item.name;
    }
  }

  void _handleTapPerson() async {
    _personFocusNode.unfocus();
    final localizations = AppLocalizations.of(context)!;
    final result = await showSearch(
      context: context,
      delegate: EntitySearchDelegate<Person>(
        buildListTile: (value, onTap) => ListTile(
          onTap: onTap,
          title: Text(value.name),
        ),
        emptyLabel: localizations.peopleEmptyList,
        onCreate: (query) => _createPersonRoute.present({'name': query}),
        searchFieldLabel: localizations.searchPerson,
        textInputAction: TextInputAction.done,
      ),
    );
    if (result != null) {
      _cubit!.savePerson(result.id);
      _personController.text = result.name;
    }
  }

  void _initCubit() async {
    final dao = context.read<MyDatabase>().lendingsDao;
    late final LendingsCompanion? maybeCompanion;
    if (widget.lendingId != null) {
      final lendingWithData =
          await dao.getLendingWithDataById(widget.lendingId!);
      maybeCompanion = lendingWithData?.lending.toCompanion(false);
      if (lendingWithData != null) {
        _categoryController.text = lendingWithData.category?.name ??
            AppLocalizations.of(context)!.categoryNone;
        _itemController.text = lendingWithData.item.name;
        _personController.text = lendingWithData.person.name;
        setState(() {
          _date = lendingWithData.lending.date;
          _returnDate = lendingWithData.lending.returnDate;
          final _referenceDate = _returnDate ?? _date;
          if (_referenceDate.isAfter(_lastDate)) {
            _lastDate = _referenceDate;
          }
          _isBorrowed = lendingWithData.lending.isBorrowed;
        });
      }
    } else {
      maybeCompanion = null;
    }
    setState(() {
      _cubit = LendingCubit(dao, maybeCompanion);
    });
  }

  @override
  void initState() {
    super.initState();
    _createItemRoute = RestorableRouteFuture<Map<String, dynamic>?>(
      onPresent: (navigator, arguments) => navigator.restorablePush(
        _createItemRouteBuilder,
        arguments: arguments,
      ),
      onComplete: (itemMap) {
        final itemId = itemMap?['itemId'] as int?;
        final itemName = itemMap?['itemName'] as String?;
        final categoryName = itemMap?['categoryName'] as String?;
        if (itemId != null && itemName != null) {
          _cubit?.saveItem(itemId);
          _categoryController.text =
              categoryName ?? AppLocalizations.of(context)!.categoryNone;
          _itemController.text = itemName;
        }
      },
    );
    _createPersonRoute = RestorableRouteFuture<Map<String, dynamic>?>(
      onPresent: (navigator, arguments) => navigator.restorablePush(
        _createPersonRouteBuilder,
        arguments: arguments,
      ),
      onComplete: (personMap) {
        final personId = personMap?['id'] as int?;
        final name = personMap?['name'] as String?;
        if (personId != null && name != null) {
          _cubit?.savePerson(personId);
          _personController.text = name;
        }
      },
    );
    _initCubit();
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_createItemRoute, 'createItemRoute');
    registerForRestoration(_createPersonRoute, 'createPersonRoute');
  }

  @override
  void dispose() {
    _cubit?.close();
    _categoryController.dispose();
    _categoryFocusNode.dispose();
    _itemController.dispose();
    _itemFocusNode.dispose();
    _personController.dispose();
    _personFocusNode.dispose();
    _createItemRoute.dispose();
    _createPersonRoute.dispose();
    super.dispose();
  }

  static Route<Map<String, dynamic>?> _createItemRouteBuilder(
      BuildContext context, Object? arguments) {
    arguments as Map<String, dynamic>?;
    final name = arguments?['name'] as String?;
    return MaterialPageRoute<Map<String, dynamic>?>(
      builder: (context) => CreateEditItemPage(
        initialName: name,
      ),
    );
  }

  static Route<Map<String, dynamic>?> _createPersonRouteBuilder(
      BuildContext context, Object? arguments) {
    arguments as Map<String, dynamic>?;
    final name = arguments?['name'] as String?;
    return MaterialPageRoute<Map<String, dynamic>?>(
      builder: (context) => CreateEditPersonPage(
        initialName: name,
      ),
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
    final theme = Theme.of(context);
    return BlocBuilder<LendingCubit, LendingsCompanion?>(
      bloc: _cubit,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.lendingId == null
                ? localizations.lendingTitleNew
                : localizations.lendingTitleEdit),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextFormField(
                    controller: _itemController,
                    decoration: InputDecoration(
                      labelText: '${localizations.labelItem}*',
                      helperText: '*${localizations.helperTextRequired}',
                    ),
                    enableInteractiveSelection: false,
                    focusNode: _itemFocusNode,
                    keyboardType: TextInputType.name,
                    maxLines: 2,
                    minLines: 1,
                    onTap: _handleTapItem,
                    readOnly: true,
                    validator: (value) {
                      if (_error != null) {
                        return _error;
                      }
                      if (value == null || value.trim().isEmpty) {
                        return localizations.errorEmptyItem;
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      disabledBorder: _error == null
                          ? null
                          : OutlineInputBorder(
                              borderSide: BorderSide(color: theme.errorColor),
                            ),
                      labelText: localizations.labelCategory,
                      labelStyle: _error == null
                          ? null
                          : TextStyle(color: theme.errorColor),
                    ),
                    enableInteractiveSelection: false,
                    maxLines: 2,
                    minLines: 1,
                    enabled: false,
                    readOnly: true,
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextFormField(
                    controller: _personController,
                    decoration: InputDecoration(
                      labelText: '${localizations.labelPerson}*',
                      helperText: '*${localizations.helperTextRequired}',
                    ),
                    enableInteractiveSelection: false,
                    focusNode: _personFocusNode,
                    keyboardType: TextInputType.name,
                    maxLines: 2,
                    minLines: 1,
                    onTap: _handleTapPerson,
                    readOnly: true,
                    validator: (value) {
                      if (_error != null) {
                        return _error;
                      }
                      if (value == null || value.trim().isEmpty) {
                        return localizations.errorEmptyPerson;
                      }
                      return null;
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: DateFormField(
                    decoration: InputDecoration(
                      labelText: '${localizations.labelDate}*',
                      helperText: '*${localizations.helperTextRequired}',
                    ),
                    firstDate: _firstDate,
                    initialValue: _date,
                    isRequired: true,
                    lastDate: _lastDate,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _date = value;
                        });
                      }
                    },
                    onSaved: (value) {
                      if (value != null) {
                        _cubit!.saveDate(value);
                        setState(() {
                          _date = value;
                          _error = null;
                        });
                      }
                    },
                    validator: (value) {
                      if (_error != null) {
                        return _error;
                      }
                      if (value == null) {
                        return 'TODO: error';
                      }
                      return null;
                    },
                  ),
                ),
                if (widget.lendingId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: DateFormField(
                      decoration: InputDecoration(
                        labelText: localizations.labelReturnDate,
                      ),
                      firstDate: _date,
                      initialValue: _returnDate,
                      lastDate: _lastDate,
                      onSaved: (value) {
                        _cubit!.saveReturnDate(value);
                        setState(() {
                          _returnDate = value;
                        });
                      },
                    ),
                  ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 16 + 64),
                  child: SwitchListTile(
                    onChanged: (value) {
                      _cubit!.saveBorrowed(value);
                      setState(() {
                        _isBorrowed = value;
                      });
                    },
                    value: _isBorrowed,
                    subtitle: Text(localizations.lendingSwitchSubtitle),
                    title: Text(_isBorrowed
                        ? localizations.lendingSwitchTitleBorrowed
                        : localizations.lendingSwitchTitleLent),
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
