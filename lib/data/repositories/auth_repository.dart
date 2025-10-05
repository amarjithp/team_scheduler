import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:team_scheduler/data/models/user_model.dart';
import 'package:team_scheduler/main.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthRepository {
  Future<UserModel> signUp({required String name, XFile? imageFile}) async {
    try {
      String? photoUrl;

      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.${imageFile.path.split('.').last}';

        if (kIsWeb) {
          final Uint8List fileBytes = await imageFile.readAsBytes();
          await supabase.storage
              .from('profile')
              .uploadBinary(fileName, fileBytes);
        } else {
          final file = File(imageFile.path);
          await supabase.storage.from('profile').upload(fileName, file);
        }

        photoUrl = supabase.storage.from('profile').getPublicUrl(fileName);
      }

      final response = await supabase
          .from('users')
          .insert({'name': name, 'photo_url': photoUrl})
          .select()
          .single();

      print('✅ Supabase response: $response');
      return UserModel.fromMap(response);
    } catch (e) {
      print('❌ Supabase error: $e');
      throw Exception('Failed to sign up: $e');
    }
  }
}
