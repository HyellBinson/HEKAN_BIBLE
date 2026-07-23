import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final TextEditingController emailController =
  TextEditingController();

  bool sending = false;
  bool sent = false;

  Future<void> sendResetEmail() async {

    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email."),
        ),
      );
      return;
    }

    setState(() {
      sending = true;
    });

    try {

      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

      setState(() {
        sent = true;
      });

    } on FirebaseAuthException catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Something went wrong.",
          ),
        ),
      );

    }

    setState(() {
      sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Center(

            child: SingleChildScrollView(

              child: sent

                  ? Column(

                children: [

                  const Icon(
                    Icons.mark_email_read_rounded,
                    color: Colors.green,
                    size: 90,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Password Reset Link Sent",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    emailController.text,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Please check your inbox and spam folder.",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text("Back to Login"),
                    ),
                  )

                ],
              )

                  : Column(

                children: [

                  Image.asset(
                    "assets/icon/app_icon.png",
                    width: 110,
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "\"With God all things are possible.\"\nMatthew 19:26",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 35),

                  TextField(
                    controller: emailController,
                    keyboardType:
                    TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(

                      onPressed: sending
                          ? null
                          : sendResetEmail,

                      child: sending
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : const Text(
                        "Send Reset Link",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back to Login",
                    ),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}