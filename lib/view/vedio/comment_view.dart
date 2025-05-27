import 'package:flutter/material.dart';

class CommentView extends StatefulWidget {
  const CommentView({super.key, required this.bvid});

  final String bvid;

  @override
  State<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '评论功能开发中...',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // TODO: 实现评论列表
        SliverFillRemaining(
          child: Center(
            child: Text('暂无评论'),
          ),
        ),
      ],
    );
  }
}