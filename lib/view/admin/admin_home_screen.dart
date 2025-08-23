import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    final categoriesCount = await _firestore
        .collection('categories')
        .count()
        .get();

    final quizzesCount = await _firestore.collection('quizzes').count().get();
    final latestQuizzes = await _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    final categories = await _firestore.collection('categories').get();

    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final quiz = await _firestore
            .collection('quizzes')
            .where('categoryId', isEqualTo: category.id)
            .count()
            .get();

        return {
          'name': category.data()['name'] as String,
          'count': quizzesCount.count,
        };
      }),
    );

    return {
      'totalCategories': categoriesCount.count,
      'totalQuizzes': quizzesCount.count,
      'latestQuizzes': latestQuizzes.docs,
      'categoryData': categoryData,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,),
        ),
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
          return Center(child: Text('An error occurred'));
        }

        final Map<String, dynamic> stats = snapshot.data!;
        final List<dynamic> categoryData = stats['categoryData'];
        final List<QueryDocumentSnapshot> latestQuizzes =
            stats['latestQuizzes'];

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Admin",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Here's your quiz application overview",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: "Total Categories",
                        value: stats['totalCategories'].toString(),
                        icon: Icons.category_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: "Total Quizzes",
                        value: stats['totalQuizzes'].toString(),
                        icon: Icons.quiz_rounded,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                CategoriesStatisticsCard(categoryData: categoryData),
                SizedBox(height: 24),
                RecentActivityCard(
                  latestQuizzes: latestQuizzes,
                  formatDate: _formatDate,
                ),
                SizedBox(height: 24),
                QuizActionCard(),
              ],
            ),
          ),
        );
      },
    );
  }
}
