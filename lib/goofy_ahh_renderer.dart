/*
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as math;
import 'dart:io' as io;

void main() {
  runApp(const MyAppQ());
}

class MyAppQ extends StatelessWidget {
  const MyAppQ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'STL Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const STLViewer(),
    );
  }
}

class STLViewer extends StatefulWidget {
  const STLViewer({Key? key}) : super(key: key);

  @override
  _STLViewerState createState() => _STLViewerState();
}

class _STLViewerState extends State<STLViewer> {
  Uint8List? _stlFileBytes;
  bool _isLoading = false;
  String _message = 'Upload an STL file to view';

  Future<void> _pickSTLFile() async {
    setState(() {
      _isLoading = true;
      _message = 'Loading...';
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['stl'],
      );

      if (result != null) {
        if (result.files.single.bytes != null) {
          setState(() {
            _stlFileBytes = result.files.single.bytes!;
          });
        } else if (result.files.single.path != null) {
          final bytes = await _readFileBytesFromPath(result.files.single.path!);
          setState(() {
            _stlFileBytes = bytes;
          });
        }
        setState(() {
          _message = 'STL file loaded successfully';
        });
      } else {
        setState(() {
          _message = 'No file selected';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error loading STL file: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading STL file: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Uint8List> _readFileBytesFromPath(String path) async {
    if (kIsWeb) return Uint8List(0);
    final file = io.File(path);
    return await file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STL Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _pickSTLFile,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Upload STL File'),
                  onPressed: _isLoading ? null : _pickSTLFile,
                ),
                const SizedBox(height: 8),
                _isLoading ? const CircularProgressIndicator() : Text(_message),
              ],
            ),
          ),
          Expanded(
            child: _stlFileBytes == null
                ? const Center(child: Text('No STL file uploaded'))
                : SimpleSTLViewer(fileBytes: _stlFileBytes!),
          ),
        ],
      ),
    );
  }
}

class SimpleSTLViewer extends StatefulWidget {
  final Uint8List fileBytes;

  const SimpleSTLViewer({Key? key, required this.fileBytes}) : super(key: key);

  @override
  _SimpleSTLViewerState createState() => _SimpleSTLViewerState();
}

class _SimpleSTLViewerState extends State<SimpleSTLViewer> {
  bool _objectCreated = false;

  void _createObject(Scene scene) {
    if (_objectCreated) return;

    final importer = STLLoader();
    importer.importFromBytes(widget.fileBytes).then((mesh) {
      if (mesh != null) {
        final object = Object(
          name: 'stl_model',
          mesh: mesh,
        );

        scene.world.add(object);

        object.updateTransform();

        double minX = double.infinity, minY = double.infinity, minZ = double.infinity;
        double maxX = -double.infinity, maxY = -double.infinity, maxZ = -double.infinity;

        for (final v in mesh.vertices) {
          minX = math.min(minX, v.x);
          minY = math.min(minY, v.y);
          minZ = math.min(minZ, v.z);
          maxX = math.max(maxX, v.x);
          maxY = math.max(maxY, v.y);
          maxZ = math.max(maxZ, v.z);
        }

        final center = Vector3(
          (minX + maxX) / 2,
          (minY + maxY) / 2,
          (minZ + maxZ) / 2,
        );

        object.position.setFrom(-center);

        final double maxDimension = math.max(
          math.max(maxX - minX, maxY - minY),
          maxZ - minZ,
        );

        if (maxDimension > 0) {
          final double scale = 5.0 / maxDimension;
          object.scale.setValues(scale, scale, scale);
        }

        object.updateTransform();

        print('STL loaded with ${mesh.vertices.length} vertices and ${mesh.indices.length} faces');

        setState(() {
          _objectCreated = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Cube(
      onSceneCreated: (Scene scene) {
        scene.camera.position.z = 10;
        scene.camera.target.z = 0;
        scene.light.position.setFrom(Vector3(0, 10, 10));

        _createObject(scene);
      },
      interactive: true,
    );
  }
}

class STLLoader {
  Future<Mesh?> importFromBytes(Uint8List bytes) async {
    try {
      if (bytes.length < 84) throw Exception('Invalid STL file');
      return _parseBinarySTL(bytes);
    } catch (e) {
      print('STL import error: $e');
      return null;
    }
  }

  Mesh _parseBinarySTL(Uint8List bytes) {
  int offset = 80;
  int triangleCount = _readUint32(bytes, offset);
  offset += 4;

  if (bytes.length < 84 + triangleCount * 50) {
    throw Exception('Invalid STL file size');
  }

  List<Vector3> vertices = [];
  List<Offset> texcoords = [];
  List<List<int>> indices = []; // ✅ CORRECT TYPE
  List<Vector3> normals = [];

  for (int i = 0; i < triangleCount; i++) {
    double nx = _readFloat(bytes, offset);
    double ny = _readFloat(bytes, offset + 4);
    double nz = _readFloat(bytes, offset + 8);
    Vector3 normal = Vector3(nx, ny, nz);
    offset += 12;

    int baseIndex = vertices.length;

    for (int j = 0; j < 3; j++) {
      double x = _readFloat(bytes, offset);
      double y = _readFloat(bytes, offset + 4);
      double z = _readFloat(bytes, offset + 8);
      offset += 12;

      vertices.add(Vector3(x, y, z));
      texcoords.add(const Offset(0, 0));
      normals.add(normal);
    }
    indices.add([baseIndex, baseIndex + 1, baseIndex + 2]); // ✅ Works!
 // ✅ CORRECT WAY
    offset += 2;
  }

  return Mesh(
    vertices: vertices,
    texcoords: texcoords,
    indices: indices.cast<List<Polygon>>(),,
    colors: [],
    name: 'stl_mesh',
  );
}


  double _readFloat(Uint8List bytes, int offset) {
    ByteData view = ByteData.view(bytes.buffer);
    return view.getFloat32(offset, Endian.little);
  }

  int _readUint32(Uint8List bytes, int offset) {
    ByteData view = ByteData.view(bytes.buffer);
    return view.getUint32(offset, Endian.little);
  }
}
*/
