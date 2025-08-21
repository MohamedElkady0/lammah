import 'package:flutter/material.dart';
import 'package:lammah/fetcher/data/model/comment.dart';
import 'package:lammah/fetcher/data/model/question.dart';
import 'package:lammah/fetcher/data/model/user_message.dart';

enum StoriesCategory {
  news,
  sports,
  entertainment,
  technology,
  health,
  business,
  education,
  lifestyle,
}

class StoriesPoint {
  String? id;
  String? title;
  String? description;
  String? logo;
  String? images;
  List<String>? tags;
  int? likes;
  Comment? comments;
  int? shares;
  int? views;
  bool? isLiked;
  bool? isCommented;
  bool? isShared;
  bool? isViewed;
  int? countBuyers;
  Map<String, dynamic>? table;
  double? rating;
  StoriesCategory? category;
  UserMessage? message;
  Question? question; // object
  double? price;
  double? discount;
  double? total;
  Color? color;
  int? size;
  String? seller;
  int? quantity;
  int? sellerId;
  int? buyerId;
  String? overview;
  int? orderId;
  bool? isSold;
  bool? isBuyer;
  bool? isSeller;
  int? soldCount;
  double? importDuties;

  StoriesPoint({
    this.id,
    this.title,
    this.description,
    this.images,
    this.likes,
    this.comments,
    this.shares,
    this.views,
    this.isLiked,
    this.isCommented,
    this.isShared,
    this.tags,
    this.logo,
    this.isViewed,
    this.countBuyers,
    this.table,
    this.rating,
    this.category,
    this.message,
    this.question,
    this.price,
    this.discount,
    this.total,
    this.color,
    this.size,
    this.seller,
    this.quantity,
    this.sellerId,
    this.buyerId,
    this.overview,
    this.orderId,
    this.isSold,
    this.isBuyer,
    this.isSeller,
    this.soldCount,
    this.importDuties,
  });

  StoriesPoint.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    images = json['images'];
    likes = json['likes'];
    comments = json['comments'];
    shares = json['shares'];
    views = json['views'];
    isLiked = json['isLiked'];
    isCommented = json['isCommented'];
    isShared = json['isShared'];
    logo = json['logo'];
    tags = json['tags'] != null ? List<String>.from(json['tags']) : null;
    isViewed = json['isViewed'];
    countBuyers = json['countBuyers'];
    table = json['table'];
    rating = json['rating'];
    category = json['category'];
    message = json['message'];
    question = json['question'];
    price = json['price'];
    discount = json['discount'];
    total = json['total'];
    color = json['color'];
    size = json['size'];
    seller = json['seller'];
    quantity = json['quantity'];
    sellerId = json['sellerId'];
    buyerId = json['buyerId'];
    overview = json['overview'];
    orderId = json['orderId'];
    isSold = json['isSold'];
    isBuyer = json['isBuyer'];
    isSeller = json['isSeller'];
    soldCount = json['soldCount'];
    importDuties = json['importDuties'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['images'] = images;
    data['likes'] = likes;
    data['comments'] = comments?.toJson();
    data['shares'] = shares;
    data['views'] = views;
    data['isLiked'] = isLiked;
    data['isCommented'] = isCommented;
    data['isShared'] = isShared;
    data['logo'] = logo;
    if (tags != null) {
      data['tags'] = tags;
    }
    data['isViewed'] = isViewed;
    data['countBuyers'] = countBuyers;
    data['table'] = table;
    data['rating'] = rating;
    data['category'] = category;
    data['message'] = message?.toJson();
    data['question'] = question?.toJson();
    data['price'] = price;
    data['discount'] = discount;
    data['total'] = total;
    data['color'] = color;
    data['size'] = size;
    data['seller'] = seller;
    data['quantity'] = quantity;
    data['sellerId'] = sellerId;
    data['buyerId'] = buyerId;
    data['overview'] = overview;
    data['orderId'] = orderId;
    data['isSold'] = isSold;
    data['isBuyer'] = isBuyer;
    data['isSeller'] = isSeller;
    data['soldCount'] = soldCount;
    data['importDuties'] = importDuties;
    return data;
  }

  @override
  String toString() {
    return 'StoriesPoint{id: $id, title: $title, description: $description, images: $images, likes: $likes, comments: $comments, shares: $shares, views: $views, isLiked: $isLiked, isCommented: $isCommented, isShared: $isShared, isViewed: $isViewed isSold: $isSold isBuyer: $isBuyer isSeller: $isSeller soldCount: $soldCount importDuties: $importDuties logo: $logo, tags: $tags, countBuyers: $countBuyers, table: $table, rating: $rating, category: $category, message: $message, question: $question, price: $price, discount: $discount, total: $total, color: $color, size: $size, seller: $seller, quantity: $quantity, sellerId: $sellerId, buyerId: $buyerId, overview: $overview, orderId: $orderId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoriesPoint &&
        id == other.id &&
        title == other.title &&
        description == other.description &&
        images == other.images &&
        likes == other.likes &&
        comments == other.comments &&
        shares == other.shares &&
        views == other.views &&
        isLiked == other.isLiked &&
        isCommented == other.isCommented &&
        isShared == other.isShared &&
        logo == other.logo &&
        tags == other.tags &&
        isViewed == other.isViewed &&
        countBuyers == other.countBuyers &&
        table == other.table &&
        rating == other.rating &&
        category == other.category &&
        message == other.message &&
        question == other.question &&
        price == other.price &&
        discount == other.discount &&
        total == other.total &&
        color == other.color &&
        size == other.size &&
        seller == other.seller &&
        quantity == other.quantity &&
        sellerId == other.sellerId &&
        buyerId == other.buyerId &&
        overview == other.overview &&
        orderId == other.orderId &&
        isSold == other.isSold &&
        isBuyer == other.isBuyer &&
        isSeller == other.isSeller &&
        soldCount == other.soldCount &&
        importDuties == other.importDuties;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        images.hashCode ^
        likes.hashCode ^
        comments.hashCode ^
        shares.hashCode ^
        views.hashCode ^
        isLiked.hashCode ^
        isCommented.hashCode ^
        isShared.hashCode ^
        logo.hashCode ^
        (tags?.hashCode ?? 0) ^
        isViewed.hashCode ^
        countBuyers.hashCode ^
        table.hashCode ^
        rating.hashCode ^
        category.hashCode ^
        message.hashCode ^
        question.hashCode ^
        price.hashCode ^
        discount.hashCode ^
        total.hashCode ^
        color.hashCode ^
        size.hashCode ^
        seller.hashCode ^
        quantity.hashCode ^
        sellerId.hashCode ^
        buyerId.hashCode ^
        overview.hashCode ^
        orderId.hashCode ^
        isSold.hashCode ^
        isBuyer.hashCode ^
        isSeller.hashCode ^
        soldCount.hashCode ^
        importDuties.hashCode;
  }

  static List<StoriesPoint> fromJsonList(List<dynamic> json) {
    List<StoriesPoint> storiesPointList = [];
    for (var i = 0; i < json.length; i++) {
      storiesPointList.add(StoriesPoint.fromJson(json[i]));
    }
    return storiesPointList;
  }

  copyWith({
    String? id,
    String? title,
    String? description,
    String? images,
    int? likes,
    Comment? comments,
    int? shares,
    int? views,
    bool? isLiked,
    bool? isCommented,
    bool? isShared,
    bool? isViewed,
    List<String>? tags,
    String? logo,
    int? countBuyers,
    Map<String, dynamic>? table,
    double? rating,
    StoriesCategory? category,
    UserMessage? message,
    Question? question,
    double? price,
    double? discount,
    double? total,
    Color? color,
    int? size,
    String? seller,
    int? quantity,
    int? sellerId,
    int? buyerId,
    String? overview,
    int? orderId,
    bool? isSold,
    bool? isBuyer,
    bool? isSeller,
    int? soldCount,
    double? importDuties,
  }) {
    return StoriesPoint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      isLiked: isLiked ?? this.isLiked,
      isCommented: isCommented ?? this.isCommented,
      isShared: isShared ?? this.isShared,
      isViewed: isViewed ?? this.isViewed,
      tags: tags ?? this.tags,
      logo: logo ?? this.logo,
      countBuyers: countBuyers ?? this.countBuyers,
      table: table ?? this.table,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      message: message ?? this.message,
      question: question ?? this.question,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      color: color ?? this.color,
      size: size ?? this.size,
      seller: seller ?? this.seller,
      quantity: quantity ?? this.quantity,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      overview: overview ?? this.overview,
      orderId: orderId ?? this.orderId,
      isSold: isSold ?? this.isSold,
      isBuyer: isBuyer ?? this.isBuyer,
      isSeller: isSeller ?? this.isSeller,
      soldCount: soldCount ?? this.soldCount,
      importDuties: importDuties ?? this.importDuties,
    );
  }
}
