import 'package:hive/hive.dart';
part 'user_model.g.dart';


abstract class UserModelBase{}
class UserLoading extends UserModelBase{}
class UserError extends UserModelBase{
  final Object error;
  UserError(this.error);
}

@HiveType(typeId: 0)
class UserModel extends UserModelBase{
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int age;
  @HiveField(2)
  final String? imagePath;

  UserModel({
    required this.name,
    required this.age,
    this.imagePath,
  });

  UserModel copyWith({
    String? name,
    int? age,
    String? imagePath,
  }) {
    return UserModel(
      name: name ?? this.name,
      age: age ?? this.age,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'],
      age: json['age'],
      imagePath: json['imagePath'],
    );
  }
}



