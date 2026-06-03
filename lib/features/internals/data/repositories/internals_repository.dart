import '../../../../core/storage/hive_service.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../domain/entities/assessment.dart';

class InternalsRepository {
  final NotificationService _notificationService;

  InternalsRepository({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  List<Assessment> getAssessments() {
    return HiveService.assessmentsBox.values.toList();
  }

  List<Assessment> getAssessmentsForSubject(String subjectId) {
    return HiveService.assessmentsBox.values
        .where((a) => a.subjectId == subjectId)
        .toList();
  }

  Future<void> saveAssessment(Assessment assessment) async {
    await HiveService.assessmentsBox.put(assessment.id, assessment);
    
    // Set notification reminders if due date is in the future
    if (assessment.dueDate != null && assessment.dueDate!.isAfter(DateTime.now())) {
      final daysBefore = 1; // 1 day before reminder
      final reminderTime = assessment.dueDate!.subtract(Duration(days: daysBefore));
      
      await _notificationService.scheduleSpecificAlert(
        id: assessment.id.hashCode,
        title: 'Assessment Deadline Reminder',
        body: '${assessment.type}: ${assessment.name} is due tomorrow.',
        scheduledDate: reminderTime,
      );
    }
  }

  Future<void> deleteAssessment(String id) async {
    await HiveService.assessmentsBox.delete(id);
    await _notificationService.cancelNotification(id.hashCode);
  }

  // Calculates stats for a subject
  // 1. Current weighted marks obtained
  // 2. Sum of weightage evaluated so far
  // 3. Overall internal marks percentage
  Map<String, dynamic> calculateSubjectInternalStats(String subjectId) {
    final assessments = getAssessmentsForSubject(subjectId);
    if (assessments.isEmpty) {
      return {
        'earnedWeighted': 0.0,
        'totalWeightage': 0.0,
        'percentage': 0.0,
      };
    }

    double earnedWeighted = 0.0;
    double totalWeightage = 0.0;

    for (final assessment in assessments) {
      if (assessment.maxMarks > 0) {
        final earned = (assessment.obtainedMarks / assessment.maxMarks) * assessment.weightage;
        earnedWeighted += earned;
        totalWeightage += assessment.weightage;
      }
    }

    final double percentage = totalWeightage == 0 ? 0.0 : (earnedWeighted / totalWeightage) * 100.0;

    return {
      'earnedWeighted': earnedWeighted,
      'totalWeightage': totalWeightage,
      'percentage': percentage,
    };
  }

  // Passing requirements calculations
  // currentMarks: earnedWeighted
  // remainingWeightage: 100 - totalWeightage
  // requiredToPass: passingMarksThreshold - currentMarks
  // requiredPercentageOnRemaining: (requiredToPass / remainingWeightage) * 100
  Map<String, dynamic> calculatePassingRequirements({
    required String subjectId,
    required double passingMarksThreshold,
  }) {
    final stats = calculateSubjectInternalStats(subjectId);
    final double current = stats['earnedWeighted'] as double;
    final double evaluatedWeightage = stats['totalWeightage'] as double;

    final double remainingWeightage = 100.0 - evaluatedWeightage;
    final double neededToPass = passingMarksThreshold - current;

    double requiredPercentageOnRemaining = 0.0;
    bool isAlreadyPassed = current >= passingMarksThreshold;
    bool isImpossible = false;

    if (!isAlreadyPassed && remainingWeightage > 0) {
      requiredPercentageOnRemaining = (neededToPass / remainingWeightage) * 100.0;
      if (requiredPercentageOnRemaining > 100.0) {
        isImpossible = true;
      }
    } else if (!isAlreadyPassed && remainingWeightage <= 0) {
      isImpossible = true;
    }

    return {
      'currentEarned': current,
      'evaluatedWeightage': evaluatedWeightage,
      'remainingWeightage': remainingWeightage,
      'neededToPass': neededToPass > 0 ? neededToPass : 0.0,
      'requiredPercentageOnRemaining': requiredPercentageOnRemaining > 0 ? requiredPercentageOnRemaining : 0.0,
      'isAlreadyPassed': isAlreadyPassed,
      'isImpossible': isImpossible,
    };
  }
}
