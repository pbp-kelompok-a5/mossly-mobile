import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api_client.dart';
import '../theme.dart';

/// Isi sementara sebuah tab sampai pemilik modul membangun halamannya
/// Tombolnya memanggil GET /api/v1/ping/ untuk memastikan aplikasi tersambung ke web service Django dan token dikenali
class ModulePlaceholder extends StatefulWidget {
  const ModulePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.owner,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String owner;
  final String description;

  @override
  State<ModulePlaceholder> createState() => _ModulePlaceholderState();
}

class _ModulePlaceholderState extends State<ModulePlaceholder> {
  bool _loading = false;
  String? _result;

  Future<void> _checkConnection() async {
    setState(() {
      _loading = true;
      _result = null;
    });
    String result;
    try {
      final data = await context.read<ApiClient>().get('/ping/');
      final map = data as Map<String, dynamic>;
      final username = map['username'];
      result = username == null
          ? 'Tersambung ke server, belum login.'
          : 'Tersambung ke server sebagai $username.';
    } on ApiException catch (error) {
      result = 'Server menolak: ${error.message}';
    } catch (error) {
      result = 'Tidak bisa menghubungi server: $error';
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MosslySpace.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(widget.icon, size: 56, color: MosslyColors.moss500),
            const SizedBox(height: MosslySpace.s4),
            Text(widget.title, style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: MosslySpace.s2),
            Text(
              widget.description,
              style: text.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MosslySpace.s2),
            Text(
              'Dikerjakan oleh ${widget.owner}',
              style: text.labelMedium?.copyWith(color: MosslyColors.neutral600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MosslySpace.s6),
            FilledButton.tonal(
              onPressed: _loading ? null : _checkConnection,
              child: Text(_loading ? 'Memeriksa...' : 'Cek koneksi ke server'),
            ),
            if (_result != null) ...<Widget>[
              const SizedBox(height: MosslySpace.s3),
              Text(_result!, style: text.bodySmall, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
