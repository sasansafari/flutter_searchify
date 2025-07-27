// searchify_refactored.dart
library searchify;

import 'dart:async';
import 'package:flutter/material.dart';

typedef SearchCity<T> = Future<List<T>> Function(String keyword);
typedef ListItem<T> = Widget Function(T model);

class SearchifyStyle {
  final InputDecoration searchInputDecoration;
  final BoxDecoration searchBoxDecoration;
  final BoxDecoration itemDecoration;
  final BoxDecoration listBoxDecoration;
  final EdgeInsets itemPadding;
  final EdgeInsets itemMargin;
  final EdgeInsets searchInputPadding;
  final EdgeInsets searchInputMargin;

  const SearchifyStyle({
    this.searchInputDecoration = const InputDecoration(hintText: 'Search...'),
    this.searchBoxDecoration = const BoxDecoration(),
    this.itemDecoration = const BoxDecoration(),
    this.listBoxDecoration = const BoxDecoration(),
    this.itemPadding = const EdgeInsets.all(0),
    this.itemMargin = const EdgeInsets.all(0),
    this.searchInputPadding = const EdgeInsets.all(0),
    this.searchInputMargin = const EdgeInsets.all(0),
  });
}

class Searchify<T> extends StatefulWidget {
  final TextEditingController searchController;
  final SearchCity<T>? onSearch;
  final Function(T) itemOnTap;
  final ListItem<T> itemBuilder;
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
  final SearchifyStyle style;

  const Searchify({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.itemOnTap,
    required this.itemBuilder,
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
    this.style = const SearchifyStyle(),
  });

  @override
  State<Searchify<T>> createState() => _SearchifyState<T>();
}

class _SearchifyState<T> extends State<Searchify<T>> {
  final GlobalKey _overlayKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  late final FocusNode _focusNode;

  OverlayEntry? _overlayEntry;
  List<T> _filteredItems = <T>[];
  Timer? _debounce;
  bool _isItemSelected = false;

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
    if (widget.searchController.text.isNotEmpty && _filteredItems.isNotEmpty) {
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

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + 50,
        width: widget.listWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: widget.style.listBoxDecoration,
              constraints: const BoxConstraints(maxHeight: 300),
              child: widget.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => widget.separator,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return InkWell(
                          onTap: () {
                            if (widget.clearOnItemTap) _filteredItems.clear();
                            _removeOverlay();
                            widget.itemOnTap(item);
                            setState(() => _isItemSelected = true);
                          },
                          child: Container(
                            decoration: widget.style.itemDecoration,
                            padding: widget.style.itemPadding,
                            margin: widget.style.itemMargin,
                            child: widget.itemBuilder(item),
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
                        _removeOverlay();
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
