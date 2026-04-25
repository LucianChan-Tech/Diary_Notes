import CommonConstants from '../common/constants/CommonConstants';
import VerifyItem from '../viewmodel/VerifyItem';
//TODO

@Extend(Text)
function promptTextStyle() {
  .fontSize($r('app.float.small_text_size'))
  .width(CommonConstants.FULL_PARENT)
  .padding({
    left: $r('app.float.verify_padding'),
    right: $r('app.float.verify_padding')
  })
}

@Entry
@Component
struct VerifyPage {
  @State isInputWrong: boolean = false;
  @State verifyItem: VerifyItem = new VerifyItem($r('app.media.ic_verity_character1'), 'XYZK');
  @State inputText: string = '';
  //TODO


  build() {
    Column() {
      Column() {
        Row() {
          //TODO

        }
        .padding({
          left: $r('app.float.verify_padding'),
          top: $r('app.float.verify_padding'),
          right: $r('app.float.verify_hints_padding')
        })
        .width(CommonConstants.FULL_PARENT)
        .justifyContent(FlexAlign.SpaceBetween)
        //TODO

        Text($r('app.string.verify_ok'))
          .fontSize($r('app.float.big_text_size'))
          .fontColor($r('app.color.login_blue_text_color'))
          .margin({
            top: $r('app.float.verify_ok_margin'),
            bottom: $r('app.float.verify_ok_margin')
          })

      }
      .backgroundColor(Color.White)
      .height(CommonConstants.FULL_PARENT)
      .borderRadius($r('app.float.verify_ok_margin'))
    }
    .padding({ bottom: $r('app.float.verify_bottom_padding') })
    .height(CommonConstants.FULL_PARENT)
  }
}