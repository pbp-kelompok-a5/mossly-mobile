import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/api_client.dart';
import '../../../core/theme.dart';
import '../models/community_feed.dart';
import '../services/community_service.dart';
import '../widgets/community_feedback.dart';
import '../widgets/thread_card.dart';
import 'thread_detail_page.dart';

/// Nama halaman dipertahankan karena dipakai oleh HomeShell.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _authorController = TextEditingController();
  final _scrollController = ScrollController();
  CommunityService? _service;
  Future<CommunityFeed>? _feed;
  String _category = '';
  String _author = '';
  int _page = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _service ??= CommunityService(context.read<ApiClient>());
    // HomeShell memasang semua tab melalui IndexedStack. Ambil feed hanya
    // setelah Community terlihat; perubahan tab memicu dependency ini lagi.
    // Future tetap disimpan supaya pindah tab tidak mengulang request.
    if (Visibility.of(context)) {
      _feed ??= _service!.getThreads();
    }
  }

  Future<void> _reload({int? page, bool scrollToTop = false}) async {
    final request = _service!.getThreads(
      category: _category,
      author: _author,
      page: page ?? _page,
    );
    setState(() {
      _page = page ?? _page;
      _feed = request;
    });
    if (scrollToTop && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    try {
      await request;
    } catch (_) {
      // FutureBuilder menampilkan kegagalan dan tombol coba lagi.
    }
  }

  void _filterAuthor() {
    FocusScope.of(context).unfocus();
    _author = _authorController.text.trim();
    _reload(page: 1, scrollToTop: true);
  }

  @override
  void dispose() {
    _authorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tab yang belum dibuka tidak membutuhkan UI loading atau animasi aktif.
    if (_feed == null) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunitas'),
        actions: [
          IconButton(
            onPressed: () => _reload(),
            tooltip: 'Muat ulang komunitas',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: FutureBuilder<CommunityFeed>(
              future: _feed,
              builder: (context, snapshot) {
                final done = snapshot.connectionState == ConnectionState.done;
                final feed = done && !snapshot.hasError ? snapshot.data : null;
                return RefreshIndicator(
                  onRefresh: () => _reload(),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(child: _header(context)),
                      if (!done)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: CircularProgressIndicator(
                              semanticsLabel: 'Memuat cerita komunitas',
                            ),
                          ),
                        )
                      else if (snapshot.hasError)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: CommunityFeedback(
                            icon: Icons.cloud_off_outlined,
                            title: 'Cerita belum bisa dimuat',
                            message: communityErrorMessage(snapshot.error!),
                            onRetry: () => _reload(),
                          ),
                        )
                      else if (feed == null || feed.threads.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: CommunityFeedback(
                            title: 'Belum ada cerita',
                            message: 'Belum ada cerita yang cocok. Coba kategori atau penulis lain.',
                          ),
                        )
                      else ...[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: MosslySpace.s4,
                          ),
                          sliver: SliverList.builder(
                            itemCount: feed.threads.length,
                            itemBuilder: (context, index) {
                              final thread = feed.threads[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: MosslySpace.s4,
                                ),
                                child: ThreadCard(
                                  thread: thread,
                                  onTap: () => Navigator.of(context).push<void>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ThreadDetailPage(threadId: thread.id),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SliverToBoxAdapter(child: _pagination(feed.pagination)),
                      ],
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

  Widget _header(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(MosslySpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sustainability Community',
            style: text.labelLarge?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: MosslySpace.s2),
          Text(
            'Tumbuh bersama,\nsatu cerita setiap hari.',
            style: text.headlineSmall,
          ),
          const SizedBox(height: MosslySpace.s2),
          const Text(
            'Temukan tips, pengalaman, dan pencapaian dari teman-teman Mossly.',
          ),
          const SizedBox(height: MosslySpace.s4),
          Wrap(
            spacing: MosslySpace.s2,
            runSpacing: MosslySpace.s2,
            children: [
              for (final category in ['', 'tips', 'general', 'achievement'])
                ChoiceChip(
                  label: Text(
                    category.isEmpty
                        ? 'Semua'
                        : communityCategoryLabel(category),
                  ),
                  selected: _category == category,
                  onSelected: (_) {
                    if (_category != category) {
                      _category = category;
                      _reload(page: 1, scrollToTop: true);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: MosslySpace.s3),
          TextField(
            controller: _authorController,
            textInputAction: TextInputAction.search,
            autocorrect: false,
            onSubmitted: (_) => _filterAuthor(),
            decoration: InputDecoration(
              labelText: 'Cari username penulis',
              hintText: 'Contoh: eleazar',
              prefixIcon: const Icon(Icons.person_search_outlined),
              suffixIcon: IconButton(
                tooltip: 'Cari penulis',
                onPressed: _filterAuthor,
                icon: const Icon(Icons.search),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MosslySpace.radiusMd),
              ),
            ),
          ),
          if (_author.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                _authorController.clear();
                _filterAuthor();
              },
              icon: const Icon(Icons.close),
              label: Text('Hapus filter penulis: $_author'),
            ),
        ],
      ),
    );
  }

  Widget _pagination(CommunityPagination pagination) {
    return Padding(
      padding: const EdgeInsets.all(MosslySpace.s4),
      child: Column(
        children: [
          Text('Halaman ${pagination.page} dari ${pagination.totalPages}'),
          const SizedBox(height: MosslySpace.s3),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: MosslySpace.s3,
            runSpacing: MosslySpace.s2,
            children: [
              OutlinedButton.icon(
                onPressed: pagination.hasPrevious
                    ? () =>
                          _reload(page: pagination.page - 1, scrollToTop: true)
                    : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Sebelumnya'),
              ),
              OutlinedButton.icon(
                onPressed: pagination.hasNext
                    ? () =>
                          _reload(page: pagination.page + 1, scrollToTop: true)
                    : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Selanjutnya'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
