import 'package:flutter/material.dart';

class IrisArt extends StatelessWidget {
  const IrisArt(
      {super.key,
      this.size = 180,
      this.variant = 0,
      this.background = const Color(0xFFE8F5E9)});
  final double size;
  final int variant;
  final Color background;
  @override
  Widget build(BuildContext context) {
    final asset = switch (variant) {
      0 => 'assets/images/flowers/iris_setosa.jpg',
      1 => 'assets/images/flowers/iris_versicolor.jpg',
      2 => 'assets/images/flowers/iris_virginica.jpg',
      _ => null,
    };
    final radius = BorderRadius.circular(size * 0.18);

    return Semantics(
      label: asset == null
          ? 'Iris flower photograph unavailable'
          : 'Iris flower photograph',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: asset == null
            ? const _FallbackFlower()
            : Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _FallbackFlower(),
              ),
      ),
    );
  }
}

class _FallbackFlower extends StatelessWidget {
  const _FallbackFlower();
  @override
  Widget build(BuildContext context) => Center(
        child: Icon(
          Icons.local_florist_outlined,
          size: 42,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.icon,
      this.busy = false});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
          onPressed: busy ? null : onPressed,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(icon ?? Icons.arrow_forward_rounded),
          label: Text(label),
          style: FilledButton.styleFrom(
              minimumSize: const Size(48, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17)),
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))));
}
