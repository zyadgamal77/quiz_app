import 'package:flutter/material.dart';
import 'package:quiz_app/view/admin/manage_categories_screen.dart';
import 'package:quiz_app/view/admin/manage_quizzes_screen.dart';
import 'package:quiz_app/theme/theme.dart';

import 'dashboard_card.dart';

class QuizActionCard extends StatelessWidget {
  const QuizActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),

                SizedBox(width: 12),
                Text(
                  "Quiz Action",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  DashboardCard(
                    context: context,
                    title: "Create Quiz",
                    icon: Icons.add_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, '/create-quiz');
                    },
                  ),
                  DashboardCard(
                    context: context,
                    title: "Quizzes",
                    icon: Icons.quiz_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageQuizzesScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    context: context,
                    title: "Categories",
                    icon: Icons.category_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageCategoriesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
