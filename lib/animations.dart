import 'package:flutter/material.dart';
import 'dart:async';

// 1️⃣ Bounce Pop Animation (for Categories blocks)
class BounceInWidget extends StatefulWidget {
  final Widget child;
  final int delayMilliseconds;

  const BounceInWidget({
    super.key,
    required this.child,
    this.delayMilliseconds = 0,
  });

  @override
  State<BounceInWidget> createState() => _BounceInWidgetState();
}

class _BounceInWidgetState extends State<BounceInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
      if (mounted) {
        setState(() => _visible = true);
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _visible ? 1 : 0,
      child: ScaleTransition(scale: _animation, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 2️⃣ Fade + Slide In (for Vendor List, one-by-one)
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;

  const FadeSlideIn({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(opacity: _opacityAnimation, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 3️⃣ Card Press Scale Animation

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AnimatedButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// 4️⃣ Image Fade-In Animation
class FadeInImageWidget extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;

  const FadeInImageWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      height: height,
      width: width,
      frameBuilder: (context, child, frame, _) {
        if (frame == null) {
          return Opacity(opacity: 0, child: child);
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 400),
          child: child,
        );
      },
    );
  }
}


// 5️⃣ Handshake Calm Fade-In Animation
class HandshakeFadeIn extends StatefulWidget {
  final String assetPath; // e.g., 'assets/images/handshake.png'
  final double height;
  final double width;

  const HandshakeFadeIn({
    super.key,
    required this.assetPath,
    this.height = 200,
    this.width = 200,
  });

  @override
  State<HandshakeFadeIn> createState() => _HandshakeFadeInState();
}

class _HandshakeFadeInState extends State<HandshakeFadeIn> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(seconds: 1),
      child: Image.asset(
        widget.assetPath,
        height: widget.height,
        width: widget.width,
      ),
    );
  }
}