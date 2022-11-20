class UserModel {
  String? photoUrl;
  String? name;
  String? id;
  String? email;

  UserModel({this.photoUrl, this.name, this.id, this.email});

  UserModel.fromJson(Map<String, dynamic> json) {
    photoUrl = json['photoUrl'];
    name = json['name'];
    id = json['id'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['photoUrl'] = photoUrl;
    data['name'] = name;
    data['id'] = id;
    data['email'] = email;
    return data;
  }
}
