import 'package:flutter/material.dart';
import 'package:post_rest/rest_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Posts demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PostsPage(),
    );
  }
}

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late final RestClient _client;
  late final PostService _service;
  List<Post> _posts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _client = RestClient();
    _service = PostService(_client);
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
    });
    try {
      final posts = await _service.list(limit: 50);
      if (!mounted) return;
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load posts: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _showCreateDialog() async {
    final userIdCtl = TextEditingController();
    final titleCtl = TextEditingController();
    final bodyCtl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: userIdCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'User ID'),
                validator: (v) => int.tryParse(v ?? '') == null
                    ? 'Enter a valid user id'
                    : null,
              ),
              TextFormField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Title required' : null,
              ),
              TextFormField(
                controller: bodyCtl,
                decoration: const InputDecoration(labelText: 'Body'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Body required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      final userId = int.tryParse(userIdCtl.text) ?? 0;
      final post = Post(
        userId: userId,
        title: titleCtl.text,
        body: bodyCtl.text,
      );
      // Optimistic insert
      final tmp = Post(
        id: null,
        userId: post.userId,
        title: post.title,
        body: post.body,
      );
      if (!mounted) return;
      setState(() {
        _posts.insert(0, tmp);
      });
      try {
        final created = await _service.create(post);
        if (!mounted) return;
        setState(() {
          _posts[0] = created;
        });
        // no cache; update UI only
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Post created')));
      } catch (e) {
        if (!mounted) return;
        // rollback optimistic
        setState(() {
          _posts.removeAt(0);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create post: $e')));
      }
    }
  }

  Future<void> _showEditDialog(int index) async {
    final post = _posts[index];
    final titleCtl = TextEditingController(text: post.title);
    final bodyCtl = TextEditingController(text: post.body);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleCtl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Title required' : null,
              ),
              TextFormField(
                controller: bodyCtl,
                decoration: const InputDecoration(labelText: 'Body'),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Body required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final updated = Post(
        id: post.id,
        userId: post.userId,
        title: titleCtl.text,
        body: bodyCtl.text,
      );
      // optimistic update
      setState(() {
        _posts[index] = updated;
      });
      try {
        final saved = await _service.update(updated);
        if (!mounted) return;
        setState(() {
          _posts[index] = saved;
        });
        // no cache; update UI only
      } catch (e) {
        if (!mounted) return;
        // reload from server
        await _loadPosts();
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update post: $e')));
      }
    }
  }

  Future<void> _deletePost(int index) async {
    final id = _posts[index].id;
    if (id == null) {
      setState(() {
        _posts.removeAt(index);
      });
      return;
    }
    final removed = _posts[index];
    setState(() {
      _posts.removeAt(index);
    });
    try {
      await _service.delete(id);
      // no cache; update UI only
    } catch (e) {
      if (!mounted) return;
      // rollback
      setState(() {
        _posts.insert(index, removed);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: _posts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final post = _posts[index];
                  return ListTile(
                    title: Text(post.title),
                    subtitle: Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') await _showEditDialog(index);
                        if (v == 'delete') await _deletePost(index);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
