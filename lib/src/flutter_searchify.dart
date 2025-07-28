library searchify;

import 'dart:async';
import 'package:flutter/material.dart';

typedef SearchObject<T> = Future<List<T>> Function(String keyword);
typedef ListItem<T> = Widget Function(T model);

/// A class that defines the styling options for [FlutterSearchify].
class Style {
  /// Decoration for the search input field container.
  final InputDecoration searchInputDecoration;

  /// Decoration for the outer search box container.
  final BoxDecoration searchBoxDecoration;

  /// Decoration for individual result items.
  final BoxDecoration itemDecoration;

  /// Decoration for the list of result items.
  final BoxDecoration listBoxDecoration;

  /// Padding for each item in the result list.
  final EdgeInsets itemPadding;

  /// Margin for each item in the result list.
  final EdgeInsets itemMargin;

  /// Padding around the search input field.
  final EdgeInsets searchInputPadding;

  /// Margin around the search input field.
  final EdgeInsets searchInputMargin;

  /// Creates a [Style] object for customizing the visual appearance of the search field and its results.
  const Style({
    this.searchInputDecoration = const InputDecoration(hintText: 'Search...'),
    this.searchBoxDecoration = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    this.listBoxDecoration = const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    this.itemDecoration = const BoxDecoration(),
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    this.itemMargin = EdgeInsets.zero,
    this.searchInputPadding =
        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
    this.searchInputMargin = EdgeInsets.zero,
  });
}

/// A highly customizable search bar widget with live results and history dropdown.
///
/// Supports asynchronous searching, debounce, styling, overlay positioning,
/// item builders, highlighting, and focus handling.
class FlutterSearchify<T> extends StatefulWidget {
  /// The controller for the search input text.
  final TextEditingController searchController;

  /// Async search function called on input changes.
  final SearchObject<T>? onSearch;

  /// Callback triggered when an item is selected.
  final Function(T) itemOnTap;

  /// Custom builder for list items.
  final ListItem<T>? itemBuilder;

  /// Optional suffix icon to show at the end of the input field.
  final Widget? suffixIcon;

  /// Widget between list items.
  final Widget separator;

  /// Whether the input field is enabled.
  final bool enabled;

  /// Shows a loading indicator in the dropdown when true.
  final bool isLoading;

  /// Whether to enter selection mode when an item is tapped.
  final bool inSelectedMode;

  /// Tap callback on the input field.
  final Function()? onTap;

  /// Text style for the input.
  final TextStyle? textStyle;

  /// Text alignment for the input field.
  final TextAlign searchFieldTextAlign;

  /// Text alignment for list items.
  final TextAlign itemTextAlign;

  /// Width of the list overlay.
  final double listWidth;

  /// Text direction of the entire widget.
  final TextDirection? textDirection;

  /// Whether to clear the search field when item tapped.
  final bool clearOnItemTap;

  /// Optional focus node to manage keyboard focus.
  final FocusNode? focusNode;

  /// Focus traversal order.
  final FocusOrder order;

  /// Styling for all parts of the widget.
  final Style style;

  /// Optional fixed width for the dropdown overlay.
  final double? overlayWidth;

  /// Creates a [FlutterSearchify] widget.
  const FlutterSearchify({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.itemOnTap,
    this.itemBuilder,
    this.suffixIcon,
    this.separator = const SizedBox.shrink(),
    this.listWidth = 200,
    this.isLoading = false,
    this.enabled = true,
    this.inSelectedMode = true,
    this.onTap,
    this.textStyle,
    this.focusNode,
    this.order = const NumericFocusOrder(0),
    this.searchFieldTextAlign = TextAlign.start,
    this.itemTextAlign = TextAlign.start,
    this.textDirection,
    this.clearOnItemTap = true,
    this.style = const Style(),
    this.overlayWidth,
  });

  @override
  State<FlutterSearchify<T>> createState() => _FlutterSearchifyState<T>();

  /// Highlights the parts of [text] that match the [query] string.
  ///
  /// This method returns a [RichText] widget with matching substrings highlighted
  /// using a yellow background and bold font. If the query is empty, it simply
  /// returns the original [text] wrapped in a [Text] widget.
  ///
  /// Useful for displaying search results where you want to visually
  /// emphasize the parts of the text that match the user's input.
  ///
  /// Example:
  /// ```dart
  /// highlightMatch('Flutter Searchify', 'search')
  /// ```
  /// will return a widget with the word "Search" highlighted.
  Widget highlightMatch(String text, String query) {
    if (query.isEmpty) return Text(text);
    final lcText = text.toLowerCase();
    final lcQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;
    int index = lcText.indexOf(lcQuery);

    while (index >= 0) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = index + query.length;
      index = lcText.indexOf(lcQuery, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: spans,
      ),
    );
  }
}

class _FlutterSearchifyState<T> extends State<FlutterSearchify<T>> {
  final GlobalKey _overlayKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  late final FocusNode _focusNode;

  OverlayEntry? _overlayEntry;
  List<T> _filteredItems = <T>[];
  Timer? _debounce;
  bool _isItemSelected = false;

  List<T> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _isItemSelected = widget.inSelectedMode;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _overlayEntry?.remove();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  /// Removes the search results overlay from the screen if present.

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Shows or hides the search results overlay based on input and results.
  ///
  /// Displays either the filtered items or recent search history
  /// depending on whether the search input is empty.

  void _toggleOverlay() {
    _removeOverlay();
    if ((widget.searchController.text.isNotEmpty &&
            _filteredItems.isNotEmpty) ||
        (widget.searchController.text.isEmpty && _searchHistory.isNotEmpty)) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  /// Performs a debounced search using the provided keyword [value].
  ///
  /// Only triggers the search if the input length is at least 3 characters.
  /// Waits 300 milliseconds before executing [widget.onSearch] to reduce redundant calls.
  /// Updates the [_filteredItems] and toggles the overlay with results.

  Future<void> _search(String value) async {
    if (value.length < 3 || widget.onSearch == null) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final results = await widget.onSearch!(value);
      setState(() {
        _filteredItems = results;
      });
      _toggleOverlay();
    });
  }

  void _addToHistory(T item) {
    setState(() {
      _searchHistory.remove(item);
      _searchHistory.add(item);
      if (_searchHistory.length > 4) {
        _searchHistory.removeAt(0);
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox =
        _overlayKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox());
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final height = renderBox.size.height;
    final width = renderBox.size.width;

    final showHistory =
        widget.searchController.text.isEmpty && _searchHistory.isNotEmpty;
    final displayList =
        showHistory ? List<T>.from(_searchHistory.reversed) : _filteredItems;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + height,
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, height),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: widget.style.listBoxDecoration,
              constraints: const BoxConstraints(maxHeight: 300),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: displayList.length,
                      separatorBuilder: (_, __) => widget.separator,
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        return InkWell(
                          onTap: () {
                            if (widget.clearOnItemTap) _filteredItems.clear();
                            _removeOverlay();
                            widget.itemOnTap(item);
                            _addToHistory(item);
                            setState(() => _isItemSelected = true);
                          },
                          child: Container(
                            decoration: widget.style.itemDecoration,
                            padding: widget.style.itemPadding,
                            margin: widget.style.itemMargin,
                            child: widget.itemBuilder != null
                                ? widget.itemBuilder!(item)
                                : widget.highlightMatch(item.toString(),
                                    widget.searchController.text),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _removeOverlay();
        _filteredItems.clear();
        _focusNode.unfocus();
        widget.onTap?.call();
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          key: _overlayKey,
          padding: widget.style.searchInputPadding,
          margin: widget.style.searchInputMargin,
          decoration: widget.style.searchBoxDecoration,
          child: Row(
            children: [
              if (_isItemSelected && widget.searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() {
                    _isItemSelected = false;
                    widget.searchController.clear();
                    _filteredItems.clear();
                    _removeOverlay();
                  }),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.clear, size: 18),
                  ),
                ),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: widget.searchController,
                  enabled: isEnabled,
                  style: widget.textStyle,
                  textAlign: widget.searchFieldTextAlign,
                  textDirection: widget.textDirection,
                  decoration: widget.style.searchInputDecoration.copyWith(
                    suffixIcon: widget.suffixIcon != null
                        ? GestureDetector(
                            onTap: () async {
                              await _search(widget.searchController.text);
                            },
                            child: widget.suffixIcon!,
                          )
                        : null,
                  ),
                  onTap: _toggleOverlay,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        _filteredItems.clear();
                        _toggleOverlay();
                      });
                    } else {
                      _search(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
