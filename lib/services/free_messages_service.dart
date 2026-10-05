import 'package:shared_preferences/shared_preferences.dart';

class FreeMessagesService {
  static const _enabledKey = 'free_messages_enabled';
  static const _bluetoothKey = 'free_messages_bluetooth';
  static const _wifiKey = 'free_messages_wifi';
  static const _mediaKey = 'free_messages_media';
  static const _callsKey = 'free_messages_calls';

  static Future<bool> isEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_enabledKey) ?? false;

  static Future<bool> bluetoothEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_bluetoothKey) ?? true;

  static Future<bool> wifiEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_wifiKey) ?? true;

  static Future<bool> mediaEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_mediaKey) ?? true;

  static Future<bool> callsEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_callsKey) ?? true;

  static Future<void> setEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_enabledKey, value);
  }

  static Future<void> setBluetoothEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_bluetoothKey, value);
  }

  static Future<void> setWifiEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_wifiKey, value);
  }

  static Future<void> setMediaEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_mediaKey, value);
  }

  static Future<void> setCallsEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_callsKey, value);
  }
}
