class ChatUsers {
  final String name;
  final String message;
  final String imageUrl;
  final String time;

  ChatUsers(
      {required this.name,
      required this.message,
      required this.imageUrl,
      required this.time});
  static List<ChatUsers> chatUsers = [
    ChatUsers(
        name: "Heathcare AI",
        message: "Tôi có thể giúp gì cho bạn",
        imageUrl: "https://cdn.dribbble.com/userupload/2798815/file/original-d8b75e59492e979ad996c39eac216499.png?resize=300x",
        time: "8:00"),
    // ChatUsers(
    //     name: "Nguyễn Văn B",
    //     message: "ok",
    //     imageUrl: "https://picsum.photos/250?image=665",
    //     time: "Thứ Bảy"),
    // ChatUsers(
    //     name: "Nguyễn Văn C",
    //     message: "ok",
    //     imageUrl: "https://picsum.photos/250?image=669",
    //     time: "Thứ Tư"),
    // ChatUsers(
    //     name: "Nguyễn Văn D",
    //     message: "Bạn: Ok",
    //     imageUrl: "https://picsum.photos/250?image=64",
    //     time: "1/3/2024")
  ];
}
