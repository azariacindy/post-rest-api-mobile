// Simple HTTP-based REST client using only `package:http`.
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

class RestClient {
  final http.Client _httpClient;
  final Uri baseUri;

  RestClient({http.Client? httpClient, String? baseUrl})
    : _httpClient = httpClient ?? http.Client(),
      baseUri = Uri.parse(baseUrl ?? 'https://jsonplaceholder.typicode.com');

  Uri _build(String path, [Map<String, dynamic>? queryParameters]) {
    // Use Uri.resolve to handle slashes correctly.
    final resolved = baseUri.resolve(path);
    if (queryParameters == null) return resolved;
    return resolved.replace(
      queryParameters: queryParameters.map(
        (k, v) => MapEntry(k, v?.toString()),
      ),
    );
  }

  Future<List<Post>> fetchPosts({int? limit}) async {
    final uri = _build('/posts');
    final resp = await _httpClient.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List<dynamic>;
      final list = data
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
      if (limit != null && limit > 0) return list.take(limit).toList();
      return list;
    }
    _throwForStatus('Failed COBA etch posts', resp.statusCode, resp.body);
  }

  Future<Post> fetchPost(int id) async {
    final uri = _build('/posts/$id');
    final resp = await _httpClient.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (resp.statusCode == 200) {
      return Post.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    _throwForStatus('Failed to fetch post $id', resp.statusCode, resp.body);
  }

  Future<Post> createPost(Post post) async {
    final uri = _build('/posts');
    final resp = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return Post.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    _throwForStatus('Failed to create post', resp.statusCode, resp.body);
  }

  Future<Post> updatePost(Post post) async {
    if (post.id == null) {
      throw ArgumentError('Post.id must be provided to update');
    }
    final uri = _build('/posts/${post.id}');
    final resp = await _httpClient.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );
    if (resp.statusCode == 200) {
      return Post.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    _throwForStatus(
      'Failed to update post ${post.id}',
      resp.statusCode,
      resp.body,
    );
  }

  Future<void> deletePost(int id) async {
    final uri = _build('/posts/$id');
    final resp = await _httpClient.delete(uri);
    if (resp.statusCode == 200 || resp.statusCode == 204) return;
    _throwForStatus('Failed to delete post $id', resp.statusCode, resp.body);
  }

  void close() => _httpClient.close();
}

abstract class RestException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  RestException(this.message, this.statusCode, this.body);

  @override
  String toString() => '$runtimeType: $message (status: $statusCode)';
}

class HttpException extends RestException {
  HttpException(super.message, super.statusCode, super.body);
}

class NotFoundException extends RestException {
  NotFoundException(super.message, super.statusCode, super.body);
}

class UnauthorizedException extends RestException {
  UnauthorizedException(super.message, super.statusCode, super.body);
}

class BadRequestException extends RestException {
  BadRequestException(super.message, super.statusCode, super.body);
}

Never _throwForStatus(String message, int? statusCode, String? body) {
  if (statusCode == 400) throw BadRequestException(message, statusCode, body);
  if (statusCode == 401 || statusCode == 403)
    throw UnauthorizedException(message, statusCode, body);
  if (statusCode == 404) throw NotFoundException(message, statusCode, body);
  throw HttpException(message, statusCode, body);
}
