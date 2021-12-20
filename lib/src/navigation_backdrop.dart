import 'package:backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'categories/categories_list_page.dart';
import 'categories/create_edit_category_page.dart';
import 'database/database.dart';
import 'items/create_edit_item_page.dart';
import 'items/items_filter_back_layer.dart';
import 'items/items_filter_cubit.dart';
import 'items/items_list_page.dart';
import 'people/create_edit_person_page.dart';
import 'people/people_list_page.dart';
import 'settings/settings_view.dart';
import 'widgets/entity_search/entity_search_delegate.dart';
import 'widgets/notification_icon.dart';

enum BackdropRoute { categories, items, people, settings }

class NavigationBackdrop extends StatefulWidget {
  const NavigationBackdrop({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  _NavigationBackdropState createState() => _NavigationBackdropState();
}

class _NavigationBackdropState extends State<NavigationBackdrop> {
  final _scaffoldKey = GlobalKey<BackdropScaffoldState>();
  bool backLayerRevealed = false;
  int currentIndex = 0;
  bool showExtraBackLayer = false;

  Widget? leadingFromRoute(BackdropRoute route) {
    final color = Theme.of(context).primaryTextTheme.button!.color;
    switch (route) {
      case BackdropRoute.categories:
        return Icon(Icons.category_outlined, color: color);
      case BackdropRoute.items:
        return Icon(Icons.blender, color: color);
      case BackdropRoute.people:
        return Icon(Icons.person, color: color);
      case BackdropRoute.settings:
        return Icon(Icons.settings, color: color);
    }
  }

  String titleFromRoute(BackdropRoute route) {
    final localizations = AppLocalizations.of(context)!;
    switch (route) {
      case BackdropRoute.categories:
        return localizations.categoriesTitle;
      case BackdropRoute.items:
        return localizations.itemsTitle;
      case BackdropRoute.people:
        return localizations.peopleTitle;
      case BackdropRoute.settings:
        return localizations.settingsTitle;
    }
  }

  List<Widget>? buildAppBarActions() {
    if (backLayerRevealed) return null;
    final currentRoute = BackdropRoute.values[currentIndex];
    final localizations = AppLocalizations.of(context)!;
    switch (currentRoute) {
      case BackdropRoute.categories:
        return [
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: EntitySearchDelegate<Category>(
                  buildListTile: (value, onTap) => ListTile(
                    onTap: onTap,
                    title: Text(value.name),
                  ),
                  emptyLabel: localizations.categoriesEmptyList,
                  searchFieldLabel: localizations.searchCategory,
                ),
              );
              if (result != null) {
                Navigator.restorablePushNamed(
                  context,
                  CreateEditCategoryPage.routeName,
                  arguments: result.id,
                );
              }
            },
            icon: const Icon(Icons.search),
          ),
        ];
      case BackdropRoute.items:
        return [
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: EntitySearchDelegate<ItemWithCategory>(
                  buildListTile: (value, onTap) => ListTile(
                    onTap: onTap,
                    title: Text(value.item.name),
                    subtitle: Text(
                        value.category?.name ?? localizations.categoryNone),
                  ),
                  emptyLabel: localizations.itemsEmptyList,
                  searchFieldLabel: localizations.searchItem,
                ),
              );
              if (result != null) {
                Navigator.restorablePushNamed(
                  context,
                  CreateEditItemPage.routeName,
                  arguments: result.item.id,
                );
              }
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                showExtraBackLayer = true;
              });
              _scaffoldKey.currentState!.fling();
            },
            icon: BlocBuilder<ItemsFilterCubit, List<Category>>(
              builder: (context, state) {
                return NotificationIcon(
                  Icons.tune,
                  notificationColor: Theme.of(context).colorScheme.secondary,
                  showNotification: state.isNotEmpty,
                );
              },
            ),
          ),
        ];
      case BackdropRoute.people:
        return [
          IconButton(
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: EntitySearchDelegate<Person>(
                  buildListTile: (value, onTap) => ListTile(
                    onTap: onTap,
                    title: Text(value.name),
                  ),
                  emptyLabel: localizations.peopleEmptyList,
                  searchFieldLabel: localizations.searchPerson,
                ),
              );
              if (result != null) {
                Navigator.restorablePushNamed(
                  context,
                  CreateEditPersonPage.routeName,
                  arguments: result.id,
                );
              }
            },
            icon: const Icon(Icons.search),
          ),
        ];
      default:
        return const [];
    }
  }

  Widget buildBackLayer() {
    final currentRoute = BackdropRoute.values[currentIndex];
    if (showExtraBackLayer) {
      switch (currentRoute) {
        case BackdropRoute.items:
          return const ItemsFilterBackLayer();
        default:
      }
    }
    return BackdropNavigationBackLayer(
      items: [
        for (final route in BackdropRoute.values)
          ListTile(
            leading: leadingFromRoute(route),
            selected: backLayerRevealed && route == currentRoute,
            selectedTileColor: Colors.white24,
            title: Text(
              titleFromRoute(route),
              style: const TextStyle(color: Colors.white),
            ),
          )
      ],
      onTap: (index) {
        if (BackdropRoute.values[index] == BackdropRoute.settings) {
          Navigator.restorablePushNamed(context, SettingsView.routeName);
        } else {
          setState(() {
            currentIndex = index;
          });
        }
      },
    );
  }

  Widget? buildFloatingActionButton() {
    if (backLayerRevealed) return null;
    final currentRoute = BackdropRoute.values[currentIndex];
    late final String routeName;
    switch (currentRoute) {
      case BackdropRoute.categories:
        routeName = CreateEditCategoryPage.routeName;
        break;
      case BackdropRoute.items:
        routeName = CreateEditItemPage.routeName;
        break;
      case BackdropRoute.people:
        routeName = CreateEditPersonPage.routeName;
        break;
      default:
        return null;
    }
    return FloatingActionButton(
      onPressed: () {
        Navigator.restorablePushNamed(
          context,
          routeName,
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget buildFrontLayer() {
    final currentRoute = BackdropRoute.values[currentIndex];
    switch (currentRoute) {
      case BackdropRoute.items:
        return const ItemsListPage();
      case BackdropRoute.people:
        return const PeopleListPage();
      case BackdropRoute.categories:
      default:
        return const CategoriesListPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = BackdropRoute.values[currentIndex];
    final theme = Theme.of(context);
    return BackdropScaffold(
      key: _scaffoldKey,
      appBar: BackdropAppBar(
        actions: buildAppBarActions(),
        centerTitle: false,
        title: Text(titleFromRoute(currentRoute)),
      ),
      backLayer: buildBackLayer(),
      backLayerBackgroundColor: theme.appBarTheme.backgroundColor,
      floatingActionButton: buildFloatingActionButton(),
      frontLayer: buildFrontLayer(),
      frontLayerScrim:
          theme.brightness == Brightness.dark ? Colors.black45 : Colors.white70,
      onBackLayerConcealed: () => setState(() {
        backLayerRevealed = false;
        showExtraBackLayer = false;
      }),
      onBackLayerRevealed: () => setState(() {
        backLayerRevealed = true;
      }),
      stickyFrontLayer: true,
      subHeader: const SizedBox(height: 16),
      subHeaderAlwaysActive: false,
    );
  }
}
