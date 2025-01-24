# Supabase Auth with Google+Apple, in Flutter.
这个 Demo 演示了如何使用 Supabase 的 Auth 服务，在 Flutter 中实现 Google 和 Apple 的登录。
- 在处理 Google 登录时，对于 Android/iOS 和 macOS 的，我们使用了 google_sign_in 插件，体验更好；其它场景使用 web 登录。
- 对于 Apple 登录，我们对 iOS 和 macOS 应用使用了 sign_in_with_apple 插件，提供原生应用体验。其它场景暂未提供支持。

## Background Setup

### Configure Google Cloud

- Create a new project in console.cloud.google.com
- Create three OAuth 2.0 client IDs in "API & Services" for Android, iOS, and Web
- Before creating the OAuth 2.0 client IDs, complete the "Branding" page content as prompted
- When creating the client, the redirect URIs for the web client need to be obtained from the configuration page of Supabase's Google Providers


### Configure Supabase

- Create a new Supabase project
- Record the Supabase URL and anon key
- Add Google in Providers
    - In the configuration page of Google Providers, add the client ID of the web client
    - In the configuration page of Google Providers, add the client secret of the web client
    - In the configuration page of Google Providers, enable the "Skip nonce checks" option (required for iOS)
    - In the configuration page of Google Providers, record the "Callback URL (for OAuth)" and later add it to the redirect URI of the Google Cloud web client
- Add Apple in Providers
    - In the configuration page of Apple Providers, add the client ID of the iOS client
- Configure the Supabase URL Configuration as follows
    - Set Site URL: http://localhost:4000 (for testing WEB login callback, use the official domain when officially released)
    - Add Callback URLs: `cn.chessroad.apps.ichess://login_callback` (callback DeepLink for universal auth)

## App Setup

### Create a new Flutter project

- flutter create --org com.chessroad.apps.ichess link

### Add dependencies

- flutter pub add supabase_flutter
- flutter pub add google_sign_in
- flutter pub add sign_in_with_apple
- flutter pub add crypto
- flutter pub add flutter_easyloading

### Coding
```dart
// All codes are in the main.dart file
```

### iOS environment setup

- In Xcode, open the project, select the project, go to "Capabilities", and enable the "Sign In with Apple" option
- At the end of the Runner's Info.plist file, add the following DeepLink configuration:
```plist
<!-- DEEP LINK -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>ChessRoad</string>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>cn.chessroad.apps.ichess</string>
        </array>
    </dict>
</array>
```

### macOS environment setup

- In Xcode, open the project, select the project, go to "Capabilities", and enable the "Sign In with Apple" option
- At the end of the Runner's Info.plist file, add the following two URL Schemes configuration:
```plist
<!-- DEEP LINK -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>ChessRoad</string>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>cn.chessroad.apps.ichess</string>
        </array>
    </dict>
</array>

<!-- Google Sign-in Section -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.369752755949-nfbp5g0qev63bq6lcng6el1fbeqg9n4t</string>
        </array>
    </dict>
</array>
<!-- End of the Google Sign-in Section -->
```
- To allow the application to access the network, add the following content to Runner/DebugProfile.entitlements and Runner/ReleaseProfile.entitlements:
```entitlements
<key>com.apple.security.network.client</key>
<true/>
```

### Last step, Run the app

- $ flutter run -d ios
- $ flutter run -d macos
- $ flutter run -c chrome --web-port=4000
