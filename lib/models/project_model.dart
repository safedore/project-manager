class ProjectModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<String> videoUrls;

  ProjectModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.videoUrls,
  });

  factory ProjectModel.fromMap(String id, Map<String, dynamic> data) {
    return ProjectModel(
      id: id,
      name: data['name'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
    );
  }

  final sampleData = [
    {
      'id': 'loc1',
      'name': 'Central City',
      'latitude': 39.9612,
      'longitude': -82.9988,
      'imageUrls': [],
      'videoUrls': []
    },
    {
      'id': 'loc2',
      'name': 'Star City',
      'latitude': 37.7749,
      'longitude': -122.4194,
      'imageUrls': [],
      'videoUrls': []
    },
    {
      'id': 'loc3',
      'name': 'Gotham City',
      'latitude': 40.7128,
      'longitude': -74.0060,
      'imageUrls': [],
      'videoUrls': []
    },
    {
      'id': 'loc4',
      'name': 'Metropolis',
      'latitude': 38.6270,
      'longitude': -90.1994,
      'imageUrls': [],
      'videoUrls': []
    },
    {
      'id': 'loc5',
      'name': 'Coast City',
      'latitude': 34.0522,
      'longitude': -118.2437,
      'imageUrls': [],
      'videoUrls': []
    }
  ];

}
