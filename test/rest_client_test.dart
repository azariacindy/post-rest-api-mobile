import 'dart:convert';

import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:post_rest/client/rest_client.dart';

void main() {
  test('fetchPosts parses list', () async {
    final mock = MockClient((request) async {
      final data = List.generate(
        3,
        (i) => {'id': i + 1, 'userId': 10 + i, 'title': 't$i', 'body': 'b$i'},
      );
      return http.Response(
        json.encode(data),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = RestClient(httpClient: mock, baseUrl: 'https://example.com');
    final posts = await client.fetchPosts();
    expect(posts.length, 3);
    expect(posts.first.title, 't0');
  });

  test('fetchPost parses single', () async {
    final mock = MockClient((request) async {
      final data = {'id': 5, 'userId': 1, 'title': 'hello', 'body': 'world'};
      return http.Response(
        json.encode(data),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final client = RestClient(httpClient: mock);
    final post = await client.fetchPost(5);
    expect(post.id, 5);
    expect(post.title, 'hello');
  });
}
