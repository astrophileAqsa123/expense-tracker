import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../services/user_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final UserService _userService = UserService();

  File? _selectedImage; // mobile/desktop
  Uint8List? _webImageBytes; // web
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final data = await _userService.getUserData();
    if (data != null) {
      nameController.text = data["name"] ?? "";
      bioController.text = data["bio"] ?? "";
      imageUrl = data["imageUrl"] ?? "";
      setState(() {});
    }
  }

  // Pick image from camera or gallery
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    }
  }

  // Show bottom sheet for camera/gallery
  void showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage() async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref("profile_photos/${DateTime.now().millisecondsSinceEpoch}.jpg");

    if (kIsWeb && _webImageBytes != null) {
      await ref.putData(_webImageBytes!);
    } else if (_selectedImage != null) {
      await ref.putFile(_selectedImage!);
    } else {
      throw Exception("No image selected to upload");
    }

    return await ref.getDownloadURL();
  }

  // Save profile data
  Future<void> saveProfile() async {
    try {
      String finalImageUrl = imageUrl;

      // Upload image if selected
      if ((kIsWeb && _webImageBytes != null) || (!kIsWeb && _selectedImage != null)) {
        finalImageUrl = await uploadImage();
        print("Uploaded image URL: $finalImageUrl");
      }

      // Update Firestore
      await _userService.updateUserProfile(
        name: nameController.text.trim(),
        bio: bioController.text.trim(),
        imageUrl: finalImageUrl,
      );
      print("Firestore updated with image URL");

      // Update local state
      setState(() {
        imageUrl = finalImageUrl;
        _selectedImage = null;
        _webImageBytes = null;
      });

      Navigator.pop(context, true); // refresh dashboard
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;

    if (kIsWeb && _webImageBytes != null) {
      avatarImage = MemoryImage(_webImageBytes!);
    } else if (_selectedImage != null) {
      avatarImage = FileImage(_selectedImage!);
    } else if (imageUrl.isNotEmpty) {
      avatarImage = NetworkImage(imageUrl);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: showImageOptions,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.deepPurple,
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: showImageOptions,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Add Profile Photo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: "Profile Bio",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfile,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
