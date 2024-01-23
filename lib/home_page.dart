import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'model/news_api_model.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  dynamic responses;
  NewsApiModel? newsApiModel;
  Dio dio = Dio();
  getData() async {
    responses = await dio.get(
        "https://newsapi.org/v2/top-headlines?country=us&apiKey=bd8a10ed2c2b4b069f801cafaf6e105b");
    newsApiModel = NewsApiModel.fromJson(responses.data);
    print('responses');
    print(responses);
  }
  @override
  void initState() {
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "DailyNews",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF7C50FD),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white60,
        child: ListView.builder(
          itemCount: newsApiModel?.articles!.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            newsApiModel?.articles![index].urlToImage ?? "",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        newsApiModel?.articles![index].title ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        newsApiModel?.articles![index].content ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


