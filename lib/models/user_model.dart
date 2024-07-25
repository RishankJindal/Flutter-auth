class User {
  String userName;
  String phoneNumber;
  String password;
  String email;
  String? imageURL;

  User({
    required this.userName,
    required this.phoneNumber,
    required this.password,
    required this.email,
    this.imageURL,
  });
}
