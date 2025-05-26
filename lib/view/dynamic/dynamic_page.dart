import 'package:blbl/model/dynamic_model.dart';
import 'package:blbl/service/dynamic_service.dart';
import 'package:flutter/material.dart';

import 'dynamic_item_widget.dart';

class DynamicPage extends StatefulWidget {
  const DynamicPage({super.key});

  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
  final List<DynamicItem> _dynamicList = [];
  List<DynamicItem> _filteredDynamicList = []; // 新增：过滤后的动态列表
  List<FrequentUser> _frequentUsers = [];
  bool _isLoading = false;
  String? _nextOffset;
  int? _selectedUserId;
  DynamicType? _selectedTypeFilter;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    // 新增：添加滚动监听器
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // 新增：移除滚动监听器并释放控制器
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 新增：滚动监听处理函数
  void _onScroll() {
    // 检查是否滚动到列表底部
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 如果不是正在加载中，并且还有下一页数据，则加载更多
      if (!_isLoading && _nextOffset != null) {
        _loadData();
      }
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载最常访问用户
      final users = await DynamicService.getFrequentUsers();
      setState(() {
        _frequentUsers = users;
      });

      // 加载动态列表
      String apiType = 'all';
      if (_selectedTypeFilter != null) {
        apiType = _selectedTypeFilter!.toString().split('.').last;
      }

      final response = await DynamicService.getFollowedDynamics(
        offset: _nextOffset,
        type: apiType,
      );
      setState(() {
        _dynamicList.addAll(response.data.items);
        _nextOffset = response.data.offset;
        _applyFilters(); // 数据加载完成后应用当前过滤器
      });
    } catch (e) {
      // 处理错误
      print('加载数据失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterDynamicsByUser(int? userId) {
    setState(() {
      _selectedUserId = userId;
      // 根据选中的用户ID过滤动态列表
      _applyFilters();
    });
  }

  // 新增：根据动态类型过滤动态列表
  void _filterDynamicsByType(DynamicType? type) {
    setState(() {
      _selectedTypeFilter = type;
      // 根据选中的动态类型过滤动态列表
      _applyFilters();
    });
  }

  // 新增：应用当前的用户和类型过滤器
  void _applyFilters() {
    Iterable<DynamicItem> filtered = _dynamicList;

    // 按用户过滤
    if (_selectedUserId != null) {
      filtered = filtered
          .where((item) => item.modules.moduleAuthor.mid == _selectedUserId);
    }

    // 按类型过滤
    if (_selectedTypeFilter != null) {
      filtered = filtered.where((item) => item.type == _selectedTypeFilter);
    }

    _filteredDynamicList = filtered.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关注'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: 实现发布动态功能
            },
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController, // 将滚动控制器关联到CustomScrollView
        slivers: [
          // 动态类型筛选标签
          SliverToBoxAdapter(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('全部', null), // 全部类型
                  _buildFilterChip('视频', DynamicType.video), // 视频类型
                  _buildFilterChip('图文', DynamicType.draw), // 图文类型
                  _buildFilterChip('文字', DynamicType.word), // 文字类型
                  _buildFilterChip('转发', DynamicType.forward), // 转发类型
                  _buildFilterChip('直播', DynamicType.live), // 直播类型
                  _buildFilterChip('专栏', DynamicType.article), // 专栏类型
                ],
              ),
            ),
          ),
          // 最常访问用户列表
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _frequentUsers.length,
                itemBuilder: (context, index) {
                  final user = _frequentUsers[index];
                  return GestureDetector(
                    onTap: () {
                      // TODO 筛选指定用户动态
                      // _filterDynamicsByUser(user.mid);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(user.face),
                          ),
                          const SizedBox(height: 4.0),
                          Text(user.name),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // 动态列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dynamicItem = _filteredDynamicList[index]; // 使用过滤后的列表
                return DynamicItemWidget(dynamicItem: dynamicItem);
              },
              childCount: _filteredDynamicList.length, // 使用过滤后的列表长度
            ),
          ),
          // 加载更多指示器
          if (_isLoading) // 只有在加载更多时显示指示器
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

// 构建筛选标签Chip
  Widget _buildFilterChip(String label, DynamicType? type) {
    final isSelected = _selectedTypeFilter == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _filterDynamicsByType(type);
          }
        },
      ),
    );
  }
}
