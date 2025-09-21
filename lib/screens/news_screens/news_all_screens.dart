import 'package:fmecg_mobile/constants/color_constant.dart';
import 'package:fmecg_mobile/controllers/news_controller.dart';
import 'package:fmecg_mobile/providers/news_provider.dart';
import 'package:fmecg_mobile/screens/news_screens/news_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NewsAllScreen extends StatelessWidget {
  const NewsAllScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List allNews = context.read<NewsProvider>().allNews;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(PhosphorIcons.regular.arrowArcLeft), onPressed: () => Navigator.pop(context)),
      ),
      body:
          allNews.isNotEmpty
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 15),
                  shrinkWrap: true,
                  itemCount: allNews.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final news = allNews[index];
                    final String imagePresentUrl = news["image"] ?? "";
                    final int newsId = news["news_id"];
                    final String newsCategory = news["category_name"];
                    final DateTime newsCreatedAt = DateTime.parse(news["created_at"]);
                    final String newsCreatedAtFormat = DateFormat("EEEE, dd-MM-yyyy", "vi").format(newsCreatedAt);
                    final String newsTitle =
                        news["title"].length > 100 ? news["title"].substring(0, 100) : news["title"];

                    return InkWell(
                      onTap: () async {
                        await NewsController.getNewsById(newsId);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsDetailScreen()));
                      },
                      splashColor: ColorConstant.primary,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(imagePresentUrl, width: 90, height: 90, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 15),
                            SizedBox(
                              height: 85,
                              // BE CAREFUL: BAD EXPERIENCE WHEN LONG WIDTH
                              width: 210,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    newsCategory,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    newsTitle,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(newsCreatedAtFormat, style: TextStyle(color: Colors.grey[700])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
              : const CircularProgressIndicator(),
    );
  }
}
