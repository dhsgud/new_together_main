import 'package:flutter/material.dart';

class BannerAd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.0,
      decoration: BoxDecoration(
        color: Colors.grey[200], // 배너의 배경색, 필요에 따라 변경하세요.
        // 여기에 배너 이미지나 콘텐츠를 추가하세요.
      ),
      child: Center(
        child: Text('광고 문의 : milkdarkway@gmail.com'), // 예시 텍스트, 실제 광고 콘텐츠로 대체하세요.
      ),
    );
  }
}