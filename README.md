# Lendix

A Flutter app to track items you borrowed from or lent to your friends.  
This app was created for my final project of Harvard University's CS50 certificate.
The name (for the lack of a better idea) is a portmanteau of the words `lending` and `index`.

The project code is structured by feature.

#### Video Demo: [YouTube](https://youtu.be/eLn7SZ4iWyM)

## Description

### Why Flutter?

[Flutter](https://flutter.dev/) is a framework for cross-platform app development, which
currently has one of the biggest (if not *the* biggest) communities. Personally, after
having worked with [React Native](https://reactnative.dev/) professionally for the past
couples of years, I preferred Flutter to React Native for my side-projects not just
because of the [Dart](https://dart.dev/) programming language.

### The Idea

Having moved recently, I could not find a couple of books and DVDs of mine. I could not
remember in which box I put them or whether I have lent them to any of my friends. Thus,
the idea for this app was born. I wanted an app, which assists me in keeping track of
the items I lent to my friends, so I would not have to remember it myself.

### The App

The app mostly follows to the [Material Design](https://material.io/) guidelines and
uses a [Material Components](https://material.io/components) throughout. I wanted to
try something new, so I chose to use a [Material Backdrop](https://material.io/components/backdrop)
instead of the usual Drawer for the root navigation. The user starts on the `Lendings`
screen and via the backdrop, they can navigate between the five main screens:
`Lendings`, `Categories`, `Items`, `People`, and `Settings`.

![Backdrop](screenshots/backdrop_android.png?raw=true "Backdrop")
![Lendings Screen](screenshots/lendings_android.png?raw=true "Lendings Screen")

The `Lendings` screen shows a list of lendings, which can be searched by item name or
filtered by status, type, item category, and person. The user can swipe a lending
horizontally, to either delete it or mark it as returned, setting the return date to the
current date, or tap on a lending to edit it. Via the floating action buttin, the user
can create new lendings.

![Search Lendings](screenshots/search_android.png?raw=true "Search Lendings")
![Filter Lendings](screenshots/filter_android.png?raw=true "Filter Lendings")

Analogous, the `Categories`, the `Items`, and the `People` screens show lists containing
the corresponding entities. They can also be searched and filtered (`Items` only),
swiped to delete and tapped, and created via the floating action buttons.

During the creation of a lending, the user can create items and people via modal screens,
without the need to leave the creation flow and switch to the corresponding screen. 
The same holds true for categories during the creation of an item. The goal was to make
the creation flow as painless as possible to the user.

User interaction uses an optimistic approach and the app provides relevant feedback to the
user mostly via snackbars.

The `Settings` screen is a modal which currently only provides the option to change the
theme. The value of the setting is persisted to the apps shared preferences.

### Database

This app uses [Drift](https://drift.simonbinder.eu/) (formerly known as Moor), a
reactive persistence library for Flutter apps, which was inspired by Room for native
Android apps.

The database schema consists of four entities, which are defined in [tables.dart](lib/src/database/tables.dart):
Category, Item, Lending, Person.

A `Lending` links an `Item` to a `Person` and has a **date**, a flag, whether the
`Item` is **lent** from or **borrowed** to that `Person`, as well as a **return date**,
for when the `Item` is returned to or by that `Person`. The dates are stored in the
database as ISO 8601 strings. An `Item` has a **name** and may have a `Category`.
Both, a `Category` and a `Person` only have a **name**.

### Localization

This project generates localized messages based on arb files found in the [localization](lib/src/localization) directory.

This app currently supports German and English locales.

To support additional languages, please visit the tutorial on [Internationalizing Flutter apps](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)

### Testing

The database schema is tested with the database tests located in [database_test.dart](test/database_test.dart).  
Widget tests have yet to be written.

## License

MIT
