import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/dairy_theme.dart';
import '../l10n/app_localizations.dart';
import '../services/link_service.dart';
import '../blocs/app_cubit.dart';
import '../data/state_advisories.dart';
import '../data/farming_advisories.dart';
import '../services/news_service.dart';
import '../db/dao/news_dao.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FlutterTts _flutterTts;
  final NewsService _newsService = NewsService();
  final NewsDao _newsDao = NewsDao();

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, String>> _allLiveNews = [];
  List<Map<String, String>> _savedNews = [];
  Set<String> _savedLinks = {};

  int? _speakingIndex;
  bool _isSpeaking = false;

  // Search & Filter state for Live News
  String _newsSearchQuery = '';
  String _selectedNewsCategory = 'all';

  // Category Filter for Offline Advisories
  String _selectedAdvisoryCategory = 'all';

  String _t(String k) => AppLocalizations.get(context, k);
  bool get _isHi => AppLocalizations.isHindiLike(context);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _flutterTts.stop();
        if (mounted) {
          setState(() {
            _isSpeaking = false;
            _speakingIndex = null;
          });
        }
      }
    });
    _initTts();
    _loadNewsData();
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setSpeechRate(0.55);
    _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() { _isSpeaking = false; _speakingIndex = null; });
    });

    _flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() { _isSpeaking = false; _speakingIndex = null; });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _loadNewsData() async {
    await _fetchLiveNews();
    await _loadSavedNews();
  }

  Future<void> _fetchLiveNews() async {
    if (mounted) setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final news = await _newsService.fetchAllNews();
      if (mounted) {
        setState(() {
          _allLiveNews = news;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_allLiveNews.isEmpty) {
            _errorMessage = _t('newsLoadErr');
          } else {
            _errorMessage = null;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('पुरानी खबरें दिख रही हैं (ऑफलाइन)'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }
  }

  Future<void> _loadSavedNews() async {
    final saved = await _newsDao.getSavedNews();
    final links = saved.map((e) => e['link'] ?? '').toSet();
    if (mounted) {
      setState(() {
        _savedNews = saved;
        _savedLinks = links;
      });
    }
  }

  Future<void> _toggleBookmark(Map<String, String> item) async {
    final isSaved = await _newsDao.toggleSaveNews(item);
    await _loadSavedNews();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSaved ? _t('newsSavedAlert') : _t('newsRemovedAlert')),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _speakNews(String text, int index) async {
    if (_isSpeaking && _speakingIndex == index) {
      await _flutterTts.stop();
      if (mounted) setState(() { _isSpeaking = false; _speakingIndex = null; });
      return;
    }

    await _flutterTts.stop();
    if (mounted) setState(() { _speakingIndex = index; _isSpeaking = true; });

    await _flutterTts.setLanguage(_isHi ? 'hi-IN' : 'en-IN');
    await _flutterTts.speak(text);
  }

  Future<void> _openNewsLink(String urlStr) async {
    // canLaunchUrl जान-बूझकर नहीं — Android 11+ पर वह भरोसेमंद नहीं।
    // LinkService सीधे खोलता है और न चले तो साफ़ संदेश दिखाता है।
    await LinkService.openUrl(context, urlStr, errorMsg: _t('newsOpenErr'));
  }

  void _shareNews(String title, String url) {
    final shareMsg = _isHi
        ? "📰 *खेती समाचार (Pro Kisan)*\n\n$title\n\nपूरी खबर पढ़ने के लिए लिंक पर क्लिक करें:\n$url\n\n🚜 *प्रो किसान ऐप*"
        : "📰 *Agri News (Pro Kisan)*\n\n$title\n\nClick link to read full story:\n$url\n\n🚜 *Pro Kisan App*";
    Share.share(shareMsg);
  }

  // Filter Live News List based on Search Query & Category
  List<Map<String, String>> _getFilteredLiveNews() {
    return _allLiveNews.where((item) {
      final q = _newsSearchQuery.trim().toLowerCase();
      final title = (item['title'] ?? '').toLowerCase();
      final desc = (item['desc'] ?? '').toLowerCase();
      final matchesSearch = q.isEmpty || title.contains(q) || desc.contains(q);

      final cat = item['category'] ?? 'all';
      final matchesCat = _selectedNewsCategory == 'all' || cat == _selectedNewsCategory;

      return matchesSearch && matchesCat;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('moreNews')),
        backgroundColor: DairyTheme.primaryTeal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          // ⚠️ इनके बिना चुने हुए tab का text हरे AppBar पर हरा/गहरा आता था
          // और छुप जाता था। अब चुना = सफ़ेद, बाक़ी = हल्का सफ़ेद।
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontSize: 14),
          tabs: [
            Tab(text: _t('newsLiveTab')),
            Tab(text: _t('newsSavedTab')),
            Tab(text: _t('newsAdvisoryTab')),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLiveNewsTab(),
            _buildSavedNewsTab(),
            _buildAdvisoryTab(),
          ],
        ),
      ),
    );
  }

  // ── 1. Live News Tab ──────────────────────────────────────────────────
  Widget _buildLiveNewsTab() {
    final filtered = _getFilteredLiveNews();

    return Column(
      children: [
        // Search & Category Bar Header
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              // Search Field
              TextField(
                onChanged: (v) => setState(() => _newsSearchQuery = v),
                decoration: InputDecoration(
                  hintText: _t('searchNewsHint'),
                  prefixIcon: const Icon(Icons.search_rounded, color: DairyTheme.primaryTeal),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _newsCatChip('all', _t('catAllNews')),
                    _newsCatChip('schemes', _t('catSchemes')),
                    _newsCatChip('mandi_price', _t('catMandi')),
                    _newsCatChip('weather_alert', _t('catWeather')),
                    _newsCatChip('tech_innovation', _t('catTech')),
                    _newsCatChip('livestock_dairy', _t('catLivestock')),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Live News List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_errorMessage != null && _allLiveNews.isEmpty)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchLiveNews,
                              style: ElevatedButton.styleFrom(backgroundColor: DairyTheme.primaryTeal, foregroundColor: Colors.white),
                              child: Text(_t('tryAgain')),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchLiveNews,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _t('newsSourceDisclaimer'),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                              ),
                            );
                          }
                          final item = filtered[index - 1];
                          final isCurrentlySpeaking = _speakingIndex == (index - 1) && _isSpeaking;
                          final isSaved = _savedLinks.contains(item['link'] ?? '');

                          return _buildNewsCard(item, index - 1, isCurrentlySpeaking, isSaved);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _newsCatChip(String catKey, String label) {
    final selected = _selectedNewsCategory == catKey;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.grey.shade800)),
        selected: selected,
        selectedColor: DairyTheme.primaryTeal,
        backgroundColor: Colors.white,
        showCheckmark: false,
        onSelected: (val) {
          if (val) setState(() => _selectedNewsCategory = catKey);
        },
      ),
    );
  }

  Widget _buildNewsCard(Map<String, String> item, int index, bool isCurrentlySpeaking, bool isSaved) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image'] != null && item['image']!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item['image']!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['source'] ?? _t('newsBadge'),
                    style: TextStyle(color: Colors.green.shade800, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      item['date'] ?? '',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isSaved ? Colors.green.shade700 : Colors.grey,
                        size: 22,
                      ),
                      onPressed: () => _toggleBookmark(item),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['title'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
            ),
            const SizedBox(height: 6),
            Text(
              item['desc'] ?? '',
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
            ),
            const Divider(height: 24),
            Row(
              children: [
                // Speak Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _speakNews('${item['title']}। ${item['fullDesc']}', index),
                    icon: Icon(
                      isCurrentlySpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                      size: 16,
                    ),
                    label: Text(
                      isCurrentlySpeaking ? _t('yStop') : _t('ySpeak'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isCurrentlySpeaking ? Colors.red : DairyTheme.primaryTeal,
                      side: BorderSide(color: isCurrentlySpeaking ? Colors.red : DairyTheme.primaryTeal),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Share Button
                IconButton(
                  icon: const Icon(Icons.share_rounded, color: Colors.green, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed: () => _shareNews(item['title'] ?? '', item['link'] ?? ''),
                  tooltip: _t('newsShareTooltip'),
                ),
                const SizedBox(width: 8),
                // Read full button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _openNewsLink(item['link'] ?? ''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DairyTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(_t('newsReadFull'), style: const TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Saved News Tab ─────────────────────────────────────────────────
  Widget _buildSavedNewsTab() {
    if (_savedNews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 14),
              Text(_t('newsNoSaved'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_t('newsNoSavedHint'), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _savedNews.length,
      itemBuilder: (context, index) {
        final item = _savedNews[index];
        final isCurrentlySpeaking = _speakingIndex == index && _isSpeaking;
        return _buildNewsCard(item, index, isCurrentlySpeaking, true);
      },
    );
  }

  // ── 3. Farm Advisory Tab ──────────────────────────────────────────────
  Widget _buildAdvisoryTab() {
    final stateCode = context.watch<AppCubit>().state.stateCode;
    final filteredAdvisories = _getFilteredAndSortedAdvisories(_selectedAdvisoryCategory, stateCode);

    return Column(
      children: [
        // Advisory Category Chips
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: Colors.green.shade50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _advFilterChip('all', _isHi ? 'सारे सुझाव' : 'All Tips'),
                _advFilterChip('organic', _isHi ? '🌱 जैविक' : '🌱 Organic'),
                _advFilterChip('soil', _isHi ? '🧪 मिट्टी' : '🧪 Soil'),
                _advFilterChip('crop_mgmt', _isHi ? '🌾 फसल' : '🌾 Crop'),
                _advFilterChip('irrigation', _isHi ? '💧 सिंचाई' : '💧 Irrigation'),
                _advFilterChip('pest', _isHi ? '🐛 कीट' : '🐛 Pest'),
                _advFilterChip('vegetable', _isHi ? '🥬 सब्जी' : '🥬 Vegetable'),
                _advFilterChip('fruit', _isHi ? '🍌 फल' : '🍌 Fruit'),
                _advFilterChip('spice', _isHi ? '🌿 मसाला' : '🌿 Spice'),
                _advFilterChip('livestock', _isHi ? '🐄 पशुपालन' : '🐄 Livestock'),
                _advFilterChip('subsidy', _isHi ? '💰 सब्सिडी' : '💰 Subsidy'),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredAdvisories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade200, width: 0.5),
                  ),
                  child: Text(
                    _isHi
                        ? "📍 आपके राज्य ($stateCode) के अनुकूल सलाह और जैविक खेती को प्राथमिकता दी गई है।"
                        : "📍 Advisories suited for your state ($stateCode) & organic tips are prioritized.",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                  ),
                );
              }

              final adv = filteredAdvisories[index - 1];
              final isCurrentlySpeaking = _speakingIndex == (1000 + index - 1) && _isSpeaking;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isHi ? adv.titleHi : adv.titleEn,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.3),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isHi ? adv.detailHi : adv.detailEn,
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => _speakNews(
                            '${_isHi ? adv.titleHi : adv.titleEn}। ${_isHi ? adv.detailHi : adv.detailEn}',
                            1000 + index - 1,
                          ),
                          icon: Icon(
                            isCurrentlySpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                            size: 16,
                          ),
                          label: Text(
                            isCurrentlySpeaking ? _t('yStop') : _t('newsListenAdvisory'),
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isCurrentlySpeaking ? Colors.red : DairyTheme.primaryTeal,
                            side: BorderSide(color: isCurrentlySpeaking ? Colors.red : DairyTheme.primaryTeal),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _advFilterChip(String catKey, String label) {
    final selected = _selectedAdvisoryCategory == catKey;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.teal.shade900)),
        selected: selected,
        selectedColor: DairyTheme.primaryTeal,
        backgroundColor: Colors.white,
        showCheckmark: false,
        onSelected: (val) {
          if (val) setState(() => _selectedAdvisoryCategory = catKey);
        },
      ),
    );
  }

  List<FarmingAdvisory> _getFilteredAndSortedAdvisories(String selectedCat, String stateCode) {
    var list = kFarmingAdvisories.toList();
    if (selectedCat != 'all') {
      list = list.where((a) => a.category == selectedCat).toList();
    }
    final primaryCrops = kStatePrimaryCrops[stateCode] ?? [];

    list.sort((a, b) {
      bool aOrganic = a.category == 'organic';
      bool bOrganic = b.category == 'organic';
      if (aOrganic && !bOrganic) return -1;
      if (!aOrganic && bOrganic) return 1;

      bool aMatch = a.applicableCrops.any((c) => primaryCrops.contains(c));
      bool bMatch = b.applicableCrops.any((c) => primaryCrops.contains(c));
      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;

      return 0;
    });

    return list;
  }
}
