import 'package:image_picker/image_picker.dart';
import 'package:team_scheduler/data/models/user_model.dart';
import 'package:team_scheduler/main.dart';

class AuthRepository {
  Future<UserModel> signInOrCreateUser({
    required String name,
    XFile? imageFile,
  }) async {
    try {
      final userEmail = '${name.toLowerCase().replaceAll(' ', '')}@example.com';
      
      final userPassword = 'password-${name.toLowerCase().replaceAll(' ', '')}';

      final existingUserResponse = await supabase
          .from('users')
          .select()
          .eq('name', name)
          .maybeSingle();

      if (existingUserResponse != null) {
        print('👋 User "$name" found. Signing in with password.');
        await supabase.auth.signInWithPassword(
          email: userEmail,
          password: userPassword,
        );
        return UserModel.fromMap(existingUserResponse);
      } else {
        print('✨ User "$name" not found. Creating new user.');
        String? photoUrl;
        if (imageFile != null) {
          //nothing
        }

        final authResponse = await supabase.auth.signUp(
          email: userEmail,
          password: userPassword,
          data: {'name': name, 'photo_url': photoUrl},
        );

        if (authResponse.user == null) throw Exception('Sign up failed.');
        final userMap = await supabase.from('users').select().eq('id', authResponse.user!.id).single();
        return UserModel.fromMap(userMap);
      }
    } catch (e) {
      print('❌ AuthRepository error: $e');
      throw Exception('Failed to sign in or create user: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await supabase.from('users').select();
      return (response as List).map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }
}
