# Lendix

A Flutter app to track items you borrowed from or lent to your friends.  
This app was created for my final project of Harvard University's CS50 certificate.
The name (for the lack of a better idea) is a portmanteau of the words `lending` and `index`.

The project code is structured by feature.

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

## License

MIT
