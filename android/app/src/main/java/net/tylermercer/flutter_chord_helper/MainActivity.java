package net.tylermercer.flutter_chord_helper;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

public class MainActivity extends FlutterActivity implements EventChannel.StreamHandler {
    private static final String CHANNEL = "samples.flutter.dev/music";

    private BroadcastReceiver receiver = null;

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setStreamHandler(this);
  }


    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        IntentFilter iF = new IntentFilter();
        iF.addAction("com.android.music.metachanged");
        iF.addAction("com.android.music.playstatechanged");
        iF.addAction("com.android.music.playbackcomplete");
        iF.addAction("com.android.music.queuechanged");

        Log.d("FOOBAR", "listening for music events!!!");

        receiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                Log.d("FOOBAR", "received music event!!!");

                HashMap<String, String> data = new HashMap<>();
                data.put("artist", intent.getStringExtra("artist"));
                data.put("album", intent.getStringExtra("album"));
                data.put("track", intent.getStringExtra("track"));

                events.success(stringMapToJson(data));
            }
        };

        registerReceiver(receiver, iF);
    }

    @Override
    public void onCancel(Object arguments) {
        if (receiver == null) return;
        unregisterReceiver(receiver);
        receiver = null;
    }

    public String stringMapToJson(Map<String, String> map) {
      StringBuilder result = new StringBuilder("{");

      for (String key : map.keySet()) {
          result.append("\"")
                  .append(key)
                  .append("\":\"")
                  .append(map.get(key))
                  .append("\",");
      }

      result.setLength(result.length() > 1 ? result.length() - 1 : 1);

      result.append('}');
      return result.toString();
    }
}