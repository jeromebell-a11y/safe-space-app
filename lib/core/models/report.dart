import 'geo_location.dart';
import 'report_category.dart';
import 'report_status.dart';

/// Firestore collection: `reports`
///
/// Represents a raw user-submitted safety report before validation.
/// Indexed on: geohash, createdAt, status, category.
class Report {
  const Report({
    required this.id,
    required this.category,
    this.notes = '',
    this.hasMedia = false,
    required this.location,
    required this.geohash,
    required this.createdAt,
    this.status = ReportStatus.pending,
    this.confidenceScore,
    required this.submittedByUid,
  });

  final String id;
  final ReportCategory category;
  final String notes;
  final bool hasMedia;
  final GeoLocation location;
  final String geohash;
  final DateTime createdAt;
  final ReportStatus status;
  final double? confidenceScore;
  final String submittedByUid;

  Report copyWith({
    ReportCategory? category,
    String? notes,
    bool? hasMedia,
    GeoLocation? location,
    String? geohash,
    ReportStatus? status,
    double? confidenceScore,
    String? submittedByUid,
  }) {
    return Report(
      id: id,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      hasMedia: hasMedia ?? this.hasMedia,
      location: location ?? this.location,
      geohash: geohash ?? this.geohash,
      createdAt: createdAt,
      status: status ?? this.status,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      submittedByUid: submittedByUid ?? this.submittedByUid,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'notes': notes,
      'hasMedia': hasMedia,
      'location': location.toMap(),
      'geohash': geohash,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
      'submittedByUid': submittedByUid,
      if (confidenceScore != null) 'confidenceScore': confidenceScore,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      category: ReportCategory.values.byName(map['category'] as String),
      notes: map['notes'] as String? ?? '',
      hasMedia: map['hasMedia'] as bool? ?? false,
      location: GeoLocation.fromMap(map['location'] as Map<String, dynamic>),
      geohash: map['geohash'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: ReportStatus.values.byName(map['status'] as String),
      confidenceScore: (map['confidenceScore'] as num?)?.toDouble(),
      submittedByUid: map['submittedByUid'] as String? ?? '',
    );
  }
}
