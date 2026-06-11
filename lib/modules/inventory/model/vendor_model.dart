class VendorModel {
  final String id;
  final String name;
  final String phone;
  final String address;

  VendorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
        id: json["id"] ?? json["_id"] ?? "",
        name: json["name"] ?? "",
        phone: json["phone"] ?? "",
        address: json["address"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "address": address,
      };
}
