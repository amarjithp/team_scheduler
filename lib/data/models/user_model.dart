import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      photoUrl: map['photo_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, photoUrl];
}