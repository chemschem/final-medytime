import 'package:flutter/material.dart';
import 'package:meditime/api/functionFCM_token.dart';
import 'package:meditime/api/function_session.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/core/theme/styles.dart';
import 'package:meditime/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';

class login_page extends StatefulWidget {
  const login_page({super.key});

  @override
  _login_pageState createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final function_session apiFunctionssession = function_session();
  String? currentUserId;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 50),

              // Email
              CustomTextField(
                controller: emailController,
                labelText: 'Email Address',
              ),

              const SizedBox(height: 30),

              // Password
              CustomTextField(
                controller: passwordController,
                labelText: 'Password',
                obscureText: obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgotPassword');
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Login button
              SizedBox(
                width: 299,
                height: 60,
                child: ElevatedButton(
                  onPressed: () async {
                    bool success = await apiFunctionssession.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                      context,
                    );
                    if (success) {
                      String? fetchedUserId = await apiFunctionssession
                          .fetchUserId(emailController.text);
                      if (fetchedUserId != null) {
                        setState(() {
                          currentUserId = fetchedUserId;
                        });
                        functionFCM_token()
                            .saveTokenToDatabase(globals.currentUserId!);
                        function_session().go_page(context, emailController.text,
                            passwordController.text, currentUserId!);
                      }
                    }
                    emailController.clear();
                    passwordController.clear();
                  },
                  style: AppStyles.buttonStyle(AppColors.primaryColor),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 30),

              // Sign up
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(
                            color: AppColors.textColor, fontSize: 18),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/signup_page');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
