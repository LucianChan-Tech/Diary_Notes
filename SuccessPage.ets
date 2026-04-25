import CommonConstants from '../common/constants/CommonConstants';
//TODO

@Entry
@Component
struct SuccessPage {
  //TODO

  build() {
    Column() {
      Column() {
        //TODO

      }
      .backgroundColor(Color.White)
      .height(CommonConstants.FULL_PARENT)
      .borderRadius($r('app.float.verify_ok_margin'))
    }
    .padding({ bottom: $r('app.float.verify_bottom_padding') })
    .height(CommonConstants.FULL_PARENT)
  }
}