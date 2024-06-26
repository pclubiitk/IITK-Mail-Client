class Attachment {
  final String fileName;
  final int size; // Size in bytes, adjust data type as necessary
  final String mimeType; // MIME type of the attachment
  final String downloadUrl; // URL or path to download the attachment

  Attachment({
    required this.fileName,
    required this.size,
    required this.mimeType,
    required this.downloadUrl,
  });
}