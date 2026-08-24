import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

/// Home screen dengan menu utama untuk petugas
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BPS Lombok Utara'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              if (user != null) ...[
                Text(
                  'Halo, ${user.displayName ?? user.email ?? "Petugas"}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
              ],
              
              const Divider(),
              const SizedBox(height: 16),

              // Menu grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _MenuCard(
                      icon: Icons.search,
                      title: 'KBLI & KBJI',
                      subtitle: 'Cari kode klasifikasi',
                      onTap: () => context.push('/kbli-kbji'),
                    ),
                    _MenuCard(
                      icon: Icons.calculate,
                      title: 'Estimasi BPJS',
                      subtitle: 'Hitung biaya perawatan',
                      onTap: () => context.push('/bpjs-cost'),
                    ),
                    _MenuCard(
                      icon: Icons.psychology,
                      title: 'Konsep & AI',
                      subtitle: 'Tanya definisi survei',
                      onTap: () {
                        // TODO: Implement concept search
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur belum tersedia')),
                        );
                      },
                    ),
                    _MenuCard(
                      icon: Icons.assignment,
                      title: 'SAKERNAS',
                      subtitle: 'Bantuan survei tenaga kerja',
                      onTap: () {
                        // TODO: Implement Sakernas
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur belum tersedia')),
                        );
                      },
                    ),
                    _MenuCard(
                      icon: Icons.home_work,
                      title: 'SUSENAS',
                      subtitle: 'Bantuan survei sosial ekonomi',
                      onTap: () {
                        // TODO: Implement Susenas
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur belum tersedia')),
                        );
                      },
                    ),
                    _MenuCard(
                      icon: Icons.receipt_long,
                      title: 'Laporan',
                      subtitle: 'Laporan perjalanan & kegiatan',
                      onTap: () {
                        // TODO: Implement Laporan
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fitur belum tersedia')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
