// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) async {
  // 1. Get the new version from the user
  if (args.isEmpty) {
    print('❌ Please provide a new version, e.g. dart run tools/release.dart 0.2.0');
    exit(1);
  }
  var newVersion = args[0].trim().replaceFirst(RegExp(r'^v'), '');

  // 2. Validate version format (x.y.z)
  if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(newVersion)) {
    print('❌ Invalid version format. Expected x.y.z, e.g. 0.2.0');
    exit(1);
  }

  // 3. Verify we are on the main or master branch
  final branchResult = await Process.run('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
  final currentBranch = branchResult.stdout.toString().trim();

  if (currentBranch != 'main' && currentBranch != 'master') {
    print('❌ You are currently on branch "$currentBranch".');
    print('   Releases must be made from "main" or "master".');
    exit(1);
  }
  print('🌿 Current branch: $currentBranch');

  // 4. Read pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('❌ pubspec.yaml not found in the current directory');
    exit(1);
  }
  final content = pubspecFile.readAsStringSync();

  // 5. Extract current version (e.g. "0.1.4+6")
  final versionMatch = RegExp(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)', multiLine: true).firstMatch(content);
  if (versionMatch == null) {
    print('❌ Cannot parse version in pubspec.yaml. Expected format: x.y.z+build');
    exit(1);
  }

  final currentVersionName = versionMatch.group(1)!; // "0.1.4"
  final currentBuildNumber = int.parse(versionMatch.group(2)!); // 6

  print('📦 Current version: $currentVersionName+$currentBuildNumber');

  // 6. Compare versions (new must be greater than current)
  if (_compareVersions(newVersion, currentVersionName) <= 0) {
    print('❌ New version must be greater than current version');
    exit(1);
  }

  // 7. Calculate new version and build number
  final newBuildNumber = currentBuildNumber + 1;
  final newFullVersion = '$newVersion+$newBuildNumber';
  final tagName = 'v$newVersion';

  print('🚀 New version: $newFullVersion (tag: $tagName)');

  // 8. Check if the tag already exists
  final tagCheck = await Process.run('git', ['tag', '-l', tagName]);
  if (tagCheck.stdout.toString().trim().isNotEmpty) {
    print('❌ Tag $tagName already exists');
    exit(1);
  }

  // 9. Update pubspec.yaml
  final newContent = content.replaceFirst(
    RegExp(r'^version:\s*\d+\.\d+\.\d+\+\d+', multiLine: true),
    'version: $newFullVersion',
  );
  pubspecFile.writeAsStringSync(newContent);
  print('✏️  Updated pubspec.yaml → version: $newFullVersion');

  // 10. git commit
  await Process.run('git', ['add', 'pubspec.yaml']);
  await Process.run('git', ['commit', '-m', 'Bumped version to $newVersion']);
  print('📝 Committed: Bumped version to $newVersion');

  // 11. git tag
  await Process.run('git', ['tag', '-a', tagName, '-m', 'Release $tagName']);
  print('🏷️  Created tag: $tagName');

  // 12. git push
  print('⬆️  Pushing $currentBranch and $tagName to remote...');
  await Process.run('git', ['push', 'origin', currentBranch]);
  await Process.run('git', ['push', 'origin', tagName]);

  // 13. Final reminder
  print('');
  print('============================================================');
  print('✅ Tag $tagName has been pushed to GitHub.');
  print('');
  print('⏳ Please wait for the GitHub Actions workflow to finish');
  print('   building and publishing this release.');
  print('============================================================');
}

/// Compare two semantic versions (x.y.z)
/// Returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal.
int _compareVersions(String v1, String v2) {
  final a = v1.split('.').map(int.parse).toList();
  final b = v2.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    if (a[i] > b[i]) return 1;
    if (a[i] < b[i]) return -1;
  }
  return 0;
}
