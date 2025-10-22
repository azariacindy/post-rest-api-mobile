import 'package:flutter_test/flutter_test.dart';
import 'package:post_rest/models/post.dart';

void main() {
  test('Post.fromJson and toJson roundtrip', () {
    final json = {'id': 1, 'userId': 42, 'title': 'Hello', 'body': 'World'};

    final post = Post.fromJson(json);
    expect(post.id, 1);
    expect(post.userId, 42);
    expect(post.title, 'Hello');
    expect(post.body, 'World');

    final encoded = post.toJson();
    expect(encoded['id'], 1);
    expect(encoded['userId'], 42);
    expect(encoded['title'], 'Hello');
    expect(encoded['body'], 'World');
  });
}
