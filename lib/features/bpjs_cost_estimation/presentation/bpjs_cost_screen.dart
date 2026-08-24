import 'package:flutter/material.dart';

/// Screen estimasi biaya perawatan BPJS (INA-CBG)
class BpjsCostScreen extends StatefulWidget {
  const BpjsCostScreen({super.key});

  @override
  State<BpjsCostScreen> createState() => _BpjsCostScreenState();
}

class _BpjsCostScreenState extends State<BpjsCostScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedJenisLayanan;
  String? _selectedKelasBpjs;
  final _kodeDiagnosaController = TextEditingController();
  
  double? _estimatedCost;
  bool _isLoading = false;

  @override
  void dispose() {
    _kodeDiagnosaController.dispose();
    super.dispose();
  }

  void _calculateCost() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _estimatedCost = null;
    });

    // TODO: Implement kalkulasi dengan data dari Drift database
    // await ref.read(appDatabaseProvider).getInaCbgTariff(kodeDiagnosa, jenisLayanan);
    
    // Mock calculation untuk sementara
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      
      double baseCost = 0;
      
      // Mock tariff based on kelas
      switch (_selectedKelasBpjs) {
        case 'Kelas 1':
          baseCost = 15000000;
          break;
        case 'Kelas 2':
          baseCost = 10000000;
          break;
        case 'Kelas 3':
          baseCost = 5000000;
          break;
      }

      // Adjust based on layanan type
      if (_selectedJenisLayanan == 'rawat_jalan') {
        baseCost *= 0.3; // Rawat jalan biasanya 30% dari rawat inap
      }

      setState(() {
        _estimatedCost = baseCost;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimasi Biaya BPJS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parameter Perhitungan',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Jenis Layanan
                      DropdownButtonFormField<String>(
                        value: _selectedJenisLayanan,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Layanan',
                          prefixIcon: Icon(Icons.local_hospital_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'rawat_inap', child: Text('Rawat Inap')),
                          DropdownMenuItem(value: 'rawat_jalan', child: Text('Rawat Jalan')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedJenisLayanan = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih jenis layanan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kelas BPJS
                      DropdownButtonFormField<String>(
                        value: _selectedKelasBpjs,
                        decoration: const InputDecoration(
                          labelText: 'Kelas BPJS',
                          prefixIcon: Icon(Icons.bed_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Kelas 1', child: Text('Kelas 1')),
                          DropdownMenuItem(value: 'Kelas 2', child: Text('Kelas 2')),
                          DropdownMenuItem(value: 'Kelas 3', child: Text('Kelas 3')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedKelasBpjs = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih kelas BPJS';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kode Diagnosa INA-CBG
                      TextFormField(
                        controller: _kodeDiagnosaController,
                        decoration: const InputDecoration(
                          labelText: 'Kode Diagnosa (INA-CBG)',
                          prefixIcon: Icon(Icons.medical_services_outlined),
                          hintText: 'Contoh: A-1-0',
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan kode diagnosa';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Calculate button
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _calculateCost,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.calculate),
                        label: Text(_isLoading ? 'Menghitung...' : 'Hitung Estimasi'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Result section
              if (_estimatedCost != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hasil Estimasi',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatCurrency(_estimatedCost!),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Catatan:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Estimasi ini berdasarkan tarif INA-CBG dan dapat berubah sesuai kondisi aktual pasien',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Biaya akhir ditentukan oleh pihak rumah sakit',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
