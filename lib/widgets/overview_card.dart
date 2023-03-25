

import 'package:flutter/material.dart';
import 'package:flutter_3d_portfolio/utils/custom_colors.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard({super.key, required this.image, required this.text});
final String image;
final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 245,
      decoration: BoxDecoration(
        color: CustomColors.brightBackground,
        border: Border.all(color: CustomColors.primary),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            spreadRadius: 0,blurRadius: 8,color: CustomColors.primary
          )
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
       children: [
        Image.asset(image,width: 45,height: 45,),
        const SizedBox(height: 15,),
        Text(text,style: const TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.bold),),
       ], 
      ),
    );
  }
}