import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
//import 'package:path_provider/path_provider.dart';
//import 'dart:io';
import 'package:myapp/qr_generation.dart';


void main() {
  runApp(const QrTo3DApp());
}

class QrTo3DApp extends StatelessWidget {
  const QrTo3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HollerTag QR Code',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const QrTo3DScreen(),
    );
  }
}

class QrTo3DScreen extends StatefulWidget {
  const QrTo3DScreen({super.key});

  @override
  State<QrTo3DScreen> createState() => _QrTo3DScreenState();
}

class _QrTo3DScreenState extends State<QrTo3DScreen> {
  Uint8List? _imageBytes;
  bool _isProcessing = false;
  double _extrusionHeight = 1.0;
  double _baseHeight = 0.5;
  String _statusMessage = '';

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _statusMessage = 'QR code image selected';
      });
    }
  }

  Future<void> _convert() async {
    if (_imageBytes == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Converting...';
    });

    try {
      // For web, we need to use a different approach since we can't directly use File
      // We'll adapt your example to work with Uint8List directly

      // Get STL bytes using your converter
      final stlBytes = await QrCodeTo3DConverter.convertQrToStl(
        _imageBytes!,
        extrusionHeight: _extrusionHeight,
        baseHeight: _baseHeight,
      );

      // Download the file using file_saver for web
      await FileSaver.instance.saveFile(
        name: 'qr_3d_model',
        bytes: stlBytes,
        ext: 'stl',
        mimeType: MimeType.other,
      );

      setState(() {
        _statusMessage = 'Conversion complete! STL model downloaded.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR to 3D Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            if (_imageBytes != null)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Image.memory(_imageBytes!),
              ),
            const SizedBox(height: 20),

            // Extrusion Height Control
            Text('Extrusion Height: ${_extrusionHeight.toStringAsFixed(1)} mm'),
            Slider(
              value: _extrusionHeight,
              min: 0.5,
              max: 5.0,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _extrusionHeight = value;
                });
              },
            ),
            
            // Base Height Control
            Text('Base Height: ${_baseHeight.toStringAsFixed(1)} mm'),
            Slider(
              value: _baseHeight,
              min: 0.0,
              max: 2.0,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  _baseHeight = value;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Select QR Code'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _imageBytes != null && !_isProcessing ? _convert : null,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Convert to 3D'),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Status Message
            if (_statusMessage.isNotEmpty)
              Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}