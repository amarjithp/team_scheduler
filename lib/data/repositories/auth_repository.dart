import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:team_scheduler/data/models/user_model.dart';
import 'package:team_scheduler/main.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';

class AuthRepository {
  Future<UserModel> signUp({
    required String name,
    XFile? imageFile,
  }) async {
    try {
      const uuid = Uuid();
      final dummyEmail = '${uuid.v4()}@example.com';
      final dummyPassword = uuid.v4();

      String? photoUrl;

      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';
        if (kIsWeb) {
          final Uint8List fileBytes = await imageFile.readAsBytes();
          await supabase.storage.from('profile').uploadBinary(fileName, fileBytes);
        } else {
          final file = File(imageFile.path);
          await supabase.storage.from('profile').upload(fileName, file);
        }
        photoUrl = supabase.storage.from('profile').getPublicUrl(fileName);
      }

      final authResponse = await supabase.auth.signUp(
        email: dummyEmail,
        password: dummyPassword,
        data: {'name': name, 'photo_url': photoUrl},
      );

      if (authResponse.user == null) {
        throw Exception('Sign up failed: No user created.');
      }

      final userMap = await supabase
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return UserModel.fromMap(userMap);

    } catch (e) {
      print('❌ AuthRepository error: $e');
      throw Exception('Failed to sign up: $e');
    }
  }
}
