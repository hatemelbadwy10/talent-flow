import 'dart:io';

class WorkItem {
  const WorkItem({
    required this.title,
    required this.description,
    required this.date,
    this.previewLink,
    this.image,
    this.files,
  });

  final String title;
  final String description;
  final String date;
  final String? previewLink;
  final File? image;
  final List<File>? files;
}
