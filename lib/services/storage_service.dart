import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload trainer image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadTrainerImage(File imageFile, String trainerId) async {
    try {
      print('Starting upload for trainer: $trainerId');
      print('File path: ${imageFile.path}');
      print('File exists: ${await imageFile.exists()}');
      
      // Create a unique file name
      final fileName = 'trainer_${trainerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('trainers/$fileName');
      
      print('Storage reference: trainers/$fileName');
      
      // Upload the file
      print('Starting putFile...');
      final uploadTask = ref.putFile(imageFile);
      
      // Wait for upload to complete
      print('Waiting for upload to complete...');
      final snapshot = await uploadTask;
      
      print('Upload complete, getting download URL...');
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e, stackTrace) {
      print('Error uploading trainer image: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload center image to Firebase Storage
  /// Returns the download URL
  Future<String> uploadCenterImage(File imageFile, String centerId) async {
    try {
      final fileName = 'center_${centerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('centers/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload category icon to Firebase Storage
  /// Returns the download URL
  Future<String> uploadCategoryIcon(File imageFile, String categoryId) async {
    try {
      final fileName = 'category_${categoryId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = _storage.ref().child('categories/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload category icon: $e');
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Image might not exist, ignore error
      print('Error deleting image: $e');
    }
  }
}
