class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String phoneNumber;
  final bool isActive;
  final bool isAppUser;
  final List<dynamic> pets;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.phoneNumber,
    required this.isActive,
    required this.isAppUser,
    required this.pets,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      username: json['username'],
      phoneNumber: json['phoneNumber'],
      isActive: json['isActive'],
      isAppUser: json['isAppUser'],
      pets: json['pets'] ?? [],
    );
  }

  String get fullName => '$firstName $lastName';
}
