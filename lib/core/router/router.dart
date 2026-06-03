import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/timetable_setup_screen.dart';
import '../../features/attendance/presentation/screens/subject_detail_screen.dart';
import '../../features/bunk/presentation/screens/bunk_screen.dart';
import '../../features/gpa/presentation/screens/gpa_screen.dart';
import '../../features/gpa/presentation/screens/semester_detail_screen.dart';
import '../../features/internals/presentation/screens/internals_screen.dart';
import '../../features/internals/presentation/screens/subject_internals_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'navigation_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Tab 2: Attendance Tracker
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/attendance',
              builder: (context, state) => const AttendanceScreen(),
              routes: [
                GoRoute(
                  path: 'timetable',
                  builder: (context, state) => const TimetableSetupScreen(),
                ),
                GoRoute(
                  path: 'detail/:subjectId',
                  builder: (context, state) {
                    final subjectId = state.pathParameters['subjectId'] ?? '';
                    return SubjectDetailScreen(subjectId: subjectId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 3: Bunk Calculator
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bunk',
              builder: (context, state) => const BunkScreen(),
            ),
          ],
        ),
        // Tab 4: GPA Calculator
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/gpa',
              builder: (context, state) => const GpaScreen(),
              routes: [
                GoRoute(
                  path: 'semester/:semesterId',
                  builder: (context, state) {
                    final semesterId = state.pathParameters['semesterId'] ?? '';
                    return SemesterDetailScreen(semesterId: semesterId);
                  },
                ),
              ],
            ),
          ],
        ),
        // Tab 5: Internals Manager
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/internals',
              builder: (context, state) => const InternalsScreen(),
              routes: [
                GoRoute(
                  path: 'subject/:subjectId',
                  builder: (context, state) {
                    final subjectId = state.pathParameters['subjectId'] ?? '';
                    return SubjectInternalsScreen(subjectId: subjectId);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Settings Screen (accessible from other pages via router.push)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
