import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../domain/entities/chat_message.dart';
import '../../../../core/errors/exceptions.dart';

class ModelConfig {
  final String name;
  final int maxTokens;
  final double costPerToken;
  final List<String> capabilities;
  final String description;

  const ModelConfig({
    required this.name,
    required this.maxTokens,
    required this.costPerToken,
    required this.capabilities,
    required this.description,
  });
}

class AIChatService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const Map<String, ModelConfig> models = {
    'gpt-4o': ModelConfig(
      name: 'GPT-4o',
      maxTokens: 4096,
      costPerToken: 0.00003,
      capabilities: ['text', 'reasoning', 'analysis', 'fast'],
      description: 'Most capable GPT-4 model with improved speed and efficiency',
    ),
    'gpt-4-turbo': ModelConfig(
      name: 'GPT-4 Turbo',
      maxTokens: 8192,
      costPerToken: 0.00001,
      capabilities: ['text', 'fast', 'long-context'],
      description: 'Fast and efficient GPT-4 model with extended context',
    ),
    'o1-mini': ModelConfig(
      name: 'O1 Mini',
      maxTokens: 2048,
      costPerToken: 0.00015,
      capabilities: ['reasoning', 'problem-solving', 'advanced'],
      description: 'Advanced reasoning model for complex problem solving',
    ),
    'o1-preview': ModelConfig(
      name: 'O1 Preview',
      maxTokens: 4096,
      costPerToken: 0.0006,
      capabilities: ['advanced-reasoning', 'complex-analysis', 'research'],
      description: 'Most advanced reasoning model for complex analysis',
    ),
  };

  final Connectivity _connectivity;
  String? _apiKey;

  AIChatService(this._connectivity) {
    _loadApiKey();
  }

  void _loadApiKey() {
    try {
      _apiKey = dotenv.env['OPENAI_API_KEY'];
    } catch (e) {
      print('Failed to load OpenAI API key: $e');
    }
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  Future<bool> get isNetworkAvailable async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.any((result) => result != ConnectivityResult.none);
  }

  static List<String> get supportedModels => models.keys.toList();

  static ModelConfig? getModelConfig(String model) => models[model];

  static bool isSupportedModel(String model) => models.containsKey(model);

  Future<String> sendMessage({
    required String message,
    required String model,
    required List<ChatMessage> context,
    String? systemPrompt,
    double temperature = 0.7,
    int? maxTokens,
  }) async {
    if (!isConfigured) {
      throw const AIException('OpenAI API key not configured');
    }

    if (!await isNetworkAvailable) {
      throw const AIException('No internet connection available');
    }

    if (!isSupportedModel(model)) {
      throw AIException('Unsupported model: $model');
    }

    final modelConfig = getModelConfig(model)!;
    final effectiveMaxTokens = maxTokens ?? modelConfig.maxTokens;

    try {
      final messages = <Map<String, String>>[];

      // Add system prompt if provided
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        messages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      }

      // Add context messages (last 10 messages to stay within token limits)
      final recentContext = context.length > 10 
          ? context.sublist(context.length - 10)
          : context;
      
      for (final msg in recentContext) {
        messages.add({
          'role': msg.type == MessageType.user ? 'user' : 'assistant',
          'content': msg.content,
        });
      }

      // Add current message
      messages.add({
        'role': 'user',
        'content': message,
      });

      final requestBody = {
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': effectiveMaxTokens,
      };

      print('Sending chat request to OpenAI: model=$model, messages=${messages.length}');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode(requestBody),
      );

      print('OpenAI chat response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final content = responseData['choices'][0]['message']['content'] as String;
        print('Chat response received successfully');
        return content;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']['message'] ?? 'Unknown error';
        throw AIException('OpenAI API error: $errorMessage');
      }
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException('Failed to send message: $e');
    }
  }

  Future<String> generateSummary({
    required String transcript,
    required String model,
    double temperature = 0.3, // Lower temperature for more consistent summaries
  }) async {
    const systemPrompt = '''
You are an expert at creating structured summaries of educational content, lectures, and discussions.

Create a comprehensive summary in Markdown format with the following structure:
- Clear headings and subheadings using ## and ###
- Bullet points for key information using -
- Bold text for important concepts using **text**
- LaTeX formulas for mathematical expressions using \$formula\$
- Organized sections by topic
- Professional and educational tone

Format example:
## Main Topic
- Key point 1
- Key point 2

### Subsection
**Important concept**: Explanation

**Formula**: \$x^2 + y^2 = z^2\$

Focus on:
1. Main topics and themes
2. Key concepts and definitions
3. Important formulas and calculations
4. Action items or assignments
5. Questions or discussions raised

Make the summary comprehensive but concise, highlighting the most important information for future reference.
''';

    return await sendMessage(
      message: 'Summarize this transcript: $transcript',
      model: model,
      systemPrompt: systemPrompt,
      temperature: temperature,
      context: [], // No context needed for summarization
    );
  }

  Future<String> generateContextualResponse({
    required String message,
    required String model,
    required List<ChatMessage> context,
    required String recordingContext, // The original transcript/summary
    double temperature = 0.7,
  }) async {
    final systemPrompt = '''
You are an AI assistant helping with a specific recording/transcript. 

Recording Context:
$recordingContext

Guidelines:
- Always consider the recording context when responding
- Provide accurate and helpful information
- Use Markdown formatting for better readability
- Include LaTeX formulas when discussing mathematical concepts
- Be concise but comprehensive
- If asked about something not in the recording, clearly state that
''';

    return await sendMessage(
      message: message,
      model: model,
      systemPrompt: systemPrompt,
      temperature: temperature,
      context: context,
    );
  }
}
