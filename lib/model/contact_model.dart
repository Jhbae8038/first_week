import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';

class ContactModel{
  String name;
  String phone;
  String? homeNumber;
  String? email;
  Uint8List? image;
  Duration? timeSinceLastCall;

  ContactModel({required this.name, required this.phone,this.homeNumber ,this.email, this.image, this.timeSinceLastCall});

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