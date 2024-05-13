import 'package:mymusicc/data/source/source.dart';

import '../model/song.dart';

abstract  interface class Repository{
  Future<List<Song>?> loadData();
}
class DefaultRepository implements Repository{
  final _localDataSource = LocalDataSource();
  final _remoteDataSource = RemoteDataSoucre();
  @override
  Future<List<Song>?> loadData() async {
    List<Song> songs = [];
    await _remoteDataSource.loadData().then((remoteSongs) async{
      if(remoteSongs == null){
    await  _localDataSource.loadData().then((localSongs) async{
        if(localSongs != null){
          songs.addAll(localSongs);
        }
        });
      }else{
        songs.addAll(remoteSongs);
      }
    });
    return songs;
  }
}