/**
 * AI Gateway Handler dengan fallback Gemini -> Groq
 */

import { GoogleGenerativeAI } from '@google/generative-ai';
import Groq from 'groq-sdk';

// API Keys dari Secret Manager (dalam implementasi nyata, gunakan GCP Secret Manager)
// Untuk development, bisa menggunakan environment variables
const GEMINI_API_KEYS: string[] = [
  process.env.GEMINI_API_KEY_1 || '',
  process.env.GEMINI_API_KEY_2 || '',
  // Tambahkan lebih banyak key jika perlu untuk load balancing
].filter(key => key.length > 0);

const GROQ_API_KEYS: string[] = [
  process.env.GROQ_API_KEY_1 || '',
  process.env.GROQ_API_KEY_2 || '',
].filter(key => key.length > 0);

// Round-robin index untuk load balancing
let geminiKeyIndex = 0;
let groqKeyIndex = 0;

interface AiResponse {
  answer: string;
  source_provider: 'gemini' | 'groq';
}

/**
 * Handler untuk memproses pertanyaan AI dengan fallback
 * 
 * @param question - Pertanyaan dari user
 * @param context - Konteks tambahan (opsional)
 * @returns Jawaban AI dan provider yang digunakan
 */
export async function askAIHandler(
  question: string,
  context?: string
): Promise<AiResponse> {
  // Coba Gemini terlebih dahulu
  try {
    console.log('Mencoba Gemini API...');
    const geminiResult = await callGemini(question, context);
    return {
      answer: geminiResult,
      source_provider: 'gemini',
    };
  } catch (geminiError) {
    console.error('Gemini API gagal:', geminiError);
    
    // Fallback ke Groq
    try {
      console.log('Fallback ke Groq API...');
      const groqResult = await callGroq(question, context);
      return {
        answer: groqResult,
        source_provider: 'groq',
      };
    } catch (groqError) {
      console.error('Groq API juga gagal:', groqError);
      throw new Error('Kedua AI provider gagal. Silakan coba lagi nanti.');
    }
  }
}

/**
 * Memanggil Gemini API dengan round-robin key
 */
async function callGemini(question: string, context?: string): Promise<string> {
  if (GEMINI_API_KEYS.length === 0) {
    throw new Error('Tidak ada API key Gemini yang tersedia');
  }

  // Ambil key secara round-robin
  const apiKey = GEMINI_API_KEYS[geminiKeyIndex];
  geminiKeyIndex = (geminiKeyIndex + 1) % GEMINI_API_KEYS.length;

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

  // Build prompt dengan konteks jika ada
  let prompt = question;
  if (context) {
    prompt = `Konteks: ${context}\n\nPertanyaan: ${question}`;
  }

  // Tambahkan instruksi khusus untuk BPS
  const fullPrompt = `Anda adalah asisten AI untuk petugas BPS (Badan Pusat Statistik) Kabupaten Lombok Utara. 
Bantu petugas dengan memberikan informasi yang akurat dan relevan terkait tugas lapangan mereka.

${prompt}

Berikan jawaban yang jelas, ringkas, dan mudah dipahami oleh petugas lapangan.`;

  const result = await model.generateContent(fullPrompt);
  const response = await result.response;
  
  return response.text();
}

/**
 * Memanggil Groq API dengan round-robin key
 */
async function callGroq(question: string, context?: string): Promise<string> {
  if (GROQ_API_KEYS.length === 0) {
    throw new Error('Tidak ada API key Groq yang tersedia');
  }

  // Ambil key secara round-robin
  const apiKey = GROQ_API_KEYS[groqKeyIndex];
  groqKeyIndex = (groqKeyIndex + 1) % GROQ_API_KEYS.length;

  const groq = new Groq({ apiKey });

  // Build prompt dengan konteks jika ada
  let systemPrompt = `Anda adalah asisten AI untuk petugas BPS (Badan Pusat Statistik) Kabupaten Lombok Utara. 
Bantu petugas dengan memberikan informasi yang akurat dan relevan terkait tugas lapangan mereka.
Berikan jawaban yang jelas, ringkas, dan mudah dipahami oleh petugas lapangan.`;

  let userMessage = question;
  if (context) {
    userMessage = `Konteks: ${context}\n\nPertanyaan: ${question}`;
  }

  const completion = await groq.chat.completions.create({
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userMessage },
    ],
    model: 'llama-3.1-70b-versatile', // Model Groq yang cepat dan berkualitas
    temperature: 0.7,
    max_tokens: 1024,
  });

  return completion.choices[0]?.message?.content || 'Maaf, tidak dapat menghasilkan jawaban.';
}
