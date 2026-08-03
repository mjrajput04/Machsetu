import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Six-box OTP entry with auto-advance, backspace-to-previous and paste support.
class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.length = 6,
    this.hasError = false,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final int length;
  final bool hasError;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers = List.generate(
    widget.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _nodes = List.generate(
    widget.length,
    (_) => FocusNode(),
  );

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _handleChange(int index, String value) {
    // Handle a pasted / autofilled block of digits.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = digits.length.clamp(0, widget.length - 1);
      _nodes[next].requestFocus();
    } else if (value.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }

    setState(() {});
    widget.onChanged(_code);
    if (_code.length == widget.length) {
      _nodes[index].unfocus();
      widget.onCompleted?.call(_code);
    }
  }

  KeyEventResult _handleKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _nodes[index - 1].requestFocus();
      setState(() {});
      widget.onChanged(_code);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        final filled = _controllers[index].text.isNotEmpty;
        final focused = _nodes[index].hasFocus;

        return Flexible(
          child: Padding(
            padding: EdgeInsets.only(right: index == widget.length - 1 ? 0 : 8),
            child: AspectRatio(
              aspectRatio: 0.82,
              child: Focus(
                onKeyEvent: (_, event) => _handleKey(index, event),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: filled ? Colors.white : AppColors.fieldFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.hasError
                          ? AppColors.danger
                          : focused
                              ? AppColors.navy
                              : filled
                                  ? AppColors.navy.withValues(alpha: 0.4)
                                  : AppColors.border,
                      width: focused || widget.hasError ? 1.6 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _nodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) => _handleChange(index, value),
                    onTap: () => setState(() {}),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
