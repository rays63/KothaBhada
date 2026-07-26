import 'package:flutter/material.dart';

import '../../../widgets/kit/kit.dart';

/// Brand-gradient splash (design screen 01).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: t.brandGradient),
        child: Stack(
          children: [
            const Positioned(
              top: -40,
              right: -40,
              child: GlowBlob(color: Color(0xFF5EEAD4), size: 260, opacity: 0.5),
            ),
            const Positioned(
              bottom: 0,
              left: -60,
              child: GlowBlob(color: Color(0xFF0F6E5C), size: 220, opacity: 0.6),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 50,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.home_work_rounded,
                        color: Colors.white, size: 46),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Kothabhada',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Rent, tracked — even offline',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.4,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
