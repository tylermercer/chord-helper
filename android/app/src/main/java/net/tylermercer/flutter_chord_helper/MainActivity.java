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

import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends FlutterActivity implements EventChannel.StreamHandler {
    private static final String CHANNEL = "net.tylermercer.chordhelper/music";

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

        receiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                JSONObject data = new JSONObject();
                try {
                    data.put("command", intent.getStringExtra("command"));
                    data.put("artist", intent.getStringExtra("artist"));
                    data.put("album", intent.getStringExtra("album"));
                    data.put("track", intent.getStringExtra("track"));
                    events.success(data.toString());
                } catch (JSONException je) {
                    events.error("UNAVAILABLE", "JSON Encoding Error", je.getMessage());
                }

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
}