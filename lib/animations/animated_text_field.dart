import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  final IconData icon;
  final String hint;
  final bool obscure;

  const AnimatedTextField({
    super.key,
    required this.icon,
    required this.hint,
    this.obscure = false,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: _isFocused ? 1.02 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: _isFocused
              ? [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ]
              : [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: TextField(
          focusNode: _focusNode,
          obscureText: widget.obscure,
          decoration: InputDecoration(
            icon: Icon(widget.icon, color: Colors.deepPurple),
            hintText: widget.hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
