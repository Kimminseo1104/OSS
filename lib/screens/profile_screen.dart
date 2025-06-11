import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trip_list_screen.dart';
import 'exchange_rate_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _controller = TextEditingController();
  String nickname = "";
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  void _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nickname = prefs.getString('nickname') ?? "";
      _controller.text = nickname;
      isEditing = nickname.isEmpty;
    });
  }

  void _saveNickname() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', _controller.text.trim());
    setState(() {
      nickname = _controller.text.trim();
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("닉네임이 저장되었습니다.")));
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nickname');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TripListScreen()));
    }
    if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ExchangeRateScreen()));
    }
    // index==2: 현재 화면
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("프로필"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 60, color: Colors.white70),
              ),
              SizedBox(height: 24),
              // 닉네임 부분
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isEditing)
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: "닉네임 입력",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        autofocus: true,
                      ),
                    )
                  else
                    Text(
                      nickname.isNotEmpty ? nickname : "닉네임 없음",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(width: 8),
                  // 수정 버튼은 닉네임이 이미 있을 때만 보임
                  if (!isEditing && nickname.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.edit, size: 18),
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                          _controller.text = nickname;
                        });
                      },
                      tooltip: '닉네임 수정',
                    ),
                ],
              ),
              // 저장 버튼
              if (isEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) _saveNickname();
                    },
                    child: Text("저장"),
                    style: ElevatedButton.styleFrom(minimumSize: Size(90, 36)),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "환율조회"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: _onTabTapped,
      ),
    );
  }
}
