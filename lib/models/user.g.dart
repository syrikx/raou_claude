// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  profileImageUrl: json['profileImageUrl'] as String?,
  joinedAt:
      json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'profileImageUrl': instance.profileImageUrl,
  'joinedAt': instance.joinedAt?.toIso8601String(),
};
