class ServiceCategoryModel {

  ServiceCategoryModel(
      {this.id,
      this.name,
      this.slug,
      this.parentId,
      this.parentCategoryName,
      this.categoryImage,});

  ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    parentId = json['parent_id'];
    parentCategoryName = json['parent_category_name'];
    categoryImage = json['category_image'];
  }
  String? id;
  String? name;
  String? slug;
  String? parentId;
  String? parentCategoryName;
  String? categoryImage;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['parent_id'] = parentId;
    data['parent_category_name'] = parentCategoryName;
    data['category_image'] = categoryImage;
    return data;
  }
}
