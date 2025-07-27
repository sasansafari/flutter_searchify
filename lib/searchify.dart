library searchify;

import 'dart:async';
import 'package:flutter/material.dart';

/// Function type for performing search
typedef SearchCity<T> = Future<List<T>> Function(String keyword);

/// Function type for building each item
typedef ListItem<T> = Widget Function(T model);

class Searchify<T> extends StatefulWidget {
  final TextEditingController searchController;
  final InputDecoration searchInputDecoration;
  final BoxDecoration searchBoxDecoration;
  final BoxDecoration itemDecoration;
  final BoxDecoration listBoxDecoration;
  final EdgeInsets itemPadding;
  final EdgeInsets itemMargin;
  final EdgeInsets searchInputPadding;
  final EdgeInsets searchInputMargin;
  final Function(T) itemOnTap;
  final Function()? onTap;
  final TextAlign searchFieldTextAlign;
  final TextAlign itemTextAlign;
  final double listWidth;
  final SearchCity<T>? onSearch;
  final Widget? suffixIcon;
  final Widget separator;
  final ListItem<T> itemBuilder;
  final bool enabled;
  final bool isLoading;
  final bool inSelectedMode;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final FocusOrder order;
  final TextDirection? textDirection;

  const Searchify({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.itemOnTap,
    required this.itemBuilder,
    this.searchInputDecoration = const InputDecoration(hintText: 'Search...'),
    this.itemDecoration = const BoxDecoration(),
    this.searchBoxDecoration = const BoxDecoration(),
    this.listBoxDecoration = const BoxDecoration(),
    this.itemPadding = const EdgeInsets.all(0),
    this.itemMargin = const EdgeInsets.all(0),
    this.searchInputPadding = const EdgeInsets.all(0),
    this.searchInputMargin = const EdgeInsets.all(0),
    this.separator = const SizedBox.shrink(),
    this.listWidth = 200,
    this.isLoading = false,
    this.enabled = true,
    this.inSelectedMode = true,
    this.suffixIcon,
    this.onTap,
    this.textStyle,
    this.focusNode,
    this.order = const NumericFocusOrder(0),
    this.searchFieldTextAlign = TextAlign.start,
    this.itemTextAlign = TextAlign.start,
    this.textDirection,
  });

  @override
  State<Searchify<T>> createState() => _SearchifyState<T>();
}

class _SearchifyState<T> extends State<Searchify<T>> {
  final GlobalKey _overlayKey = GlobalKey();
  List<T> _filteredItems = <T>[];
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  bool _isItemSelected = false;

  @override
  void initState() {
    super.initState();
    _isItemSelected = widget.inSelectedMode;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _debounce?.cancel();
    super.dispose();
  }

  void _toggleOverlay() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
      if (widget.searchController.text.isNotEmpty &&
          _filteredItems.isNotEmpty) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  Future<List<T>> _getFilteredItems(String searchValue) async {
    if (widget.onSearch != null) {
      return await widget.onSearch!(searchValue);
    }
    return [];
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          _filteredItems.clear();
          widget.focusNode?.unfocus();
        },
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy + 50,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: widget.listWidth,
                  decoration: widget.listBoxDecoration,
                  child: widget.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 300,
                          child: ListView.separated(
                            itemCount: _filteredItems.length,
                            separatorBuilder: (_, __) => widget.separator,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              return GestureDetector(
                                onTap: () {
                                  _filteredItems.clear();
                                  _overlayEntry?.remove();
                                  _overlayEntry = null;
                                  widget.itemOnTap(item);
                                  _isItemSelected = true;
                                  setState(() {});
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: widget.itemDecoration,
                                  padding: widget.itemPadding,
                                  margin: widget.itemMargin,
                                  child: widget.itemBuilder(item),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled ? !_isItemSelected : false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _overlayEntry?.remove();
        _overlayEntry = null;
        _filteredItems.clear();
        widget.focusNode?.unfocus();
        widget.onTap?.call();
      },
      child: Container(
        key: _overlayKey,
        padding: widget.searchInputPadding,
        margin: widget.searchInputMargin,
        decoration: widget.searchBoxDecoration,
        child: Row(
          children: [
            if (_isItemSelected)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isItemSelected = false;
                    widget.searchController.clear();
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.clear, size: 18),
                ),
              ),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.text,
                enabled: isEnabled,
                style: widget.textStyle,
                textAlign: widget.searchFieldTextAlign,
                textDirection: widget.textDirection,
                controller: widget.searchController,
                decoration: widget.searchInputDecoration.copyWith(
                  suffixIcon: widget.suffixIcon != null
                      ? GestureDetector(
                          onTap: () async {
                            // _filteredItems = await _getFilteredItems(
                            //   widget.searchController.text,
                            // );
                            // setState(() => _toggleOverlay());
                            _filteredItems = await _getFilteredItems(
                                widget.searchController.text);
                            setState(() {});
                            _toggleOverlay();
                          },
                          child: widget.suffixIcon!,
                        )
                      : null,
                ),
                onChanged: (value) async {
                  if (value.length >= 3) {
                    _filteredItems = await _getFilteredItems(value);
                    setState(() {});
                    _toggleOverlay();
                  }
                },
                onTap: _toggleOverlay,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
