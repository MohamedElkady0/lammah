class Question {
  String? id;
  String? question;
  String? createdAt;
  String? updatedAt;
  bool? isDeleted;
  int? senderStatus;
  int? receiverStatus;
  String? receiverId;
  String? receiverName;
  String? receiverImage;

  Question({
    this.id,
    this.question,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.senderStatus,
    this.receiverStatus,
    this.receiverId,
    this.receiverName,
    this.receiverImage,
  });

  Question.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDeleted = json['isDeleted'];
    senderStatus = json['senderStatus'];
    receiverStatus = json['receiverStatus'];
    receiverId = json['receiverId'];
    receiverName = json['receiverName'];
    receiverImage = json['receiverImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['isDeleted'] = isDeleted;
    data['senderStatus'] = senderStatus;
    data['receiverStatus'] = receiverStatus;
    data['receiverId'] = receiverId;
    data['receiverName'] = receiverName;
    data['receiverImage'] = receiverImage;
    return data;
  }

  @override
  String toString() {
    return 'Question{id: $id, question: $question, createdAt: $createdAt, updatedAt: $updatedAt, isDeleted: $isDeleted, senderStatus: $senderStatus, receiverStatus: $receiverStatus, receiverId: $receiverId, receiverName: $receiverName, receiverImage: $receiverImage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Question &&
        id == other.id &&
        question == other.question &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        isDeleted == other.isDeleted &&
        senderStatus == other.senderStatus &&
        receiverStatus == other.receiverStatus &&
        receiverId == other.receiverId &&
        receiverName == other.receiverName &&
        receiverImage == other.receiverImage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        question.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isDeleted.hashCode ^
        senderStatus.hashCode ^
        receiverStatus.hashCode ^
        receiverId.hashCode ^
        receiverName.hashCode ^
        receiverImage.hashCode;
  }

  static List<Question> fromJsonList(List<dynamic> json) {
    List<Question> questionList = [];
    for (var i = 0; i < json.length; i++) {
      questionList.add(Question.fromJson(json[i]));
    }
    return questionList;
  }

  copyWith({
    String? id,
    String? question,
    String? createdAt,
    String? updatedAt,
    bool? isDeleted,
    int? senderStatus,
    int? receiverStatus,
    String? receiverId,
    String? receiverName,
    String? receiverImage,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      senderStatus: senderStatus ?? this.senderStatus,
      receiverStatus: receiverStatus ?? this.receiverStatus,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverImage: receiverImage ?? this.receiverImage,
    );
  }
}
