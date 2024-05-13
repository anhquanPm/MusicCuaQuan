import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mymusicc/ui/discovery/discovery.dart';
import 'package:mymusicc/ui/home/viewmodel.dart';
import 'package:mymusicc/ui/setting/setting.dart';
import 'package:mymusicc/ui/user/user.dart';
import '../../data/model/song.dart';
import '../now_play/play.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Music App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MusicHomePage(),
      debugShowCheckedModeBanner: false,
      
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tab = [
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingTab()
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Music App"),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
            BottomNavigationBarItem(icon: Icon(Icons.album), label: "Khám phá"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: "Người dùng"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: "Cài đặt"),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tab[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observerData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if (showLoading) {
      return getProgressBar();
    } else {
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget getListView() {
    return ListView.separated(
      itemBuilder: (context, position) {
        return Center(child: getRow(position));
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _songItemSection(parent: this, song: songs[index]);
  }

  void observerData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  void showButtonSheet() {
    showModalBottomSheet(context: context, builder: (context){
       return  ClipRRect(
         borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
         child: Container(
           height: 400,
           color: Colors.black12,
           child:  Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               mainAxisSize: MainAxisSize.min,
               children: <Widget>[
                 const Text("Anh Quan"),
                 ElevatedButton(onPressed: () => Navigator.pop(context),
                     child: const Text(
                   "Đóng"
                 ),
                 )
               ],
             ),
           ),
         ),
       );
    });
  }

  void navigate(Song song) {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return NowPlaying(
        songs: songs,
        playingSong: song,
      );
    }));
  }
}

class _songItemSection extends StatelessWidget {
  const _songItemSection({required this.parent, required this.song});

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 24, right: 12),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage.assetNetwork(
          width: 48,
          height: 48,
          placeholder: "assets/logo600.png",
          image: song.image,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              "assets/logo600.png",
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          parent.showButtonSheet(
          );
        },
      ),
      onTap: () {
        parent.navigate(song);
      },
    );
  }
}
