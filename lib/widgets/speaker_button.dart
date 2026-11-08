import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/context_ext.dart';
import '../data/services/tts_service.dart';

/// Round speaker button that pronounces [text] with text-to-speech.
class SpeakerButton extends StatefulWidget {
  const SpeakerButton({
    super.key,
    required this.text,
    required this.languageCode,
    this.size = 44,
    this.color,
    this.filled = true,
  });

  final String text;
  final String languageCode;
  final double size;
  final Color? color;
  final bool filled;

  @override
  State<SpeakerButton> createState() => _SpeakerButtonState();
}

class _SpeakerButtonState extends State<SpeakerButton> {
  bool _speaking = false;

  Future<void> _speak() async {
    if (_speaking) return;
    setState(() => _speaking = true);
    final ok = await context.read<TtsService>().speak(
      widget.text,
      widget.languageCode,
    );
    if (!mounted) return;
    setState(() => _speaking = false);
    if (!ok) {
      context.showSnack(
        'Audio is not available on this device.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? context.colors.primary;
    return Semantics(
      button: true,
      label: 'Play pronunciation',
      child: Material(
        color: widget.filled
            ? color.withValues(alpha: 0.12)
            : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _speak,
          child: SizedBox.square(
            dimension: widget.size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                _speaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                key: ValueKey(_speaking),
                color: color,
                size: widget.size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
