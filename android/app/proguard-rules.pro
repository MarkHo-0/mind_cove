# 1. 保持您的 App 業務邏輯與入口類別不被混淆
-keep class hk.mark.mind_cove.** { *; }

# 2. 保持 Flutter 引擎與插件核心類別
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 3. 保持原生 Application 與 Activity 類別
-keep class android.app.Application { *; }

# 4. 避免 R8 優化時對 Flutter channel/反射方法誤刪
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# 5. 忽略常見的無害缺失類別警告（如 Google Play Core）
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**