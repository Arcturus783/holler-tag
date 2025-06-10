/*
import 'package:flutter/material.dart';
import 'dart:html' as html; // For file upload/download if targeting Flutter web
import 'package:file_picker/file_picker.dart'; // For picking local files
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:three_dart/extra/obj_loader.dart';

/// A widget class that allows a user to upload an image and apply it as a decal
/// onto a 3D object named `circular_tag.obj`. After applying the decal, it
/// automatically initiates a download of the updated 3D file for the user.
///
/// Note: This code assumes a Flutter Web environment. You will need to:
/// - Add necessary dependencies (e.g., three_dart) to your pubspec.yaml.
/// - Ensure 'circular_tag.obj' is placed in the `lib` folder.
/// - Properly configure web assets access in your Flutter web project.
/// - Test and adjust the final implementation for your specific setup.
class TagUploader extends StatefulWidget {
  const TagUploader({Key? key}) : super(key: key);

  @override
  State<TagUploader> createState() => _TagUploaderState();
}

class _TagUploaderState extends State<TagUploader> {
  late THREE.Scene scene;
  late THREE.PerspectiveCamera camera;
  late THREE.WebGLRenderer renderer;
  THREE.Object3D? object3D;
  THREE.Texture? decalTexture;

  @override
  void initState() {
    super.initState();
    _initScene();
    _loadModel();
  }

  /// Initialize the 3D scene, camera, and renderer.
  void _initScene() {
    scene = THREE.Scene();
    camera = THREE.PerspectiveCamera(60, 1.0, 0.1, 1000)
      ..position.set(0, 0, 5);
    renderer = THREE.WebGLRenderer();
  }

  /// Load the OBJ model (circular_tag.obj) from the lib folder.
  void _loadModel() async {
    final loader = OBJLoader();
    // For Flutter Web, you might need to serve the OBJ file as an asset and load via network.
    // e.g., 'assets/circular_tag.obj' or a NetworkAssetBundle. Adjust accordingly.
    // Example (assuming it's directly accessible under the web assets):
    final loadedObject = await loader.load('circular_tag.obj');
    object3D = loadedObject;
    scene.add(object3D!);

    // Adjust position of your model if needed
    object3D!.position.set(0, 0, 0);

    setState(() {});
  }

  /// Allows user to pick an image, then converts it to a texture and applies as a decal.
  Future<void> _uploadImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;

    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    // Convert image bytes into a texture
    final blob = html.Blob([bytes]);
    final imageUrl = html.Url.createObjectUrl(blob);

    decalTexture = THREE.TextureLoader().load(imageUrl);
    decalTexture!.needsUpdate = true;

    // Apply the decal (simplistic approach: apply as material on top polygons near origin)
    // For complex decal mapping, you'd need to calculate correct UV offset or use a decal helper library.
    if (object3D != null) {
      for (final child in object3D!.children) {
        if (child is THREE.Mesh) {
          final mesh = child;
          final material = (mesh.material is THREE.MeshStandardMaterial)
              ? mesh.material as THREE.MeshStandardMaterial
              : THREE.MeshStandardMaterial();

          material.map = decalTexture;
          mesh.material = material;
        }
      }
    }

    setState(() {});
  }

  /// Initiates a download for the user of the updated OBJ file with the decal applied.
  /// In practice, you might want to use an OBJ exporter or scene exporter from 'three_dart/extra'.
  Future<void> _downloadUpdatedModel() async {
    if (object3D == null) return;

    // Example usage of the OBJExporter (this is a simplistic approach).
    final exporter = THREE.OBJExporter();
    final exportedString = exporter.parse(object3D!);

    // Create a Blob and anchor link for download
    final blob = html.Blob([exportedString]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..download = 'circular_tag_with_decal.obj'
      ..style.display = 'none';
    html.document.body!.append(anchor);
    anchor.click();
    html.document.body!.removeChild(anchor);
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('3D Decal Uploader')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _downloadUpdatedModel,
              child: const Text('Download Model with Decal'),
            ),
            const SizedBox(height: 40),
            Container(
              width: size.width * 0.6,
              height: size.height * 0.5,
              color: Colors.black12,
              alignment: Alignment.center,
              child: const Text(
                '3D Preview (for illustration only)\nIntegrate a WebGL preview here if desired',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */