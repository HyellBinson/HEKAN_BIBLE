import 'package:flutter/material.dart';
import 'settings_service.dart';
import 'notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const SettingsScreen({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String version = "KJV";
  bool verseEnabled = true;
  bool prayerEnabled = true;
  bool isDark = false;

  TimeOfDay verseTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay morningPrayerTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay eveningPrayerTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    version = await SettingsService.getBibleVersion();
    verseEnabled = await SettingsService.getVerseEnabled();
    prayerEnabled = await SettingsService.getPrayerEnabled();
    isDark = await SettingsService.getDarkMode();

    final verseSaved = await SettingsService.getVerseTime();
    verseTime = TimeOfDay(hour: verseSaved[0], minute: verseSaved[1]);

    final morningSaved = await SettingsService.getMorningPrayerTime();
    morningPrayerTime = TimeOfDay(hour: morningSaved[0], minute: morningSaved[1]);

    final eveningSaved = await SettingsService.getEveningPrayerTime();
    eveningPrayerTime = TimeOfDay(hour: eveningSaved[0], minute: eveningSaved[1]);

    setState(() {});
  }

  // Reschedule notifications after any change
  Future<void> _rescheduleNotifications() async {
    await NotificationService.loadAndScheduleAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings ⚙️")),
      body: ListView(
        children: [
          // BIBLE VERSION
          ListTile(
            title: const Text("Bible Version for Notifications"),
            trailing: DropdownButton<String>(
              value: version,
              items: const [
                DropdownMenuItem(value: "KJV", child: Text("KJV")),
                DropdownMenuItem(value: "NIV", child: Text("NIV")),
                DropdownMenuItem(value: "NLT", child: Text("NLT")),
                DropdownMenuItem(value: "ESV", child: Text("ESV")),
                DropdownMenuItem(value: "PIDGIN", child: Text("PIDGIN")),
                DropdownMenuItem(value: "HAUSA", child: Text("HAUSA")),
              ],
              onChanged: (value) async {
                if (value == null) return;

                await SettingsService.setBibleVersion(value);

                final uid = FirebaseAuth.instance.currentUser!.uid;

                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .update({
                  "bibleVersion": value,
                });

                setState(() => version = value);

                await NotificationService.loadAndScheduleAll();
              },
            ),
          ),
          const Divider(),

          // DAILY VERSE
          SwitchListTile(
            title: const Text("📖 Daily Verse Notification"),
            value: verseEnabled,
            onChanged: (value) async {
              await SettingsService.setVerseEnabled(value);
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                "verseEnabled": value,
              });
              setState(() => verseEnabled = value);
              await _rescheduleNotifications();
            },
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text("Verse Time"),
            subtitle: Text(verseTime.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: verseTime,
              );
              if (picked != null) {
                await SettingsService.setVerseTime(picked.hour, picked.minute);
                setState(() => verseTime = picked);
                await _rescheduleNotifications();
              }
            },
          ),
          const Divider(),

          // DAILY PRAYER
          SwitchListTile(
            title: const Text("🙏 Daily Prayer Notification"),
            subtitle: const Text("Morning & Evening"),
            value: prayerEnabled,
            onChanged: (value) async {
              await SettingsService.setPrayerEnabled(value);
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({
                "prayerEnabled": value,
              });
              setState(() => prayerEnabled = value);
              await _rescheduleNotifications();
            },
          ),

          // Morning Prayer
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text("🌅 Morning Prayer Time"),
            subtitle: Text(morningPrayerTime.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: morningPrayerTime,
              );
              if (picked != null) {
                await SettingsService.setMorningPrayerTime(picked.hour, picked.minute);
                setState(() => morningPrayerTime = picked);
                await _rescheduleNotifications();
              }
            },
          ),

          // Evening Prayer
          ListTile(
            leading: const Icon(Icons.nightlight_outlined),
            title: const Text("🌙 Evening Prayer Time"),
            subtitle: Text(eveningPrayerTime.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: eveningPrayerTime,
              );
              if (picked != null) {
                await SettingsService.setEveningPrayerTime(picked.hour, picked.minute);
                setState(() => eveningPrayerTime = picked);
                await _rescheduleNotifications();
              }
            },
          ),

          const Divider(),

          // DARK MODE
          SwitchListTile(
            title: const Text("Dark Mode 🌙"),
            value: isDark,
            onChanged: (bool newValue) async {

              final uid =
                  FirebaseAuth.instance.currentUser!.uid;

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .update({
                "darkMode": newValue,
              });

              await SettingsService.setDarkMode(newValue);

              widget.onThemeChanged?.call(newValue);

              setState(() {
                isDark = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}