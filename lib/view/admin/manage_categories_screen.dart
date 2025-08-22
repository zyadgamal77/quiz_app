import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/model/category.dart';
import '../../theme/theme.dart';
import 'add_categories_screens.dart';
import 'manage_quizzes_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          "Manage Categories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.push(
                context, MaterialPageRoute(
                builder:(context) => AddCategoriesScreens(),
              ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('categories').orderBy('name').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred'));
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          final categories = snapshot.data!.docs
              .map(
                (doc) => Category.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: AppTheme.secondaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No categories found",
                    style: TextStyle(
                      color: AppTheme.textPrimaryColor,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                        builder:(context) => AddCategoriesScreens(),
                      ),
                      );
                    },
                    child: Text(
                      "Add Category",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final Category category = categories[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                  title: Text(
                    category.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(category.description),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: "edit",
                        child: ListTile(
                          leading: Icon(
                            Icons.edit,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text("Edit"),
                        ),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.redAccent),
                          title: Text("delete"),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      _handleCategoryAction(context, value, category);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageQuizzesScreen(categoryId: category.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleCategoryAction(
    BuildContext context,
    String action,
    Category category,
  ) async {
    if (action == 'edit') {
      Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => AddCategoriesScreens(category: category),
        ),
      );
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete Category"),
          content: Text("Are you sure you want to delete this category?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _firestore.collection('categories').doc(category.id).delete();
      }
    }
  }
}
