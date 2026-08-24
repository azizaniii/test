/**
 * Middleware untuk verifikasi autentikasi dan authorization
 */

import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';

export interface AuthContext {
  uid: string;
  email?: string;
  role: 'admin_kantor' | 'petugas_lapangan';
  wilayahTugas?: string;
}

/**
 * Verifikasi Firebase ID token dan dapatkan user context
 */
export async function verifyAuth(idToken: string): Promise<AuthContext> {
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    
    // Dapatkan custom claims untuk role
    const userRecord = await admin.auth().getUser(decodedToken.uid);
    const customClaims = userRecord.customClaims || {};
    
    const role = (customClaims.role as string) || 'petugas_lapangan';
    
    return {
      uid: decodedToken.uid,
      email: decodedToken.email || undefined,
      role: role as 'admin_kantor' | 'petugas_lapangan',
      wilayahTugas: customClaims.wilayah_tugas as string | undefined,
    };
  } catch (error) {
    throw new HttpsError('unauthenticated', 'Token tidak valid');
  }
}

/**
 * Middleware untuk memastikan user adalah admin
 */
export function requireAdmin(context: AuthContext): void {
  if (context.role !== 'admin_kantor') {
    throw new HttpsError(
      'permission-denied',
      'Akses ditolak. Hanya admin yang dapat melakukan aksi ini.'
    );
  }
}

/**
 * Middleware untuk memastikan user adalah petugas lapangan
 */
export function requirePetugas(context: AuthContext): void {
  if (context.role !== 'petugas_lapangan') {
    throw new HttpsError(
      'permission-denied',
      'Akses ditolak. Hanya petugas lapangan yang dapat melakukan aksi ini.'
    );
  }
}

/**
 * Cek apakah user memiliki akses ke wilayah tertentu
 */
export function checkWilayahAccess(
  context: AuthContext,
  requiredWilayah: string
): void {
  // Admin kantor bisa akses semua wilayah
  if (context.role === 'admin_kantor') {
    return;
  }
  
  // Petugas hanya bisa akses wilayah tugasnya
  if (context.wilayahTugas !== requiredWilayah) {
    throw new HttpsError(
      'permission-denied',
      'Akses ditolak. Anda tidak memiliki izin untuk wilayah ini.'
    );
  }
}
