import 'package:flutter/material.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/components/custom_text_form_field.dart';

class AddOfferWidget extends StatelessWidget {
  const AddOfferWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تقدم للمشروع',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 16.h,
          ),
          const Divider(
            height: 1,
            thickness: .5,
          ),
          SizedBox(
            height: 16.h,
          ),
          const CustomTextField(
            maxLines: 5,
            minLines: 3,
            hint: "اكتب هنا",
          ),
        ],
      ),
    );
  }
}
