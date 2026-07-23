import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'responsive.dart';
import 'license_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final String name;

  const ProfileScreen({
    super.key,
    required this.name,
    this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String imageBase64 = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadPhoto();
  }

  // 📥 LOAD SAVED PHOTO
  Future<void> loadPhoto() async {

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    setState(() {
      imageBase64 = data["profileImage"] ?? "";
      email = data["email"] ?? "";
    });
  }

  // 📤 PICK PHOTO FROM GALLERY
  Future<void> pickPhoto() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image == null) return;

      final bytes = await File(image.path).readAsBytes();

      final base64Image = base64Encode(bytes);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .update({
        "profileImage": base64Image,
      });

      setState(() {
        imageBase64 = base64Image;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile picture updated."),
        ),
      );
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }


  void _showAboutApp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark =
            Theme.of(context).brightness == Brightness.dark;

        final scale = Responsive.scale(context);

        return Container(
          padding: EdgeInsets.fromLTRB(
            24 * scale,
            20 * scale,
            24 * scale,
            30 * scale,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // drag handle
                Container(
                  width: 45 * scale,
                  height: 5 * scale,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 40 * scale,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    "assets/icon/app_icon.png",
                  ),
                ),

                SizedBox(height: 15 * scale),

                 Text(
                  "HEKAN Bible",
                  style: TextStyle(
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  "HEKAN Bible is a modern Christian Bible application built to help believers study God's Word, search the Scriptures, read hymns, keep personal notes, receive daily verses, and strengthen their walk with Christ.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.6,
                    fontSize: 15 * scale,
                  ),
                ),

                const SizedBox(height: 30),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.business),
                  title: const Text("Developer"),
                  subtitle: const Text("HEKAN Nigeria"),
                ),

                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text("Email"),
                  subtitle: const SelectableText(
                    "abreub2022@gmail.com",
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text("Phone"),
                  subtitle: const SelectableText(
                    "07026100033",
                  ),
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text("Open Source Licenses"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LicenseScreen(),
                      ),
                    );
                  },
                ),

                 SizedBox(height: 15 * scale),

                Text(
                  "© 2026 HEKAN Nigeria\nAll Rights Reserved.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60 * scale,
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 22 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: EdgeInsets.all(20 * scale),
        children: [

          // 👤 PROFILE PHOTO
          // 👤 PROFILE PHOTO
          Center(
            child: GestureDetector(
              onTap: pickPhoto,
              child: CircleAvatar(
                radius: 55 * scale,
                backgroundImage: imageBase64.isNotEmpty
                    ? MemoryImage(base64Decode(imageBase64))
                    : null,

                child: imageBase64.isEmpty
                    ? Icon(
                  Icons.person,
                  size: 50 * scale,
                )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 15),

// 👤 NAME & EMAIL
          Center(
            child: Column(
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email,
                  style:  TextStyle(
                    color: Colors.grey,
                    fontSize: 16 * scale,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 25 * scale),

          // ⚙️ SETTINGS BUTTON
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 8 * scale,
              vertical: 4 * scale,
            ),
            leading: Icon(
              Icons.settings,
              size: 24 * scale,
            ),
            title: const Text("Settings"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    onThemeChanged: widget.onThemeChanged,  // Pass the real one from root
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // ℹ️ ABOUT
          ListTile(
            leading:  Icon(Icons.info_outline),
            title: const Text("About App"),
            trailing: Icon(Icons.arrow_forward_ios,size: 16 * scale),
            onTap: _showAboutApp,
          ),

          const Divider(),

          // 🚪 LOGOUT
          // 🚪 LOGOUT
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text(
                    "Are you sure you want to logout?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              // Sign out from Google (if the user used Google Sign-In)
              await GoogleSignIn().signOut();

              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}