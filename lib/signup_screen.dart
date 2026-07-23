import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_verification_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'responsive.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();
  bool isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();

  }

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
    });
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
        ),
      );
      return;
    }

    try {
      final UserCredential credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = credential.user!;

      await user.updateDisplayName(name);

// Send verification email
      await user.sendEmailVerification();

// Save user data
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "uid": user.uid,
        "name": name,
        "email": email,
        "profileImage": "",
        "darkMode": false,
        "bibleVersion": "KJV",
        "verseEnabled": true,
        "prayerEnabled": true,
        "createdAt": FieldValue.serverTimestamp(),
      });

// IMPORTANT: Sign the user out until they verify
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            name: name,
            email: email,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Sign up failed.";

      switch (e.code) {
        case "email-already-in-use":
          message = "This email is already registered.";
          break;

        case "weak-password":
          message = "Password must be at least 6 characters.";
          break;

        case "invalid-email":
          message = "Invalid email address.";
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> signUpWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });

      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final User user = userCredential.user!;

      // Check if user already exists in Firestore
      final existingUser = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user.email)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This Google account is already registered. Please login instead.",
            ),
          ),
        );

        await FirebaseAuth.instance.signOut();
        await _googleSignIn.signOut();

        setState(() {
          isLoading = false;
        });

        return;
      }

      // Save user
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "uid": user.uid,
        "name": user.displayName,
        "email": user.email,
        "photo": user.photoURL,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: user.displayName ?? "User",
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Google Sign Up Failed",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.scale(context);

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF14532D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(

          child: SingleChildScrollView(

          child: Container(

              margin: EdgeInsets.all(20 * scale),
              padding: EdgeInsets.all(25 * scale),

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30 * scale),

                border: Border.all(
                  color: Colors.white24,
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  Image.asset(
                    "assets/icon/app_icon.png",
                    width: 90 * scale,
                    height: 90 * scale,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height:5 * scale),

                  Text(
                    "Join the HEKAN Bible community",
                    style: TextStyle(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(height: 30 * scale),

                  _input(
                    controller: nameController,
                    hint: "Full Name",
                    icon: Icons.person_outline,
                    scale: scale,
                  ),
                  SizedBox(height: 15 * scale),

                  _input(
                    controller: emailController,
                    hint: "Email",
                    icon: Icons.email_outlined,
                    scale: scale,
                  ),

                  const SizedBox(height: 15),

                  _input(
                    controller: passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    obscure: true,
                    scale: scale,
                  ),

                  SizedBox(height: 30 * scale),
                  /// SIGN UP BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: signUp,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF22C55E),

                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),

                      child: isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : signUpWithGoogle,
                      icon: Image.asset(
                        "assets/icon/google.png",
                        width: 22 * scale,
                        height: 22 * scale,
                      ),
                      label: const Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.white30,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),



                  /// BACK TO LOGIN
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required double scale,
    bool obscure = false,
  }) {

    return TextField(

      controller: controller,

      obscureText: obscure,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(

        prefixIcon: Icon(
          icon,
          color: Colors.white70,
        ),

        hintText: hint,

        hintStyle: const TextStyle(
          color: Colors.white70,
        ),

        filled: true,
        fillColor: Colors.white.withOpacity(0.08),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15 * scale),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}