class Item{
  String objectId;
  String title;
  bool done;

  Item({this.title,this.done, this.objectId});

  Item.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    title = json['title'];
    done = json['done'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['objectId'] = this.objectId;
    data['title'] = this.title;
    data['done'] = this.done;
    return data;
  }
}