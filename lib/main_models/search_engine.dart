class SearchEngine {
  String? id;
  dynamic query;
  dynamic data;
  int? currentPage;
  int limit, total = 1;
  int maxPages = 1;
  bool isLoading = true;
  bool isUpdate;
  SearchEngine(
      {this.query,
      this.data,
      this.id,
      this.isUpdate = false,
      this.isLoading = true,
      this.currentPage = 0,
      this.total = 0,
      this.limit = 10});

  updateCurrentPage(int page) => currentPage = page;

  toJson() {
    Map data = {};
    data["id"] = id;
    data["query"] = query;
    data["current_page"] = currentPage;
    return data;
  }

  Map<String, dynamic> toPage() {
    return {
      "limit": limit,
      "view": currentPage,
    };
  }
}
