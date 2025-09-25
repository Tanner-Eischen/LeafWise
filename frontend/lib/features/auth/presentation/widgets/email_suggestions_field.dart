import 'package:flutter/material.dart';
import 'package:leafwise/core/services/preferences_service.dart';
import 'package:leafwise/features/auth/presentation/widgets/auth_text_field.dart';

/// Custom email field with suggestions dropdown
/// Shows previously used emails as suggestions while typing
class EmailSuggestionsField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
  final Function(String)? onChanged;

  const EmailSuggestionsField({
    super.key,
    required this.controller,
    this.label = 'Email',
    this.hintText = 'Enter your email',
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  State<EmailSuggestionsField> createState() => _EmailSuggestionsFieldState();
}

class _EmailSuggestionsFieldState extends State<EmailSuggestionsField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
    _loadSuggestions();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  /// Load email suggestions from preferences
  void _loadSuggestions() {
    setState(() {
      _suggestions = PreferencesService.getEmailSuggestions();
    });
  }

  /// Handle focus changes to show/hide suggestions
  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showSuggestionsOverlay();
    } else {
      _hideSuggestionsOverlay();
    }
  }

  /// Handle text changes to filter suggestions
  void _onTextChanged() {
    final query = widget.controller.text;
    final filteredSuggestions = PreferencesService.getFilteredEmailSuggestions(query);
    
    setState(() {
      _suggestions = filteredSuggestions;
    });

    if (_focusNode.hasFocus && _suggestions.isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _hideSuggestionsOverlay();
    }

    widget.onChanged?.call(query);
  }

  /// Show the suggestions overlay
  void _showSuggestionsOverlay() {
    if (_suggestions.isEmpty || _showSuggestions) return;

    _showSuggestions = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide the suggestions overlay
  void _hideSuggestionsOverlay() {
    if (!_showSuggestions) return;

    _showSuggestions = false;
    _removeOverlay();
  }

  /// Remove the overlay entry
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Create the suggestions overlay
  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return _buildSuggestionItem(suggestion);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build a single suggestion item
  Widget _buildSuggestionItem(String suggestion) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _selectSuggestion(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: () => _removeSuggestion(suggestion),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Select a suggestion and fill the field
  void _selectSuggestion(String suggestion) {
    widget.controller.text = suggestion;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    _hideSuggestionsOverlay();
    widget.onChanged?.call(suggestion);
  }

  /// Remove a suggestion from the list
  void _removeSuggestion(String suggestion) async {
    await PreferencesService.removeEmailSuggestion(suggestion);
    _loadSuggestions();
    
    if (_suggestions.isEmpty) {
      _hideSuggestionsOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AuthTextField(
        controller: widget.controller,
        focusNode: _focusNode,
        label: widget.label,
        hintText: widget.hintText,
        keyboardType: TextInputType.emailAddress,
        prefixIcon: Icons.email_outlined,
        validator: widget.validator,
        textInputAction: widget.textInputAction,
        autofillHints: const [AutofillHints.email],
        onSubmitted: (_) => widget.onSubmitted?.call(),
        suffixIcon: _suggestions.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () {
                  if (_showSuggestions) {
                    _hideSuggestionsOverlay();
                  } else {
                    _focusNode.requestFocus();
                    _showSuggestionsOverlay();
                  }
                },
              )
            : null,
      ),
    );
  }
}