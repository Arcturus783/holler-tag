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
  
  // Control modes
  bool _isMovingCropper = false; // true = move cropper, false = move image
  
  // Initial scale values for slider bounds
  double _initialScale = 1.0;
  double _minScale = 0.5;
  double _maxScale = 3.0;

  // Image rotation angle in degrees (0-360)
  double _imageRotation = 0.0;

  // Helper method to get safe crop radius bounds
  double get _minCropRadius => 30.0;
  double get _maxCropRadius {
    if (_containerSize.width == 0 || _containerSize.height == 0) {
      return 150.0; // Default fallback
    }
    return math.max(60.0, math.min(_containerSize.width, _containerSize.height) * 0.45);
  }

  // Helper method to ensure crop radius is within bounds
  void _ensureCropRadiusInBounds() {
    final minRadius = _minCropRadius;
    final maxRadius = _maxCropRadius;
    
    if (_cropRadius < minRadius) {
      _cropRadius = minRadius;
    } else if (_cropRadius > maxRadius) {
      _cropRadius = maxRadius;
    }
  }

  // Helper method to get the bounds of the rotated image
  Rect _getRotatedImageBounds() {
    final scaledWidth = _imageSize.width * _imageScale;
    final scaledHeight = _imageSize.height * _imageScale;
    
    // Calculate the center of the scaled image
    final imageCenterX = _imageOffset.dx + scaledWidth / 2;
    final imageCenterY = _imageOffset.dy + scaledHeight / 2;
    
    if (_imageRotation == 0.0) {
      // No rotation, return simple bounds
      return Rect.fromLTWH(
        _imageOffset.dx,
        _imageOffset.dy,
        scaledWidth,
        scaledHeight,
      );
    }
    
    // Calculate rotated bounds
    final rotationRadians = _imageRotation * math.pi / 180;
    final cosAngle = math.cos(rotationRadians).abs();
    final sinAngle = math.sin(rotationRadians).abs();
    
    // Calculate the bounding box of the rotated image
    final rotatedWidth = scaledWidth * cosAngle + scaledHeight * sinAngle;
    final rotatedHeight = scaledWidth * sinAngle + scaledHeight * cosAngle;
    
    return Rect.fromCenter(
      center: Offset(imageCenterX, imageCenterY),
      width: rotatedWidth,
      height: rotatedHeight,
    );
  }

  // Helper method to check if a proposed offset would keep crop circle within image bounds
  bool _isOffsetValid(Offset proposedOffset) {
    if (!_isImageLoaded || _imageSize.width == 0 || _imageSize.height == 0) {
      return true; // Allow movement if image not loaded yet
    }
    
    // Temporarily calculate what the image bounds would be with the proposed offset
    final originalOffset = _imageOffset;
    _imageOffset = proposedOffset;
    final imageBounds = _getRotatedImageBounds();
    _imageOffset = originalOffset; // Restore original
    
    // Check if crop circle would be fully contained within image bounds
    final cropLeft = _cropCenter.dx - _cropRadius;
    final cropRight = _cropCenter.dx + _cropRadius;
    final cropTop = _cropCenter.dy - _cropRadius;
    final cropBottom = _cropCenter.dy + _cropRadius;
    
    // Return true only if the entire crop circle is within the image bounds
    return cropLeft >= imageBounds.left && 
           cropRight <= imageBounds.right && 
           cropTop >= imageBounds.top && 
           cropBottom <= imageBounds.bottom;
  }

  // Helper method to find a valid offset by constraining to boundaries (for operations like zoom/rotate)
  Offset _findValidOffset(Offset proposedOffset) {
    if (!_isImageLoaded || _imageSize.width == 0 || _imageSize.height == 0) {
      return proposedOffset;
    }
    
    // Binary search approach to find the closest valid position
    Offset testOffset = proposedOffset;
    final originalOffset = _imageOffset;
    
    // Try the proposed offset first
    if (_isOffsetValid(testOffset)) {
      return testOffset;
    }
    
    // If not valid, try to find the closest valid position by moving towards the original position
    final deltaX = proposedOffset.dx - originalOffset.dx;
    final deltaY = proposedOffset.dy - originalOffset.dy;
    
    // Try reducing the movement incrementally
    for (double factor = 0.9; factor >= 0.0; factor -= 0.1) {
      testOffset = Offset(
        originalOffset.dx + deltaX * factor,
        originalOffset.dy + deltaY * factor,
      );
      
      if (_isOffsetValid(testOffset)) {
        return testOffset;
      }
    }
    
    // If nothing works, return the original offset
    return originalOffset;
  }

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
      _calculateInitialScale();
      _adjustImageToFitScreen();
      
      // Center the crop circle
      _cropCenter = Offset(
        _containerSize.width / 2,
        _containerSize.height / 2,
      );
      
      // Set initial crop radius and ensure it's within bounds
      final maxRadius = _maxCropRadius;
      _cropRadius = maxRadius * 0.6; // Start at 60% of max size
      _ensureCropRadiusInBounds(); // Make sure it's valid
      
      setState(() {});
    }
  }

  void _calculateInitialScale() {
    if (_containerSize.width == 0 || _containerSize.height == 0) return;
    
    // Calculate scale to show entire image with some padding
    final padding = 40.0;
    final availableWidth = _containerSize.width - padding;
    final availableHeight = _containerSize.height - padding;
    
    final scaleX = availableWidth / _imageSize.width;
    final scaleY = availableHeight / _imageSize.height;
    
    // Use the smaller scale to ensure entire image fits
    _initialScale = math.min(scaleX, scaleY);
    
    // Ensure initial scale is reasonable
    _initialScale = _initialScale.clamp(0.1, 2.0);
    
    // Set scale bounds relative to the initial fit scale
    _minScale = math.max(0.1, _initialScale * 0.5); // Can make smaller than fit
    _maxScale = _initialScale * 4.0; // Can make much larger
    
    // Start at the initial fit scale
    _imageScale = _initialScale;
  }

  void _adjustImageToFitScreen() {
    if (_containerSize.width == 0 || _containerSize.height == 0) return;
    
    // Use the pre-calculated initial scale
    _imageScale = _initialScale;
    
    // Center the image
    final scaledWidth = _imageSize.width * _imageScale;
    final scaledHeight = _imageSize.height * _imageScale;
    
    _imageOffset = Offset(
      (_containerSize.width - scaledWidth) / 2,
      (_containerSize.height - scaledHeight) / 2,
    );
  }

  Future<XFile> _cropImage() async {
    if (_decodedImage == null) throw Exception('No image loaded');

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final cropSize = _cropRadius * 2;
    
    // Calculate the rotation center point (center of the scaled image)
    final scaledWidth = _imageSize.width * _imageScale;
    final scaledHeight = _imageSize.height * _imageScale;
    final imageCenterX = _imageOffset.dx + scaledWidth / 2;
    final imageCenterY = _imageOffset.dy + scaledHeight / 2;
    
    // Apply rotation to find the actual crop area in the rotated coordinate system
    final rotationRadians = _imageRotation * math.pi / 180;
    
    // Transform crop center relative to image center, then apply inverse rotation
    final relativeCropX = _cropCenter.dx - imageCenterX;
    final relativeCropY = _cropCenter.dy - imageCenterY;
    
    final cosAngle = math.cos(-rotationRadians);
    final sinAngle = math.sin(-rotationRadians);
    
    final rotatedCropX = relativeCropX * cosAngle - relativeCropY * sinAngle;
    final rotatedCropY = relativeCropX * sinAngle + relativeCropY * cosAngle;
    
    // Convert back to image coordinates
    final imageSpaceCropX = (rotatedCropX + scaledWidth / 2) / _imageScale;
    final imageSpaceCropY = (rotatedCropY + scaledHeight / 2) / _imageScale;
    final imageSpaceRadius = _cropRadius / _imageScale;
    
    final sourceRect = Rect.fromLTRB(
      (imageSpaceCropX - imageSpaceRadius).clamp(0.0, _imageSize.width),
      (imageSpaceCropY - imageSpaceRadius).clamp(0.0, _imageSize.height),
      (imageSpaceCropX + imageSpaceRadius).clamp(0.0, _imageSize.width),
      (imageSpaceCropY + imageSpaceRadius).clamp(0.0, _imageSize.height),
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

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      if (_isMovingCropper) {
        // Move the crop circle
        _cropCenter += details.delta;
        
        // Keep crop circle within bounds
        _cropCenter = Offset(
          _cropCenter.dx.clamp(_cropRadius, _containerSize.width - _cropRadius),
          _cropCenter.dy.clamp(_cropRadius, _containerSize.height - _cropRadius),
        );
      } else {
        // Try to move the image - only apply if it's valid
        final proposedOffset = _imageOffset + details.delta;
        if (_isOffsetValid(proposedOffset)) {
          _imageOffset = proposedOffset;
        }
        // If the proposed offset is invalid, simply don't move (physical barrier effect)
      }
    });
  }

  void _onZoomChanged(double value) {
    setState(() {
      final oldScale = _imageScale;
      _imageScale = value;
      
      // Adjust offset to keep the image centered around the crop area
      final scaleChange = _imageScale / oldScale;
      final centerX = _cropCenter.dx;
      final centerY = _cropCenter.dy;
      
      final dx = (centerX - _imageOffset.dx) * (scaleChange - 1);
      final dy = (centerY - _imageOffset.dy) * (scaleChange - 1);
      
      final proposedOffset = Offset(
        _imageOffset.dx - dx,
        _imageOffset.dy - dy,
      );
      
      // Find the closest valid position after scaling
      _imageOffset = _findValidOffset(proposedOffset);
    });
  }

  void _onRotationChanged(double value) {
    setState(() {
      _imageRotation = value;
      // Find a valid position after rotation
      _imageOffset = _findValidOffset(_imageOffset);
    });
  }

  void _onCropSizeChanged(double value) {
    setState(() {
      _cropRadius = value;
      
      // Ensure crop circle stays within bounds after resize
      _cropCenter = Offset(
        _cropCenter.dx.clamp(_cropRadius, _containerSize.width - _cropRadius),
        _cropCenter.dy.clamp(_cropRadius, _containerSize.height - _cropRadius),
      );
      
      // Find a valid position with the new crop size
      _imageOffset = _findValidOffset(_imageOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9 >= 800 ? 800 : MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(10),
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
                    'Fit Picture',
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
              padding: const EdgeInsets.all(10),
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
          child: GestureDetector(
            onPanUpdate: _onPanUpdate,
            child: Stack(
              children: [
                // Image with rotation applied
                Positioned(
                  left: _imageOffset.dx,
                  top: _imageOffset.dy,
                  child: Transform.scale(
                    scale: _imageScale,
                    alignment: Alignment.topLeft,
                    child: Transform.rotate(
                      angle: _imageRotation * math.pi / 180, // Convert degrees to radians
                      alignment: Alignment.center,
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
                ),
                
                // Crop overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: CropOverlayPainter(
                      cropCenter: _cropCenter,
                      cropRadius: _cropRadius,
                      isMovingCropper: _isMovingCropper,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    // Ensure bounds are valid before building sliders
    _ensureCropRadiusInBounds();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Optional mode toggle buttons
          /*
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isMovingCropper = true;
                    if (_isMovingCropper) {
                      _adjustImageToFitScreen(); // Resize image to fit when moving cropper
                    }
                  });
                },
                icon: Icon(_isMovingCropper ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                label: const Text('Move Cropper'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isMovingCropper ? Colors.blue : Colors.grey[300],
                  foregroundColor: _isMovingCropper ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isMovingCropper = false;
                  });
                },
                icon: Icon(!_isMovingCropper ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                label: const Text('Move Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_isMovingCropper ? Colors.blue : Colors.grey[300],
                  foregroundColor: !_isMovingCropper ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          */
          // Instructions
          /*
          Text(
            _isMovingCropper 
              ? 'Drag to move the crop circle • Image auto-resized to fit'
              : 'Drag to move image • Use rotate slider to rotate',
            style: TextStyle(
              color: Theme.of(context).hintColor,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          */
          // Rotate slider (only show when moving image) - replaced zoom slider
          if (!_isMovingCropper) ...[
            Row(
              children: [
                const Icon(Icons.rotate_left, size: 20),
                const SizedBox(width: 8),
                const Text('Rotate: '),
                Expanded(
                  child: Slider(
                    value: _imageRotation, // 0-360 degrees
                    min: 0.0,
                    max: 360.0,
                    divisions: 72, // 5-degree increments
                    label: '${_imageRotation.round()}°', // Show current angle
                    onChanged: _onRotationChanged,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.rotate_right, size: 20),
              ],
            ),
            const SizedBox(height: 8),
          ],
          
          // Crop size control
          Row(
            children: [
              const Icon(Icons.crop_free, size: 20),
              const SizedBox(width: 8),
              const Text('Crop Size: '),
              Expanded(
                child: Slider(
                  value: _cropRadius.clamp(_minCropRadius, _maxCropRadius), // Ensure value is in bounds
                  min: _minCropRadius,
                  max: _maxCropRadius,
                  divisions: 20,
                  onChanged: _onCropSizeChanged,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Reset and fit buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /*
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _adjustImageToFitScreen();
                    _cropCenter = Offset(_containerSize.width / 2, _containerSize.height / 2);
                  });
                },
                icon: const Icon(Icons.fit_screen),
                label: const Text('Fit to Screen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              */
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _initializeCropArea();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
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
  final bool isMovingCropper;

  CropOverlayPainter({
    required this.cropCenter,
    required this.cropRadius,
    required this.isMovingCropper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final cropPaint = Paint()
      ..color = isMovingCropper ? Colors.blue : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = isMovingCropper ? 3.0 : 2.0;

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
      ..color = (isMovingCropper ? Colors.blue : Colors.white).withOpacity(0.7)
      ..strokeWidth = 1.5;
    
    canvas.drawLine(
      Offset(cropCenter.dx - 15, cropCenter.dy),
      Offset(cropCenter.dx + 15, cropCenter.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(cropCenter.dx, cropCenter.dy - 15),
      Offset(cropCenter.dx, cropCenter.dy + 15),
      crosshairPaint,
    );

    // Add mode indicator
    if (isMovingCropper) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'MOVING CROPPER',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}