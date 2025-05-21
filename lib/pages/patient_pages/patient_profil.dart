import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditime/api/api_functions.dart';
import 'package:meditime/api/globals.dart' as globals;
import 'package:meditime/core/theme/colors.dart';

class PatientProfil extends StatefulWidget {
  const PatientProfil({super.key});

  @override
  State<PatientProfil> createState() => _PatientProfilState();
}

class _PatientProfilState extends State<PatientProfil> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool isEditing = false;
  File? patientImage;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      userData = await api_functions().fetchUser();
      _nameController.text = userData?['name'] ?? '';
      _emailController.text = userData?['email'] ?? '';
      _addressController.text = userData?['address'] ?? '';
      _birthController.text = userData?['age'] ?? '';
      _phoneController.text = userData!['phone'].toString();
      setState(() {});
    } catch (e) {
      print('Failed to load user data: $e');
    }
  }

  Future<void> _saveChanges() async {
    try {
      final updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'age': _birthController.text,
        'phone': int.tryParse(_phoneController.text) ?? 0,
      };

      await FirebaseFirestore.instance
          .collection('user')
          .doc(globals.currentUserId)
          .update(updatedData);

      setState(() => isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data updated successfully')),
      );
    } catch (e) {
      print('Failed to update user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => patientImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(isEditing ? 'Edit Patient Info' : 'Profile',
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontWeight: FontWeight.bold,

            )),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit,
                color: AppColors.whiteColor),
            onPressed: () {
              if (isEditing) _saveChanges();
              setState(() => isEditing = !isEditing);
            },
          ),
        ],
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Patient Image'),
                  GestureDetector(
                    onTap: isEditing ? _pickImage : null,
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        image: patientImage != null
                            ? DecorationImage(
                                image: FileImage(patientImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: patientImage == null
                          ? const Center(
                              child: Icon(Icons.add_a_photo,
                                  size: 40, color: AppColors.primaryColor),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Name'),
                  _buildTextField(controller: _nameController),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Birth Date'),
                  _buildTextField(controller: _birthController),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Email'),
                  _buildTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Address'),
                  _buildTextField(controller: _addressController),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Phone'),
                  _buildTextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  if (isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text('Save',
                            style: TextStyle(
                              color: Colors.white,
                            )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),


         



    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: isEditing,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
