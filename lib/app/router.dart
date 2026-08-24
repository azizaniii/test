import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/home_screen.dart';
import '../features/kbli_kbji/presentation/kbli_kbji_search_screen.dart';
import '../features/bpjs_cost_estimation/presentation/bpjs_cost_screen.dart';

/// Router konfigurasi dengan role-based routing
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Route publik - login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Route utama setelah login
      GoRoute(
        path: '/',
        name: 'home',
        redirect: (context, state) => '/home',
        routes: [
          GoRoute(
            path: 'home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: 'kbli-kbji',
            name: 'kbliKbji',
            builder: (context, state) => const KbliKbjiSearchScreen(),
          ),
          GoRoute(
            path: 'bpjs-cost',
            name: 'bpjsCost',
            builder: (context, state) => const BpjsCostScreen(),
          ),
          // TODO: Tambahkan route untuk fitur lainnya setelah diimplementasikan
          // GoRoute(
          //   path: 'concept-search',
          //   name: 'conceptSearch',
          //   builder: (context, state) => const ConceptSearchScreen(),
          // ),
          // GoRoute(
          //   path: 'sakernas',
          //   name: 'sakernas',
          //   builder: (context, state) => const SakernasScreen(),
          // ),
          // GoRoute(
          //   path: 'susenas',
          //   name: 'susenas',
          //   builder: (context, state) => const SusenasScreen(),
          // ),
          // GoRoute(
          //   path: 'laporan',
          //   name: 'laporan',
          //   builder: (context, state) => const LaporanScreen(),
          // ),
        ],
      ),
    ],
    // Error handling untuk route tidak ditemukan
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Halaman tidak ditemukan')),
    ),
  );
}
