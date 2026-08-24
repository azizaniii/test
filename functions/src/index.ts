/**
 * Cloud Functions untuk aplikasi BPS Lombok Utara
 */

import { onRequest, onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Import AI Gateway function
import { askAIHandler } from './askAI';

/**
 * AI Gateway - Fungsi untuk tanya jawab AI dengan fallback Gemini -> Groq
 * 
 * Input: { question: string, context?: string }
 * Output: { answer: string, source_provider: "gemini" | "groq" }
 */
export const askAI = onCall(
  {
    region: 'asia-southeast1', // Singapore region untuk latency rendah
    cors: true,
  },
  async (request) => {
    // Verifikasi autentikasi user
    if (!request.auth) {
      throw new HttpsError(
        'unauthenticated',
        'User harus login untuk menggunakan fitur AI'
      );
    }

    const uid = request.auth.uid;
    
    // Validasi input
    const data = request.data as { question?: string; context?: string };
    if (!data.question || typeof data.question !== 'string') {
      throw new HttpsError(
        'invalid-argument',
        'Pertanyaan (question) harus diisi'
      );
    }

    // Cek rate limiting per user (simple implementation)
    const userLimitsRef = admin.firestore().collection('ai_limits').doc(uid);
    const today = new Date().toISOString().split('T')[0];
    
    const userLimitsDoc = await userLimitsRef.get();
    const userLimits = userLimitsDoc.data() || { count: 0, date: today };
    
    if (userLimits.date !== today) {
      // Reset counter untuk hari baru
      await userLimitsRef.set({ count: 0, date: today });
      userLimits.count = 0;
      userLimits.date = today;
    }
    
    // Batas 100 pertanyaan per hari per user
    if (userLimits.count >= 100) {
      throw new HttpsError(
        'resource-exhausted',
        'Batas pertanyaan harian telah tercapai. Silakan coba lagi besok.'
      );
    }

    try {
      // Panggil AI handler
      const result = await askAIHandler(data.question, data.context);
      
      // Increment counter
      await userLimitsRef.set({
        count: admin.firestore.FieldValue.increment(1),
        date: today,
        last_used: admin.firestore.FieldValue.serverTimestamp(),
        provider: result.source_provider,
      }, { merge: true });

      return result;
    } catch (error) {
      console.error('AI Gateway error:', error);
      throw new HttpsError(
        'internal',
        'Gagal mendapatkan jawaban AI. Silakan coba lagi nanti.'
      );
    }
  }
);

// Export fungsi lainnya yang akan ditambahkan
// export const syncData = onCall(...);
// export const backupMedia = onCall(...);
