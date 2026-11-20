import 'community_thread.dart';

class CommunityPagination {
  const CommunityPagination({
    required this.page,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  final int page;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  factory CommunityPagination.fromJson(Map<String, dynamic> json) {
    final page = json['page'];
    final total = json['total_pages'];
    final next = json['has_next'];
    final previous = json['has_previous'];
    if (page is! int ||
        page < 1 ||
        total is! int ||
        total < page ||
        next is! bool ||
        previous is! bool) {
      throw const FormatException('Data halaman tidak valid.');
    }
    return CommunityPagination(
      page: page,
      totalPages: total,
      hasNext: next,
      hasPrevious: previous,
    );
  }
}

class CommunityFeed {
  const CommunityFeed({
    required this.threads,
    required this.category,
    required this.pagination,
  });

  final List<CommunityThread> threads;
  final String category;
  final CommunityPagination pagination;

  factory CommunityFeed.fromJson(Map<String, dynamic> json) {
    final results = json['results'];
    final category = json['category'];
    final pagination = json['pagination'];
    if (results is! List ||
        category is! String ||
        pagination is! Map<String, dynamic>) {
      throw const FormatException('Data komunitas tidak valid.');
    }
    final threads = results.map((row) {
      if (row is! Map<String, dynamic>) {
        throw const FormatException('Data cerita tidak valid.');
      }
      return CommunityThread.fromJson(row);
    });
    return CommunityFeed(
      threads: List.unmodifiable(threads),
      category: category,
      pagination: CommunityPagination.fromJson(pagination),
    );
  }
}
