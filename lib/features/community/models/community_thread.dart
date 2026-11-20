/// Identitas publik penulis dari serializer Community.
class CommunityAuthor {
  const CommunityAuthor({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatar,
  });

  final int id;
  final String username;
  final String displayName;
  final String avatar;

  factory CommunityAuthor.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final username = json['username'];
    final name = json['display_name'];
    final avatar = json['avatar'];
    if (id is! int ||
        id < 1 ||
        username is! String ||
        username.isEmpty ||
        name is! String ||
        avatar is! String) {
      throw const FormatException('Data penulis tidak valid.');
    }
    return CommunityAuthor(
      id: id,
      username: username,
      displayName: name.trim().isEmpty ? username : name,
      avatar: avatar,
    );
  }
}

/// Feed dan detail memakai representasi thread yang sama di API Django.
class CommunityThread {
  const CommunityThread({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.author,
    required this.isAutoPost,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.replyCount,
    required this.isLiked,
  });

  final int id;
  final String title;
  final String body;
  final String category;
  final CommunityAuthor author;
  final bool isAutoPost;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int replyCount;
  final bool isLiked;

  factory CommunityThread.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final body = json['body'];
    final category = json['category'];
    final author = json['author'];
    final autoPost = json['is_auto_post'];
    final created = json['created_at'];
    final updated = json['updated_at'];
    final likes = json['like_count'];
    final replies = json['reply_count'];
    final liked = json['is_liked'];
    if (id is! int ||
        id < 1 ||
        title is! String ||
        body is! String ||
        category is! String ||
        author is! Map<String, dynamic> ||
        autoPost is! bool ||
        created is! String ||
        updated is! String ||
        likes is! int ||
        likes < 0 ||
        replies is! int ||
        replies < 0 ||
        liked is! bool) {
      throw const FormatException('Data cerita tidak valid.');
    }
    final createdAt = DateTime.tryParse(created);
    final updatedAt = DateTime.tryParse(updated);
    if (createdAt == null || updatedAt == null) {
      throw const FormatException('Tanggal cerita tidak valid.');
    }
    return CommunityThread(
      id: id,
      title: title,
      body: body,
      category: category,
      author: CommunityAuthor.fromJson(author),
      isAutoPost: autoPost,
      createdAt: createdAt,
      updatedAt: updatedAt,
      likeCount: likes,
      replyCount: replies,
      isLiked: liked,
    );
  }
}
