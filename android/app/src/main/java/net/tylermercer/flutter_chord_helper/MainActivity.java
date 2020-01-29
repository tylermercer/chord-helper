package net.tylermercer.flutter_chord_helper;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.media.AudioManager;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

public class MainActivity extends FlutterActivity implements EventChannel.StreamHandler, MethodChannel.MethodCallHandler {
    private static final String EVENT_CHANNEL = "net.tylermercer.chordhelper/music";
    private static final String METHOD_CHANNEL = "net.tylermercer.chordhelper/control";
    private AudioManager audioManager;

    private BroadcastReceiver receiver = null;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL)
                .setStreamHandler(this);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(this);

        audioManager = (AudioManager)getSystemService(Context.AUDIO_SERVICE);
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

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "playMusic":
                playMusic(call.arguments, result);
                break;
            case "pauseMusic":
                pauseMusic(call.arguments, result);
                break;
            case "goToNextSong":
                goToNextSong(call.arguments, result);
                break;
            case "goToPreviousSong":
                goToPreviousSong(call.arguments, result);
                break;
            case "getMediaPlayState":
                getMediaPlayState(call.arguments, result);
        }
    }

    private void getMediaPlayState(Object arguments, @NonNull MethodChannel.Result result) {
        Log.d("MainActivity", "getMediaPlayState");
        result.success(audioManager.isMusicActive() ? "PLAYING" : "PAUSED");
    }

    private void goToPreviousSong(Object arguments, @NonNull MethodChannel.Result result) {
        Log.d("MainActivity", "goToPreviousSong");
    }

    private void goToNextSong(Object arguments, @NonNull MethodChannel.Result result) {
        Log.d("MainActivity", "goToNextSong");
    }

    private void pauseMusic(Object arguments, @NonNull MethodChannel.Result result) {
        Log.d("MainActivity", "pauseMusic");
        if (audioManager.isMusicActive()) {

            Intent i = new Intent("com.android.music.musicservicecommand");

            i.putExtra("command", "pause");
            MainActivity.this.sendBroadcast(i);
        }
    }

    private void playMusic(Object arguments, @NonNull MethodChannel.Result result) {
        Log.d("MainActivity", "playMusic");
    }
}