import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter CRUD Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String apiUrl = "/https://t2210m-flutter.onrender.com/products";
  List products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );
      if (response.statusCode == 201) {
        fetchProducts();
      } else {
        print('Failed to add product: ${response.body}');
        throw Exception('Failed to add product');
      }
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );
      if (response.statusCode == 200) {
        fetchProducts();
      } else {
        print('Failed to update product: ${response.body}');
        throw Exception('Failed to update product');
      }
    } catch (e) {
      print('Error updating product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchProducts();
      } else {
        print('Failed to delete product: ${response.body}');
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void showProductDialog({Map<String, dynamic>? product}) {
    final TextEditingController nameController = TextEditingController(text: product?['name'] ?? '');
    final TextEditingController descriptionController = TextEditingController(text: product?['description'] ?? '');
    final TextEditingController priceController = TextEditingController(text: product?['price']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Update Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final Map<String, dynamic> newProduct = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'price': int.parse(priceController.text),
                };
                if (product == null) {
                  addProduct(newProduct);
                } else {
                  updateProduct(product['id'], newProduct);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: products.isEmpty
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(products[index]['name']),
                    subtitle: Text(products[index]['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => showProductDialog(product: products[index]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteProduct(products[index]['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showProductDialog(),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
