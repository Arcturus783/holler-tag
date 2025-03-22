import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

/// A class to represent a 3D vertex
class Vertex {
  final double x;
  final double y;
  final double z;

  Vertex(this.x, this.y, this.z);
}

/// A class to represent a triangle face in the mesh
class Face {
  final Vertex v1;
  final Vertex v2;
  final Vertex v3;
  final Vertex normal; // Normal vector for the face

  Face(this.v1, this.v2, this.v3) : normal = calculateNormal(v1, v2, v3);

  // Calculate the normal vector for the face
  static Vertex calculateNormal(Vertex v1, Vertex v2, Vertex v3) {
    final u = Vertex(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z);
    final v = Vertex(v3.x - v1.x, v3.y - v1.y, v3.z - v1.z);

    // Cross product
    final nx = u.y * v.z - u.z * v.y;
    final ny = u.z * v.x - u.x * v.z;
    final nz = u.x * v.y - u.y * v.x;

    // Normalize
    final length = math.sqrt(nx * nx + ny * ny + nz * nz);
    return Vertex(nx / length, ny / length, nz / length);
  }
}

/// Convert a QR code image to a 3D STL file
class QrCodeTo3DConverter {
  /// Convert a QR code image to an STL file
  ///
  /// [imageBytes] - The bytes of the image
  /// [extrusionHeight] - Height of the QR code elements in mm
  /// [baseHeight] - Height of the base in mm
  /// Returns the bytes of the STL file
  static Future<Uint8List> convertQrToStl(
    Uint8List imageBytes, {
    double extrusionHeight = 1.0,
    double baseHeight = 0.5,
  }) async {
    // Decode the image bytes
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Convert to grayscale
    final grayscale = img.grayscale(image);

    // Create binary representation (1 for black, 0 for white)
    final width = grayscale.width;
    final height = grayscale.height;
    final binary = List.generate(
      height,
      (y) => List.generate(width, (x) {
        // Get pixel color (0-255), threshold at 127
        final pixel = grayscale.getPixel(x, y);
        final brightness = img.getLuminance(
          pixel,
        ); // All RGB channels are same in grayscale
        return brightness < 127 ? 1 : 0; // 1 for dark pixels (QR code)
      }),
    );

    // Count black pixels for memory allocation
    /*
    int blackPixels = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (binary[y][x] == 1) {
          blackPixels++;
        }
      }
    }
    */

    // Create faces for the 3D model
    final faces = <Face>[];

    // Add base plate (bottom face - all pixels)
    for (int y = 0; y < height - 1; y++) {
      for (int x = 0; x < width - 1; x++) {
        // Bottom face (2 triangles per pixel)
        faces.add(
          Face(
            Vertex(x.toDouble(), y.toDouble(), 0),
            Vertex(x + 1.0, y.toDouble(), 0),
            Vertex(x.toDouble(), y + 1.0, 0),
          ),
        );

        faces.add(
          Face(
            Vertex(x + 1.0, y.toDouble(), 0),
            Vertex(x + 1.0, y + 1.0, 0),
            Vertex(x.toDouble(), y + 1.0, 0),
          ),
        );

        // Top face of base plate (only for non-QR pixels)
        if (binary[y][x] == 0) {
          faces.add(
            Face(
              Vertex(x.toDouble(), y.toDouble(), baseHeight),
              Vertex(x.toDouble(), y + 1.0, baseHeight),
              Vertex(x + 1.0, y.toDouble(), baseHeight),
            ),
          );

          faces.add(
            Face(
              Vertex(x + 1.0, y.toDouble(), baseHeight),
              Vertex(x.toDouble(), y + 1.0, baseHeight),
              Vertex(x + 1.0, y + 1.0, baseHeight),
            ),
          );
        }
      }
    }

    // Add QR code elements (extruded parts)
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (binary[y][x] == 1) {
          final topHeight = baseHeight + extrusionHeight;

          // Top face (only add if not at the edge)
          if (y < height - 1 && x < width - 1) {
            faces.add(
              Face(
                Vertex(x.toDouble(), y.toDouble(), topHeight),
                Vertex(x.toDouble(), y + 1.0, topHeight),
                Vertex(x + 1.0, y.toDouble(), topHeight),
              ),
            );

            faces.add(
              Face(
                Vertex(x + 1.0, y.toDouble(), topHeight),
                Vertex(x.toDouble(), y + 1.0, topHeight),
                Vertex(x + 1.0, y + 1.0, topHeight),
              ),
            );
          }

          // Front face
          if (y < height - 1) {
            faces.add(
              Face(
                Vertex(x.toDouble(), y.toDouble(), baseHeight),
                Vertex(x + 1.0, y.toDouble(), baseHeight),
                Vertex(x.toDouble(), y.toDouble(), topHeight),
              ),
            );

            faces.add(
              Face(
                Vertex(x + 1.0, y.toDouble(), baseHeight),
                Vertex(x + 1.0, y.toDouble(), topHeight),
                Vertex(x.toDouble(), y.toDouble(), topHeight),
              ),
            );
          }

          // Back face
          if (y < height - 1) {
            faces.add(
              Face(
                Vertex(x.toDouble(), y + 1.0, baseHeight),
                Vertex(x.toDouble(), y + 1.0, topHeight),
                Vertex(x + 1.0, y + 1.0, baseHeight),
              ),
            );

            faces.add(
              Face(
                Vertex(x + 1.0, y + 1.0, baseHeight),
                Vertex(x.toDouble(), y + 1.0, topHeight),
                Vertex(x + 1.0, y + 1.0, topHeight),
              ),
            );
          }

          // Left face
          if (x < width - 1) {
            faces.add(
              Face(
                Vertex(x.toDouble(), y.toDouble(), baseHeight),
                Vertex(x.toDouble(), y.toDouble(), topHeight),
                Vertex(x.toDouble(), y + 1.0, baseHeight),
              ),
            );

            faces.add(
              Face(
                Vertex(x.toDouble(), y.toDouble(), topHeight),
                Vertex(x.toDouble(), y + 1.0, topHeight),
                Vertex(x.toDouble(), y + 1.0, baseHeight),
              ),
            );
          }

          // Right face
          if (x < width - 1) {
            faces.add(
              Face(
                Vertex(x + 1.0, y.toDouble(), baseHeight),
                Vertex(x + 1.0, y + 1.0, baseHeight),
                Vertex(x + 1.0, y.toDouble(), topHeight),
              ),
            );

            faces.add(
              Face(
                Vertex(x + 1.0, y + 1.0, baseHeight),
                Vertex(x + 1.0, y + 1.0, topHeight),
                Vertex(x + 1.0, y.toDouble(), topHeight),
              ),
            );
          }
        }
      }
    }

    print('Created ${faces.length} triangular faces');

    // Generate the STL file (binary format)
    return generateBinaryStl(faces);
  }

  /// Generate a binary STL file from the faces
  static Uint8List generateBinaryStl(List<Face> faces) {
    // Binary STL format:
    // - 80 byte header (unused)
    // - 4 byte unsigned integer (number of triangles)
    // - For each triangle:
    //   - 3 x float32: Normal vector (x, y, z)
    //   - 3 x float32: Vertex 1 (x, y, z)
    //   - 3 x float32: Vertex 2 (x, y, z)
    //   - 3 x float32: Vertex 3 (x, y, z)
    //   - 2 byte attribute (unused)

    // Calculate the size of the STL file
    final headerSize = 80;
    final triangleCountSize = 4;
    final triangleSize =
        50; // 12 floats (3 per vertex + 3 for normal) * 4 bytes + 2 bytes attribute
    final fileSize =
        headerSize + triangleCountSize + triangleSize * faces.length;

    final buffer = ByteData(fileSize);

    // Write header (80 bytes, unused but typically contains info about the generator)
    final headerText = 'Generated by Flutter QR to 3D Converter';
    for (int i = 0; i < headerText.length && i < 80; i++) {
      buffer.setUint8(i, headerText.codeUnitAt(i));
    }

    // Write number of triangles
    buffer.setUint32(80, faces.length, Endian.little);

    // Write all triangles
    int offset = 84; // 80 byte header + 4 byte triangle count
    for (final face in faces) {
      // Write normal
      buffer.setFloat32(offset, face.normal.x, Endian.little);
      buffer.setFloat32(offset + 4, face.normal.y, Endian.little);
      buffer.setFloat32(offset + 8, face.normal.z, Endian.little);

      // Write vertices
      buffer.setFloat32(offset + 12, face.v1.x, Endian.little);
      buffer.setFloat32(offset + 16, face.v1.y, Endian.little);
      buffer.setFloat32(offset + 20, face.v1.z, Endian.little);

      buffer.setFloat32(offset + 24, face.v2.x, Endian.little);
      buffer.setFloat32(offset + 28, face.v2.y, Endian.little);
      buffer.setFloat32(offset + 32, face.v2.z, Endian.little);

      buffer.setFloat32(offset + 36, face.v3.x, Endian.little);
      buffer.setFloat32(offset + 40, face.v3.y, Endian.little);
      buffer.setFloat32(offset + 44, face.v3.z, Endian.little);

      // Attribute byte count (unused, set to zero)
      buffer.setUint16(offset + 48, 0, Endian.little);

      offset += triangleSize;
    }

    return buffer.buffer.asUint8List();
  }
}

/// Example usage in a Flutter app
class QrCodeTo3DExample {
  /// Convert QR code from file and save STL
  static Future<void> convertFromFile(
    String inputPath,
    String outputPath, {
    double extrusionHeight = 1.0,
    double baseHeight = 0.5,
  }) async {
    final file = File(inputPath);
    final bytes = await file.readAsBytes();

    final stlBytes = await QrCodeTo3DConverter.convertQrToStl(
      bytes,
      extrusionHeight: extrusionHeight,
      baseHeight: baseHeight,
    );

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(stlBytes);

    print('Saved 3D model to $outputPath');
  }
}
