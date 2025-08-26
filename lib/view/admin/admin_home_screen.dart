import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_service.dart';
import '../../theme/theme.dart';
import '../../widgets/categories_statistics_card.dart';
import '../../widgets/quiz_action_card.dart';
import '../../widgets/recent_activity_card.dart';
import '../../widgets/stat_card.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    try {
      // Get categories count
      final categoriesCount = await _firestore
          .collection('categories')
          .count()
          .get()
          .catchError((error) => throw Exception('Failed to load categories count'));

      // Get quizzes count
      final quizzesCount = await _firestore
          .collection('quizzes')
          .count()
          .get()
          .catchError((error) => throw Exception('Failed to load quizzes count'));

      // Get latest quizzes
      final latestQuizzes = await _firestore
          .collection('quizzes')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get()
          .catchError((error) => throw Exception('Failed to load latest quizzes'));

      // Get categories
      final categories = await _firestore
          .collection('categories')
          .get()
          .catchError((error) => throw Exception('Failed to load categories'));

      final categoryData = await Future.wait(
        categories.docs.map((category) async {
          try {
            final quizCount = await _firestore
                .collection('quizzes')
                .where('categoryId', isEqualTo: category.id)
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

  Future<void> _signOut() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      // Navigation is handled by AuthWrapper
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error signing out')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
        elevation: 0,
      ),
      body: _buildBody(),
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
                const QuizActionCard(

                ),
              ],
            ),
          ),
        );
      },
    );
  }
}