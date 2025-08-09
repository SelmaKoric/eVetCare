class Pet {
  final int ownerId;
  final String ownerFirstName;
  final String ownerLastName;
  final String ownerEmail;
  final String ownerPhoneNumber;
  final String name;
  final int speciesId;
  final String breed;
  final int genderId;
  final int age;
  final double weight;
  final String? photo;

  Pet({
    required this.ownerId,
    required this.ownerFirstName,
    required this.ownerLastName,
    required this.ownerEmail,
    required this.ownerPhoneNumber,
    required this.name,
    required this.speciesId,
    required this.breed,
    required this.genderId,
    required this.age,
    required this.weight,
    this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'ownerFirstName': ownerFirstName,
      'ownerLastName': ownerLastName,
      'ownerEmail': ownerEmail,
      'ownerPhoneNumber': ownerPhoneNumber,
      'name': name,
      'speciesId': speciesId,
      'breed': breed,
      'genderId': genderId,
      'age': age,
      'weight': weight,
      if (photo != null) 'photo': photo,
    };
  }
}
