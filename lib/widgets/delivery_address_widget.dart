import 'dart:async';

import 'package:demo_firebase/models/address.dart';
import 'package:demo_firebase/services/share_pref_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../screens/map_screen.dart';
import '../services/map_service.dart';

class DeliveryAddressWidget extends StatefulWidget {
  final Function(double)? onDistanceSelected;
  const DeliveryAddressWidget({super.key, this.onDistanceSelected});

  @override
  State<DeliveryAddressWidget> createState() => _DeliveryAddressWidgetState();
}

class _DeliveryAddressWidgetState extends State<DeliveryAddressWidget> {
  bool isDelivery = true;
  bool isExpanded = false;

  String? selectedAddress;
  LatLng? selectedLocation;
  double selectedDistance = 0;
  bool isLoading = true;

  // Add a StreamSubscription to track and cancel the listener
  StreamSubscription? _prefSubscription;

  List<Address> pickupAddresses = [
    Address(
        addressId: '1',
        addressName: '32 Trường Sơn, Phường 2, Tân Bình, TP Hồ Chí Minh',
        latitude: 10.8136,
        longitude: 106.6636
    ),
  ];

  late Address selectedPickupAddress;

  @override
  void initState() {
    super.initState();

    // Set default pickup address once
    selectedPickupAddress = pickupAddresses.first;

    // Register the stream listener and store the subscription
    _prefSubscription = SharePrefService.preferencesStream.listen((data) {
      if (!mounted) return; // Check if widget is still mounted before using setState

      if (data.containsKey('address')) {
        setState(() {
          selectedAddress = data['address'];
        });
      }

      if (data.containsKey('location')) {
        setState(() {
          selectedLocation = data['location'];
        });
      }

      if (data.containsKey('distance')) {
        setState(() {
          selectedDistance = data['distance'];
        });
      }

      if (data.containsKey('pickup_address')) {
        if (mounted) { // Check if still mounted
          setState(() {
            selectedPickupAddress = data['pickup_address'];
          });
        }
      }
    });

    initial();
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _prefSubscription?.cancel();
    super.dispose();
  }

  Future<void> initial() async {
    if (!mounted) return; // Check if widget is still mounted

    // First, get all address from firebase
    pickupAddresses = await MapService.getAddressesFromFirebase();

    // Second, check has data in shared preferences
    bool hasData = await SharePrefService.hasStoredLocationData();

    // if doesn't have data in share prefs we will get current position
    if (!hasData) {
      // Get current position
      Position? position = await MapService.getCurrentPosition();
      if (position != null && mounted) { // Check if still mounted
        // Convert position to LatLng
        LatLng latLng = MapService.positionToLatLng(position);

        // Get address from coordinates
        String? address = await MapService.getAddressFromLatLng(latLng);
        double? distance = MapService.calculateDistance(LatLng(selectedPickupAddress.latitude, selectedPickupAddress.longitude), latLng);

        if (address != null && mounted) { // Check if still mounted
          _updateDeliveryAddress(address, latLng, distance);
          _updateSelectedPickupAddress(selectedPickupAddress);

          print("Set and saved address: $address");
          print("Set and saved location: Lat ${latLng.latitude}, Lng ${latLng.longitude}");
        }
      }
    }
    // if data is exist we will get data into selected address,
    // selected location and selected pickup address
    else {
      await SharePrefService.printAllSavedData();

      selectedAddress = await SharePrefService.getSelectedAddress();
      selectedLocation = await SharePrefService.getSelectedLocation();
      final savedPickupAddress = await SharePrefService.getSelectedPickupAddress();

      if (selectedLocation != null) {
        final savedDistance = MapService.calculateDistance(
            LatLng(selectedPickupAddress.latitude, selectedPickupAddress.longitude),
            selectedLocation!
        );

        if (savedPickupAddress != null && mounted) { // Check if still mounted
          // Find matching address in the list or add it
          final existingIndex = pickupAddresses.indexWhere(
                  (address) => address.addressId == savedPickupAddress.addressId
          );

          setState(() {
            if (existingIndex >= 0) {
              selectedPickupAddress = pickupAddresses[existingIndex];
              selectedDistance = savedDistance;
            } else {
              // If the saved pickup address isn't in our list, add it
              pickupAddresses.add(savedPickupAddress);
              selectedPickupAddress = savedPickupAddress;
            }
          });
          print("Set pickup address: ${selectedPickupAddress.addressName}");
        }
      }

      print("Loaded address: $selectedAddress");
      print("Loaded location: ${selectedLocation?.latitude}, ${selectedLocation?.longitude}");
      print("Loaded distance: ${MapService.formatDistance(selectedDistance)}");
      print("Loaded pickup address: ${selectedPickupAddress.addressName}");
    }
  }

  void _updateSelectedPickupAddress(Address address) {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      selectedPickupAddress = address;
      isExpanded = false;
    });

    if (widget.onDistanceSelected != null) {
      widget.onDistanceSelected!(selectedDistance);
    }

    if (selectedLocation != null) {
      final newDistance = MapService.calculateDistance(LatLng(address.latitude, address.longitude), selectedLocation!);
      print('new distance: ${MapService.formatDistance(newDistance)}');

      // Save to SharedPreferences
      SharePrefService.saveSelectedPickupAddress(address);
      SharePrefService.saveSelectedDistance(newDistance);
    }
  }

  // Call this when returning from MapScreen
  void _updateDeliveryAddress(String address, LatLng location, double distance) {
    if (!mounted) return; // Check if widget is still mounted

    setState(() {
      selectedAddress = address;
      selectedLocation = location;
      selectedDistance = distance;
    });

    if (widget.onDistanceSelected != null) {
      widget.onDistanceSelected!(selectedDistance);
    }

    // Save to SharedPreferences
    SharePrefService.saveSelectedAddress(address);
    SharePrefService.saveSelectedLocation(location);
    SharePrefService.saveSelectedDistance(distance);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Delivery Type Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Delivery Option
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDelivery = true;
                        isExpanded = false;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.delivery_dining,
                          color: isDelivery ? Colors.red : Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giao tận nơi',
                          style: TextStyle(
                            color: isDelivery ? Colors.red : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Pickup Option
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDelivery = false;
                        isExpanded = false;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.store,
                          color: !isDelivery ? Colors.red : Colors.black,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Đặt đến lấy',
                          style: TextStyle(
                            color: !isDelivery ? Colors.red : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Pickup Address Section with Dropdown

          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.store,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedPickupAddress.addressName,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                children: pickupAddresses
                    .map((address) => InkWell(
                          onTap: () {
                            setState(() {
                              _updateSelectedPickupAddress(address);
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedPickupAddress == address
                                  ? Colors.grey.shade100
                                  : Colors.white,
                            ),
                            child: Text(
                              address.addressName,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          const Divider(height: 1, thickness: 0.5),
          // Delivery Address Section
          if (isDelivery) ...[
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      startPoint: LatLng(selectedPickupAddress.latitude,
                          selectedPickupAddress.longitude),
                      initialLocation: selectedLocation,
                    ),
                  ),
                );

                // Update with the selected location and address
                if (result != null && result is Map<String, dynamic> && mounted) { // Check if still mounted
                  _updateDeliveryAddress(result['address'], result['location'], result['distance']); // Use the new method
                  print('Distance: ${MapService.formatDistance(result['distance'])}');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedAddress ?? "Không tìm thấy vị trí",
                        style: TextStyle(
                            fontSize: 14,
                            color: selectedAddress == null
                                ? Colors.grey
                                : Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.edit_location_alt,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
