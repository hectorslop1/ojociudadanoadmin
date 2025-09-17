import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/full_screen_image.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/video_player_widget.dart';

class EnhancedEvidenceGallery extends StatefulWidget {
  final List<String> evidenceUrls;
  final Report report;
  final bool showCategories;
  final bool allowDownload;

  const EnhancedEvidenceGallery({
    super.key,
    required this.evidenceUrls,
    required this.report,
    this.showCategories = true,
    this.allowDownload = true,
  });

  @override
  State<EnhancedEvidenceGallery> createState() =>
      _EnhancedEvidenceGalleryState();
}

class _EnhancedEvidenceGalleryState extends State<EnhancedEvidenceGallery>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Todas';
  List<String> _filteredEvidenceUrls = [];
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _filteredEvidenceUrls = widget.evidenceUrls;
    _tabController = TabController(
      length: _getCategories().length,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _getCategories()[_tabController.index];
        _filterEvidences();
        _selectedIndex = 0;
      });
    }
  }

  List<String> _getCategories() {
    final List<String> categories = ['Todas'];

    for (final url in widget.evidenceUrls) {
      final category = _getCategoryFromUrl(url);
      if (!categories.contains(category)) {
        categories.add(category);
      }
    }

    return categories;
  }

  String _getCategoryFromUrl(String url) {
    if (url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi')) {
      return 'Videos';
    } else if (url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png')) {
      return 'Imágenes';
    } else if (url.endsWith('.pdf')) {
      return 'Documentos';
    } else {
      return 'Otros';
    }
  }

  void _filterEvidences() {
    if (_selectedCategory == 'Todas') {
      _filteredEvidenceUrls = widget.evidenceUrls;
    } else {
      _filteredEvidenceUrls = widget.evidenceUrls
          .where((url) => _getCategoryFromUrl(url) == _selectedCategory)
          .toList();
    }
  }

  void _onEvidenceSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categorías
        if (widget.showCategories && _getCategories().length > 1) ...[
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: _getCategories().map((category) {
              return Tab(text: category);
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Vista previa grande
        if (_filteredEvidenceUrls.isNotEmpty) ...[
          SizedBox(
            height: 250,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _filteredEvidenceUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final url = _filteredEvidenceUrls[index];
                return _buildLargePreview(url);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Miniaturas
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filteredEvidenceUrls.length,
              itemBuilder: (context, index) {
                final url = _filteredEvidenceUrls[index];
                final isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () => _onEvidenceSelected(index),
                  child: Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            )
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _buildThumbnail(url),
                    ),
                  ),
                );
              },
            ),
          ),
        ] else ...[
          const Center(
            child: Text('No hay evidencias disponibles en esta categoría'),
          ),
        ],
      ],
    );
  }

  Widget _buildLargePreview(String url) {
    final isVideo =
        url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');

    return GestureDetector(
      onTap: () => _openFullScreen(url),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
            ),
            clipBehavior: Clip.antiAlias,
            child: isVideo
                ? Container(
                    color: Colors.black,
                    child: const Center(
                      child: Icon(
                        Icons.movie_outlined,
                        size: 64,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (isVideo)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
            ),
          if (widget.allowDownload)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(153),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () => _downloadEvidence(url),
                  tooltip: 'Descargar evidencia',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String url) {
    final isVideo =
        url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');

    if (isVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(
                Icons.movie_outlined,
                size: 24,
                color: Colors.white70,
              ),
            ),
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(179),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image, size: 24, color: Colors.grey),
            ),
          );
        },
      );
    }
  }

  void _openFullScreen(String url) {
    final isVideo =
        url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi');

    if (isVideo) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Text(widget.report.title),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Center(
                child: VideoPlayerWidget(videoUrl: url, report: widget.report),
              ),
            ),
          ),
        ),
      );
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => FullScreenImage(imageUrl: url)));
    }
  }

  void _downloadEvidence(String url) {
    // En una implementación real, aquí se implementaría la descarga
    // Por ahora, solo mostramos un mensaje
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descarga iniciada...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
