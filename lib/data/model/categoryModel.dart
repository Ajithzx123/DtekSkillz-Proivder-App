class CategoryModel {

  CategoryModel(
      {this.id,
      this.name,
      this.slug,
      this.parentId,
      this.parentCategoryName,
      this.categoryImage,
      this.adminCommission,
      this.status,});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    parentId = json['parent_id'];
    parentCategoryName = json['parent_category_name'];
    categoryImage = json['category_image'];
    adminCommission = json['admin_commission'];
    status = json['status'];
  }
  String? id;
  String? name;
  String? slug;
  String? parentId;
  String? parentCategoryName;
  String? categoryImage;
  String? adminCommission;
  String? status;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['parent_id'] = parentId;
    data['parent_category_name'] = parentCategoryName;
    data['category_image'] = categoryImage;
    data['admin_commission'] = adminCommission;
    data['status'] = status;
    return data;
  }
}
