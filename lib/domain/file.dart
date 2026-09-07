class FileResponse {
  final String id;
  final String name;
  final String mimeType;
  final int size;
  final String lastVersion;

  FileResponse({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    required this.lastVersion,
  });

  factory FileResponse.fromJson(Map<String, dynamic> json) {
    return FileResponse(
      id: json['id']?.toString() ?? "",
      name: json['name']?.toString() ?? "",
      mimeType: json['mimeType']?.toString() ?? "",
      size: int.tryParse(json['size']?.toString() ?? "0") ?? 0,
      lastVersion: json['lastVersion']?.toString() ?? "",
    );
  }
}
