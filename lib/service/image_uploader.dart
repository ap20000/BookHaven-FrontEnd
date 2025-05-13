import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final String uploadUrl =
      'http://your-api.com/api/upload'; // Replace with your backend endpoint

  /// Pick image and upload it to backend
  Future<void> pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) {
        print('No image selected.');
        return;
      }

      final File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    } catch (e) {
      print('❗ Error during image pick: $e');
    }
  }

  /// Private method to upload the image
  Future<void> _uploadImage(File file) async {
    try {
      final uri = Uri.parse(uploadUrl);
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // this must match your .NET parameter
          file.path,
        ),
      );

      // Optional: Add headers (e.g., authorization)
      request.headers.addAll({
        'Accept': 'application/json',
        // 'Authorization': 'Bearer YOUR_TOKEN',
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        print('✅ Upload successful: $respStr');
      } else {
        print('❌ Upload failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❗ Error during upload: $e');
    }
  }
}
