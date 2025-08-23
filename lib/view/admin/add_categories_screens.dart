import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../model/category.dart';
import '../../theme/theme.dart';

class AddCategoriesScreens extends StatefulWidget {
  final Category? category;

  const AddCategoriesScreens({super.key, this.category});

  @override
  State<AddCategoriesScreens> createState() => _AddCategoriesScreensState();
}

class _AddCategoriesScreensState extends State<AddCategoriesScreens> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (widget.category != null) {
        // Update existing category
        final updatedCategory = widget.category!.copyWith(
          description: _descriptionController.text.trim(),
          name: _nameController.text.trim(),
        );
        await _firestore
            .collection('categories')
            .doc(widget.category!.id)
            .update(updatedCategory.toMap());

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
      } else {
        // Add new category
        final docRef = _firestore.collection('categories').doc();
        final newCategory = Category(
          id: docRef.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
        );

        await docRef.set(newCategory.toMap());

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print('Error$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_nameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Discard Changes"),
              content: Text("Are you sure you want to discard changes?"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    "Discard",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.category == null ? "Add Category" : "Edit Category",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Category Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Create a new category for organizing your quizzes",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      fillColor: Colors.white,
                      labelText: " Category Name",
                      hintText: "Enter category name ",
                      prefixIcon: Icon(
                        Icons.category_rounded,
                        color: AppTheme.textPrimaryColor,
                      ),
                      alignLabelWithHint: true,
                    ),

                    validator: (value) =>
                        value!.isEmpty ? "Please enter category name" : null,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 24),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      labelText: " Description",
                      hintText: "Enter category description ",
                      prefixIcon: Icon(
                        Icons.description_rounded,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) =>
                        value!.isEmpty ? "Please enter description name" : null,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.category == null
                                  ? "Update Category"
                                  : "Add Category",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
