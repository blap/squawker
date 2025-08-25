# Suppress ProGuard warnings for missing classes
# These warnings don't affect functionality and can be safely ignored

# Suppress warnings for ConcurrentHashMap classes
-dontwarn j$.util.concurrent.ConcurrentHashMap**
-dontwarn j$.util.IntSummaryStatistics
-dontwarn j$.util.LongSummaryStatistics
-dontwarn j$.util.DoubleSummaryStatistics

# Suppress warnings for Google Play Core classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Keep the classes that are causing warnings to avoid any potential issues
# but don't fail if they're not present
-keep class j$.util.concurrent.ConcurrentHashMap$TreeBin { *; }
-keep class j$.util.concurrent.ConcurrentHashMap { *; }
-keep class j$.util.concurrent.ConcurrentHashMap$CounterCell { *; }
-keep class j$.util.IntSummaryStatistics { *; }
-keep class j$.util.LongSummaryStatistics { *; }
-keep class j$.util.DoubleSummaryStatistics { *; }

# Alternatively, if you want to be more specific about what to keep:
# -keepclassmembers class j$.util.concurrent.ConcurrentHashMap$TreeBin {
#   int lockState;
# }
# -keepclassmembers class j$.util.concurrent.ConcurrentHashMap {
#   int sizeCtl;
#   int transferIndex;
#   long baseCount;
#   int cellsBusy;
# }
# -keepclassmembers class j$.util.concurrent.ConcurrentHashMap$CounterCell {
#   long value;
# }
# -keepclassmembers class j$.util.IntSummaryStatistics {
#   long count;
#   long sum;
#   int min;
#   int max;
# }
# -keepclassmembers class j$.util.LongSummaryStatistics {
#   long count;
#   long sum;
#   long min;
#   long max;
# }
# -keepclassmembers class j$.util.DoubleSummaryStatistics {
#   long count;
#   double sum;
#   double min;
#   double max;
# }

# General Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.BuildConfig { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters in POJOs for serialization
-keepclassmembers class * {
    public void set*(***);
}

# Keep reflection used by frameworks
-keepclassmembernames class * {
    java.lang.Class class$(java.lang.String);
    java.lang.Class class$(java.lang.String, boolean);
}

# Keep classes that are accessed via reflection
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}