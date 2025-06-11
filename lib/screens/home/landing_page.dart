import 'package:flutter/material.dart';
import '../../services/community_service.dart';
// import '../../cells/custom_app_bar.dart';
import '../../cells/landing_app_bar.dart';
import '../../cells/banner_carousel.dart';
import '../../cells/community_card.dart';
import '../../cells/app_drawer.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  List<dynamic> communities = [];
  bool isLoading = true;
  final CommunityService communityService = CommunityService();

  @override
  void initState() {
    super.initState();
    loadCommunities();
  }

  Future<void> loadCommunities() async {
    try {
      final data = await communityService.fetchCommunities();
      setState(() {
        communities = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading communities: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 800 ? 3 : (width > 600 ? 2 : 1);

    return Scaffold(
      appBar: CustomAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const BannerCarousel(),



            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              width: double.infinity,
              child: Card(
                color: Colors.black,
                elevation: 4,
                shadowColor: const Color(0xFF0BC148).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "APHRC COMMUNITIES",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),



            // const SizedBox(height: 10),
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 12.0),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: Text(
            //       "APHRC COMMUNITIES",
            //       style: TextStyle(
            //         fontSize: 18,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.green,
            //       ),
            //     ),
            //   ),
            // ),



            const SizedBox(height: 6),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())


                      :Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      itemCount: communities.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CommunityCard(
                          community: communities[index],
                          communityService: communityService,
                        ),
                      ),
                    ),
                  ),


                  // GridView.builder(
                  //       padding: const EdgeInsets.symmetric(horizontal: 8),
                  //       itemCount: communities.length,
                  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //         crossAxisCount: crossAxisCount,
                  //         crossAxisSpacing: 10,
                  //         mainAxisSpacing: 10,
                  //         childAspectRatio: 0.85,
                  //       ),
                  //       itemBuilder: (context, index) {
                  //         return CommunityCard(
                  //           community: communities[index],
                  //           communityService: communityService,
                  //         );
                  //       },
                  //     ),



            ),
            Container(
              color:  Colors.black,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text(
                '© 2025 APHRC Community of Practice. All rights reserved.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
