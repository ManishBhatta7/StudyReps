// Mock Video Data for Physics Force Chapter
// Ready for NotebookLM-generated audio/video integration

import '../../domain/models/video_model.dart';

/// Mock videos for the Force chapter
/// In production, URLs would point to NotebookLM-generated content
class ForceChapterVideos {
  
  /// All videos for the Force chapter
  static List<VideoModel> getVideos() => [];

  /// Get a subset for different difficulty levels
  static List<VideoModel> getBeginnerVideos() => 
      getVideos().where((v) => ['physics_force_intro', 'physics_momentum', 'physics_equilibrium'].contains(v.id)).toList();
  
  static List<VideoModel> getIntermediateVideos() =>
      getVideos().where((v) => ['physics_newton_first', 'physics_newton_third', 'physics_cog'].contains(v.id)).toList();
  
  static List<VideoModel> getAdvancedVideos() =>
      getVideos().where((v) => ['physics_newton_second', 'physics_equations_motion', 'physics_torque', 'physics_circular_motion'].contains(v.id)).toList();
}

/// Helper to integrate with existing mock data provider
extension ForceChapterExtension on List<VideoModel> {
  /// Add Force chapter videos to existing list
  List<VideoModel> withForceChapter() => [...this, ...ForceChapterVideos.getVideos()];
}
