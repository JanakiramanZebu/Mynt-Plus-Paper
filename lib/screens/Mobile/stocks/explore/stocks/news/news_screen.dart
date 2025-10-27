import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../../res/res.dart';
import '../../../../../../provider/stocks_provider.dart';
import '../../../../../../provider/thems.dart';
import '../../../../../../res/global_state_text.dart';
import '../../../../../../routes/route_names.dart';
import '../../../../../../sharedWidget/list_divider.dart';
import '../../../../../../sharedWidget/no_data_found.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNews();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(stocksProvide).getNews();
    } catch (e) {
      print('Error fetching news: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stocksProvider = ref.watch(stocksProvide);
    final news = stocksProvider.newsModel?.data;
    final theme = ref.watch(themeProvider);
    
    return Container(
      color: theme.isDarkMode ? Colors.grey[900] : const Color(0xffFFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? Colors.grey[850] : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: theme.isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.subText(
                  text: "Market News",
                  theme: false,
                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  fw: 2,
                ),
                if (!_isLoading)
                  GestureDetector(
                    onTap: _fetchNews,
                    child: Icon(
                      Icons.refresh,
                      color: theme.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          
          // Content Section
          Expanded(
            child: _buildContent(news, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(dynamic news, dynamic theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (news == null || news.isEmpty) {
      return const Center(
        child: NoDataFound(),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNews,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: news.length,
        itemBuilder: (context, index) {
          return _buildNewsItem(news[index], theme, index == news.length - 1);
        },
      ),
    );
  }

  Widget _buildNewsItem(dynamic newsItem, dynamic theme, bool isLast) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final Uri url = Uri.parse("${newsItem.link}");
          if (!await launchUrl(url)) {
            throw Exception('Could not launch $url');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.isDarkMode ? Colors.grey[850] : Colors.white,
            border: !isLast ? Border(
              bottom: BorderSide(
                color: theme.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                width: 1,
              ),
            ) : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.isDarkMode ? Colors.grey[700] : Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: newsItem.image != null && newsItem.image != "None"
                      ? Image.network(
                          "${newsItem.image}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholder(theme);
                          },
                        )
                      : _buildPlaceholder(theme),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "${newsItem.title}",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.isDarkMode 
                            ? colors.textPrimaryDark 
                            : colors.textPrimaryLight,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Date and Source Row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatDate("${newsItem.pubDate}"),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: theme.isDarkMode 
                                  ? colors.textSecondaryDark 
                                  : colors.textSecondaryLight,
                            ),
                          ),
                        ),
                        
                        // Read more indicator
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: theme.isDarkMode 
                              ? Colors.grey[500] 
                              : Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(dynamic theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? Colors.grey[700] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "MYNT",
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return "${difference.inDays}d ago";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h ago";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m ago";
      } else {
        return "Just now";
      }
    } catch (e) {
      return dateString;
    }
  }
}
