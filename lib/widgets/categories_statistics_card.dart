import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CategoriesStatisticsCard extends StatelessWidget {
  final List<dynamic> categoryData;

   const CategoriesStatisticsCard({
    super.key,
    required this.categoryData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Categories Statistics",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: categoryData.length * 100.0,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryData.length,
                itemBuilder: (context, index) {
                  final category = categoryData[index];
                  final totalQuizzes = categoryData.fold<int>(
                    0,
                    (sum, item) => sum + (item['count'] as int),
                  );
                  final percentage = totalQuizzes > 0
                      ? (category['count'] as int) / totalQuizzes * 100
                      : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category['name'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${category['count']} ${(category['count'] as int == 1 ? 'quiz : ' : 'quizzes : ')}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${percentage.toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
