class Species {
  final int speciesId;
  final String name;

  Species({required this.speciesId, required this.name});

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(speciesId: json['speciesId'], name: json['name']);
  }
}

class SpeciesResponse {
  final int count;
  final List<Species> result;
  final int page;
  final int pageSize;

  SpeciesResponse({
    required this.count,
    required this.result,
    required this.page,
    required this.pageSize,
  });

  factory SpeciesResponse.fromJson(Map<String, dynamic> json) {
    return SpeciesResponse(
      count: json['count'],
      result: (json['result'] as List)
          .map((item) => Species.fromJson(item))
          .toList(),
      page: json['page'],
      pageSize: json['pageSize'],
    );
  }
}
