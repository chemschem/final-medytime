import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meditime/api/api_functions.dart';
import 'package:meditime/core/theme/colors.dart';
import 'package:meditime/core/theme/styles.dart';
import 'package:meditime/models/clinic_model.dart';
import 'package:meditime/widgets/CustomTextField_1.dart';


class edit_clinic_info extends StatefulWidget {
  const edit_clinic_info({super.key});

  @override
  State<edit_clinic_info> createState() => _edit_clinic_infoState();
}

class _edit_clinic_infoState extends State<edit_clinic_info> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
    final TextEditingController _doctorDesController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  bool isEditing = false;
  File? clinicImage;

 late Future<clinic_model> _clinicFuture;
String? _loadedClinicId; // لتخزين ID العيادة التي تم تحميلها


//املأ الحقول مرة واحدة فقط داخل initState بعد تحميل البيانات
@override
void initState() {
  super.initState();
  _clinicFuture = _fetchOrCreateClinic().then((clinic) {
    _loadedClinicId = clinic.id_clinic;
    _nameController.text = clinic.name_clinic ?? '';
    _emailController.text = clinic.email_clinic ?? '';
    _addressController.text = clinic.addresse_clinic ?? '';
    _doctorNameController.text = clinic.doctor_name ?? '';
    _phoneController.text = clinic.clinic_phone?.toString() ?? '';
    return clinic;
  });
}


Future<clinic_model> _fetchOrCreateClinic() async {
  final collection = FirebaseFirestore.instance.collection('clinic');
  final snapshot = await collection.limit(1).get();

  if (snapshot.docs.isNotEmpty) {
    final doc = snapshot.docs.first;
    _loadedClinicId = doc.id; // نحتفظ بـ ID العيادة
    return clinic_model.fromJson(doc.data());
  } else {
    // لا توجد عيادة، نقوم بإنشائها
    final newDoc = await collection.add({
      "name_clinic": "",
      "email_clinic": "",
      "addresse_clinic": "",
      "doctor_name": "",
      "clinic_phone": null,
    });

    _loadedClinicId = newDoc.id;

    return clinic_model(
      id_clinic: _loadedClinicId!,
      name_clinic: "",
      email_clinic: "",
      addresse_clinic: "",
      doctor_name: "",
      clinic_phone: null,
    );
  }
}

void _saveChanges() {
  if (_loadedClinicId == null) return; // تأكدنا من أن ID محمل

  final updatedClinic = clinic_model(
    id_clinic: _loadedClinicId!,
    name_clinic: _nameController.text.trim(),
    email_clinic: _emailController.text.trim(),
    addresse_clinic: _addressController.text.trim(),
    doctor_name: _doctorNameController.text.trim(),
    clinic_phone: int.tryParse(_phoneController.text.trim()),
    doctor_des: _doctorDesController.text.trim(),
  );

  api_functions.updateClinicInFirestore(updatedClinic);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Changes saved successfully!')),
  );
}

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        clinicImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
      title: Text(isEditing ? 'Edit Clinic Info' : 'Clinic Information',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
      actions: [
        FutureBuilder<clinic_model>(
          future: _clinicFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            final clinic = snapshot.data!;
            return IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: () {
                if (isEditing) _saveChanges();
                setState(() => isEditing = !isEditing);
              },
            );
          },
        ),
      ],
    ),
      body: FutureBuilder<clinic_model>(
        future: _clinicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No clinic data found'));
          }

          final clinic = snapshot.data!;


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('About clinic'),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      image: clinicImage != null
                          ? DecorationImage(
                              image: FileImage(clinicImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: clinicImage == null
                        ? const Center(
                            child: Icon(Icons.add_a_photo,
                                size: 40, color: AppColors.primaryColor),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField_1(controller: _nameController,
                labelText: 'Clinic name',),
                CustomTextField_1(controller: _emailController,
                labelText: 'Email',),
CustomTextField_1(controller: _addressController,
                labelText: 'Address',),
                CustomTextField_1(controller: _phoneController,
                labelText: 'Phone',),
CustomTextField_1(controller: _doctorNameController,
                labelText: 'Doctor name',),
                CustomTextField_1(controller: _doctorDesController,
                labelText: 'About Doctor',),



                const SizedBox(height: 32),
                if (isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
onPressed: () {
  if (isEditing) {
    _saveChanges();
  }
  setState(() {
    isEditing = !isEditing;
  });
},
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('save', style: TextStyle(color: Colors.white),),
                     style:AppStyles.OtherbuttonStyle(AppColors.primaryColor),

                    ),
                  ),
              ],
            ),
          );
        },
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

 
  }

