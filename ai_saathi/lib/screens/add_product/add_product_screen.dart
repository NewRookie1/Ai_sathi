import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/config/theme.dart';
import '../../services/localization_service.dart';
import '../../services/product_service.dart';
import '../../services/vision_service.dart';

class AddProductScreen extends StatefulWidget {
  final dynamic initialData;

  const AddProductScreen({super.key, this.initialData});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _materialController = TextEditingController();
  final _craftTypeController = TextEditingController();
  String? _category;
  List<String> _tags = [];
  final _tagController = TextEditingController();
  bool _isSaving = false;
  XFile? _pickedImage;
  bool _isAnalyzing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _populateFromAnalysis(widget.initialData);
    }
  }

  static const List<String> _knownCategories = [
    'Home Decor',
    'Clothing',
    'Jewelry',
    'Art',
    'Kitchen',
    'Accessories',
    'Furniture',
    'Textiles',
    'Other',
  ];

  /// Matches AI-returned category text to the dropdown list, tolerating
  /// case/plural variants ("textile" -> "Textiles"). Falls back to Other.
  String _normalizeCategory(dynamic raw) {
    if (raw == null) return 'Other';
    final text = raw.toString().trim().toLowerCase();
    for (final cat in _knownCategories) {
      if (cat.toLowerCase() == text) return cat;
    }
    for (final cat in _knownCategories) {
      final lower = cat.toLowerCase();
      if (lower.startsWith(text) || text.startsWith(lower)) return cat;
    }
    return 'Other';
  }

  void _populateFromAnalysis(Map<String, dynamic> analysis) {
    if (analysis['product_name'] != null &&
        analysis['product_name'].toString() != 'Unknown Product') {
      _nameController.text = analysis['product_name'].toString();
    }
    if (analysis['description'] != null &&
        !analysis['description']
            .toString()
            .startsWith('Analysis error')) {
      _descriptionController.text = analysis['description'].toString();
    }
    if (analysis['category'] != null) {
      _category = _normalizeCategory(analysis['category']);
    }
    if (analysis['material'] != null) {
      _materialController.text = analysis['material'].toString();
    }
    if (analysis['craft_type'] != null) {
      _craftTypeController.text = analysis['craft_type'].toString();
    }
    if (analysis['tags'] is List) {
      _tags = List<String>.from(
        (analysis['tags'] as List).map((t) => t.toString()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _materialController.dispose();
    _craftTypeController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('add_product')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              _buildMaterialField(),
              const SizedBox(height: 16),
              _buildCraftTypeField(),
              const SizedBox(height: 16),
              _buildPriceField(),
              const SizedBox(height: 16),
              _buildQuantityField(),
              const SizedBox(height: 16),
              _buildTagsSection(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: _pickedImage != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_pickedImage!.path),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                ),
                if (_isAnalyzing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            context.t('analyzing'),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: _isAnalyzing ? null : _showImageSourceSheet,
                    ),
                  ),
                ),
              ],
            )
          : widget.initialData != null &&
                  widget.initialData['image_url'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.initialData['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                )
              : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 48,
          color: AppTheme.primaryColor.withOpacity(0.5),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => context.push('/scanner'),
              icon: const Icon(Icons.camera_alt, size: 18),
              label: Text(context.t('take_photo')),
            ),
            TextButton.icon(
              onPressed: _isAnalyzing ? null : _showImageSourceSheet,
              icon: const Icon(Icons.photo_library, size: 18),
              label: Text(context.t('choose_gallery')),
            ),
          ],
        ),
      ],
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.t('take_photo')),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/scanner');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.t('choose_gallery')),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;
      setState(() {
        _pickedImage = image;
        _isAnalyzing = true;
      });
      // AI auto-fill: same analysis the scanner uses.
      try {
        final visionService = context.read<VisionService>();
        final result = await visionService.analyzeImageForProduct(image.path);
        if (mounted && result.success && result.data != null) {
          _populateFromAnalysis(result.data!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.t('product_analysis'))),
          );
        }
      } catch (_) {
        // Keep the photo even if AI analysis is unavailable.
      }
      if (mounted) setState(() => _isAnalyzing = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('capture_failed'))),
        );
      }
    }
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: context.t('product_name'),
        hintText: context.t('product_name_hint'),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.t('enter_product_name');
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: context.t('description'),
        hintText: context.t('describe_product'),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.t('enter_description');
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: InputDecoration(
        labelText: context.t('category'),
      ),
      items: _knownCategories.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(cat),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _category = value);
      },
    );
  }

  Widget _buildMaterialField() {
    return TextFormField(
      controller: _materialController,
      decoration: InputDecoration(
        labelText: context.t('material'),
        hintText: context.t('material_hint'),
      ),
    );
  }

  Widget _buildCraftTypeField() {
    return TextFormField(
      controller: _craftTypeController,
      decoration: InputDecoration(
        labelText: context.t('craft_type'),
        hintText: context.t('craft_hint'),
      ),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: context.t('price_rs'),
        hintText: '0',
        prefixText: '₹ ',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return context.t('enter_price');
        }
        if (double.tryParse(value) == null) {
          return context.t('valid_price');
        }
        return null;
      },
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: context.t('quantity'),
        hintText: '0',
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('tags'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() => _tags.remove(tag));
                },
              );
            }),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  hintText: context.t('add_tag'),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_tags.contains(value)) {
                    setState(() => _tags.add(value));
                    _tagController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isSaving ? null : _saveProduct,
      child: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(context.t('save_product')),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final productService = context.read<ProductService>();
      final product = await productService.createProduct({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _category,
        'material': _materialController.text.trim(),
        'craft_type': _craftTypeController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'tags': _tags,
      });

      if (product != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('product_created'))),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('product_create_failed'))),
        );
      }
    }

    setState(() => _isSaving = false);
  }
}