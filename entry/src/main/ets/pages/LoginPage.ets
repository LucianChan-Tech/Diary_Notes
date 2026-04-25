import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct LoginPage {
  @State private account: string = '';
  @State private password: string = '';
  @State private isLoading: boolean = false;
  @State private showPassword: boolean = false;

  private doLogin(accountName: string) {
    AppStorage.setOrCreate<string>('currentUser', accountName);
    router.replaceUrl({ url: 'pages/MainPage' });
  }

  private handleLogin() {
    if (this.account.trim().length === 0) {
      promptAction.showToast({ message: '请输入账号。', duration: 2000 });
      return;
    }
    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码。', duration: 2000 });
      return;
    }

    this.isLoading = true;
    setTimeout(() => {
      this.isLoading = false;
      this.doLogin(this.account.trim());
    }, 800);
  }

  build() {
    Column() {
      Column() {
        Stack() {
          Circle()
            .width(80)
            .height(80)
            .fill('#CF0A2C')

          Text('H')
            .fontSize(44)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }

        Text('华为账号')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ top: 14 })

        Text('使用华为账号登录日记备忘录')
          .fontSize(13)
          .fontColor('#757575')
          .margin({ top: 6 })
      }
      .margin({ top: 60, bottom: 40 })

      Column() {
        Row() {
          Text('账号')
            .fontSize(14)
            .fontColor('#555555')
            .width(72)

          TextInput({ placeholder: '请输入账号或手机号', text: this.account })
            .layoutWeight(1)
            .fontSize(15)
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .onChange((value) => {
              this.account = value;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 4 })
        .border({ width: { bottom: 1 }, color: '#E0E0E0' })

        Row() {
          Text('密码')
            .fontSize(14)
            .fontColor('#555555')
            .width(72)

          TextInput({
            placeholder: '请输入密码',
            text: this.password
          })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .layoutWeight(1)
            .fontSize(15)
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .onChange((value) => {
              this.password = value;
            })

          Text(this.showPassword ? '隐藏' : '显示')
            .fontSize(13)
            .fontColor('#CF0A2C')
            .onClick(() => {
              this.showPassword = !this.showPassword;
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 4, bottom: 4 })
        .margin({ top: 8 })
        .border({ width: { bottom: 1 }, color: '#E0E0E0' })

        Row() {
          Blank()
          Text('忘记密码？')
            .fontSize(13)
            .fontColor('#CF0A2C')
            .onClick(() => {
              promptAction.showToast({
                message: '请前往华为账号官网找回密码。',
                duration: 2000
              });
            })
        }
        .width('100%')
        .padding({ top: 8, right: 16 })
      }
      .width('90%')
      .backgroundColor(Color.White)
      .borderRadius(12)
      .padding({ top: 20, bottom: 20 })
      .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })

      Button(this.isLoading ? '登录中...' : '登录')
        .width('90%')
        .height(50)
        .margin({ top: 28 })
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.isLoading ? '#E0E0E0' : '#CF0A2C')
        .fontColor(Color.White)
        .borderRadius(25)
        .enabled(!this.isLoading)
        .onClick(() => {
          this.handleLogin();
        })

      Row() {
        Divider().layoutWeight(1).color('#E0E0E0')
        Text('  或  ')
          .fontSize(13)
          .fontColor('#9E9E9E')
        Divider().layoutWeight(1).color('#E0E0E0')
      }
      .width('90%')
      .margin({ top: 24 })

      Button() {
        Row({ space: 8 }) {
          Stack() {
            Circle()
              .width(24)
              .height(24)
              .fill('#CF0A2C')

            Text('H')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }

          Text('华为账号一键登录')
            .fontSize(15)
            .fontColor('#1A1A1A')
        }
      }
      .width('90%')
      .height(50)
      .margin({ top: 16 })
      .backgroundColor(Color.White)
      .borderRadius(25)
      .border({ width: 1, color: '#E0E0E0' })
      .onClick(() => {
        promptAction.showToast({ message: '正在使用演示账号登录...', duration: 1200 });
        setTimeout(() => {
          this.doLogin('demo@huawei.com');
        }, 1200);
      })

      Blank()

      Text('登录即表示你同意《用户协议》和《隐私声明》。')
        .fontSize(11)
        .fontColor('#9E9E9E')
        .textAlign(TextAlign.Center)
        .padding({ bottom: 24, left: 24, right: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .alignItems(HorizontalAlign.Center)
  }
}
