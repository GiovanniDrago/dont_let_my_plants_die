import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LocationSetupScreen extends StatelessWidget {
  const LocationSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(
                l10n.locationSetupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.locationSetupSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Placeholder: will be replaced in Phase 1d
                  },
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
