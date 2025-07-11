import 'package:flutter/material.dart';
import 'package:ojo_ciudadano_admin/domain/entities/report.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/full_screen_image.dart';
import 'package:ojo_ciudadano_admin/presentation/widgets/video_player_widget.dart';

class EvidenceGallery extends StatelessWidget {
  final List<String> evidenceUrls;
  final Report report;

  const EvidenceGallery({
    super.key,
    required this.evidenceUrls,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: evidenceUrls.length,
        itemBuilder: (context, index) {
          final url = evidenceUrls[index];
          final isVideo = url.endsWith('.mp4') || 
                          url.endsWith('.mov') || 
                          url.endsWith('.avi');
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                if (!isVideo) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FullScreenImage(imageUrl: url),
                    ),
                  );
                } else {
                  // Mostramos el reproductor de video en pantalla completa
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: Text(report.title),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        backgroundColor: Colors.black,
                        body: SafeArea(
                          child: Center(
                            child: VideoPlayerWidget(
                              videoUrl: url,
                              report: report,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isVideo
                      ? Container(
                          width: 120,
                          height: 120,
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.movie_outlined,
                              size: 40,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : Image.network(
                          url,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Error cargando imagen - se muestra fallback
                            return Container(
                              width: 120,
                              height: 120,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                  if (isVideo)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withAlpha(179), // 0.7 opacity
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(179),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(179),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'VIDEO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
