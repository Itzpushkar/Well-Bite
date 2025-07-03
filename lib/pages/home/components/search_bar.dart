import 'package:flutter/material.dart';

class SearchBar1 extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final String hintText;
  final Color currentThemeColor;

  const SearchBar1({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.hintText,
    required this.onClear,
    required this.currentThemeColor,
  });

  @override
  State<SearchBar1> createState() => _SearchBar1State();
}

class _SearchBar1State extends State<SearchBar1> {
  final FocusNode _focusNode = FocusNode();
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_updateClearIcon);
    _showClear = widget.controller.text.isNotEmpty;
  }

  void _handleFocusChange() {
    setState(() {
      _showClear = widget.controller.text.isNotEmpty;
    });
  }

  void _updateClearIcon() {
    setState(() {
      _showClear = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_updateClearIcon);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                focusNode: _focusNode,
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                ),
                onChanged: (_) => _updateClearIcon(),
                onSubmitted: (_) => widget.onSearch(),
              ),
            ),
          ),
          if (_showClear) const SizedBox(width: 10),
          if (_showClear)
            _iconCircleButton(
              icon: Icons.clear,
              onTap: () {
                widget.controller.clear(); // clear field
                _updateClearIcon();
                setState(() {
                  widget.onClear();
                });// hide clear icon
              },
            ),
          const SizedBox(width: 10),
          _iconCircleButton(icon: Icons.search, onTap: widget.onSearch),
        ],
      ),
    );
  }

  Widget _iconCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:widget.currentThemeColor,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
