class AppConstants {
  // SHARED PREFERENCES CONSTANTS
  static const String sharedPrefsUpdatedRepoIdsKey = 'updated_repo_ids';
  static const String sharedPrefsLastBackupDateKey = 'last_backup_date';

  // STRINGS
  static const String appVersion = "1.8.0";
  static const String appName = "Git Repo Watcher Fschmatz";
  static const String appNameHomePage = "Git Repo Watcher";
  static const String backupFileName = "git_repo_watcher_backup";
  static const String repositoryLink = 'https://github.com/Fschmatz/git_repo_watcher';

  static const String changelogCurrent = '''
$appVersion
- Add release note
- Edit repository
- Bug fixes
- UI changes
''';

  static const String changelogsOld = '''
1.7.7
- Material Expressive Design
- Add refresh all notification
- UI changes
- Bug fixes
- New backup logic 
- Flutter 3.44

1.6.6
- UI changes
- Added GitHub token
- Bug fixes
- Create backup
- Restore from backup
- Update Flutter 3.38

1.5.0
- Monet
- Bug fixes
- Flutter 3.19

1.4.3
- Add Refresh All FAB
- UI changes
- Bug fixes

1.3.3
- Repository note
- UI changes
- Bug fix
- Print list
- Flutter 3
  
1.2.0  
- UI changes
- Bug fix

1.1.2  
- Bug fixes
- UI changes
- Add commits page link
- Loading indicator

1.0.4
- Technically usable
- New UI
- App icon
- Alert icon for new versions

0.6.0
- Release data
- Release link
- Bug fixes

0.5.0
- UI changes
- Bottom sheet
- Delete repository

0.4.0
- Save repository

0.3.0
- API
- DB
- Setting page

0.2.0
- Home

0.1.0
- Project start
''';
}
