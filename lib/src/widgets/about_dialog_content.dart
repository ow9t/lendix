import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutDialogContent extends StatelessWidget {
  const AboutDialogContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final headingStyle = TextStyle(
      color: textTheme.bodyText1!.color,
      fontSize: textTheme.bodyText1!.fontSize,
      fontWeight: FontWeight.bold,
      height: 2,
    );
    final sectionStyle = TextStyle(
      color: textTheme.bodyText2!.color,
      fontSize: textTheme.bodyText2!.fontSize,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.aboutPrivacyHeading,
            style: headingStyle,
          ),
          Text(
            localizations.aboutPrivacySection,
            style: sectionStyle,
          ),
          Text(
            localizations.aboutLicensingHeading,
            style: headingStyle,
          ),
          Text(
            localizations.aboutLicensingSection,
            style: sectionStyle,
          ),
        ],
      ),
    );
  }
}
