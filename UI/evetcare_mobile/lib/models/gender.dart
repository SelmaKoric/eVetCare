class Gender {
  final int genderId;
  final String name;

  Gender({required this.genderId, required this.name});

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(genderId: json['genderId'], name: json['name']);
  }
}

class GenderResponse {
  final int count;
  final List<Gender> result;
  final int page;
  final int pageSize;

  GenderResponse({
    required this.count,
    required this.result,
    required this.page,
    required this.pageSize,
  });

  factory GenderResponse.fromJson(Map<String, dynamic> json) {
    return GenderResponse(
      count: json['count'],
      result: (json['result'] as List)
          .map((item) => Gender.fromJson(item))
          .toList(),
      page: json['page'],
      pageSize: json['pageSize'],
    );
  }
}
