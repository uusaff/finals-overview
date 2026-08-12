import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  late final GenerativeModel _model;
  
  AiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is missing from .env file.');
    }
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  /// Parses raw syllabus text into a list of topics
  Future<List<String>> generateStudyPlan(String text) async {
    final prompt = '''
You are an expert AI Study Planner. The user will provide raw text from a syllabus or course outline.
Extract the main topics to study and return them as a JSON array of strings. 
Do not include any formatting, markdown, or other text outside of the JSON array.
Only return valid JSON like: ["Topic 1", "Topic 2", "Topic 3"]

Syllabus Text:
$text
''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    final responseText = response.text;
    if (responseText == null || responseText.isEmpty) {
      throw Exception('AI returned an empty response.');
    }

    try {
      // Sometimes the model wraps the response in ```json ```
      String cleanedText = responseText;
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      
      final List<dynamic> decoded = jsonDecode(cleanedText.trim());
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }

  /// Generates personalized progress insights based on completed topics and upcoming exams.
  Future<String> generateInsights({
    required int completedTopics,
    required int totalTopics,
    required List<String> upcomingExams,
  }) async {
    final prompt = '''
You are a motivational and strategic AI Study Coach.
The user has completed $completedTopics out of $totalTopics topics in their current subjects.
Their upcoming exams are: ${upcomingExams.isEmpty ? "None" : upcomingExams.join(', ')}.

Provide a short, punchy (2-3 sentences max) personalized insight and advice to keep them motivated and focused. 
Adopt a direct, slightly energetic tone. Do not use markdown.
''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    return response.text?.trim() ?? "Keep studying, you're doing great!";
  }
}
