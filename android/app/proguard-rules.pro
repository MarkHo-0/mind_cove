# 保持您的主要入口類別不被混淆或移除
-keep class hk.mark.mind_cove.** { *; }

# 保持 Flutter 的基礎類別
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 防止 R8 移除標準 Application 類別
-keep class android.app.Application { *; }

# --- 解決 R8 缺類別錯誤 ---
# Flutter 引擎包含 Google Play 動態交付的代碼，但如果沒引入 Play Core 庫就會報錯。
# 既然我們沒用這些功能，直接忽略警告即可。
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**