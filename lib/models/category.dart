import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category{
  final int id;
  final String name;
  final dynamic icon;
  Category(this.id, this.name, {this.icon});

}

final List<Category> categories = [
  Category(9,"Quan hệ giữa con người"),
  Category(10,"Cuộc sống"),
  Category(11,"Ở nhà"),
  Category(12,"Ở trường"),
  Category(13,"Ở công ty"),
  Category(14,"Tìm việc"),
  Category(15,"Sức khoẻ"),
  Category(16,"Sở thích"),
  Category(17,"Thế giới"),
  Category(18,"Thiên Nhiên"),
  Category(19,"Tình trạng"),
  Category(20,"Tai nạn"),
  Category(21,"Xã hội"),
  Category(22,"kinh tế"),
  Category(23,"Chính trị"),
  Category(24,"Doanh nghiệp"),
  Category(25,"Công việc"),
  Category(26,"Phố thị"),
  Category(27,"Công cộng"),
  Category(28,"Giao thông" ),
  Category(29,"Công nghiệp"),
  Category(30,"Quê nhà", icon: FontAwesomeIcons.mobileAlt),
  
];