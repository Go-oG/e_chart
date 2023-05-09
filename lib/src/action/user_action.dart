class UserAction {
  final bool select;
  final int maskFlag; //是否需要遮罩层 -1 遮住 0不改变 1 高亮
  const UserAction({
    this.select = false,
    this.maskFlag = 0,
  });
}