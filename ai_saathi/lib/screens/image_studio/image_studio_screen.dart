import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/vision_service.dart';
import '../../services/localization_service.dart';

class ImageStudioScreen extends StatefulWidget {
  const ImageStudioScreen({super.key});

  @override
  State<ImageStudioScreen> createState() => _ImageStudioScreenState();
}

class _ImageStudioScreenState extends State<ImageStudioScreen> {
  String? _imagePath;
  String? _processedImagePath;
  bool _isProcessing = false;
  String _selectedTool = 'enhance';

  final List<_ImageTool> _tools = [
    _ImageTool(
      id: 'enhance',
      icon: Icons.auto_fix_high,
      label: 'enhance',
      description: 'Improve lighting and quality',
    ),
    _ImageTool(
      id: 'background',
      icon: Icons.layers_clear,
      label: 'remove_bg',
      description: 'Remove background',
    ),
    _ImageTool(
      id: 'crop',
      icon: Icons.crop,
      label: 'crop',
      description: 'Crop to product focus',
    ),
    _ImageTool(
      id: 'ecommerce',
      icon: Icons.shopping_cart,
      label: 'ecommerce',
      description: 'Make it shop-ready',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('image_studio')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_processedImagePath != null)
            TextButton(
              onPressed: _saveImage,
              child: Text(context.t('save')),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildPreviewArea(),
          ),
          _buildToolsPanel(),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      child: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(context.t('processing_image')),
                ],
              ),
            )
          : _processedImagePath != null
              ? Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        _processedImagePath!,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image, size: 80, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: () {
                          setState(() {
                            _processedImagePath = null;
                          });
                        },
                        child: const Icon(Icons.undo),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 64,
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.t('select_image'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/scanner'),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(context.t('take_photo')),
                    ),
                  ],
                ),
    );
  }

  Widget _buildToolsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.t('tools'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                final isSelected = _selectedTool == tool.id;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedTool = tool.id);
                    _processImage();
                  },
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          tool.icon,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.t(tool.label),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processImage() async {
    if (_imagePath == null) return;

    setState(() => _isProcessing = true);

    try {
      final visionService = context.read<VisionService>();
      final result = await visionService.enhanceImage(_imagePath!);

      if (result.success && result.data != null) {
        setState(() {
          _processedImagePath = result.data!['enhanced_image_url'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('process_failed'))),
        );
      }
    }

    setState(() => _isProcessing = false);
  }

  void _saveImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.t('image_saved'))),
    );
    context.pop(_processedImagePath);
  }
}

class _ImageTool {
  final String id;
  final IconData icon;
  final String label;
  final String description;

  _ImageTool({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
  });
}