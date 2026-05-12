import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

import '../models/location.dart';
import '../services/open_meteo_service.dart';

class LocationSearchField extends StatefulWidget {
  final ValueChanged<AppLocation>? onLocationSelected;
  final String? label;

  const LocationSearchField({
    super.key,
    this.onLocationSelected,
    this.label,
  });

  @override
  State<LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<LocationSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<AppLocation> _suggestions = [];
  bool _isLoading = false;
  bool _notFound = false;
  bool _showSuggestions = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.trim().length < 2) {
        setState(() {
          _suggestions = [];
          _notFound = false;
          _showSuggestions = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _notFound = false;
        _showSuggestions = true;
      });

      try {
        final l10n = AppLocalizations.of(context)!;
        final lang = l10n.localeName;
        final results = await OpenMeteoService.searchLocation(query, lang);
        // Deduplicate by unique key, keeping first occurrence
        final seen = <String>{};
        final deduped = <AppLocation>[];
        for (final loc in results) {
          if (seen.add(loc.uniqueKey)) {
            deduped.add(loc);
          }
        }
        if (mounted) {
          setState(() {
            _suggestions = deduped;
            _notFound = deduped.isEmpty;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _notFound = true;
            _suggestions = [];
          });
        }
      }
    });
  }

  void _selectLocation(AppLocation location) {
    _controller.text = location.displayName;
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    widget.onLocationSelected?.call(location);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label ?? l10n.searchLocation,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _suggestions = [];
                            _notFound = false;
                            _showSuggestions = false;
                          });
                        },
                      )
                    : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
        ),
        if (_notFound)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              l10n.locationNotFound,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final loc = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(loc.displayName),
                  subtitle: loc.detailLabel != loc.displayName
                      ? Text(
                          loc.detailLabel.substring(loc.displayName.length).trimLeft().replaceFirst('• ', ''),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                  leading: const Icon(Icons.location_on_outlined),
                  onTap: () => _selectLocation(loc),
                );
              },
            ),
          ),
      ],
    );
  }
}
