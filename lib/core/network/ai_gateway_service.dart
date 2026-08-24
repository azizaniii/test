import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service untuk memanggil Cloud Function AI Gateway
class AiGatewayService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Memanggil fungsi askAI dengan fallback Gemini -> Groq
  /// 
  /// [question] pertanyaan dari user
  /// [context] konteks tambahan (opsional)
  /// 
  /// Returns jawaban AI dan provider yang digunakan
  Future<AiResponse> askAI({
    required String question,
    String? context,
  }) async {
    try {
      // Dapatkan ID token user yang login
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User tidak terautentikasi');
      }

      final idToken = await user.getIdToken();

      // Panggil Cloud Function
      final callable = _functions.httpsCallable('askAI');
      final response = await callable.call(<String, dynamic>{
        'question': question,
        if (context != null) 'context': context,
      }, options: HttpsCallableOptions(
        timeout: const Duration(seconds: 30),
        headers: {'Authorization': 'Bearer $idToken'},
      ));

      final data = response.data as Map<String, dynamic>;
      
      return AiResponse(
        answer: data['answer'] as String,
        sourceProvider: data['source_provider'] as String,
      );
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Error calling AI: ${e.message}');
    } catch (e) {
      throw Exception('Gagal mendapatkan jawaban AI: $e');
    }
  }
}

/// Response dari AI Gateway
class AiResponse {
  final String answer;
  final String sourceProvider;

  AiResponse({
    required this.answer,
    required this.sourceProvider,
  });

  @override
  String toString() => 'AiResponse(answer: $answer, provider: $sourceProvider)';
}
