import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  final String _apiKey = "AIzaSyATwMuH8V97bAI9Yqx9nYkgRi_EC_yvJKQ";
  late GenerativeModel _model;

  ChatService() {
    // Chuyển sang model 'gemini-1.5-flash' hoặc 'gemini-pro'
    // Tôi đổi thành 'gemini-1.5-flash' (đảm bảo đúng định dạng)
    // Nếu vẫn lỗi, bạn hãy thử đổi chữ 'gemini-1.5-flash' dưới đây thành 'gemini-pro'
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String> getResponse(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Xin lỗi, tôi không thể trả lời lúc này.";
    } catch (e) {
      // Nếu gặp lỗi 'not found', tự động thử lại với model 'gemini-pro'
      if (e.toString().contains('not found')) {
        try {
          final fallbackModel = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
          final response = await fallbackModel.generateContent([Content.text(prompt)]);
          return response.text ?? "AI đang bận, thử lại sau nhé!";
        } catch (err) {
          return "Lỗi AI: $err";
        }
      }
      return "Lỗi kết nối: $e";
    }
  }
}
