import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lendix/constants.dart';

import 'categories/create_edit_category_page.dart';
import 'database/database.dart';
import 'items/create_edit_item_page.dart';
import 'items/items_filter_cubit.dart';
import 'navigation_backdrop.dart';
import 'people/create_edit_person_page.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'widgets/entity_search/entity_search_cubit.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.settingsController,
  }) : super(key: key);

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return RepositoryProvider(
      create: (context) => MyDatabase(openLazy(databaseFilename)),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => EntitySearchCubit<Category>(
              (query) => context
                  .read<MyDatabase>()
                  .categoriesDao
                  .watchCategories(nameFilter: query),
            ),
          ),
          BlocProvider(
            create: (context) => EntitySearchCubit<ItemWithCategory>(
              (query) => context
                  .read<MyDatabase>()
                  .itemsDao
                  .watchItemsWithCategory(nameFilter: query),
            ),
          ),
          BlocProvider(
            create: (context) => EntitySearchCubit<Person>(
              (query) => context
                  .read<MyDatabase>()
                  .peopleDao
                  .watchPeople(nameFilter: query),
            ),
          ),
        ],
        child: AnimatedBuilder(
          animation: settingsController,
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              // Providing a restorationScopeId allows the Navigator built by the
              // MaterialApp to restore the navigation stack when a user leaves and
              // returns to the app after it has been killed while running in the
              // background.
              restorationScopeId: 'app',

              // Provide the generated AppLocalizations to the MaterialApp. This
              // allows descendant Widgets to display the correct translations
              // depending on the user's locale.
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English, no country code
                Locale('de', ''), // German, no country code
              ],

              // Use AppLocalizations to configure the correct application title
              // depending on the user's locale.
              //
              // The appTitle is defined in .arb files found in the localization
              // directory.
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context)!.appTitle,

              // Define a light and dark color theme. Then, read the user's
              // preferred ThemeMode (light, dark, or system default) from the
              // SettingsController to display the correct theme.
              theme: ThemeData(
                appBarTheme: const AppBarTheme(backgroundColor: Colors.purple),
                colorScheme: ColorScheme.light(
                  primary: Colors.purple,
                  primaryVariant: Colors.purple[600]!,
                  secondary: Colors.green,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  foregroundColor: Colors.white,
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                ),
              ),
              darkTheme: ThemeData(
                appBarTheme: const AppBarTheme(backgroundColor: Colors.purple),
                colorScheme: ColorScheme.dark(
                  primary: Colors.purple,
                  primaryVariant: Colors.purple[600]!,
                  secondary: Colors.green,
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  foregroundColor: Colors.white,
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                ),
              ),
              themeMode: settingsController.themeMode,

              // Define a function to handle named routes in order to support
              // Flutter web url navigation and deep linking.
              onGenerateRoute: (RouteSettings routeSettings) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return MaterialPageRoute<void>(
                      settings: routeSettings,
                      builder: (context) {
                        return SettingsView(controller: settingsController);
                      },
                    );
                  case CreateEditCategoryPage.routeName:
                    return MaterialPageRoute<void>(
                      settings: routeSettings,
                      builder: (BuildContext context) {
                        final categoryId = routeSettings.arguments as int?;
                        return CreateEditCategoryPage(categoryId: categoryId);
                      },
                    );
                  case CreateEditItemPage.routeName:
                    return MaterialPageRoute<void>(
                      settings: routeSettings,
                      builder: (BuildContext context) {
                        final itemId = routeSettings.arguments as int?;
                        return CreateEditItemPage(itemId: itemId);
                      },
                    );
                  case CreateEditPersonPage.routeName:
                    return MaterialPageRoute<void>(
                      settings: routeSettings,
                      builder: (BuildContext context) {
                        final personId = routeSettings.arguments as int?;
                        return CreateEditPersonPage(personId: personId);
                      },
                    );
                  default:
                    return MaterialPageRoute<void>(
                      settings: routeSettings,
                      builder: (context) {
                        return BlocProvider(
                          create: (context) => ItemsFilterCubit(),
                          child: const NavigationBackdrop(),
                        );
                      },
                    );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
