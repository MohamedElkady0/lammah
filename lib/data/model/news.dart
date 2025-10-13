enum Category {
  general,
  sport,
  entertainment,
  science,
  technology,
  business,
  health,
  lifestyle,
}

class News {
  String? title;
  String? description;
  String? image;
  String? url;
  String? date;
  String? source;
  Category? category;

  News({
    this.title,
    this.description,
    this.image,
    this.url,
    this.date,
    this.source,
    this.category,
  });

  News.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    image = json['image'];
    url = json['url'];
    date = json['date'];
    source = json['source'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['image'] = image;
    data['url'] = url;
    data['date'] = date;
    data['source'] = source;
    data['category'] = category;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is News &&
        other.title == title &&
        other.description == description &&
        other.image == image &&
        other.url == url &&
        other.date == date &&
        other.source == source &&
        other.category == category;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        image.hashCode ^
        url.hashCode ^
        date.hashCode ^
        source.hashCode ^
        category.hashCode;
  }

  @override
  String toString() {
    return 'News(title: $title, description: $description, image: $image, url: $url, date: $date, source: $source, category: $category)';
  }

  copyWith({
    String? title,
    String? description,
    String? image,
    String? url,
    String? date,
    String? source,
    Category? category,
  }) {
    return News(
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      url: url ?? this.url,
      date: date ?? this.date,
      source: source ?? this.source,
      category: category ?? this.category,
    );
  }
}
