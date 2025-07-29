import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ClinicLocatorScreen extends StatefulWidget {
  const ClinicLocatorScreen({super.key});

  @override
  State<ClinicLocatorScreen> createState() => _ClinicLocatorScreenState();
}

class _ClinicLocatorScreenState extends State<ClinicLocatorScreen> {
  GoogleMapController? _mapController;
  String selectedType = "clinic";
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  // Add these new variables for polyline
  Set<Polyline> _polylines = {};
  Map<String, dynamic>? _selectedLocation;
  bool _showPolyline = false; // Add this new variable

  // Enhanced clinics data with distance calculation support
  List<Map<String, dynamic>> clinics = [
    {
      'name': 'Dr. Heide P. Abdurahman (Adult Hematologist)',
      'address':
          'Metro Davao Medical & Research Center, J.P. Laurel Ave, Bajada, Davao City',
      'lat': '7.095116',
      'lng': '125.613161',
      'contact': '09099665139',
      'schedule': 'Wednesday & Friday 1 pm – 6 pm',
      'distance': null,
      'distanceValue': double.infinity, // For sorting
    },
    {
      'name': 'Dr. Lilia Matildo Yu (Pediatric Hematologist)',
      'address':
          'Medical Arts Building, front of San Pedro Hospital, Guerrero St., Davao City',
      'lat': '7.078266',
      'lng': '125.614739',
      'contact': 'Unknown',
      'schedule': 'Unknown',
      'distance': null,
      'distanceValue': double.infinity,
    },
    {
      'name': 'Dr. Jeannie B. Ong (Pediatric Hematologist)',
      'address': 'San Pedro Hospital, Guzman St., Davao City',
      'lat': '7.078959',
      'lng': '125.614977',
      'contact': '09924722148',
      'schedule': 'Mon, Thu & Fri 10 am – 1 pm',
      'distance': null,
      'distanceValue': double.infinity,
    },
  ];

  // Enhanced drug outlets data
  List<Map<String, dynamic>> drugOutlets = [
    {
      'name': 'Globo Asiatico Enterprises, Inc.',
      'address': 'Door #4 Eldec Realty Bldg., Cabaguio Ave, Agdao, Davao City',
      'lat': '7.0894',
      'lng': '125.6232',
      'contact': '+63 82 224 1234',
      'distance': null,
      'distanceValue': double.infinity,
    },
    {
      'name': 'CLE Bio and Medical Supply',
      'address':
          '#003 Chiong Bldg, Flyover, Buhangin (JP Laurel Ave), Davao City',
      'lat': '7.0968',
      'lng': '125.6152',
      'contact': '+63 82 234 5678',
      'distance': null,
      'distanceValue': double.infinity,
    },
  ];

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _updateMarkers();
  }

  Future<void> _initializeLocation() async {
    // Try to get location on app start
    await _getCurrentLocation();
  }

  // 📍 Enhanced Current Location Detection
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // 📏 Calculate distances and update UI
      _calculateAllDistances();
      _updateMarkers();
      _centerMapOnUser();

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Location updated! ${_getCurrentDataList().length} locations sorted by distance.',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 📏 Enhanced Distance Calculation
  void _calculateAllDistances() {
    if (_currentPosition == null) return;

    // Calculate distances for clinics
    for (int i = 0; i < clinics.length; i++) {
      final clinic = clinics[i];
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        double.parse(clinic['lat']),
        double.parse(clinic['lng']),
      );

      final distanceKm = distance / 1000;
      clinics[i]['distance'] = distanceKm.toStringAsFixed(1);
      clinics[i]['distanceValue'] = distanceKm;
    }

    // Calculate distances for drug outlets
    for (int i = 0; i < drugOutlets.length; i++) {
      final outlet = drugOutlets[i];
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        double.parse(outlet['lat']),
        double.parse(outlet['lng']),
      );

      final distanceKm = distance / 1000;
      drugOutlets[i]['distance'] = distanceKm.toStringAsFixed(1);
      drugOutlets[i]['distanceValue'] = distanceKm;
    }

    // 📊 Smart Sorting by distance
    _sortLocationsByDistance();
  }

  // 📊 Smart Sorting Implementation
  void _sortLocationsByDistance() {
    clinics.sort((a, b) => a['distanceValue'].compareTo(b['distanceValue']));
    drugOutlets.sort(
      (a, b) => a['distanceValue'].compareTo(b['distanceValue']),
    );
  }

  // 🎨 Distance Color Coding Implementation
  Color _getDistanceColor(String? distance) {
    if (distance == null) return Colors.grey;

    double dist = double.tryParse(distance) ?? double.infinity;
    if (dist <= 2.0) return Colors.green; // Very close
    if (dist <= 5.0) return Colors.orange; // Moderate distance
    return Colors.red; // Far
  }

  // Get distance status text
  String _getDistanceStatus(String? distance) {
    if (distance == null) return 'Unknown';

    double dist = double.tryParse(distance) ?? double.infinity;
    if (dist <= 2.0) return 'Very Close';
    if (dist <= 5.0) return 'Moderate';
    return 'Far';
  }

  // Get distance icon
  IconData _getDistanceIcon(String? distance) {
    if (distance == null) return Icons.help_outline;

    double dist = double.tryParse(distance) ?? double.infinity;
    if (dist <= 2.0) return Icons.directions_walk;
    if (dist <= 5.0) return Icons.directions_bike;
    return Icons.directions_car;
  }

  // 🗺️ Enhanced Marker Updates with User Location
  void _updateMarkers() {
    Set<Marker> markers = {};

    // Add user location marker (Green marker)
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: '📍 Your Location',
            snippet: 'You are here',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    // Add location markers based on selected type
    final currentData = _getCurrentDataList();
    for (var location in currentData) {
      markers.add(
        Marker(
          markerId: MarkerId(location['name']!),
          position: LatLng(
            double.parse(location['lat']!),
            double.parse(location['lng']!),
          ),
          infoWindow: InfoWindow(
            title: location['name'],
            snippet: location['distance'] != null
                ? '${location['distance']} km • ${_getDistanceStatus(location['distance'])}'
                : 'Distance unknown',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            selectedType == "clinic"
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  // Center map on user location
  void _centerMapOnUser() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  // Get current data list based on selected type
  List<Map<String, dynamic>> _getCurrentDataList() {
    return selectedType == "clinic" ? clinics : drugOutlets;
  }

  // 🗺️ Create Polyline to Selected Location
  void _createPolylineToLocation(Map<String, dynamic> location) {
    if (_currentPosition == null || !_showPolyline) return;

    setState(() {
      _selectedLocation = location;
      _polylines.clear();

      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route_to_location'),
          points: [
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            LatLng(
              double.parse(location['lat']!),
              double.parse(location['lng']!),
            ),
          ],
          color: selectedType == "clinic"
              ? Colors.blue.shade700
              : Colors.red.shade700, // Darker color
          width: 6, // Increased width from 4 to 6
          patterns: [
            PatternItem.dash(25),
            PatternItem.gap(15),
          ], // Longer dashes
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true, // Add this for better accuracy over long distances
        ),
      );
    });

    // Center map to show both points
    _fitMapToShowBothPoints(location);
  }

  // Toggle polyline visibility
  void _zoomToLocation(Map<String, dynamic> location) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            double.parse(location['lat']!),
            double.parse(location['lng']!),
          ),
          16, // Higher zoom level for better detail
        ),
      );
    }
  }

  // Fit map to show both user location and selected location
  void _fitMapToShowBothPoints(Map<String, dynamic> location) {
    if (_mapController == null || _currentPosition == null) return;

    final userLat = _currentPosition!.latitude;
    final userLng = _currentPosition!.longitude;
    final locLat = double.parse(location['lat']!);
    final locLng = double.parse(location['lng']!);

    final bounds = LatLngBounds(
      southwest: LatLng(
        userLat < locLat ? userLat : locLat,
        userLng < locLng ? userLng : locLng,
      ),
      northeast: LatLng(
        userLat > locLat ? userLat : locLat,
        userLng > locLng ? userLng : locLng,
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
  }

  // Clear polyline
  void _clearPolyline() {
    setState(() {
      _polylines.clear();
      _selectedLocation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataList = _getCurrentDataList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header with Location Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clinic Locator',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.redAccent,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _currentPosition != null
                                  ? 'Locations sorted by distance'
                                  : 'Find nearby clinics or drug outlets',
                            ),
                            if (_isLoadingLocation) ...[
                              const SizedBox(width: 8),
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                            // Add polyline status indicator
                            if (_currentPosition != null && _showPolyline) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (selectedType == "clinic"
                                              ? Colors.blue
                                              : Colors.red)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        (selectedType == "clinic"
                                                ? Colors.blue
                                                : Colors.red)
                                            .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timeline,
                                      size: 12,
                                      color: selectedType == "clinic"
                                          ? Colors.blue
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Routes ON',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: selectedType == "clinic"
                                            ? Colors.blue
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showFilterBottomSheet,
                    icon: const Icon(
                      FontAwesomeIcons.filter,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Enhanced Google Map
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition != null
                          ? LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            )
                          : const LatLng(
                              7.0731,
                              125.6128,
                            ), // Default to Davao City
                      zoom: 13,
                    ),
                    markers: _markers,
                    polylines: _polylines, // Add polylines
                    onMapCreated: (controller) {
                      _mapController = controller;
                      if (_currentPosition != null) {
                        _centerMapOnUser();
                      }
                    },
                    myLocationEnabled: _currentPosition != null,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    zoomControlsEnabled: true, // Enable zoom controls
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Enhanced List Header with Statistics
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedType == "clinic" ? "Treatment Centers" : "Drug Outlets"} (${dataList.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      if (_currentPosition != null)
                        Text(
                          'Closest: ${dataList.isNotEmpty && dataList[0]['distance'] != null ? "${dataList[0]['distance']} km" : "Unknown"}',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 13,
                          ),
                        )
                      else
                        const Text(
                          'Enable location for distances',
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Enhanced Location List with Distance Details and Route Buttons
              Expanded(
                child: ListView.separated(
                  itemCount: dataList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = dataList[index];
                    final hasDistance = item['distance'] != null;
                    final canShowRoute =
                        _currentPosition != null && hasDistance;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: hasDistance
                            ? Border.all(
                                color: _getDistanceColor(
                                  item['distance'],
                                ).withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: selectedType == "clinic"
                                ? Colors.blue.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            selectedType == "clinic"
                                ? FontAwesomeIcons.hospitalUser
                                : FontAwesomeIcons.pills,
                            color: selectedType == "clinic"
                                ? Colors.blue.shade600
                                : Colors.red.shade600,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (hasDistance)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDistanceColor(
                                    item['distance'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getDistanceColor(
                                      item['distance'],
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getDistanceIcon(item['distance']),
                                      size: 12,
                                      color: _getDistanceColor(
                                        item['distance'],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item['distance']} km',
                                      style: TextStyle(
                                        color: _getDistanceColor(
                                          item['distance'],
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              item['address']!,
                              style: const TextStyle(fontSize: 13),
                            ),
                            if (item['contact'] != 'Unknown') ...[
                              const SizedBox(height: 2),
                              Text(
                                '📞 ${item['contact']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (hasDistance) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDistanceColor(
                                    item['distance'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getDistanceStatus(item['distance']),
                                  style: TextStyle(
                                    color: _getDistanceColor(item['distance']),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                            // Add Route Button Row
                            if (canShowRoute) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Toggle Route Button
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        // Check if this location already has a route
                                        bool hasActiveRoute =
                                            _selectedLocation == item &&
                                            _polylines.isNotEmpty;

                                        if (hasActiveRoute) {
                                          // Clear the route
                                          _clearPolyline();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Row(
                                                children: [
                                                  Icon(
                                                    Icons.clear,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text('Route cleared'),
                                                ],
                                              ),
                                              backgroundColor: Colors.grey,
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        } else {
                                          // Show the route
                                          _selectedLocation = item;
                                          _showPolylineForLocation(item);
                                          _zoomToLocation(item);

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.route,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Route to ${item['name']} (${item['distance']} km)',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor:
                                                  selectedType == "clinic"
                                                  ? Colors.blue
                                                  : Colors.red,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        _selectedLocation == item &&
                                                _polylines.isNotEmpty
                                            ? Icons.clear
                                            : Icons.directions,
                                        size: 16,
                                      ),
                                      label: Text(
                                        _selectedLocation == item &&
                                                _polylines.isNotEmpty
                                            ? 'Clear Route'
                                            : 'Show Route',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            _selectedLocation == item &&
                                                _polylines.isNotEmpty
                                            ? Colors.grey.shade600
                                            : (selectedType == "clinic"
                                                  ? Colors.blue
                                                  : Colors.red),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          Icons.zoom_in,
                          color: Colors.grey.shade600,
                        ),
                        onTap: () {
                          // Only zoom to the selected location
                          _zoomToLocation(item);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.zoom_in,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Zoomed to ${item['name']}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "clinic_locator_fab", // Unique tag to avoid conflicts
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        label: Text(selectedType == "clinic" ? 'Find Clinics' : 'Find Outlets'),
        backgroundColor: selectedType == "clinic" ? Colors.blue : Colors.red,
        foregroundColor: Colors.white,
        icon: Icon(
          selectedType == "clinic"
              ? FontAwesomeIcons.hospitalUser
              : FontAwesomeIcons.pills,
        ),
        onPressed: _showFilterBottomSheet,
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'What are you looking for?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.hospitalUser,
                    color: Colors.white,
                  ),
                ),
                title: const Text('Treatment Centers'),
                subtitle: Text(
                  'Find ${clinics.length} nearby hemophilia treatment centers',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                trailing: selectedType == "clinic"
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedType = "clinic";
                    _updateMarkers();
                  });
                },
              ),
              const Divider(height: 1, color: Colors.black12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.pills,
                    color: Colors.white,
                  ),
                ),
                title: const Text('Drug Outlets'),
                subtitle: Text(
                  'Find ${drugOutlets.length} nearby pharmacies and drug outlets',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                trailing: selectedType == "drug"
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedType = "drug";
                    _updateMarkers();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fix: Add the missing method
  void _showPolylineForLocation(Map<String, dynamic> location) {
    _showPolyline = true;
    _createPolylineToLocation(location);
  }
}
