
import '../../model/dynamic_data.dart';
import 'scale_base.dart';

class CategoryScale extends BaseScale<String, num> {
  CategoryScale(super.domain, super.range, super.inverse);

  @override
  String domainValue(num rangeData) {
    num diff = range.last - range.first;
    num interval = diff / domain.length;
    int diff2 = (rangeData - range.first) ~/ interval;
    if(diff2<0){diff2=0;}
    if(diff2>=domain.length){
      diff2=domain.length-1;
    }
    return domain[diff2];
  }

  @override
  num rangeValue(DynamicData domainData) {
    num index = domain.indexOf(domainData.data);
    if (index == -1) {
      return double.nan;
    }
    index += 0.5; //居中

    num diff = range.last - range.first;
    num interval = diff / domain.length;

    return range.first + index * interval;
  }

  @override
  int get tickCount => domain.length;
}
