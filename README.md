<h1 align="center"> Squawker </h1>
<br>
<p align="center">
  <a href="https://github.com/j-fbriere/squawker">
    <img alt="Squawker" title="Squawker" src="fastlane/metadata/android/en-US/images/icon.png" width="144">
  </a>
</p>
<p align="center">
  Maintaining the <a href="https://github.com/jonjomckay/fritter">Fritter</a> feed, originally by <a href="https://github.com/TheHCJ/Quacker">Quacker</a>
</p>

<p align="center">
  <a href="https://github.com/j-fbriere/squawker/releases" alt="GitHub release"><img src="https://img.shields.io/github/release/j-fbriere/squawker.svg?style=for-the-badge" ></a>
  <a href="https://f-droid.org/packages/org.ca.squawker" alt="GitHub release"><img src="https://img.shields.io/f-droid/v/org.ca.squawker?label=release%20(f-droid)&style=for-the-badge" ></a>
  <a href="https://github.com/j-fbriere/squawker/blob/master/LICENSE" alt="License: MIT"><img src="https://img.shields.io/badge/License-MIT-red.svg?style=for-the-badge"></a>
  <a href="https://github.com/j-fbriere/squawker/actions" alt="Build Status"><img src="https://img.shields.io/github/actions/workflow/status/j-fbriere/squawker/ci.yml?style=for-the-badge"></a>
  <a href="https://hosted.weblate.org/engage/squawker/" alt="Translation Status"><img src="https://img.shields.io/weblate/progress/squawker?label=Translated%20(squawker)&style=for-the-badge"></a>
</p>
<p align="center">
  <a href="https://f-droid.org/packages/org.ca.squawker">
    <img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png" alt="Get it on F-Droid" height="80">
  </a>
</p>
<p align="center">
  There is also an alternate F-Droid repository that allows updates for Squawker to be available faster than on the default F-Droid repository.
</p>
<p align="left">
  Scan the QR code below or click this <a href="https://apkrep.creativaxion.org/fdroid/repo?fingerprint=443DA0A316DFB86BFD05D0123951855E7CD8724969FAD66D6E62EB801299744A">link</a> and process it with your F-Droid client. Here's the full link text for easy viewing:<br>
    https://apkrep.creativaxion.org/fdroid/repo?fingerprint=443DA0A316DFB86BFD05D0123951855E7CD8724969FAD66D6E62EB801299744A
</p>
<p align="left">
  <img src="https://apkrep.creativaxion.org/fdroid/repo/index.png" width="80">
</p>
<p align="center">
 <sub>Important note: In case Squawker is already installed on your device and you want to reinstall it or want to install a version from another repository (from F-Droid to github or from F-Droid to the alternate F-Droid repository for instance), make sure to backup your application data (Settings/Data, tap Export, select all items then tap the save icon) and uninstall Squawker before proceeding.
  After you have reinstalled Squawker from the new repository, import your backup (Settings/Data, tap Import).</sub>
</p>
 
## Features:

* Privacy: No tracking, with all data local
* No ads: Not clogged by multiple ads
* Feed: View all your subscriptions in a chronological feed
* Subscriptions: Follow and group accounts
* Search: Find users and tweets
* Bookmarks: Save tweets locally and offline
* Trends: See what's trending in the world
* Polls: View results without needing to vote
* Light and Dark themes: Protect your eyes
* And more!
  
## Screenshots

| <img alt="Viewing subscriptions" src="fastlane/metadata/android/en-US/images/phoneScreenshots/1.jpg" width="218"/>| <img alt="Viewing groups" src="fastlane/metadata/android/en-US/images/phoneScreenshots/2.jpg" width="218"/> | <img alt="Viewing trends" src="fastlane/metadata/android/en-US/images/phoneScreenshots/3.jpg" width="218"/> | 

## Contribute
If you'd like to help make Squawker even better, here are a just a few of the ways you can help!

### Report a bug
If you've found a bug in Squawker, open a [new issue](https://github.com/j-fbriere/squawker/issues/new/choose), but please make sure to check that someone else hasn't reported it first on Fritter or on Squawker.

### Fix a bug
If you're looking for something to dip your toes into the codebase, check if there are any issues labelled good first issue. Otherwise, if you see another issue you'd like to tackle, go for it - just fork the repository, push to a branch, and create a PR detailing your changes. We'll review it and merge it in, once it meets all our checks and balances!

### Translations
Most of Squawker's translations have come from [Weblate](https://hosted.weblate.org/engage/squawker/)

### Building from Source

To build Squawker from source, you'll need to have Flutter installed on your system.

#### Prerequisites
- Flutter SDK
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)

#### Build Scripts
This repository includes several scripts to simplify the build process:

1. **build_apk.bat** - Simple batch script to build a release APK
2. **build_apk_advanced.bat** - Advanced batch script with multiple build options
3. **build_apk.ps1** - PowerShell script for building APKs

#### Manual Build Process
1. Clone the repository:
   ```
   git clone https://github.com/j-fbriere/squawker.git
   ```
2. Navigate to the project directory:
   ```
   cd squawker
   ```
3. Get dependencies:
   ```
   flutter pub get
   ```
4. Build the APK:
   ```
   flutter build apk --release --no-tree-shake-icons
   ```

The built APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

#### Build Warnings
During the build process, you may see warnings like:
```
warning: [options] source value 8 is obsolete and will be removed in a future release
```
and
```
Info: Proguard configuration rule does not match anything: `-keepclassmembers class j$.util.concurrent.ConcurrentHashMap...
```

These warnings are normal and don't affect the functionality of the built APK:
- The Java version warnings occur because some dependencies still reference older Java versions, but they don't prevent the build
- The ProGuard warnings are related to unused configuration rules and can be safely ignored. These have been properly configured in the project with specific rules in `android/app/proguard-rules.pro` to suppress them without affecting functionality.

The project now includes specific ProGuard rules in `android/app/proguard-rules.pro` to handle these warnings properly, ensuring they don't cause build failures while maintaining the security and optimization benefits of code shrinking and obfuscation.

#### Dependency Management

##### Flutter Triple 3.0.0 Migration
The project currently uses flutter_triple version 2.2.0. An attempt was made to upgrade to version 3.0.0, but this introduced compatibility issues due to breaking changes in the package's architecture.

Version 3.0.0 migrated from RxNotifier to ASP (Atomic State Pattern), which requires significant code changes throughout the codebase. For details about the issues encountered and the recommended migration path, see [FLUTTER_TRIPLE_MIGRATION.md](FLUTTER_TRIPLE_MIGRATION.md).

The decision was made to maintain stability by keeping version 2.2.0 until a comprehensive migration plan can be implemented.

### Acknowledgments
Duck Icon: <a href="https://www.vecteezy.com/free-vector/bathroom">Bathroom Vectors by Vecteezy</a>