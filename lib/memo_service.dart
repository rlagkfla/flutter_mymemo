import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

// Memo 데이터의 형식을 정해줍니다. 추후 isPinned, updatedAt 등의 정보도 저장할 수 있습니다.
class Memo {
  String content;
  bool isPinned = false;
  // bool isPinned;

  Memo({
    // 생성자
    required this.content,
    required this.isPinned,
    // this.isPinned = false,
    // required => 무조건 초기값 지정
  });

  Map toJson() {
    return {'content': content, 'isPinned': isPinned};
  }

  factory Memo.fromJson(json) {
    return Memo(
      content: json['content'],
      isPinned: json['isPinned'], // ?? false
      // ??연산자 사용 이유: memoservice에서 loadmemolist를 제일 먼저 실행
      // -> loadmemolist에서 memo.fromjson을 불러오는데 ispinned에서 null값을 가져와 에러 발생하기 때문
      // 근데 isPinned 초기값을 false로 미리 지정해두면 null값이 들어오지 않으므로 사용할 필요 없음
    );
  }
}

// Memo 데이터는 모두 여기서 관리
class MemoService extends ChangeNotifier {
  MemoService() {
    loadMemoList();
  }

  List<Memo> memoList = [
    Memo(content: '장보기 목록: 사과, 양파', isPinned: false), // 더미(dummy) 데이터
    Memo(content: '새 메모', isPinned: false), // 더미(dummy) 데이터
  ];

  createMemo({required String content}) {
    Memo memo = Memo(content: content, isPinned: false);
    memoList.add(memo);
    notifyListeners(); // Consumer<MemoService>의 builder 부분을 호출해서 화면 새로고침
    saveMemoList();
  }

  updateMemo({required int index, required String content}) {
    Memo memo = memoList[index];
    memo.content = content;
    notifyListeners();
    saveMemoList();
  }

  updatePinMemo({required int index}) {
    Memo memo = memoList[index];
    memo.isPinned = !memo.isPinned;
    memoList = [
      ...memoList.where((e) => e.isPinned),
      ...memoList.where((e) => !e.isPinned)
      // where: 배열 요소를 필터링, ...: spread operator
    ];
    notifyListeners();
    saveMemoList();
  }

  deleteMemo({required int index}) {
    memoList.removeAt(index);
    notifyListeners();
    saveMemoList();
  }

  saveMemoList() {
    List memoJsonList = memoList.map((memo) => memo.toJson()).toList();
    // [{"content": "1"}, {"content": "2"}]

    String jsonString = jsonEncode(memoJsonList);
    // '[{"content": "1"}, {"content": "2"}]'

    prefs.setString('memoList', jsonString);
  }

  loadMemoList() {
    String? jsonString = prefs.getString('memoList');
    // '[{"content": "1"}, {"content": "2"}]'

    if (jsonString == null) return; // null 이면 로드하지 않음

    List memoJsonList = jsonDecode(jsonString);
    // [{"content": "1"}, {"content": "2"}]

    memoList = memoJsonList.map((json) => Memo.fromJson(json)).toList();
  }
}
