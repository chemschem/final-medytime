import 'package:flutter/material.dart';
import 'package:meditime/api/api_functions.dart';
import 'package:meditime/models/user_model.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/core/theme/styles.dart';
import 'package:meditime/widgets/custom_text_field.dart';

class signup_page extends StatefulWidget {
  const signup_page({super.key});

  @override
  State<signup_page> createState() => _signup_pageState();
}

class _signup_pageState extends State<signup_page> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressteController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          color: AppColors.backgroundPrimary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 50),

              CustomTextField(
                controller: _fullNameController,
                labelText: "Full Name",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _emailController,
                labelText: "Email Address",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _phoneController,
                labelText: "Phone Number",
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primaryColor,
                            onPrimary: AppColors.backgroundPrimary,
                            onSurface: AppColors.textColor,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    _birthDateController.text =
                        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                  }
                },
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: _birthDateController,
                    labelText: "Date of Birth",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _addressteController,
                labelText: "Address",
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _passwordController,
                labelText: "Password",
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: "Confirm Password",
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: 299,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    // تجهيز المستخدم للإرسال
                    final user = user_model(
                      id_user: 'meditime_${_fullNameController.text}_${_birthDateController.text}',
                      name: _fullNameController.text,
                      age: _birthDateController.text,
                      phone: int.tryParse(_phoneController.text) ?? 0,
                      address: _addressteController.text,
                      password: _passwordController.text,
                      email: _emailController.text,
                    );

                    api_functions.addUserToFirestore(user);

                    // تنظيف الحقول بعد التسجيل
                    _fullNameController.clear();
                    _birthDateController.clear();
                    _phoneController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                    _emailController.clear();
                    _addressteController.clear();

                    // التنقل إلى الصفحة الرئيسية أو تسجيل الدخول
                    Navigator.pushNamed(context, '/login_page');
                  },
                  style: AppStyles.HomebuttonStyle(AppColors.primaryColor),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Divider(color: Colors.grey, thickness: 1),
              const SizedBox(height: 30),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login_page'),
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
