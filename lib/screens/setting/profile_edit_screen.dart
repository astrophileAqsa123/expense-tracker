import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/user_service.dart';
import '../../services/cloudinary_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final UserService _userService = UserService();

  File? _selectedImage;
  String imageUrl = "";

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final data = await _userService.getUserData();
    if (!mounted) return;
    if (data != null) {
      nameController.text = (data["name"] ?? "").toString();
      bioController.text = (data["bio"] ?? "").toString();
      // Your Firestore field is imageUrl
      imageUrl = (data["imageUrl"] ?? "").toString();
      setState(() {});
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

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

<<<<<<< HEAD
=======
  Future<String> uploadImage() async {
    final storage = FirebaseStorage.instance;
    final ref = storage.ref("profile_photos/${DateTime.now().millisecondsSinceEpoch}.jpg");

    if (kIsWeb && _webImageBytes != null) {
      await ref.putData(_webImageBytes!);
    } else if (_selectedImage != null) {
      await ref.putFile(_selectedImage!);
    } else {
      return imageUrl; // no new image
    }

    return await ref.getDownloadURL();
  }

>>>>>>> 0f10098 (Your commit message)
  Future<void> saveProfile() async {
    setState(() => loading = true);

    try {
      String finalImageUrl = imageUrl;

<<<<<<< HEAD
      // ✅ Upload to Cloudinary if new image selected
      if (_selectedImage != null) {
        finalImageUrl = await CloudinaryService.uploadImage(_selectedImage!);
=======
      // Upload new image if selected
      if ((kIsWeb && _webImageBytes != null) || (!kIsWeb && _selectedImage != null)) {
        finalImageUrl = await uploadImage();
>>>>>>> 0f10098 (Your commit message)
      }

      await _userService.updateUserProfile(
        name: nameController.text.trim(),
        bio: bioController.text.trim(),
        imageUrl: finalImageUrl,
      );

<<<<<<< HEAD
      if (!mounted) return;

=======
>>>>>>> 0f10098 (Your commit message)
      setState(() {
        imageUrl = finalImageUrl;
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: Colors.red,
        ),
=======
        const SnackBar(content: Text("Profile updated successfully"), backgroundColor: Colors.green),
      );

      Navigator.pop(context, true); // return true to indicate profile updated
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e"), backgroundColor: Colors.red),
>>>>>>> 0f10098 (Your commit message)
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;

    if (_selectedImage != null) {
      avatarImage = FileImage(_selectedImage!);
    } else if (imageUrl.isNotEmpty) {
      avatarImage = NetworkImage(imageUrl);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
<<<<<<< HEAD
=======
                  const SizedBox(height: 10),
                  const Text(
                    "Add Profile Photo",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
>>>>>>> 0f10098 (Your commit message)
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
