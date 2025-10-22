import '../client/rest_client.dart';
import '../models/post.dart';

class PostService {
  final RestClient client;

  PostService(this.client);

  Future<List<Post>> list({int? limit}) => client.fetchPosts(limit: limit);
  Future<Post> get(int id) => client.fetchPost(id);
  Future<Post> create(Post post) => client.createPost(post);
  Future<Post> update(Post post) => client.updatePost(post);
  Future<void> delete(int id) => client.deletePost(id);
}
