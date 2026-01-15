import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../config/design_system.dart';

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
    _tabController.addListener(() => setState(() {})); 
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
      backgroundColor: OrderaDesign.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrderaDesign.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Menu Management', style: OrderaDesign.heading2),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: OrderaDesign.primary,
          unselectedLabelColor: OrderaDesign.textSecondary,
          indicatorColor: OrderaDesign.primary,
          indicatorWeight: 3,
          tabs: const [
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
        icon: Icon(_tabController.index == 0 ? Icons.category : Icons.fastfood, color: Colors.white),
        label: Text(_tabController.index == 0 ? 'Add Category' : 'Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: OrderaDesign.primary,
      ),
    );
  }

  Widget _buildCategoriesTab() {
    if (_categories.isEmpty) {
      return Center(
        child: Text('No categories yet. Tap + to add one.', style: OrderaDesign.bodyMedium),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (ctx, i) {
        final category = _categories[i];
        final productCount = _products.where((p) => p.categoryId == category.id).length;
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: OrderaDesign.cardDecoration,
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: OrderaDesign.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.category, color: OrderaDesign.primary),
            ),
            title: Text(category.name, style: OrderaDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text('$productCount products', style: OrderaDesign.bodyMedium),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: OrderaDesign.primary),
                  onPressed: () => _editCategory(category),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: OrderaDesign.danger),
                  onPressed: () => _deleteCategory(category.id),
                ),
              ],
            ),
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
        child: Text('No products yet. Tap + to add one.', style: OrderaDesign.bodyMedium),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        final categoryName = _categories.firstWhere((c) => c.id == entry.key, orElse: () => Category(id: 0, name: 'Unknown', restaurantId: 0)).name;
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: OrderaDesign.cardDecoration,
          child: ExpansionTile(
            title: Text(categoryName, style: OrderaDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            children: entry.value.map((product) {
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          '${_apiService.baseUrl}${product.imageUrl}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Container(color: OrderaDesign.background, child: Icon(Icons.broken_image)),
                        )
                      : Container(color: OrderaDesign.background, child: Icon(Icons.fastfood, color: Colors.grey)),
                ),
                title: Text(product.name, style: OrderaDesign.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('\$${product.price.toStringAsFixed(2)}', style: OrderaDesign.label),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: OrderaDesign.primary, size: 20),
                      onPressed: () => _editProduct(product),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: OrderaDesign.danger, size: 20),
                      onPressed: () => _deleteProduct(product.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final List<Category> categories;
  final String token;
  final Product? product; 

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
        }
      }
    } catch (e) {
      setState(() => _uploading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product', style: OrderaDesign.heading2),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Product Name *'),
            TextField(
              controller: _nameController,
              decoration: OrderaDesign.inputDecoration('Enter product name'),
            ),
            SizedBox(height: 16),
            _buildLabel('Price *'),
            TextField(
              controller: _priceController,
              decoration: OrderaDesign.inputDecoration('0.00').copyWith(prefixText: '\$ '),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            _buildLabel('Category *'),
            DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: OrderaDesign.inputDecoration('Select category'),
              items: widget.categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
            SizedBox(height: 16),
            _buildLabel('Description'),
            TextField(
              controller: _descController,
              decoration: OrderaDesign.inputDecoration('Enter description'),
              maxLines: 2,
            ),
            SizedBox(height: 24),
            Center(
              child: GestureDetector(
                onTap: _uploading ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: OrderaDesign.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OrderaDesign.textSecondary.withOpacity(0.2)),
                  ),
                  child: _uploading 
                      ? Center(child: CircularProgressIndicator())
                      : (_imageUrl != null && _imageUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network('${ApiService().baseUrl}$_imageUrl', fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: OrderaDesign.primary, size: 32),
                                SizedBox(height: 8),
                                Text('Upload Product Image', style: OrderaDesign.label),
                              ],
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: OrderaDesign.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: OrderaDesign.primary),
          onPressed: () {
            if (_nameController.text.trim().isEmpty || _priceController.text.trim().isEmpty || _selectedCategoryId == null) return;
            final price = double.tryParse(_priceController.text);
            if (price == null) return;
            
            Navigator.pop(context, {
              'name': _nameController.text.trim(),
              'price': price,
              'description': _descController.text.trim(),
              'category_id': _selectedCategoryId,
              'image_url': _imageUrl,
            });
          },
          child: Text(widget.product == null ? 'Create' : 'Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(text, style: OrderaDesign.label),
    );
  }
}
