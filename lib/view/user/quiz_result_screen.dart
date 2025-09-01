import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../theme/theme.dart';

class QuizResultScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions; // Added missing field
  final dynamic quiz; // Added missing field
  final Map<int, int> selectedAnswers;

  const QuizResultScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.quiz,
    required this.selectedAnswers,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    ).animate().scale(
      duration: Duration(milliseconds: 400),
      delay: Duration(milliseconds: 300),
    );
  }

  Widget _buildAnswerRow(String answer, Color answerColor, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: answerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            answer,
            style: TextStyle(fontWeight: FontWeight.w500, color: answerColor),
          ),
        ),
      ],
    );
  }

  IconData _getPercentageIcon(double score) {
    if (score >= 0.9) return Icons.emoji_events;
    if (score >= 0.8) return Icons.star;
    if (score >= 0.6) return Icons.thumb_up;
    if (score >= 0.4) return Icons.trending_up;
    return Icons.refresh;
  }

  Color _getPercentageColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.redAccent;
  }

  String _getPercentageLabel(double score) {
    if (score >= 0.9) return 'Outstanding';
    if (score >= 0.8) return 'Great Job';
    if (score >= 0.6) return 'Good Effort!';
    if (score >= 0.4) return 'Keep Practicing!';
    return 'Try Again1';
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.correctAnswers / widget.totalQuestions;
    final scorePercentage = (score * 100).round();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Quiz Result',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          // This also needs to be const
                          shape: BoxShape.circle,
                        ),
                        child: CircularPercentIndicator(
                          radius: 100,
                          lineWidth: 15,
                          animation: true,
                          animationDuration: 1500,
                          percent: score,
                          center: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${scorePercentage}%",
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "${(widget.correctAnswers / widget.totalQuestions*100).toInt()}",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ).animate().scale(
                    delay: Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    margin: EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPercentageIcon(score),
                          size: 28,
                          color: _getPercentageColor(score),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _getPercentageLabel(score),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _getPercentageColor(score),
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(
                    begin: 0.3,
                    duration: Duration(milliseconds: 500),
                    delay: Duration(milliseconds: 500),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Correct",
                      widget.correctAnswers.toString(),
                      Icons.check_circle_outline,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildStatCard(
                      "Incorrect",
                      (widget.totalQuestions - widget.correctAnswers)
                          .toString(),
                      Icons.cancel,
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        size: 24,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Details Analytics",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ...widget.quiz.questions.asMap().entries.map((entry) {
                    final question = entry.value;
                    final index = entry.key;
                    final selectedAnswer = widget.selectedAnswers[index];
                    final isCorrect =
                        selectedAnswer != null &&
                        selectedAnswer == question.correctOptionIndex;
                    final notCorrect = selectedAnswer != isCorrect;


                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white, // Set background color to white
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.redAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCorrect
                                  ? Icons.check_circle_outline
                                  : Icons.close,
                              color: isCorrect
                                  ? Colors.green
                                  : Colors.redAccent,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            "Question ${index + 1}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                          subtitle: Text(
                            question.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                                left: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.text,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 20),
                                  _buildAnswerRow(
                                    selectedAnswer != null
                                        ? question.options[selectedAnswer]
                                        : "Not Answered",
                                    isCorrect ? Colors.green : Colors.redAccent,
                                    "Your Answer:",
                                  ),
                                  if (!isCorrect) ...[
                                    SizedBox(height: 20),
                                    _buildAnswerRow(
                                      question.options[question.correctOptionIndex],
                                      Colors.green,
                                      "Correct Answer:",
                                    ),
                                  ],
                                  SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().scale(
                      begin: Offset(0.3, 0.3),
                      // Use Offset for both x and y scale
                      duration: Duration(milliseconds: 300),
                      delay: Duration(milliseconds: (100 * index).toInt()),
                    );
                  }).toList(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                      ),),

                      icon: Icon(Icons.refresh, size: 26,color: Colors.white,),

                      label: Text(
                        "Try Again",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
