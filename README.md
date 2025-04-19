# 🗣️ Verbose AI – Professional Text Standardization

**Verbose AI** is a Dart-based utility that uses AI to automatically standardize, correct grammar and spelling, and rewrite casual or broken English into professionally polished text using Google's `gemma-2-2b-it` model via Hugging Face Inference API.

---

## ✨ Features

- ✅ Fixes grammar, spelling, and sentence structure
- ✅ Rewrites text in a formal, professional tone
- ✅ Uses state-of-the-art open-source LLM (Gemma 2B IT)
- ✅ Fallback mechanism if the API fails
- ✅ Easy to plug into any Dart / Flutter project

---

## 🚀 How It Works

The app sends user input to the Hugging Face **Chat Completions API**, using Google's instruction-tuned Gemma model. The model rewrites the text professionally and returns the standardized output.

---

## 🧠 Powered By

- 🧩 **Model**: [`google/gemma-2-2b-it`](https://huggingface.co/google/gemma-2-2b-it)
- 🔗 **API**: Hugging Face Inference Chat Completions Endpoint
- 🧰 **Language**: Dart

---

## 📦 Installation

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^0.13.6
```

---

## 🛠️ Setup

1. Create an account at [Hugging Face](https://huggingface.co/join).
2. Generate a free API token at [https://huggingface.co/settings/tokens](https://huggingface.co/settings/tokens).
3. Replace the placeholder API key in `TextService` with your own:

```dart
final String apiKey = "hf_YourTokenHere";
```

---

## 💡 Example Usage

```dart
final service = TextService();

void main() async {
  String input = "how are u dongd aht bro";
  String result = await service.standardizeText(input);
  print(result); // Output: "How are you doing that, brother?" (Professionally rephrased)
}
```

---

## 🧰 API Details

**Endpoint:**
```
POST https://api-inference.huggingface.co/chat/completions
```

**Payload:**
```json
{
  "model": "google/gemma-2-2b-it",
  "messages": [
    {"role": "system", "content": "You are a professional editor..."},
    {"role": "user", "content": "raw input text"}
  ],
  "temperature": 0.3,
  "max_tokens": 150
}
```

---

## 🛡️ Fallback Behavior

If the Hugging Face API fails (e.g. network error or quota exceeded), the app gracefully falls back to a basic standardization method using simple string replacements.

---

## 📝 License

MIT License. Feel free to modify, use, and distribute.

---

## 👨‍💻 Author

Made with ❤️ by [Harishri](https://github.com/Harishri2002)

---

```

Let me know if you want to include screenshots, a badge (e.g. Dart Pub), or convert this into a Flutter UI version too!