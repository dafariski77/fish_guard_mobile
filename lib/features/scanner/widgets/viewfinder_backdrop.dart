import 'package:material_ui/material_ui.dart';

/// Single Responsibility widget that renders the simulated camera background gradient.
class ViewfinderBackdrop extends StatelessWidget {
  const ViewfinderBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            const Color(0xFF1E293B),
            Colors.black.withAlpha(240),
          ],
        ),
      ),
      child: const Center(
        child: Opacity(
          opacity: 0.15,
          child: Icon(
            Icons.set_meal_rounded,
            size: 280,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
