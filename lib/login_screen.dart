import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'settings_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgot_password_screen.dart';
import 'responsive.dart';

class LoginScreen extends StatefulWidget {

  final Function(bool)? onThemeChanged;

  const LoginScreen({
    super.key,
    this.onThemeChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: ['email'],
  );

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> goToHome() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email and password."),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = credential.user!;

      // Refresh user information
      await user.reload();
      user = FirebaseAuth.instance.currentUser!;

      // Check email verification
      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please verify your email before logging in.",
            ),
          ),
        );

        return;
      }

      // Get user's name from Firestore
      String name = "User";

      final query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user.email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        name = query.docs.first.data()["name"] ?? "User";
      }

      if (!mounted) return;

      await SettingsService.syncFromCloud();

      // Restore theme
      final isDark = await SettingsService.getDarkMode();
      widget.onThemeChanged?.call(isDark);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: name,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login failed.";

      switch (e.code) {
        case 'user-not-found':
          message = "No account found with that email.";
          break;

        case 'wrong-password':
        case 'invalid-credential':
          message = "Incorrect email or password.";
          break;

        case 'invalid-email':
          message = "Invalid email address.";
          break;

        case 'too-many-requests':
          message = "Too many attempts. Please try again later.";
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Email Address",
            hintText: "Enter your email",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();

              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter your email."),
                  ),
                );
                return;
              }

              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Password reset link has been sent to your email.",
                    ),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? "Something went wrong."),
                  ),
                );
              }
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Container(
              margin: EdgeInsets.all(20 * scale),
              padding: EdgeInsets.all(25 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(30 * scale),
                border: Border.all(color: Colors.white24),
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
                    "HEKAN Bible",
                    style: TextStyle(
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Welcome Back 👋",
                    style: TextStyle(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(height: 30 * scale),

                  _input(
                    controller: emailController,
                    hint: "Email",
                  ),
                  const SizedBox(height: 15),
                  _input(
                    controller: passwordController,
                    hint: "Password",
                    obscure: obscurePassword,
                    isPassword: true,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                  //  child: TextButton(
                      //  onPressed: forgotPassword,

                    ),
                //  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text("Forgot Password?"),
                    ),
                  ),



                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : goToHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        padding: EdgeInsets.symmetric(
                          vertical: 16 * scale,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "OR",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        signInWithGoogle();
                      },
                      icon: Image.asset(
                        "assets/images/google.png",
                        width: 22,
                      ),
                      label: const Text(
                        "Continue with Google",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: EdgeInsets.symmetric(
                          vertical: 15 * scale,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SIGNUP BUTTON
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(color: Colors.white),
                    ),


                  ),
                ],
              ),
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
    bool obscure = false,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12 * Responsive.scale(context),
          ),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscurePassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        )
            : null,
      ),
    );
  }
  Future<void> signInWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });
      print("Google button pressed");

      // Sign out first so the account picker always appears
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
      await _googleSignIn.signIn();
      print("Google user: $googleUser");

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
      await FirebaseAuth.instance
          .signInWithCredential(credential);
      print("Firebase Login Success");

      final User user = userCredential.user!;

      final query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user.email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        await FirebaseAuth.instance.signOut();
        await _googleSignIn.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "This Google account is not registered. Please sign up first.",
            ),
          ),
        );

        return;
      }

      final data = query.docs.first.data();

      final String name = data["name"] ?? user.displayName ?? "User";

      if (!mounted) return;
      await SettingsService.syncFromCloud();

// Reload the app theme for the logged-in user
      final isDark = await SettingsService.getDarkMode();
      widget.onThemeChanged?.call(isDark);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: name,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );

      if (!mounted) return;

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? "Authentication failed"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }}