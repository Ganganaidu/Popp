import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:popp/src/utils/app_loger.dart';
import 'package:popp/src/utils/build_extensions.dart';

import '../utils/app_constants.dart';

// A model to represent a single search result from the TomTom API.
class PlaceSuggestion {
  final String placeId;
  final String text;
  final String? postalCode;
  final String? municipality;

  PlaceSuggestion({
    required this.placeId,
    required this.text,
    this.postalCode,
    this.municipality,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final address = json['address'];
    return PlaceSuggestion(
      placeId: json['id'],
      text: address['freeformAddress'],
      postalCode: address['postalCode'],
      municipality: address['municipality'],
    );
  }
}

// The reusable autocomplete widget.
class AutocompleteSearchField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController controller;
  final void Function(PlaceSuggestion suggestion) onPlaceSelected;
  final double? lat;
  final double? lon;
  final int? maxLines;
  final FormFieldValidator<String>? validator;

  const AutocompleteSearchField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onPlaceSelected,
    this.maxLines,
    this.icon,
    this.lat,
    this.lon,
    this.validator,
  });

  @override
  State<AutocompleteSearchField> createState() =>
      _AutocompleteSearchFieldState();
}

class _AutocompleteSearchFieldState extends State<AutocompleteSearchField> {
  List<PlaceSuggestion> _suggestions = [];
  Timer? _debounce;
  bool _isLoading = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isHandlingSelection = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    // This prevents searching when a selection is being processed.
    if (_isHandlingSelection) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (widget.controller.text.length > 2) {
        _fetchSuggestions(widget.controller.text);
      } else {
        setState(() {
          _suggestions = [];
          _removeOverlay();
        });
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    // This method remains unchanged
    setState(() => _isLoading = true);

    final encodedQuery = Uri.encodeComponent(query);
    var urlString =
        'https://api.tomtom.com/search/2/search/$encodedQuery.json?key=${Constants.tomPlacesApiKey}&typeahead=true&limit=10&countrySet=IN';
    // If lat and lon are provided, append them to the URL to bias search results
    if (widget.lat != null && widget.lon != null) {
      urlString += '&lat=${widget.lat}&lon=${widget.lon}';
    }
    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _suggestions = (data['results'] as List)
              .map((json) => PlaceSuggestion.fromJson(json))
              .toList();
        });
        if (_suggestions.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      AppLogger.e("Error fetching suggestions: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 8.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  title: Text(suggestion.text),
                  onTap: () {
                    setState(() {
                      _isHandlingSelection = true;
                      widget.controller.text = suggestion.text;
                      widget.onPlaceSelected(suggestion);
                      _suggestions = [];
                      _removeOverlay();
                      _isHandlingSelection = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        maxLines: widget.maxLines ?? 1,
        controller: widget.controller,
        decoration: context
            .inputDecoration(
              widget.label,
              widget.hint,
              icon: widget.icon,
            )
            .copyWith(
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
        validator: widget.validator,
      ),
    );
  }
}
