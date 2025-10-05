import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_scheduler/data/models/user_model.dart';
import 'package:team_scheduler/data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial());

  final ImagePicker _picker = ImagePicker();

  Future<void> signUp({
    required String name,
    XFile? imageFile,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _repository.signUp(name: name, imageFile: imageFile);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);

      emit(AuthSuccess(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<XFile?> pickImage() async {
    try {
        return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    } catch (e) {
        emit(AuthFailure("Failed to pick image: ${e.toString()}"));
        return null;
    }
  }
}