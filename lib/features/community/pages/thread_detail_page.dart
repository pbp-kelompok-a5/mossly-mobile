import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/theme.dart';
import '../models/community_thread.dart';
import '../services/community_service.dart';
import '../widgets/community_feedback.dart';
import '../widgets/thread_card.dart';

class ThreadDetailPage extends StatefulWidget {
  const ThreadDetailPage({super.key, required this.threadId});
  final int threadId;
  @override
  State<ThreadDetailPage> createState() => _ThreadDetailPageState();
}

class _ThreadDetailPageState extends State<ThreadDetailPage> {
  CommunityService? _service;
  Future<CommunityThread>? _thread;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service ??= CommunityService(context.read<ApiClient>());
    _thread ??= _service!.getThread(widget.threadId);
  }

  Future<void> _reload() async {
    final request = _service!.getThread(widget.threadId);
    setState(() => _thread = request);
    try {
      await request;
    } catch (_) {
      // FutureBuilder menangani error, termasuk saat refresh gagal.
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail cerita'),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Muat ulang cerita',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<CommunityThread>(
              future: _thread,
              builder: (context, snapshot) {
                final thread = snapshot.data;
                Widget content;
                if (snapshot.connectionState != ConnectionState.done) {
                  content = const Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Memuat detail cerita',
                    ),
                  );
                } else if (snapshot.hasError) {
                  content = CommunityFeedback(
                    title: 'Cerita belum bisa dimuat',
                    message: communityErrorMessage(snapshot.error!),
                    icon: Icons.cloud_off_outlined,
                    onRetry: _reload,
                  );
                } else if (thread == null) {
                  content = const CommunityFeedback(
                    title: 'Cerita tidak ditemukan',
                    message: 'Cerita ini sudah tidak tersedia.',
                  );
                } else {
                  content = Padding(
                    padding: const EdgeInsets.all(MosslySpace.s4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ThreadAuthorHeader(thread: thread),
                        const SizedBox(height: MosslySpace.s3),
                        ThreadLabels(thread: thread),
                        const SizedBox(height: MosslySpace.s3),
                        SelectableText(thread.title, style: text.headlineSmall),
                        const SizedBox(height: MosslySpace.s2),
                        Text(
                          communityDate(thread.createdAt),
                          style: text.bodySmall,
                        ),
                        if (thread.updatedAt.isAfter(thread.createdAt)) ...[
                          const SizedBox(height: MosslySpace.s1),
                          Text(
                            'Diperbarui ${communityDate(thread.updatedAt)}',
                            style: text.bodySmall,
                          ),
                        ],
                        const SizedBox(height: MosslySpace.s6),
                        SelectableText(thread.body, style: text.bodyLarge),
                        const SizedBox(height: MosslySpace.s6),
                        const Divider(),
                        const SizedBox(height: MosslySpace.s3),
                        ThreadStats(thread: thread),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(hasScrollBody: false, child: content),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
