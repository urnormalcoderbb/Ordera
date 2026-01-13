import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class ManageMenuScreen extends StatefulWidget {
  @override
  _ManageMenuScreenState createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {})); // Update FAB label when tab changes
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    
    if (token != null) {
      try {
        final cats = await _apiService.getCategories(token);
        final prods = await _apiService.getProducts(token);
        setState(() {
          _categories = cats;
          _products = prods;
          _loading = false;
        });
      } catch (e) {
        setState(() => _loading = false);
        print('Error loading data: $e');
      }
    }
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text('Create'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      try {
        await _apiService.createCategory(result, auth.token!);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category created')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _editCategory(Category category) async {
    final controller = TextEditingController(text: category.name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Category'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Category Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text('Update'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != category.name) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      try {
        await _apiService.updateCategory(category.id, result, auth.token!);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _apiService.deleteCategory(categoryId, auth.token!);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category deleted ')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _addProduct() async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create a category first!')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _ProductDialog(categories: _categories, token: auth.token!),
    );

    if (result != null) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      try {
        await _apiService.createProduct(result, auth.token!);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _editProduct(Product product) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _ProductDialog(categories: _categories, token: auth.token!, product: product),
    );

    if (result != null) {
      try {
        await _apiService.updateProduct(product.id, result, auth.token!);
        _loadData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(int productId) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _apiService.deleteProduct(productId, auth.token!);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Categories'),
            Tab(text: 'Products'),
          ],
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriesTab(),
                _buildProductsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tabController.index == 0 ? _addCategory : _addProduct,
        icon: Icon(_tabController.index == 0 ? Icons.category : Icons.fastfood),
        label: Text(_tabController.index == 0 ? 'Add Category' : 'Add Product'),
        backgroundColor: _tabController.index == 0 ? Colors.orange : Colors.green,
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categories.isEmpty) {
      return Center(
        child: Text('No categories yet. Tap + to add one.'),
      );
    }

    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (ctx, i) {
        final category = _categories[i];
        final productCount = _products.where((p) => p.categoryId == category.id).length;
        return ListTile(
          leading: Icon(Icons.category),
          title: Text(category.name),
          subtitle: Text('$productCount products'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editCategory(category),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCategory(category.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsTab() {
    final grouped = <int, List<Product>>{};
    for (var p in _products) {
      grouped.putIfAbsent(p.categoryId, () => []).add(p);
    }

    if (grouped.isEmpty) {
      return Center(
        child: Text('No products yet. Tap + to add one.'),
      );
    }

    return ListView(
      children: grouped.entries.map((entry) {
        final categoryName = _categories.firstWhere((c) => c.id == entry.key, orElse: () => Category(id: 0, name: 'Unknown', restaurantId: 0)).name;
        return ExpansionTile(
          title: Text(categoryName, style: TextStyle(fontWeight: FontWeight.bold)),
          children: entry.value.map((product) {
            return ListTile(
              leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                      '${_apiService.baseUrl}${product.imageUrl}',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Icon(Icons.broken_image),
                    )
                  : Icon(Icons.fastfood),
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editProduct(product),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProduct(product.id),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final List<Category> categories;
  final String token;
  final Product? product; // Add this for editing

  _ProductDialog({required this.categories, required this.token, this.product});

  @override
  __ProductDialogState createState() => __ProductDialogState();
}

class __ProductDialogState extends State<_ProductDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  int? _selectedCategoryId;
  String? _imageUrl;
  List<int>? _imageBytes;
  String? _imageName;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descController.text = widget.product!.description ?? '';
      _selectedCategoryId = widget.product!.categoryId;
      _imageUrl = widget.product!.imageUrl;
      // We don't have bytes for existing image, but that's okay, _imageUrl will show it
    } else if (widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _imageBytes = result.files.single.bytes!;
          _imageName = result.files.single.name;
          _uploading = true;
        });
        
        // Upload the image
        final apiService = ApiService();
        final uploadedUrl = await apiService.uploadImage(
          _imageBytes!,
          _imageName!,
          widget.token,
        );
        
        setState(() {
          _imageUrl = uploadedUrl;
          _uploading = false;
        });
        
        if (uploadedUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image uploaded'), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Product Name *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'Price *',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: widget.categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
            SizedBox(height: 15),
            // Image Picker
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (_imageBytes != null)
                    Column(
                      children: [
                        Image.memory(
                          Uint8List.fromList(_imageBytes!),
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 8),
                        Text(_imageName ?? 'Image selected', style: TextStyle(fontSize: 12)),
                      ],
                    )
                  else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                    Column(
                      children: [
                        Image.network(
                          '${ApiService().baseUrl}$_imageUrl',
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Icon(Icons.broken_image, size: 50),
                        ),
                        SizedBox(height: 8),
                        Text('Current Image', style: TextStyle(fontSize: 12)),
                      ],
                    )
                  else
                    Icon(Icons.image, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _pickImage,
                    icon: Icon(_uploading ? Icons.hourglass_empty : Icons.upload),
                    label: Text(_uploading ? 'Uploading...' : 'Choose Image'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('* Required fields', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter product name')),
              );
              return;
            }
            if (_priceController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter price')),
              );
              return;
            }
            if (_selectedCategoryId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select a category')),
              );
              return;
            }
            
            final price = double.tryParse(_priceController.text);
            if (price == null || price <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter a valid price')),
              );
              return;
            }
            
            Navigator.pop(context, {
              'name': _nameController.text.trim(),
              'price': price,
              'description': _descController.text.trim(),
              'category_id': _selectedCategoryId,
              'image_url': _imageUrl,
            });
          },
          child: Text(widget.product == null ? 'Add Product' : 'Update Product'),
        ),
      ],
    );
  }
}
