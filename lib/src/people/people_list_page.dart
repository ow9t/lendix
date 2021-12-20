import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';
import '../widgets/asciimoji_shrug.dart';
import 'people_cubit.dart';
import 'people_list_view.dart';

class PeopleListPage extends StatelessWidget {
  const PeopleListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => PeopleCubit(context.read<MyDatabase>().peopleDao),
      child: BlocBuilder<PeopleCubit, List<Person>?>(
        builder: (context, state) {
          if (state == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isEmpty) {
            return Center(
              child: AsciimojiShrug(label: localizations.peopleEmptyList),
            );
          }
          return PeopleListView(people: state);
        },
      ),
    );
  }
}
