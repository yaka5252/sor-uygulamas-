class UserModel {
  final String? name;
  final String mail;
  final String id;

  UserModel({this.name, required this.mail, required this.id});

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(name: json['name'], mail: json['mail'], id: json['id']);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'mail': mail, 'id': id};
  }

  @override
  String toString() {
    return 'UserModel(name: $name, mail: $mail, id: $id)';
  }
}
