import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/core/app_event.dart';
import '../../../app/core/app_state.dart';

class OnboardingBloc extends Bloc<AppEvent, AppState> {
  // عدد الصفحات الإجمالي، قد ترغب في تمريره من الخارج لاحقًا
  final int totalPages = 3;

  OnboardingBloc() : super(Start()) {
    // 1. عند بدء الشاشة
    on<Init>((event, emit) {
      // نصدر حالة "Done" مع رقم الصفحة الأولى (0)
      emit(Done(data: 0));
    });

    // 2. عندما يقوم المستخدم بالتمرير
    on<Scroll>((event, emit) {
      // نتأكد من أن "arguments" هو رقم الصفحة (int)
      if (event.arguments is int) {
        // نصدر حالة جديدة مع رقم الصفحة المحدث
        emit(Done(data: event.arguments as int));
      }
    });

    // 3. عندما يضغط المستخدم على زر "التالي"
    on<Click>((event, emit) {
      // نتأكد أن الحالة الحالية هي "Done" ولها بيانات
      if (state is Done && (state as Done).data is int) {
        int currentPage = (state as Done).data as int;

        // إذا لم تكن الصفحة الأخيرة، ننتقل إلى الصفحة التالية
        if (currentPage < totalPages - 1) {
          emit(Done(data: currentPage + 1));
        }
        // إذا كانت الصفحة الأخيرة، فإننا لا نغير الحالة.
        // سيتم التعامل مع التنقل إلى الشاشة الرئيسية في الواجهة مباشرة.
      }
    });
  }
}