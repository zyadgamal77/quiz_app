import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_service.dart';
import '../../theme/theme.dart';
import '../../widgets/categories_statistics_card.dart';
import '../../widgets/quiz_action_card.dart';
import '../../widgets/recent_activity_card.dart';
import '../../widgets/stat_card.dart';
import '../splash_screen/role_selection_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      // Get categories count
      final categoriesCount = await _firestore
          .collection('categories')
          .where('ownerId', isEqualTo: uid)
          .count()
          .get()
          .catchError(
            (error) => throw Exception('Failed to load categories count'),
          );

      // Get quizzes count
      final quizzesCount = await _firestore
          .collection('quizzes')
          .where('ownerId', isEqualTo: uid)
          .count()
          .get()
          .catchError(
            (error) => throw Exception('Failed to load quizzes count'),
          );

      // Get latest quizzes
      final latestQuizzes = await _firestore
          .collection('quizzes')
          .where('ownerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get()
          .catchError(
            (error) => throw Exception('Failed to load latest quizzes'),
          );

      // Get categories
      final categories = await _firestore
          .collection('categories')
          .where('ownerId', isEqualTo: uid)
          .get()
          .catchError((error) => throw Exception('Failed to load categories'));

      final categoryData = await Future.wait(
        categories.docs.map((category) async {
          try {
            final quizCount = await _firestore
                .collection('quizzes')
                .where('categoryId', isEqualTo: category.id)
                .where('ownerId', isEqualTo: uid)
                .count()
                .get();

            return {
              'name': category.data()['name'] ?? 'Unnamed Category',
              'count': quizCount.count,
            };
          } catch (e) {
            return {
              'name': category.data()['name'] ?? 'Unnamed Category',
              'count': 0,
            };
          }
        }),
      );

      return {
        'totalCategories': categoriesCount.count,
        'totalQuizzes': quizzesCount.count,
        'latestQuizzes': latestQuizzes.docs,
        'categoryData': categoryData,
      };
    } catch (e) {
      debugPrint('Error in _fetchStatistics: $e');
      rethrow; // This will be caught by the FutureBuilder
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
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
    return shouldPop ?? false;
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
        const SnackBar(content: Text('Error logging out. Please try again!.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
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
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: _fetchStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }
        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }

        final Map<String, dynamic> stats = snapshot.data!;
        final List<dynamic> categoryData = stats['categoryData'];
        final List<QueryDocumentSnapshot> latestQuizzes =
            stats['latestQuizzes'];

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Admin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Here's your quiz application overview",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Categories',
                        value: stats['totalCategories'].toString(),
                        icon: Icons.category_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total Quizzes',
                        value: stats['totalQuizzes'].toString(),
                        icon: Icons.quiz_rounded,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CategoriesStatisticsCard(categoryData: categoryData),
                const SizedBox(height: 24),
                RecentActivityCard(
                  latestQuizzes: latestQuizzes,
                  formatDate: _formatDate,
                ),
                const SizedBox(height: 24),
                const QuizActionCard(),
              ],
            ),
          ),
        );
      },
    );
  }
}
