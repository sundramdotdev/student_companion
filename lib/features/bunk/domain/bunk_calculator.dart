import 'dart:math';

class BunkCalculationResult {
  final double currentPercentage;
  final bool isSafe;
  final int maxBunksAllowed;
  final int recoveryClassesNeeded;
  final String statusMessage;

  BunkCalculationResult({
    required this.currentPercentage,
    required this.isSafe,
    required this.maxBunksAllowed,
    required this.recoveryClassesNeeded,
    required this.statusMessage,
  });
}

class BunkCalculator {
  static BunkCalculationResult calculate({
    required int present,
    required int total,
    required double requiredPercent,
  }) {
    final double percent = total == 0 ? 100.0 : (present / total) * 100.0;
    final bool isSafe = percent >= requiredPercent;
    
    int maxBunks = 0;
    int recovery = 0;
    String message = '';

    if (isSafe) {
      // How many classes can be missed
      // (present) / (total + B) >= req / 100
      // present * 100 / req >= total + B
      // B <= (present * 100 / req) - total
      if (requiredPercent > 0) {
        final maxTotal = (present * 100.0) / requiredPercent;
        maxBunks = max(0, (maxTotal - total).floor());
      } else {
        maxBunks = 999; // 0% required
      }
      
      message = maxBunks > 0
          ? 'You can safely miss the next $maxBunks class(es).'
          : 'You are exactly on the margin. Cannot miss any more classes!';
    } else {
      // Recovery calculation
      // (present + C) / (total + C) >= req / 100
      // (present + C) * 100 >= req * (total + C)
      // 100 * present + 100 * C >= req * total + req * C
      // (100 - req) * C >= req * total - 100 * present
      // C >= (req * total - 100 * present) / (100 - req)
      final denominator = 100.0 - requiredPercent;
      if (denominator > 0) {
        final numerator = (requiredPercent * total) - (100.0 * present);
        recovery = max(0, (numerator / denominator).ceil());
      } else {
        recovery = 999; // 100% required and currently below it, mathematically impossible if you've missed a class
      }

      message = 'Attend the next $recovery class(es) continuously to recover to $requiredPercent%.';
    }

    return BunkCalculationResult(
      currentPercentage: percent,
      isSafe: isSafe,
      maxBunksAllowed: maxBunks,
      recoveryClassesNeeded: recovery,
      statusMessage: message,
    );
  }
}
