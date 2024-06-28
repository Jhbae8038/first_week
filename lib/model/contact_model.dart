import 'dart:typed_data';

class ContactModel{
  String name;
  String phone;
  String? email;
  Uint8List? image;

  ContactModel({required this.name, required this.phone, this.email, this.image});

  factory ContactModel.fromJson(Map<String, dynamic> json){
    return ContactModel(
      name: json['name'],
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? Uint8List(0)
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'image': image
    };
  }


}