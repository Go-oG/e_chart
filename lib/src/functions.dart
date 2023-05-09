import 'action/user_action.dart';

typedef Fun1<A, B> = B Function(A);

typedef Fun2<A, B, C> = C Function(A, B);

typedef Fun3<A, B, C, D> = D Function(A, B, C);

typedef Fun4<A, B, C, D, E> = E Function(A, B, C, D);

typedef VoidFun1<A> = void Function(A);

typedef VoidFun2<A, B> = void Function(A, B);

typedef VoidFun3<A, B, C> = void Function(A, B, C);

typedef VoidFun4<A, B, C, D> = void Function(A, B, C, D);

typedef FormatterFun<T> = String Function(T t);

typedef FormatterFun2<A, B> = String Function(A, B);

typedef StyleFun<D, S> = S? Function(D d, UserAction? action);

typedef StyleFun2<A, B, S> = S? Function(A a, B b, UserAction? action);

typedef StyleFun3<A, B, C, S> = S? Function(A a, B b, C c, UserAction? action);

typedef StyleFun4<A, B, C, D, S> = S? Function(A a, B b, C c, D d, UserAction? action);

typedef ConvertFun<I, O> = O? Function(I input);

typedef ValueCallback<T> = VoidFun1<T>;
