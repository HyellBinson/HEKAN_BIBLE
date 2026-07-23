import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';

import 'package:url_launcher/url_launcher.dart';



class EmailVerificationScreen extends StatefulWidget {
  final String name;
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends State<EmailVerificationScreen> {

  bool checking = false;
  bool sending = false;

  Timer? timer;
  Timer? countdownTimer;

  int secondsRemaining = 60;
  bool canResend = false;

  @override
  void initState() {
    super.initState();

    startCountdown();

    timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => checkVerification(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    secondsRemaining = 60;
    canResend = false;

    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (secondsRemaining == 0) {
          timer.cancel();

          setState(() {
            canResend = true;
          });

        } else {
          setState(() {
            secondsRemaining--;
          });
        }
      },
    );
  }


  Future<void> checkVerification() async {

    await FirebaseAuth.instance.currentUser?.reload();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {

      timer?.cancel();
      countdownTimer?.cancel();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: widget.name,
          ),
        ),
            (route) => false,
      );
    }
  }




  Future<void> resendEmail() async {

    if (!canResend) return;

    setState(() {
      sending = true;
    });

    await FirebaseAuth.instance.currentUser
        ?.sendEmailVerification();

    setState(() {
      sending = false;
    });

    startCountdown();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Verification email sent.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.mark_email_read_rounded,
                  color: Color(0xFF22C55E),
                  size: 100,
                ),

                const SizedBox(height: 25),

                const Text(
                  "Verify Your Email",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "We've sent a verification email to:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  "Please open your email, click the verification link, then return here and tap the button below.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                    checking ? null : checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                    child: checking
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "I've Verified My Email",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: const Text(
                      "Open Gmail",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      const intent = AndroidIntent(
                        action: 'android.intent.action.MAIN',
                        category: 'android.intent.category.APP_EMAIL',
                      );

                      await intent.launch();
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: canResend && !sending
                        ? resendEmail
                        : null,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF22C55E),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: sending
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      canResend
                          ? "Resend Verification Email"
                          : "Resend in ${secondsRemaining}s",
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();

                    if (!mounted) return;

                    Navigator.popUntil(
                      context,
                          (route) => route.isFirst,
                    );
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}