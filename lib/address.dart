class Address {
  String? code;
  List<Result>? result;

  Address({this.code, this.result});

  Address.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? id;
  String? name;
  String? address;
  Location? location;
  List<String>? types;
  List<AddressComponents>? addressComponents;

  Result(
      {this.id,
      this.name,
      this.address,
      this.location,
      this.types,
      this.addressComponents});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    types = json['types'].cast<String>();
    if (json['addressComponents'] != null) {
      addressComponents = <AddressComponents>[];
      json['addressComponents'].forEach((v) {
        addressComponents!.add(AddressComponents.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['address'] = address;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['types'] = types;
    if (addressComponents != null) {
      data['addressComponents'] =
          addressComponents!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Location {
  double? lng;
  double? lat;

  Location({this.lng, this.lat});

  Location.fromJson(Map<String, dynamic> json) {
    lng = json['lng'];
    lat = json['lat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lng'] = lng;
    data['lat'] = lat;
    return data;
  }
}

class AddressComponents {
  List<String>? types;
  String? name;

  AddressComponents({this.types, this.name});

  AddressComponents.fromJson(Map<String, dynamic> json) {
    types = json['types'].cast<String>();
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['types'] = types;
    data['name'] = name;
    return data;
  }
}
