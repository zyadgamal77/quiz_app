import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/theme/theme.dart';

import '../../model/category.dart';
import '../splash_screen/role_selection_screen.dart';
import 'category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  List<String> _categoryFilters = [];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .get();
    setState(() {
      _allCategories = snapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      _categoryFilters =
          ['All'] +
          _allCategories.map((category) => category.name).toSet().toList();
      _filteredCategories = _allCategories;
    });
  }

  void _filterCategories(String query, {String? categoryFilter}) {
    setState(() {
      _filteredCategories = _allCategories.where((category) {
        final searchQuery = query.toLowerCase();
        final matchesSearch = category.name.toLowerCase().contains(searchQuery) ||
            category.description.toLowerCase().contains(searchQuery);

        final matchesCategory = categoryFilter == null ||
            categoryFilter == 'All' ||
            category.name == categoryFilter;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<bool> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return shouldLogout ?? false;
  }

  Future<void> _signOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('yes'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RoleSelectionScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging out. Please try again.')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    return await _showLogoutConfirmation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Smart Quiz'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _signOut,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            // Welcome Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 0),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    String displayName = 'User';
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      displayName = (data['name'] as String?)?.trim().isNotEmpty == true
                          ? data['name']
                          : (data['email'] as String? ?? 'User');
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome $displayName',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Are you ready?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: const Duration(milliseconds: 200)).slideY(begin: 0.2, end: 0);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categoryFilters.length,
                  itemBuilder: (context, index) {
                    final filter = _categoryFilters[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          filter,
                          style: TextStyle(
                            color: _selectedFilter == filter
                                ? Colors.white
                                : AppTheme.primaryColor,
                          ),
                        ),
                        selected: _selectedFilter == filter,
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedFilter = filter;
                            _filterCategories(
                              _searchController.text,
                              categoryFilter: filter,
                            );
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _filteredCategories.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'No categories found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildCategoryCard(_filteredCategories[index], index),
                        childCount: _filteredCategories.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(category: category),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.quiz,
                      color: AppTheme.primaryColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(category.ownerId).get(),
                    builder: (context, userSnap) {
                      if (userSnap.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 10);
                      }
                      String creatorName = 'Unknown';
                      if (userSnap.hasData && userSnap.data!.exists) {
                        final data = userSnap.data!.data() as Map<String, dynamic>;
                        creatorName = (data['name'] as String?)?.trim().isNotEmpty == true
                            ? data['name']
                            : (data['email'] as String? ?? 'Unknown');
                      }
                      return Text(
                        'By: $creatorName',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: Duration(microseconds: 100 * index))
        .slideY(begin: 0.5, end: 0, duration: const Duration(microseconds: 300))
        .fadeIn();
  }
}
