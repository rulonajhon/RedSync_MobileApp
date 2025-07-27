import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PreScreeningScreen extends StatefulWidget {
  const PreScreeningScreen({super.key});

  @override
  State<PreScreeningScreen> createState() => _PreScreeningScreenState();
}

class _PreScreeningScreenState extends State<PreScreeningScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _totalScore = 0;
  
  final Map<String, dynamic> _answers = {};
  
  final List<Map<String, dynamic>> _questions = [
    {
      'id': 'bleeding_frequency',
      'title': 'Bleeding Episodes',
      'question': 'How often do you experience unexpected bleeding episodes?',
      'type': 'single_choice',
      'options': [
        {'text': 'Never or very rarely', 'score': 0},
        {'text': 'Occasionally (1-2 times per year)', 'score': 1},
        {'text': 'Frequently (3-6 times per year)', 'score': 2},
        {'text': 'Very frequently (more than 6 times per year)', 'score': 3},
      ],
    },
    {
      'id': 'bruising',
      'title': 'Bruising Patterns',
      'question': 'Do you bruise easily or have large bruises from minor bumps?',
      'type': 'single_choice',
      'options': [
        {'text': 'No, normal bruising', 'score': 0},
        {'text': 'Slightly more than normal', 'score': 1},
        {'text': 'Yes, I bruise easily', 'score': 2},
        {'text': 'Yes, very large bruises from minor contact', 'score': 3},
      ],
    },
    {
      'id': 'joint_bleeding',
      'title': 'Joint Problems',
      'question': 'Have you experienced bleeding into joints (knees, elbows, ankles)?',
      'type': 'single_choice',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Once or twice', 'score': 2},
        {'text': 'Several times', 'score': 3},
        {'text': 'Frequently', 'score': 4},
      ],
    },
    {
      'id': 'surgery_bleeding',
      'title': 'Surgery & Dental Work',
      'question': 'Have you had excessive bleeding during or after surgery, dental work, or tooth extractions?',
      'type': 'single_choice',
      'options': [
        {'text': 'No surgical procedures yet', 'score': 0},
        {'text': 'Normal bleeding', 'score': 0},
        {'text': 'Slightly more bleeding than expected', 'score': 2},
        {'text': 'Excessive bleeding requiring intervention', 'score': 4},
      ],
    },
    {
      'id': 'family_history',
      'title': 'Family History',
      'question': 'Do you have family members with bleeding disorders or hemophilia?',
      'type': 'single_choice',
      'options': [
        {'text': 'No known family history', 'score': 0},
        {'text': 'Distant relatives with bleeding issues', 'score': 1},
        {'text': 'Close relatives with bleeding disorders', 'score': 3},
        {'text': 'Diagnosed hemophilia in family', 'score': 4},
      ],
    },
    {
      'id': 'nosebleeds',
      'title': 'Nosebleeds',
      'question': 'How often do you experience nosebleeds?',
      'type': 'single_choice',
      'options': [
        {'text': 'Rarely or never', 'score': 0},
        {'text': 'Occasionally', 'score': 1},
        {'text': 'Frequently and hard to stop', 'score': 2},
        {'text': 'Very frequent and prolonged', 'score': 3},
      ],
    },
    {
      'id': 'muscle_bleeding',
      'title': 'Muscle Bleeding',
      'question': 'Have you experienced deep muscle bleeding or hematomas?',
      'type': 'single_choice',
      'options': [
        {'text': 'Never', 'score': 0},
        {'text': 'Once or twice', 'score': 2},
        {'text': 'Several times', 'score': 3},
        {'text': 'Frequently', 'score': 4},
      ],
    },
    {
      'id': 'symptoms',
      'title': 'Additional Symptoms',
      'question': 'Which of these symptoms have you experienced?',
      'type': 'multiple_choice',
      'options': [
        {'text': 'Joint pain or stiffness', 'score': 1},
        {'text': 'Swelling in joints', 'score': 1},
        {'text': 'Limited range of motion', 'score': 1},
        {'text': 'Fatigue after bleeding episodes', 'score': 1},
        {'text': 'None of the above', 'score': 0},
      ],
    },
  ];

  void _nextPage() {
    if (_currentPage < _questions.length) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectAnswer(String questionId, dynamic answer, int score) {
    setState(() {
      _answers[questionId] = answer;
      // Recalculate total score
      _calculateScore();
    });
  }

  void _calculateScore() {
    _totalScore = 0;
    for (var question in _questions) {
      final answer = _answers[question['id']];
      if (answer != null) {
        if (question['type'] == 'multiple_choice') {
          for (var selectedOption in answer) {
            _totalScore += selectedOption['score'] as int;
          }
        } else {
          _totalScore += answer['score'] as int;
        }
      }
    }
  }

  void _showResults() {
    String riskLevel;
    String recommendation;
    Color resultColor;

    if (_totalScore <= 3) {
      riskLevel = 'Low Risk';
      recommendation = 'Your responses suggest a low likelihood of hemophilia. However, if you have concerns about bleeding, consult with a healthcare provider.';
      resultColor = Colors.green;
    } else if (_totalScore <= 8) {
      riskLevel = 'Moderate Risk';
      recommendation = 'Your responses suggest some bleeding concerns. We recommend consulting with a healthcare provider for proper evaluation.';
      resultColor = Colors.orange;
    } else {
      riskLevel = 'High Risk';
      recommendation = 'Your responses suggest significant bleeding concerns that warrant immediate medical evaluation. Please consult with a hematologist or healthcare provider as soon as possible.';
      resultColor = Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.assessment, color: resultColor, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pre-screening Results',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: resultColor.withOpacity(0.3)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Risk Level: $riskLevel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: resultColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Score: $_totalScore/24',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: resultColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Recommendation:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  recommendation,
                  style: TextStyle(height: 1.4),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Note: This is a screening tool only and not a diagnostic test. Please consult with a healthcare professional for proper medical evaluation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Finish'),
          ),
          if (_totalScore > 8)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: Text('Create Account'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Hemophilia Pre-screening',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Question ${_currentPage + 1} of ${_questions.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / _questions.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
        
            // Questions
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return _buildQuestionPage(question);
                },
              ),
            ),
        
            // Navigation Buttons
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.grey.shade700,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Previous'),
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _answers.containsKey(_questions[_currentPage]['id'])
                          ? (_currentPage == _questions.length - 1 ? _showResults : _nextPage)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_currentPage == _questions.length - 1 ? 'Show Results' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(Map<String, dynamic> question) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getQuestionIcon(question['id']),
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  question['question'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20),
                _buildAnswerOptions(question),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(Map<String, dynamic> question) {
    if (question['type'] == 'single_choice') {
      return Column(
        children: question['options'].map<Widget>((option) {
          final isSelected = _answers[question['id']] == option;
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _selectAnswer(question['id'], option, option['score']),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.blue.shade700 : Colors.grey.shade500,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option['text'],
                        style: TextStyle(
                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Multiple choice
      final selectedOptions = _answers[question['id']] as List? ?? [];
      return Column(
        children: question['options'].map<Widget>((option) {
          final isSelected = selectedOptions.contains(option);
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                List newSelection = List.from(selectedOptions);
                if (option['text'] == 'None of the above') {
                  newSelection = [option];
                } else {
                  newSelection.removeWhere((item) => item['text'] == 'None of the above');
                  if (isSelected) {
                    newSelection.remove(option);
                  } else {
                    newSelection.add(option);
                  }
                }
                _selectAnswer(question['id'], newSelection, 0);
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isSelected ? Colors.blue.shade700 : Colors.grey.shade500,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option['text'],
                        style: TextStyle(
                          color: isSelected ? Colors.blue.shade700 : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  IconData _getQuestionIcon(String questionId) {
    switch (questionId) {
      case 'bleeding_frequency':
        return FontAwesomeIcons.droplet;
      case 'bruising':
        return Icons.healing;
      case 'joint_bleeding':
        return FontAwesomeIcons.bone;
      case 'surgery_bleeding':
        return FontAwesomeIcons.userDoctor;
      case 'family_history':
        return FontAwesomeIcons.users;
      case 'nosebleeds':
        return Icons.face;
      case 'muscle_bleeding':
        return FontAwesomeIcons.dumbbell;
      case 'symptoms':
        return Icons.medical_services;
      default:
        return Icons.help_outline;
    }
  }
}
