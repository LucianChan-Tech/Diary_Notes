import {
  AccountRepository,
  LoginValidationResult,
  RegisterAccountResult,
  TaskRepository,
  UserSessionRepository
} from '../model/AppRepository';
import { AuthPopupConfig, createRegisterAccountPopup } from '../model/PopupTypes';
import { AuthPopupHost } from './PopupPage';

@Entry
@Component
struct LoginPage {
  @State private displayName: string = '';
  @State private account: string = '';
  @State private password: string = '';
  @State private showPassword: boolean = false;
  @State private currentPopup: AuthPopupConfig = null;
  @State private popupDisplayName: string = '';
  @State private popupAccount: string = '';
  @State private popupPassword: string = '';
  @State private popupConfirmPassword: string = '';

  aboutToAppear(): void {
    const hostContext = this.getUIContext().getHostContext();
    if (hostContext !== undefined) {
      AccountRepository.initialize(hostContext);
      TaskRepository.initialize(hostContext);
      UserSessionRepository.initialize(hostContext);
    }
  }

  private navigateReplace(url: string): void {
    void this.getUIContext().getRouter().replaceUrl({ url }).catch((): void => {});
  }

  private showToast(message: string, duration: number = 2000): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration });
    } catch (error) {
    }
  }

  private doLogin(accountName: string): void {
    UserSessionRepository.setCurrentUser(accountName);
    this.navigateReplace('pages/MainPage');
  }

  private openRegisterPopup(): void {
    this.currentPopup = createRegisterAccountPopup();
    this.popupDisplayName = '';
    this.popupAccount = '';
    this.popupPassword = '';
    this.popupConfirmPassword = '';
  }

  private closeRegisterPopup(): void {
    this.currentPopup = null;
    this.popupDisplayName = '';
    this.popupAccount = '';
    this.popupPassword = '';
    this.popupConfirmPassword = '';
  }

  private handleLogin(): void {
    const loginDisplayName = this.displayName.trim();
    const accountName = this.account.trim();
    if (loginDisplayName.length === 0) {
      this.showToast('请输入用户名');
      return;
    }

    if (accountName.length === 0) {
      this.showToast('请输入用户账号');
      return;
    }

    if (this.password.length === 0) {
      this.showToast('请输入密码');
      return;
    }

    const result = AccountRepository.validate(loginDisplayName, accountName, this.password);
    if (result === LoginValidationResult.AccountNotFound) {
      this.showToast('账号不存在，请先注册！', 2200);
      return;
    }

    if (result === LoginValidationResult.DisplayNameMismatch) {
      this.showToast('用户名与用户账号不匹配，请重新输入！', 2400);
      return;
    }

    if (result === LoginValidationResult.WrongPassword) {
      this.showToast('密码错误，登录失败！请重新输入！', 2400);
      return;
    }

    this.doLogin(accountName);
  }

  private confirmRegisterPopup(): void {
    const registerDisplayName = this.popupDisplayName.trim();
    const accountName = this.popupAccount.trim();
    if (registerDisplayName.length === 0) {
      this.showToast('请输入用户名');
      return;
    }

    if (accountName.length === 0) {
      this.showToast('请输入用户账号');
      return;
    }

    if (this.popupPassword.length === 0) {
      this.showToast('请输入密码');
      return;
    }

    if (this.popupConfirmPassword.length === 0) {
      this.showToast('请输入确认密码');
      return;
    }

    if (this.popupPassword !== this.popupConfirmPassword) {
      this.showToast('两次输入的密码不一致，请重新输入！', 2400);
      return;
    }

    const result = AccountRepository.register(registerDisplayName, accountName, this.popupPassword);
    if (result === RegisterAccountResult.Duplicate) {
      this.showToast('该账号已存在，请更换用户账号', 2200);
      return;
    }

    this.displayName = registerDisplayName;
    this.account = accountName;
    this.password = this.popupPassword;
    this.closeRegisterPopup();
    this.showToast('注册成功，请登录！');
  }

  build() {
    Stack() {
      Column() {
        Column() {
          Image($r('app.media.thunderbird'))
            .width(88)
            .height(88)
            .borderRadius(20)
            .objectFit(ImageFit.Contain)

          Text('用户登录')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .margin({ top: 14 })

          Text('登录后可继续查看并管理你的历史任务')
            .fontSize(13)
            .fontColor('#757575')
            .margin({ top: 6 })
        }
        .margin({ top: 60, bottom: 40 })

        Column() {
          Row() {
            Text('用户名')
              .fontSize(14)
              .fontColor('#555555')
              .width(72)

            TextInput({ placeholder: '请输入用户名', text: this.displayName })
              .layoutWeight(1)
              .fontSize(15)
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .onChange((value: string) => {
                this.displayName = value;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 4, bottom: 4 })
          .border({ width: { bottom: 1 }, color: '#E0E0E0' })

          Row() {
            Text('账号')
              .fontSize(14)
              .fontColor('#555555')
              .width(72)

            TextInput({ placeholder: '请输入用户账号', text: this.account })
              .layoutWeight(1)
              .fontSize(15)
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .onChange((value: string) => {
                this.account = value;
              })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 4, bottom: 4 })
          .margin({ top: 8 })
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
              .onChange((value: string) => {
                this.password = value;
              })

            Text(this.showPassword ? '隐藏' : '显示')
              .fontSize(13)
              .fontColor('#FF2F5D')
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
              .fontColor('#FF2F5D')
              .onClick(() => {
                this.showToast('当前版本暂不支持找回密码，请重新注册新账号。', 2600);
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

        Button('登录')
          .width('90%')
          .height(50)
          .margin({ top: 28 })
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF2F5D')
          .fontColor(Color.White)
          .borderRadius(25)
          .onClick(() => {
            this.handleLogin();
          })

        Button('注册')
          .width('90%')
          .height(50)
          .margin({ top: 14 })
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.White)
          .fontColor('#FF2F5D')
          .borderRadius(25)
          .border({ width: 1, color: '#FF2F5D' })
          .onClick(() => {
            this.openRegisterPopup();
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

      if (this.currentPopup !== null) {
        AuthPopupHost({
          popupConfig: this.currentPopup,
          displayName: $popupDisplayName,
          account: $popupAccount,
          password: $popupPassword,
          confirmPassword: $popupConfirmPassword,
          onClose: () => { this.closeRegisterPopup(); },
          onConfirm: () => { this.confirmRegisterPopup(); }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
