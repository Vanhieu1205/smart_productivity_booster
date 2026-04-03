// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboardingTitle1 => 'Smart Task Management';

  @override
  String get onboardingDesc1 =>
      'Effectively categorize all your tasks using the Eisenhower Matrix to know what is truly important.';

  @override
  String get onboardingTitle2 => 'Focus with Pomodoro';

  @override
  String get onboardingDesc2 =>
      'Apply the 25-minute technique to enhance focus and minimize fatigue.';

  @override
  String get onboardingTitle3 => 'Track Your Progress';

  @override
  String get onboardingDesc3 =>
      'View precise weekly statistics to proactively adjust your working habits.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginEmail => 'Email';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginNoAccount => 'Don\'t have an account? Register now';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordDesc =>
      'Enter your email address and we\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordEmail => 'Email address';

  @override
  String get forgotPasswordButton => 'Send Reset Link';

  @override
  String get forgotPasswordBack => 'Back to Login';

  @override
  String get forgotPasswordSuccess =>
      'Reset link sent! Please check your email.';

  @override
  String get registerTitle => 'Register Account';

  @override
  String get registerUsername => 'Display Name';

  @override
  String get registerEmail => 'Email';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerButton => 'Register';

  @override
  String get registerHasAccount => 'Already have an account?';

  @override
  String get welcomeSpb => 'Welcome SPB';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm =>
      'Are you sure you want to log out of the application?';

  @override
  String get logoutCancel => 'Cancel';

  @override
  String get logoutTitle => 'Confirm Logout';

  @override
  String get exitTitle => 'Confirm Exit';

  @override
  String get exitConfirm => 'Do you want to exit the app?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get eisenhowerMatrix => 'Eisenhower Matrix';

  @override
  String get matrix => 'Matrix';

  @override
  String get urgent => 'Urgent';

  @override
  String get important => 'Important';

  @override
  String get notUrgent => 'Not Urgent';

  @override
  String get notImportant => 'Not Important';

  @override
  String get quadrant1 => 'Do First';

  @override
  String get quadrant2 => 'Schedule';

  @override
  String get quadrant3 => 'Delegate';

  @override
  String get quadrant4 => 'Eliminate';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get deleteTaskLabel => 'Delete this task';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskDescription => 'Description';

  @override
  String get confirmDelete => 'Are you sure you want to delete this task?';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get cannotBeEmpty => 'This field cannot be empty';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get emailCannotBeEmpty => 'Email cannot be empty';

  @override
  String get passwordCannotBeEmpty => 'Password cannot be empty';

  @override
  String get invalidEmail => 'Invalid email format';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get securityQuestion => 'Security Question';

  @override
  String get securityAnswer => 'Security Answer';

  @override
  String get verifySecurityQuestion => 'Answer Your Security Question';

  @override
  String get verifyButton => 'Verify';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDesc => 'Enter your new password';

  @override
  String get resetPasswordButton => 'Reset Password';

  @override
  String get classify => 'Classify';

  @override
  String get taskLabels => 'Labels';

  @override
  String get noLabel => 'No Label';

  @override
  String get dropTaskHere => 'Drop task here';

  @override
  String get noTask => 'No tasks';

  @override
  String get pomodoroTimer => 'Pomodoro Timer';

  @override
  String get workTime => 'Work Time';

  @override
  String get shortBreak => 'Short Break';

  @override
  String get longBreak => 'Long Break';

  @override
  String get startTimer => 'Start';

  @override
  String get pauseTimer => 'Pause';

  @override
  String get resumeTimer => 'Resume';

  @override
  String get resetTimer => 'Reset';

  @override
  String get skipPhase => 'Skip Phase';

  @override
  String get pomodoroComplete => 'Great! You have completed a focus session.';

  @override
  String get breakComplete => 'Break time is over! Ready to get back to work?';

  @override
  String get pomodoroCount => 'Pomodoros';

  @override
  String get streak => 'Productivity Streak';

  @override
  String get startPomodoro => 'Start Pomodoro';

  @override
  String get focusMode => 'Focus Mode';

  @override
  String get phaseComplete => 'Phase Complete!';

  @override
  String get focusHint => 'Stay focused! Work hard on this task.';

  @override
  String get breakHint => 'Take a short break. You\'ve earned it!';

  @override
  String get longBreakHint => 'Great job! Take a longer break to recharge.';

  @override
  String get statistics => 'Statistics';

  @override
  String get weeklyStats => 'Weekly Statistics';

  @override
  String get totalPomodoros => 'Total Pomodoros';

  @override
  String get focusMinutes => 'Focus Minutes';

  @override
  String get completedTasks => 'Completed Tasks';

  @override
  String get mostProductiveDay => 'Most Productive Day';

  @override
  String get noDataThisWeek => 'No data this week';

  @override
  String get previousWeek => 'Previous Week';

  @override
  String get nextWeek => 'Next Week';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get shareStats => 'Share Statistics';

  @override
  String get refresh => 'Refresh';

  @override
  String get cannotCaptureImage => 'Cannot capture image';

  @override
  String get errorProcessingImage => 'Error processing image';

  @override
  String get shareText => 'Check out my productivity stats!';

  @override
  String get errorSharing => 'Error sharing';

  @override
  String get days => 'days';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'Version';

  @override
  String get developerName => 'Student Name: Pham Van Hieu';

  @override
  String get appName => 'Smart Productivity Booster';

  @override
  String get developedBy => 'Developed by';

  @override
  String get studentId => 'Student ID';

  @override
  String get graduationProject => 'Graduation Internship Project';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get cannotLoadSettings => 'Cannot load settings';

  @override
  String get notificationSound => 'Notification Sound';

  @override
  String get playSoundOnComplete => 'Play sound when timer completes';

  @override
  String get pomodoroGoal => 'Pomodoro Goal';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get pomodoroPerDay => 'pomodoros/day';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get daysShort => 'days';

  @override
  String get streakRecord => 'Streak Record';

  @override
  String get achievements => 'Achievements';

  @override
  String get viewAchievements => 'View Achievements';

  @override
  String get checkAchievements => 'Check your achievements';

  @override
  String get dataBackup => 'Data Backup';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get exportData => 'Export Data';

  @override
  String get shareBackupFile => 'Share backup file to other devices';

  @override
  String get importData => 'Import Data';

  @override
  String get restoreFromBackup => 'Restore data from backup file';

  @override
  String get exportSuccess => 'Export successful';

  @override
  String get exportError => 'Export error';

  @override
  String get confirmImportData => 'Confirm Import Data';

  @override
  String get importWarning => 'This will replace all current data. Continue?';

  @override
  String get continueText => 'Continue';

  @override
  String get importSuccess => 'Import successful';

  @override
  String get importError => 'Import error';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get today => 'Today';

  @override
  String get todaySubtitle => 'Your focus for today';

  @override
  String get estimated => 'Estimated';

  @override
  String get prioritiesToday => 'Priorities for Today';

  @override
  String get noTasksInQuadrant => 'No tasks in this quadrant';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get totalAchievements => 'total achievements';

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get goToMatrixToComplete => 'Go to Matrix page to complete this task';

  @override
  String pomodoroProgress(int completed, int total) {
    return 'Pomodoro: $completed/$total';
  }

  @override
  String taskCount(int count) {
    return '$count tasks';
  }

  @override
  String get greetingNight => 'Good Night';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get greetingLateEvening => 'Good Evening';

  @override
  String get greetingLateNight => 'Good Night';

  @override
  String get welcomeLabel => 'Welcome';

  @override
  String get calendarMode => 'Calendar View';

  @override
  String get matrixMode => 'Matrix View';

  @override
  String get calendarViewMode => 'Calendar View';

  @override
  String get reload => 'Reload';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get initializing => 'Initializing...';

  @override
  String get myProfile => 'My Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get editNotes => 'Edit Notes';

  @override
  String get dueDate => 'Due Date';

  @override
  String get dueTime => 'Due Time';

  @override
  String get dueDateTime => 'Date & Time';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectDateTime => 'Select Date and Time';

  @override
  String todayOnly(String hour, String minute) {
    return 'Today ($hour:$minute)';
  }

  @override
  String get dueDateInfo =>
      'Do It: select time only for today. Other tabs: select date and time';

  @override
  String get notes => 'Notes';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get enterTaskNotes => 'Enter task notes...';
}
