import 'package:latlong2/latlong.dart';

class Address {
  String addressId;
  String addressName;
  LatLng addressLocation;

  Address(this.addressId, this.addressName, this.addressLocation);
}