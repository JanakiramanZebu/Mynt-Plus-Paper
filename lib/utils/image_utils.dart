import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageUtils {
  /// Fixes image orientation based on EXIF data
  /// This is particularly important for iOS photos which often have orientation metadata
  static Future<File> fixImageOrientation(File imageFile) async {
    try {
      // Read the image file
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Decode the image - this automatically handles orientation from EXIF
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        // If we can't decode the image, return the original file
        return imageFile;
      }
      
      // The image package automatically applies EXIF orientation when decoding
      // So we just need to re-encode it as JPEG to strip the EXIF data
      // and ensure the orientation is "baked in" to the image data
      
      // Encode the corrected image as JPEG
      final Uint8List correctedBytes = Uint8List.fromList(img.encodeJpg(image, quality: 85));
      
      // Create a temporary file with the corrected image
      final String tempPath = '${imageFile.path}_corrected.jpg';
      final File correctedFile = File(tempPath);
      await correctedFile.writeAsBytes(correctedBytes);
      
      return correctedFile;
    } catch (e) {
      // If there's an error, return the original file
      return imageFile;
    }
  }
  
  /// Compress and fix orientation of an image
  /// This method both fixes orientation and compresses the image for better upload performance
  static Future<File> processImageForUpload(File imageFile, {int? maxWidth, int? maxHeight, int quality = 85}) async {
    try {
      // Read the image file
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return imageFile;
      }
      
      // The image package automatically applies EXIF orientation when decoding
      // So the image is already correctly oriented at this point
      
      // Resize if dimensions are specified
      if (maxWidth != null || maxHeight != null) {
        int targetWidth = image.width;
        int targetHeight = image.height;
        
        if (maxWidth != null && image.width > maxWidth) {
          targetWidth = maxWidth;
          targetHeight = (image.height * maxWidth / image.width).round();
        }
        
        if (maxHeight != null && targetHeight > maxHeight) {
          targetHeight = maxHeight;
          targetWidth = (image.width * maxHeight / image.height).round();
        }
        
        if (targetWidth != image.width || targetHeight != image.height) {
          image = img.copyResize(image, width: targetWidth, height: targetHeight);
        }
      }
      
      // Encode the processed image as JPEG
      final Uint8List processedBytes = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      
      // Create a temporary file with the processed image
      final String tempPath = '${imageFile.path}_processed.jpg';
      final File processedFile = File(tempPath);
      await processedFile.writeAsBytes(processedBytes);
      
      return processedFile;
    } catch (e) {
      return imageFile;
    }
  }
}
