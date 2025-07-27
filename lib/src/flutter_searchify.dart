library searchify;

import 'dart:async';
import 'package:flutter/material.dart';

typedef SearchObject<T> = Future<List<T>> Function(String keyword);
typedef ListItem<T> = Widget Function(T model);

class Style {
  final InputDecoration searchInputDecoration;
  final BoxDecoration searchBoxDecoration;
  final BoxDecoration itemDecoration;
  final BoxDecoration listBoxDecoration;
  final EdgeInsets itemPadding;
  final EdgeInsets itemMargin;
  final EdgeInsets searchInputPadding;
  final EdgeInsets searchInputMargin;

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

class FlutterSearchify<T> extends StatefulWidget {
  final TextEditingController searchController;
  final SearchObject<T>? onSearch;
  final Function(T) itemOnTap;
  final ListItem<T>? itemBuilder;
  final Widget? suffixIcon;
  final Widget separator;
  final bool enabled;
  final bool isLoading;
  final bool inSelectedMode;
  final Function()? onTap;
  final TextStyle? textStyle;
  final TextAlign searchFieldTextAlign;
  final TextAlign itemTextAlign;
  final double listWidth;
  final TextDirection? textDirection;
  final bool clearOnItemTap;
  final FocusNode? focusNode;
  final FocusOrder order;
  final Style style;
  final double? overlayWidth;

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

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleOverlay() {
    _removeOverlay();
    if ((widget.searchController.text.isNotEmpty &&
            _filteredItems.isNotEmpty) ||
        (widget.searchController.text.isEmpty && _searchHistory.isNotEmpty)) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

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
