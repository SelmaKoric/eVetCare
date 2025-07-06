class SearchResult<T> {
  int count = 0;
  List<T> result = [];
  int page = 1; 
  int pageSize = 10; 

  SearchResult();

  factory SearchResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return SearchResult<T>()
      ..count = json['count'] ?? 0
      ..page = json['page'] ?? 1 
      ..pageSize = json['pageSize'] ?? 10 
      ..result = (json['result'] as List<dynamic>?) 
              ?.map((item) => fromJsonT(item as Map<String, dynamic>)) 
              .toList() ?? 
          [];
  }
}