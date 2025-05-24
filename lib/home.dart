import 'package:flutter/material.dart';
import 'package:meditime/core/theme/fonts.dart';
import 'core/theme/colors.dart';
import 'core/theme/styles.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.backgroundPrimary,
          child: Column(
            children: [
              const SizedBox(height: 50),

              Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 180,
              ),

              const SizedBox(height: 20),
              Text(
                "Welcome to MEDITIME!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFonts.headlineMedium.fontSize,
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Let’s make healthcare simpler,\none appointment at a time!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppFonts.bodyLarge.fontSize,
                    // ignore: deprecated_member_use
                    color: AppColors.textColor.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/login_page");
                      },
                      style: AppStyles.HomebuttonStyle(AppColors.primaryColor),
                      child: const Text(
                        "Login",
                       style: TextStyle(
                           fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/signup_page");
                      },
                      style: AppStyles.HomebuttonStyle(const Color.fromARGB(255, 255, 255, 255)),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                   
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
