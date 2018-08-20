
---
title: 整理Google接入
date: 2016-10-04 20:37:31
tags: google
---
![google](http://oanvj2lsv.bkt.clouddn.com/google/googleapi.png)
<center> 配置GCM 、FCM 、 Google-Map (全程科学上网)</center >
<!---more--->
## API
[API管理器(配置入口)](https://console.developers.google.com/apis/library?project=hauyan-8b259)

![api](http://oanvj2lsv.bkt.clouddn.com/google/api/api1.png)

---

## GCM
 [真のGCM文档](https://developers.google.com/cloud-messaging/gcm?hl=zh-cn)
通过 API管理器 进入的是FCM 的配置文档，FCM 兼容GCM 同时更加简洁，并提供更多的可用服务。

以下配置参照[GCM设置文档](https://developers.google.com/cloud-messaging/android/client?hl=zh-cn)和 [GoogleSamples](https://github.com/googlesamples/google-services/tree/master/android/gcm/app/src/main/java/gcm/play/android/samples/com/gcmquickstart)，找代码也是一个复杂的过程，索性一并贴出。

### Set up a GCM Client App on Android

[GCM Clients 传送门](https://developers.google.com/cloud-messaging/android/client?hl=zh-cn)

假设你的设备支持GCM，这里有一份缩减版：

### 在Firebase控制台注册
对应文档(Create an API project)

1.[注册项目](https://console.firebase.google.com/?hl=zh-cn)，已有相关项目点击导入.没有点击新建.

2.点击添加Firebase到你的应用，然后继续，注意包名，一定要对应app的build.gradle中的applicationId,SHA1(android studio 右边gradle task面板 ：app-->Tasks-->android-->signingReport 或者：Android studio 下方控制台 ./gradlew signingReport)，完成后下载配置文件。如果要重新下载配置文件：项目右上角->管理->下载最新配置文件(下载该项目的google-servers.json)

3.将下载好的google-services.json添加到app/目录下

### 配置project
对应文档（Add the configuration file to your project）

1.添加依赖到 project-level **build.gradle**:
```
classpath 'com.google.gms:google-services:3.0.0'
```
2.添加插件和依赖库到 app-level **build.gradle**

```
apply plugin: 'com.google.gms.google-services'

dependencies {
  compile "com.google.android.gms:play-services-gcm:9.6.1"
}
```
注意插件是添加在顶部，不要放到Android内，依赖默认版本 9.6.1,编译不过建议改为 9.0.0

### 对应文档(Edit Your Application's Manifest)

1.添加权限 和 service

```
<manifest package="com.example.gcm" ...>

    <uses-sdk android:minSdkVersion="8" android:targetSdkVersion="17"/>
    <!--GCM 权限-->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <permission android:name="<your-package-name>.permission.C2D_MESSAGE"
        android:protectionLevel="signature" />
    <uses-permission android:name="<your-package-name>.permission.C2D_MESSAGE" />
    <!--GCM 权限 end-->
    <application ...>
    <!--GCM receiver and service-->
        <receiver
            android:name="com.google.android.gms.gcm.GcmReceiver"
            android:exported="true"
            android:permission="com.google.android.c2dm.permission.SEND" >
            <intent-filter>
                <action android:name="com.google.android.c2dm.intent.RECEIVE" />
                <action android:name="com.google.android.c2dm.intent.REGISTRATION" /> //support pre-4.4 KitKat devices
                <category android:name="<your-package-name>" />
            </intent-filter>
        </receiver>
        <service
            android:name="com.example.MyGcmListenerService"//继承GcmListenerService 的自定义类
            android:exported="false" >
            <intent-filter>
                <action android:name="com.google.android.c2dm.intent.RECEIVE" />
            </intent-filter>
        </service>
        <service
            android:name="com.example.MyInstanceIDListenerService"//继承InstanceIDListenerService 的自定义类
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.android.gms.iid.InstanceID" />
            </intent-filter>
        </service>
        <service
            android:name="gcm.play.android.samples.com.gcmquickstart.RegistrationIntentService"//继承RegistrationIntentService 的自定义类
            android:exported="false">
        </service>
    <!--GCM receiver and service end-->
    </application>

</manifest>
```
注意：< your-package-name > 这里要设置为gradle中的applicationId.

2.自定义service类及Activiy开启服务

从manifest中看到需要实现3个service类

PreferCode.java

```
public class PreferCode {

    public static final String SENT_TOKEN_TO_SERVER = "sentTokenToServer";
    public static final String REGISTRATION_COMPLETE = "registrationComplete";
}
```

 MyGcmListenerService.java

```
public class MyGcmListenerService extends GcmListenerService {

    public static final String TAG = "MyGcmListenerService";


    /**
     * Called when message is received.
     *
     * @param from SenderID of the sender.
     * @param data Data bundle containing message data as key/value pairs.
     *             For Set of keys use data.keySet().
     */
    // [START receive_message]
    @Override
    public void onMessageReceived(String from, Bundle data) {
        String message = "";
        try {
            if(data!=null) {
                message = data.getString("message");
                Log.d("received message", "From: " + from);
                Log.d("received message", "Message: " + message);
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        if (from.startsWith("/topics/")) {
            // message received from some topic.
        } else {
            // normal downstream message.
        }

        // [START_EXCLUDE]
        /**
         * Production applications would usually process the message here.
         * Eg: - Syncing with server.
         *     - Store message in local database.
         *     - Update UI.
         */

        /**
         * In some cases it may be useful to show a notification indicating to the user
         * that a message was received.
         */
        if (Paper.book().read(Utility.NOTIFICATION,Utility.NOTIFICATION_OPEN).equals(Utility.NOTIFICATION_OPEN) && !TextUtils.isEmpty(message))
            sendNotification(message);
        // [END_EXCLUDE]
    }
    // [END receive_message]

    /**
     * Create and show a simple notification containing the received GCM message.
     *
     * @param message GCM message received.
     */
    private void sendNotification(String message) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.mipmap.homepage_image)
                .setContentTitle(getApplicationName(this))
                .setContentText(message)
                .setAutoCancel(true)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }
    public static String getApplicationName(Context context) {
        int stringId = context.getApplicationInfo().labelRes;
        return context.getString(stringId);
    }
}
```
MyInstanceIDListenerService.java

```
public class MyInstanceIDListenerService extends InstanceIDListenerService {
    public static final String TAG = "MyInstanceIDListenerService";

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. This call is initiated by the
     * InstanceID provider.
     */
    // [START refresh_token]
    @Override
    public void onTokenRefresh() {
        // Fetch updated Instance ID token and notify our app's server of any changes (if applicable).
        Intent intent = new Intent(this, RegistrationIntentService.class);
        startService(intent);
    }
    // [END refresh_token]
}

```
RegistrationIntentService.java
```
public class RegistrationIntentService extends IntentService{
    public static final String TAG = "RegistrationIntentService";
    private static final String[] TOPICS = {"global"};
    /**
     * Creates an IntentService.  Invoked by your subclass's constructor.
     */
    public RegistrationIntentService() {
        super(TAG);
    }


    @Override
    protected void onHandleIntent(Intent intent) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this);

        try {
            // [START register_for_gcm]
            // Initially this call goes out to the network to retrieve the token, subsequent calls
            // are local.
            // R.string.gcm_defaultSenderId (the Sender ID) is typically derived from google-services.json.
            // See https://developers.google.com/cloud-messaging/android/start for details on this file.
            // [START get_token]
            InstanceID instanceID = InstanceID.getInstance(getApplicationContext());
            String token = instanceID.getToken(getString(R.string.gcm_defaultSenderId), GoogleCloudMessaging.INSTANCE_ID_SCOPE, null);
            // [END get_token]
            Log.i(TAG, "GCM Registration Token: " + token);

            // TODO: Implement this method to send any registration to your app's servers.
            sendRegistrationToServer(token);

            // Subscribe to topic channels
            subscribeTopics(token);

            // You should store a boolean that indicates whether the generated token has been
            // sent to your server. If the boolean is false, send the token to your server,
            // otherwise your server should have already received the token.
            sharedPreferences.edit().putBoolean(PreferCode.SENT_TOKEN_TO_SERVER, true).apply();
            // [END register_for_gcm]
        } catch (Exception e) {
            Log.i(TAG, "Failed to complete token refresh", e);
            // If an exception happens while fetching the new token or updating our registration data
            // on a third-party server, this ensures that we'll attempt the update at a later time.
            sharedPreferences.edit().putBoolean(PreferCode.SENT_TOKEN_TO_SERVER, false).apply();
        }
        // Notify UI that registration has completed, so the progress indicator can be hidden.
        Intent registrationComplete = new Intent(PreferCode.REGISTRATION_COMPLETE);
        LocalBroadcastManager.getInstance(this).sendBroadcast(registrationComplete);
    }

    /**
     * Persist registration to third-party servers.
     *
     * Modify this method to associate the user's GCM registration token with any server-side account
     * maintained by your application.
     *
     * @param token The new token.
     */
    private void sendRegistrationToServer(String token) {
        Map<String ,String > params = new HashMap<>();
        params.put("device","android");
        params.put("token",token);
        HttpUtils.simplePost(Api.sendToken, this, params, new RequestCBK() {
            @Override
            public void onResponse(JSONObject response) {
                Log.i(TAG,response.toString());
            }

            @Override
            public void onErrorResponse() {

            }
        });
    }

    /**
     * Subscribe to any GCM topics of interest, as defined by the TOPICS constant.
     *
     * @param token GCM token
     * @throws IOException if unable to reach the GCM PubSub service
     */
    // [START subscribe_topics]
    private void subscribeTopics(String token) throws IOException {
        GcmPubSub pubSub = GcmPubSub.getInstance(this);
        for (String topic : TOPICS) {
            pubSub.subscribe(token, "/topics/" + topic, null);
        }
    }
    // [END subscribe_topics]
}

```
Acitivity中设置监听开启服务


```
public class MainActivity extends AppCompatActivity {

    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;
    private static final String TAG = "MainActivity";

    private BroadcastReceiver mRegistrationBroadcastReceiver;
    private ProgressBar mRegistrationProgressBar;
    private TextView mInformationTextView;
    private boolean isReceiverRegistered;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mRegistrationProgressBar = (ProgressBar) findViewById(R.id.registrationProgressBar);
        mRegistrationBroadcastReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                mRegistrationProgressBar.setVisibility(ProgressBar.GONE);
                SharedPreferences sharedPreferences =
                        PreferenceManager.getDefaultSharedPreferences(context);
                boolean sentToken = sharedPreferences
                        .getBoolean(QuickstartPreferences.SENT_TOKEN_TO_SERVER, false);
                if (sentToken) {
                    mInformationTextView.setText(getString(R.string.gcm_send_message));
                } else {
                    mInformationTextView.setText(getString(R.string.token_error_message));
                }
            }
        };
        mInformationTextView = (TextView) findViewById(R.id.informationTextView);

        // Registering BroadcastReceiver
        registerReceiver();

        if (checkPlayServices()) {
            // Start IntentService to register this application with GCM.
            Intent intent = new Intent(this, RegistrationIntentService.class);
            startService(intent);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        registerReceiver();
    }

    @Override
    protected void onPause() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(mRegistrationBroadcastReceiver);
        isReceiverRegistered = false;
        super.onPause();
    }

    private void registerReceiver(){
        if(!isReceiverRegistered) {
            LocalBroadcastManager.getInstance(this).registerReceiver(mRegistrationBroadcastReceiver,
                    new IntentFilter(QuickstartPreferences.REGISTRATION_COMPLETE));
            isReceiverRegistered = true;
        }
    }
    /**
     * Check the device to make sure it has the Google Play Services APK. If
     * it doesn't, display a dialog that allows users to download the APK from
     * the Google Play Store or enable it in the device's system settings.
     */
    private boolean checkPlayServices() {
        GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = apiAvailability.isGooglePlayServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (apiAvailability.isUserResolvableError(resultCode)) {
                apiAvailability.getErrorDialog(this, resultCode, PLAY_SERVICES_RESOLUTION_REQUEST)
                        .show();
            } else {
                Log.i(TAG, "This device is not supported.");
                finish();
            }
            return false;
        }
        return true;
    }

}
```

---

## FCM
添加FCM SDK到项目中。

获取google-services.json同GCM，**build.gradle** 配置和 **2.1.2** 略有不同

### FCM gradle配置

首先，请向您的根级 build.gradle 文件添加一条规则，以包含 Google 服务插件：


```
buildscript {
    // ...
    dependencies {
        // ...
        classpath 'com.google.gms:google-services:3.0.0'
    }
}
```
然后在您的模块 Gradle 文件（通常为 app/build.gradle）中，在文件底部添加 apply plugin 行，以启用 Gradle 插件：


```
apply plugin: 'com.android.application'

android {
  // ...
}

dependencies {
  // ...
  compile 'com.google.firebase:firebase-core:9.6.1' // Firebase sdk

  compile 'com.google.firebase:firebase-messaging:9.6.1' // FCM 依赖
}

// ADD THIS AT THE BOTTOM
apply plugin: 'com.google.gms.google-services'
```
您还应为自己想使用的 [Firebase SDK](https://firebase.google.com/docs/android/setup) 添加依赖项

### FCM Mainifests及类设置
 下面是FCM的简洁之处  [示例](https://firebase.google.com/docs/samples/#android)

 贴代码：

 AndroidManifest.xml
```
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.google.firebase.quickstart.fcm">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/AppTheme">
        <!-- [START fcm_default_icon] -->
        <!-- Set custom default icon. This is used when no icon is set for incoming notification messages.
             See README(https://goo.gl/l4GJaQ) for more. -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_stat_ic_notification" />
        <!-- Set color used with incoming notification messages. This is used when no color is set for the incoming
             notification message. See README(https://goo.gl/6BKBk7) for more. -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/colorAccent" />
        <!-- [END fcm_default_icon] -->
        <activity
            android:name="com.google.firebase.quickstart.fcm.MainActivity"
            android:label="@string/app_name">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- [START firebase_service] -->
        <service
            android:name=".MyFirebaseMessagingService">//继承FirebaseMessagingService 的自定义类
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT"/>
            </intent-filter>
        </service>
        <!-- [END firebase_service] -->
        <!-- [START firebase_iid_service] -->
        <service
            android:name=".MyFirebaseInstanceIDService">//继承FirebaseInstanceIDService 的自定义类
            <intent-filter>
                <action android:name="com.google.firebase.INSTANCE_ID_EVENT"/>
            </intent-filter>
        </service>
        <!-- [END firebase_iid_service] -->
    </application>

</manifest>
```
可以看到需要自定义的实现类更少MyFirebaseMessagingService 和MyFirebaseInstanceIDService

MyFirebaseMessagingService.java

```
public class MyFirebaseMessagingService extends FirebaseMessagingService {

    private static final String TAG = "MyFirebaseMsgService";

    /**
     * Called when message is received.
     *
     * @param remoteMessage Object representing the message received from Firebase Cloud Messaging.
     */
    // [START receive_message]
    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        // [START_EXCLUDE]
        // There are two types of messages data messages and notification messages. Data messages are handled
        // here in onMessageReceived whether the app is in the foreground or background. Data messages are the type
        // traditionally used with GCM. Notification messages are only received here in onMessageReceived when the app
        // is in the foreground. When the app is in the background an automatically generated notification is displayed.
        // When the user taps on the notification they are returned to the app. Messages containing both notification
        // and data payloads are treated as notification messages. The Firebase console always sends notification
        // messages. For more see: https://firebase.google.com/docs/cloud-messaging/concept-options
        // [END_EXCLUDE]

        // TODO(developer): Handle FCM messages here.
        // Not getting messages here? See why this may be: https://goo.gl/39bRNJ
        Log.d(TAG, "From: " + remoteMessage.getFrom());

        // Check if message contains a data payload.
        if (remoteMessage.getData().size() > 0) {
            Log.d(TAG, "Message data payload: " + remoteMessage.getData());
        }

        // Check if message contains a notification payload.
        if (remoteMessage.getNotification() != null) {
            Log.d(TAG, "Message Notification Body: " + remoteMessage.getNotification().getBody());
        }

        // Also if you intend on generating your own notifications as a result of a received FCM
        // message, here is where that should be initiated. See sendNotification method below.
    }
    // [END receive_message]

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     * @param messageBody FCM message body received.
     */
    private void sendNotification(String messageBody) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);

        Uri defaultSoundUri= RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.ic_stat_ic_notification)
                .setContentTitle("FCM Message")
                .setContentText(messageBody)
                .setAutoCancel(true)
                .setSound(defaultSoundUri)
                .setContentIntent(pendingIntent);

        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }
}
```
MyFirebaseInstanceIDService.java

```

public class MyFirebaseInstanceIDService extends FirebaseInstanceIdService {

    private static final String TAG = "MyFirebaseIIDService";

    /**
     * Called if InstanceID token is updated. This may occur if the security of
     * the previous token had been compromised. Note that this is called when the InstanceID token
     * is initially generated so this is where you would retrieve the token.
     */
    // [START refresh_token]
    @Override
    public void onTokenRefresh() {
        // Get updated InstanceID token.
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        Log.d(TAG, "Refreshed token: " + refreshedToken);

        // If you want to send messages to this application instance or
        // manage this apps subscriptions on the server side, send the
        // Instance ID token to your app server.
        sendRegistrationToServer(refreshedToken);
    }
    // [END refresh_token]

    /**
     * Persist token to third-party servers.
     *
     * Modify this method to associate the user's FCM InstanceID token with any server-side account
     * maintained by your application.
     *
     * @param token The new token.
     */
    private void sendRegistrationToServer(String token) {
        // TODO: Implement this method to send token to your app server.
    }
}
```
Activiy 中依然需要检测设备 方法同GCM Activity
再来看FCM中的Activity

```
public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // If a notification message is tapped, any data accompanying the notification
        // message is available in the intent extras. In this sample the launcher
        // intent is fired when the notification is tapped, so any accompanying data would
        // be handled here. If you want a different intent fired, set the click_action
        // field of the notification message to the desired intent. The launcher intent
        // is used when no click_action is specified.
        //
        // Handle possible data accompanying notification message.
        // [START handle_data_extras]
        if (getIntent().getExtras() != null) {
            for (String key : getIntent().getExtras().keySet()) {
                Object value = getIntent().getExtras().get(key);
                Log.d(TAG, "Key: " + key + " Value: " + value);
            }
        }
        // [END handle_data_extras]

        Button subscribeButton = (Button) findViewById(R.id.subscribeButton);
        subscribeButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // [START subscribe_topics]
                FirebaseMessaging.getInstance().subscribeToTopic("news");
                // [END subscribe_topics]

                // Log and toast
                String msg = getString(R.string.msg_subscribed);
                Log.d(TAG, msg);
                Toast.makeText(MainActivity.this, msg, Toast.LENGTH_SHORT).show();
            }
        });

        Button logTokenButton = (Button) findViewById(R.id.logTokenButton);
        logTokenButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Get token
                String token = FirebaseInstanceId.getInstance().getToken();

                // Log and toast
                String msg = getString(R.string.msg_token_fmt, token);
                Log.d(TAG, msg);
                Toast.makeText(MainActivity.this, msg, Toast.LENGTH_SHORT).show();
            }
        });
    }

}
```
不需要自行监测服务

至此GCM和FCM的APP端就都以配置完成，保证测试机科学上网，便可以通过FCM控制台推送消息测试。下面是配置过程中可能遇到的问题和一些解决方法。

1.是否配置正确，首先看应用中是否能取得token，不能-->确定所有需要包名的地方填写了正确的包名，确认科学上网。

2.不能接收到通知，参照1.


---

## Google Map

[Map API](https://developers.google.com/maps/documentation/android-api/?hl=zh_CN)

[配置](https://developers.google.com/maps/documentation/android-api/signup)

### 在 Google Developers Console 中创建 API 项目

[启用API](https://console.developers.google.com/flows/enableapi?apiid=maps_android_backend&keyType=CLIENT_SIDE_ANDROID)

![APIs](http://oanvj2lsv.bkt.clouddn.com/google/api/api2.png)
注：来自 Google 地图 Android v1 应用的现有密钥通常称为 MapView，它们无法与 v2 API 配合使用。 Google Maps Android API 采用了全新的密钥管理系统。

### 向您的应用添加 API 密钥

1.在 AndroidManifest.xml 中，通过在 </application> 结束标记前插入以下元素，将其添加为 <application> 元素的子元素：

```
<meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY"/>
```
用您的 API 密钥替代 value 属性中的 YOUR_API_KEY。该元素会将密钥 com.google.android.geo.API_KEY 设置为您的 API 密钥的值。

注：如上所示，com.google.android.geo.API_KEY 是建议使用的 API 密钥元数据名称。可使用具有该名称的密钥向 Android 平台上的多个基于 Google Maps 的 API（包括 Google Maps Android API）验证身份。出于向后兼容性上的考虑，该 API 还支持 com.google.android.maps.v2.API_KEY 名称。该旧有名称只允许向 Android Maps API v2 验证身份。应用只能指定其中一个 API 密钥元数据名称。如果两个都指定，API 会抛出异常。

### [导入](https://developers.google.com/maps/documentation/android-api/map)和特殊显示的[samples](https://github.com/googlemaps/android-samples/tree/master/ApiDemos/app/src/main/java/com/example/mapdemo)

File--> new--> Google-->Google Maps Activity
自动导入依赖和mainifest配置，这里manifests文件需要手动合并，依赖默认导入最新版本，编译不过建议 9.0.0。之后可以自己手动调整

