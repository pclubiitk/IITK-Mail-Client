import 'dart:typed_data';

class Attachment {
  final String fileName;
  final int size; /// Size in bytes, adjust data type as necessary
  final String mimeType; /// MIME type of the attachment
  final String downloadUrl; /// URL or path to download the attachment

  Attachment({
    required this.fileName,
    required this.size,
    required this.mimeType,
    required this.downloadUrl,
  });
  Future<Uint8List?> download() async {
    /// logic to download attachment content as Uint8List
    /// fetching from a network URL or from local storage
    /// Return null or throw an error if download fails
    return null; // Replace with actual data in bytes
  }
}
