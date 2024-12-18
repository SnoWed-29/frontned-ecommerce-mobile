class ImageData {
  final int id;
  final String path;

  ImageData({
    required this.id,
    required this.path,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'],
      path: json['path'],
    );
  }
}