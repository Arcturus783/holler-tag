import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class ImageCropperPopup extends StatefulWidget {
  final Function(XFile) onImageCropped;
  final XFile? initialImage;

  const ImageCropperPopup({
    Key? key,
    required this.onImageCropped,
    this.initialImage,
  }) : super(key: key);

  @override
  State<ImageCropperPopup> createState() => _ImageCropperPopupState();
}

class _ImageCropperPopupState extends State<ImageCropperPopup> {
  XFile? _selectedImage;
  ui.Image? _decodedImage;
  final GlobalKey _cropAreaKey = GlobalKey();
  Offset _cropCenter = Offset.zero;
  double _cropRadius = 100.0;
  double _imageScale = 1.0;
  Offset _imageOffset = Offset.zero;
  Size _imageSize = Size.zero;
  Size _containerSize = Size.zero;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _selectedImage = widget.initialImage;
      _loadImage();
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isImageLoaded = false;
      });
      await _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (_selectedImage == null) return;

    final bytes = await _selectedImage!.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    
    setState(() {
      _decodedImage = frame.image;
      _imageSize = Size(
        frame.image.width.toDouble(),
        frame.image.height.toDouble(),
      );
      _isImageLoaded = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCropArea();
    });
  }

  void _initializeCropArea() {
    final RenderBox? renderBox = 
        _cropAreaKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox != null) {
      _containerSize = renderBox.size;
      
      // Standardize image size - fit to container while maintaining aspect ratio
      final containerAspectRatio = _containerSize.width / _containerSize.height;
      final imageAspectRatio = _imageSize.width / _imageSize.height;
      
      if (imageAspectRatio > containerAspectRatio) {
        // Image is wider - fit to height
        _imageScale = _containerSize.height / _imageSize.height;
      } else {
        // Image is taller or square - fit to width
        _imageScale = _containerSize.width / _imageSize.width;
      }
      
      // Scale it up a bit so there's room to adjust
      _imageScale *= 1.2;
      
      // Center the image
      final scaledWidth = _imageSize.width * _imageScale;
      final scaledHeight = _imageSize.height * _imageScale;
      
      _imageOffset = Offset(
        (_containerSize.width - scaledWidth) / 2,
        (_containerSize.height - scaledHeight) / 2,
      );
      
      // Center the crop circle
      _cropCenter = Offset(
        _containerSize.width / 2,
        _containerSize.height / 2,
      );
      
      // Set initial crop radius
      final maxRadius = math.min(_containerSize.width, _containerSize.height) * 0.4;
      _cropRadius = maxRadius * 0.6;
      
      setState(() {});
    }
  }

  Future<XFile> _cropImage() async {
    if (_decodedImage == null) throw Exception('No image loaded');

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final cropSize = _cropRadius * 2;
    
    // Calculate the source rectangle from the original image
    final cropLeft = (_cropCenter.dx - _cropRadius - _imageOffset.dx) / _imageScale;
    final cropTop = (_cropCenter.dy - _cropRadius - _imageOffset.dy) / _imageScale;
    final cropRight = (_cropCenter.dx + _cropRadius - _imageOffset.dx) / _imageScale;
    final cropBottom = (_cropCenter.dy + _cropRadius - _imageOffset.dy) / _imageScale;
    
    final sourceRect = Rect.fromLTRB(
      cropLeft.clamp(0.0, _imageSize.width),
      cropTop.clamp(0.0, _imageSize.height),
      cropRight.clamp(0.0, _imageSize.width),
      cropBottom.clamp(0.0, _imageSize.height),
    );
    
    final destRect = Rect.fromLTWH(0, 0, cropSize, cropSize);
    
    // Create circular clipping path
    final path = Path()..addOval(destRect);
    canvas.clipPath(path);
    
    // Draw the cropped image
    canvas.drawImageRect(_decodedImage!, sourceRect, destRect, Paint());
    
    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(cropSize.toInt(), cropSize.toInt());
    
    // Convert to bytes
    final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    // Save to temporary file
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    
    return XFile(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Crop Profile Picture',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Image selection/cropping area
            Expanded(
              child: _selectedImage == null
                  ? _buildImageSelector()
                  : _buildImageCropper(),
            ),
            
            // Controls
            if (_selectedImage != null && _isImageLoaded)
              _buildControls(),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: Text(_selectedImage == null ? 'Select Image' : 'Change Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (_selectedImage != null && _isImageLoaded)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final croppedImage = await _cropImage();
                          widget.onImageCropped(croppedImage);
                          Navigator.of(context).pop();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error cropping image: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.crop),
                      label: const Text('Use Cropped Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Select an image to crop',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).hintColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library),
            label: const Text('Choose from Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCropper() {
    if (!_isImageLoaded || _decodedImage == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      key: _cropAreaKey,
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              // Image
              Positioned(
                left: _imageOffset.dx,
                top: _imageOffset.dy,
                child: Transform.scale(
                  scale: _imageScale,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: _imageSize.width,
                    height: _imageSize.height,
                    child: RawImage(
                      image: _decodedImage,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              
              // Crop overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: CropOverlayPainter(
                    cropCenter: _cropCenter,
                    cropRadius: _cropRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Image position controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => setState(() => _imageOffset += const Offset(-10, 0)),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Move Left',
              ),
              IconButton(
                onPressed: () => setState(() => _imageOffset += const Offset(0, -10)),
                icon: const Icon(Icons.arrow_upward),
                tooltip: 'Move Up',
              ),
              IconButton(
                onPressed: () => setState(() => _imageOffset += const Offset(0, 10)),
                icon: const Icon(Icons.arrow_downward),
                tooltip: 'Move Down',
              ),
              IconButton(
                onPressed: () => setState(() => _imageOffset += const Offset(10, 0)),
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'Move Right',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Scale control
          Row(
            children: [
              const Text('Zoom: '),
              Expanded(
                child: Slider(
                  value: _imageScale,
                  min: 0.1,
                  max: 5.0,
                  divisions: 25,
                  onChanged: (value) => setState(() => _imageScale = value),
                ),
              ),
            ],
          ),
          
          // Crop size control
          Row(
            children: [
              const Text('Crop Size: '),
              Expanded(
                child: Slider(
                  value: _cropRadius,
                  min: 10.0,
                  max: math.max(100.0, math.min(_containerSize.width, _containerSize.height) * 0.45), // Ensure max is always > min
                  divisions: 20,
                  onChanged: (value) => setState(() => _cropRadius = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Offset cropCenter;
  final double cropRadius;

  CropOverlayPainter({
    required this.cropCenter,
    required this.cropRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final cropPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: cropCenter, radius: cropRadius))
      ..fillType = PathFillType.evenOdd;

    // Draw overlay with hole
    canvas.drawPath(path, overlayPaint);
    
    // Draw crop circle border
    canvas.drawCircle(cropCenter, cropRadius, cropPaint);
    
    // Draw center crosshairs
    final crosshairPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1.0;
    
    canvas.drawLine(
      Offset(cropCenter.dx - 10, cropCenter.dy),
      Offset(cropCenter.dx + 10, cropCenter.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(cropCenter.dx, cropCenter.dy - 10),
      Offset(cropCenter.dx, cropCenter.dy + 10),
      crosshairPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}