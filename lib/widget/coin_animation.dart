import 'package:flutter/material.dart';

class CoinFlyAnimation {
  static void fly({
    required BuildContext context,
    required GlobalKey fromKey,
    required GlobalKey toKey,
  }) {
    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final fromBox = fromKey.currentContext?.findRenderObject() as RenderBox?;
    final toBox = toKey.currentContext?.findRenderObject() as RenderBox?;
    if (fromBox == null || toBox == null) return;

    final fromPos = fromBox.localToGlobal(Offset.zero);
    final toPos = toBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return _FlyingCoin(from: fromPos, to: toPos);
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 700), () {
      overlayEntry.remove();
    });
  }
}

class _FlyingCoin extends StatefulWidget {
  final Offset from;
  final Offset to;

  const _FlyingCoin({required this.from, required this.to});

  @override
  State<_FlyingCoin> createState() => _FlyingCoinState();
}

class _FlyingCoinState extends State<_FlyingCoin>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> position;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    position = Tween<Offset>(
      begin: widget.from,
      end: widget.to,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Positioned(
            left: position.value.dx,
            top: position.value.dy,
            child: Icon(Icons.monetization_on, color: Colors.amber, size: 32),
          );
        },
      ),
    );
  }
}
