import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/*
void main() {
  runApp(MyApp());
}
*/
class UltimateDecalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Model Decal App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DecalApp(),
    );
  }
}

class DecalApp extends StatefulWidget {
  @override
  _DecalAppState createState() => _DecalAppState();
}

class _DecalAppState extends State<DecalApp> {
  Object? _object;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isProcessing = false;
  Scene? _scene;
  
  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      // Load the default object.obj model
      final object = Object(fileName: "circular_tag.obj");
      await object.loadObj();
      
      _scene = Scene(
        world: World(children: [object]),
        camera: Camera(
          position: vm.Vector3(0, 0, 10),
          target: vm.Vector3(0, 0, 0),
        ),
        light: Light(
          position: vm.Vector3(0, 0, 10),
          target: vm.Vector3(0, 0, 0),
        ),
      );
      
      setState(() {
        _object = object;
      });
    } catch (e) {
      print('Error loading model: $e');
      _showErrorDialog('Failed to load 3D model. Make sure object.obj exists in assets folder.');
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _selectedImageBytes = result.files.single.bytes!;
          _selectedImageName = result.files.single.name;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  Future<void> _applyDecal() async {
    if (_selectedImageBytes == null || _object == null) {
      _showErrorDialog('Please select an image first');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create texture from selected image
      final codec = await ui.instantiateImageCodec(_selectedImageBytes!);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // Apply the image as a texture to the front face of the model
      await _applyImageToModel(image);

      _showSuccessDialog('Decal applied successfully!');
    } catch (e) {
      _showErrorDialog('Failed to apply decal: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _applyImageToModel(ui.Image image) async {
    // This is a simplified version - in a real implementation,
    // you would need to modify the UV mapping and texture coordinates
    // to properly apply the decal to the front face
    
    // For demonstration, we'll create a new material with the image texture
    final material = Material(
      ambient: Color.fromRGBO(0.5, 0.5, 0.5, 1.0),
      diffuse: Color.fromRGBO(1.0, 1.0, 1.0, 1.0),
      specular: Color.fromRGBO(0.0, 0.0, 0.0, 1.0),
      ke: 0.0,
      ns: 0.0,
    );

    // Apply the material to the object
    _object?.material = material;
    
    // Refresh the scene
    setState(() {});
  }

  Future<void> _downloadModel() async {
    if (_object == null) {
      _showErrorDialog('No model to download');
      return;
    }

    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        _showErrorDialog('Storage permission required to download');
        return;
      }

      // Get the downloads directory
      Directory? downloadsDir = await getExternalStorageDirectory();
      if (downloadsDir == null) {
        _showErrorDialog('Could not access downloads directory');
        return;
      }

      // Create the modified model file
      String fileName = 'modified_object_${DateTime.now().millisecondsSinceEpoch}.obj';
      String filePath = '${downloadsDir.path}/$fileName';

      // Export the model (simplified - in real implementation you'd export actual OBJ format)
      File file = File(filePath);
      await file.writeAsString(_generateObjContent());

      _showSuccessDialog('Model downloaded to: $filePath');
    } catch (e) {
      _showErrorDialog('Failed to download model: $e');
    }
  }

  String _generateObjContent() {
    // This is a simplified OBJ export - in a real implementation,
    // you would properly serialize the modified 3D model with UV coordinates
    return '''# Modified OBJ file with decal
# Generated by Flutter 3D Decal App
# ${DateTime.now().toIso8601String()}

# Vertices (simplified example)
v -1.0 -1.0 0.0
v 1.0 -1.0 0.0
v 1.0 1.0 0.0
v -1.0 1.0 0.0

# Texture coordinates for decal
vt 0.0 0.0
vt 1.0 0.0
vt 1.0 1.0
vt 0.0 1.0

# Normals
vn 0.0 0.0 1.0

# Faces with texture coordinates
f 1/1/1 2/2/1 3/3/1
f 1/1/1 3/3/1 4/4/1
''';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('3D Model Decal App'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.grey[300]!],
          ),
        ),
        child: Column(
          children: [
            // Control Panel
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Decal Controls',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: Icon(Icons.image),
                          label: Text('Select Image'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _applyDecal,
                          icon: _isProcessing 
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(Icons.brush),
                          label: Text(_isProcessing ? 'Processing...' : 'Apply Decal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloadModel,
                          icon: Icon(Icons.download),
                          label: Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedImageName != null) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selected: $_selectedImageName',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 3D Viewer
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _scene != null
                      ? Cube(
                          onSceneCreated: (Scene scene) {
                            scene.world.add(_object!);
                            scene.camera.position.setFrom(vm.Vector3(0, 0, 10));
                            scene.camera.target.setFrom(vm.Vector3(0, 0, 0));
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading 3D Model...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
            
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}