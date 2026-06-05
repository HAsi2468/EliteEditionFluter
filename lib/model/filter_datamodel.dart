class FilterDataModel {
  final List<Filter> filter;

  FilterDataModel({
    required this.filter,
  });

  factory FilterDataModel.fromJson(Map<String, dynamic> json) =>
      FilterDataModel(
        filter:
            List<Filter>.from(json["filter"].map((x) => Filter.fromJson(x))),
      );
}

class Filter {
  final String name;
  final List<dynamic> values;

  Filter({
    required this.name,
    required this.values,
  });

  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
        name: json["name"],
        values: List<dynamic>.from(json["values"].map((x) => x)),
      );
}

class ValueClass {
  final String state;
  final List<String> cities;

  ValueClass({
    required this.state,
    required this.cities,
  });

  factory ValueClass.fromJson(Map<String, dynamic> json) => ValueClass(
        state: json["state"],
        cities: List<String>.from(json["cities"].map((x) => x)),
      );
}
