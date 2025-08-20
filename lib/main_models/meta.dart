class Meta {
  int? currentPage;
  int? pagesCount;
  int? total;
  int? limit;

  Meta({this.currentPage, this.pagesCount, this.total, this.limit});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    pagesCount = json['last_page'];
    total = json['total'];
    limit = int.tryParse(json['per_page']?.toString() ?? "0");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = pagesCount;
    data['per_page'] = limit;
    data['total'] = total;
    return data;
  }
}
