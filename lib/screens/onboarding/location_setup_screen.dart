import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../models/location.dart';
import '../../services/cache_service.dart';
import '../../widgets/location_search_field.dart';

class LocationSetupScreen extends ConsumerStatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  ConsumerState<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  AppLocation? _selectedLocation;

  Future<void> _save() async {
    if (_selectedLocation == null) return;
    await CacheService.setMainLocation(_selectedLocation!.toJson());
    if (mounted) {
      // Navigate to main app — replaced in Phase 1h
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Main screen placeholder')))),
      );
    }
  }

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
              LocationSearchField(
                onLocationSelected: (loc) {
                  setState(() {
                    _selectedLocation = loc;
                  });
                },
              ),
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Chip(
                    avatar: const Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      _selectedLocation!.displayName,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedLocation != null ? _save : null,
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
