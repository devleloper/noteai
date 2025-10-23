import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';

class TranscriptionService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _transcriptionEndpoint = '/audio/transcriptions';
  
  final http.Client _client;
  final NetworkInfo _networkInfo;
  
  TranscriptionService({
    http.Client? client,
    NetworkInfo? networkInfo,
  }) : _client = client ?? http.Client(),
       _networkInfo = networkInfo ?? NetworkInfoImpl(Connectivity());
  
  /// Transcribes audio file using OpenAI Whisper API
  /// 
  /// [audioFile] - The audio file to transcribe
  /// [language] - Optional language code (e.g., 'en', 'es', 'fr')
  /// [model] - Whisper model to use (default: 'gpt-4o-transcribe')
  /// [responseFormat] - Response format (default: 'text')
  /// [temperature] - Temperature for transcription (0.0 to 1.0)
  /// [prompt] - Optional prompt to improve transcription quality
  /// 
  /// Returns the transcribed text
  /// Throws [TranscriptionException] if transcription fails
  Future<String> transcribeAudio({
    required File audioFile,
    String? language,
    String model = 'gpt-4o-transcribe',
    String responseFormat = 'text',
    double temperature = 0.0,
    String? prompt,
  }) async {
    try {
      // Check network connectivity first
      if (!await _networkInfo.isConnected) {
        throw TranscriptionException('No internet connection available');
      }
      
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw TranscriptionException('OpenAI API key not found');
      }
      
      // Validate file exists and is readable
      if (!await audioFile.exists()) {
        throw TranscriptionException('Audio file does not exist: ${audioFile.path}');
      }
      
      // Check file size (OpenAI has a 25MB limit)
      final fileSize = await audioFile.length();
      const maxSize = 25 * 1024 * 1024; // 25MB
      if (fileSize > maxSize) {
        throw TranscriptionException('Audio file too large: $fileSize bytes (max: $maxSize bytes)');
      }
      
      // Validate model
      if (!isSupportedModel(model)) {
        throw TranscriptionException('Unsupported model: $model. Supported models: ${supportedModels.join(', ')}');
      }
      
      // Validate response format
      if (!isSupportedResponseFormat(responseFormat)) {
        throw TranscriptionException('Unsupported response format: $responseFormat. Supported formats: ${supportedResponseFormats.join(', ')}');
      }
      
      // Validate file format
      if (!isSupportedFormat(audioFile.path)) {
        throw TranscriptionException('Unsupported file format. Supported formats: ${supportedFormats.join(', ')}');
      }
      
      // Prepare multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_transcriptionEndpoint'),
      );
      
      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $apiKey',
      });
      
      // Add audio file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
      );
      
      // Add form fields
      request.fields['model'] = model;
      request.fields['response_format'] = responseFormat;
      request.fields['temperature'] = temperature.toString();
      
      if (language != null && language.isNotEmpty) {
        request.fields['language'] = language;
      }
      
      if (prompt != null && prompt.isNotEmpty) {
        request.fields['prompt'] = prompt;
      }
      
      // Send request
      print('Sending transcription request: model=$model, format=$responseFormat, language=$language, prompt=${prompt != null ? 'provided' : 'none'}');
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      print('Transcription response status: ${response.statusCode}');
      
      // Handle response
      if (response.statusCode == 200) {
        if (responseFormat == 'text') {
          // For text format, response body is directly the transcribed text
          return response.body;
        } else {
          // For json format, parse the response
          final responseData = json.decode(response.body);
          return responseData['text'] as String? ?? '';
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        
        // Handle specific error cases
        switch (response.statusCode) {
          case 401:
            throw TranscriptionException('Invalid API key. Please check your OpenAI API key.');
          case 429:
            throw TranscriptionException('Rate limit exceeded. Please try again later.');
          case 413:
            throw TranscriptionException('File too large. Please use a smaller audio file.');
          case 400:
            throw TranscriptionException('Invalid request: $errorMessage');
          case 500:
          case 502:
          case 503:
          case 504:
            throw TranscriptionException('OpenAI service temporarily unavailable. Please try again later.');
          default:
            throw TranscriptionException('Transcription failed: $errorMessage (Status: ${response.statusCode})');
        }
      }
    } on http.ClientException catch (e) {
      throw TranscriptionException('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw TranscriptionException('Invalid response format: ${e.message}');
    } catch (e) {
      if (e is TranscriptionException) {
        rethrow;
      }
      throw TranscriptionException('Unexpected error: ${e.toString()}');
    }
  }
  
  /// Validates if the service is properly configured
  Future<bool> isConfigured() async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      final isConfigured = apiKey != null && apiKey.isNotEmpty;
      print('TranscriptionService configured: $isConfigured');
      if (!isConfigured) {
        print('OpenAI API key not found. Please create .env file with OPENAI_API_KEY=your_key_here');
      }
      return isConfigured;
    } catch (e) {
      print('Error checking TranscriptionService configuration: $e');
      return false;
    }
  }
  
  /// Gets the maximum file size supported by the API
  int get maxFileSize => 25 * 1024 * 1024; // 25MB
  
  /// Gets supported audio formats
  List<String> get supportedFormats => [
    'mp3', 'mp4', 'mpeg', 'mpga', 'm4a', 'wav', 'webm'
  ];
  
  /// Gets supported transcription models
  List<String> get supportedModels => [
    'whisper-1',
    'gpt-4o-transcribe',
    'gpt-4o-mini-transcribe',
  ];
  
  /// Gets supported response formats
  List<String> get supportedResponseFormats => [
    'json',
    'text',
    'srt',
    'verbose_json',
    'vtt',
  ];
  
  /// Validates if the audio file format is supported
  bool isSupportedFormat(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return supportedFormats.contains(extension);
  }
  
  /// Validates if the model is supported
  bool isSupportedModel(String model) {
    return supportedModels.contains(model);
  }
  
  /// Validates if the response format is supported
  bool isSupportedResponseFormat(String format) {
    return supportedResponseFormats.contains(format);
  }
  
  /// Check if network is available
  Future<bool> get isNetworkAvailable async {
    return await _networkInfo.isConnected;
  }
  
  /// Disposes the HTTP client
  void dispose() {
    _client.close();
  }
}
