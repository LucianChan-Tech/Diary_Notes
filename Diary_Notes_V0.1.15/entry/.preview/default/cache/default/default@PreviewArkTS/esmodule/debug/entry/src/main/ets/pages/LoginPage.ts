if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface LoginPage_Params {
    account?: string;
    password?: string;
    isLoading?: boolean;
    showPassword?: boolean;
}
import { UserSessionRepository } from "@normalized:N&&&entry/src/main/ets/model/AppRepository&";
class LoginPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.__account = new ObservedPropertySimplePU('', this, "account");
        this.__password = new ObservedPropertySimplePU('', this, "password");
        this.__isLoading = new ObservedPropertySimplePU(false, this, "isLoading");
        this.__showPassword = new ObservedPropertySimplePU(false, this, "showPassword");
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: LoginPage_Params) {
        if (params.account !== undefined) {
            this.account = params.account;
        }
        if (params.password !== undefined) {
            this.password = params.password;
        }
        if (params.isLoading !== undefined) {
            this.isLoading = params.isLoading;
        }
        if (params.showPassword !== undefined) {
            this.showPassword = params.showPassword;
        }
    }
    updateStateVars(params: LoginPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__account.purgeDependencyOnElmtId(rmElmtId);
        this.__password.purgeDependencyOnElmtId(rmElmtId);
        this.__isLoading.purgeDependencyOnElmtId(rmElmtId);
        this.__showPassword.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__account.aboutToBeDeleted();
        this.__password.aboutToBeDeleted();
        this.__isLoading.aboutToBeDeleted();
        this.__showPassword.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private __account: ObservedPropertySimplePU<string>;
    get account() {
        return this.__account.get();
    }
    set account(newValue: string) {
        this.__account.set(newValue);
    }
    private __password: ObservedPropertySimplePU<string>;
    get password() {
        return this.__password.get();
    }
    set password(newValue: string) {
        this.__password.set(newValue);
    }
    private __isLoading: ObservedPropertySimplePU<boolean>;
    get isLoading() {
        return this.__isLoading.get();
    }
    set isLoading(newValue: boolean) {
        this.__isLoading.set(newValue);
    }
    private __showPassword: ObservedPropertySimplePU<boolean>;
    get showPassword() {
        return this.__showPassword.get();
    }
    set showPassword(newValue: boolean) {
        this.__showPassword.set(newValue);
    }
    aboutToAppear(): void {
        UserSessionRepository.initialize();
    }
    private navigateReplace(url: string): void {
        void this.getUIContext().getRouter().replaceUrl({ url }).catch((): void => { });
    }
    private showToast(message: string, duration: number = 2000): void {
        try {
            this.getUIContext().getPromptAction().showToast({ message, duration });
        }
        catch (error) {
        }
    }
    private doLogin(accountName: string): void {
        UserSessionRepository.setCurrentUser(accountName);
        this.navigateReplace('pages/MainPage');
    }
    private handleLogin(): void {
        if (this.account.trim().length === 0) {
            this.showToast('请输入账号。', 2000);
            return;
        }
        if (this.password.length === 0) {
            this.showToast('请输入密码。', 2000);
            return;
        }
        this.isLoading = true;
        setTimeout((): void => {
            this.isLoading = false;
            this.doLogin(this.account.trim());
        }, 800);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/LoginPage.ets(50:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('#F5F5F5');
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/LoginPage.ets(51:7)", "entry");
            Column.margin({ top: 60, bottom: 40 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.debugLine("entry/src/main/ets/pages/LoginPage.ets(52:9)", "entry");
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create();
            Circle.debugLine("entry/src/main/ets/pages/LoginPage.ets(53:11)", "entry");
            Circle.width(80);
            Circle.height(80);
            Circle.fill('#CF0A2C');
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('H');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(58:11)", "entry");
            Text.fontSize(44);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(Color.White);
        }, Text);
        Text.pop();
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('华为账号');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(64:9)", "entry");
            Text.fontSize(22);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor('#1A1A1A');
            Text.margin({ top: 14 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('使用华为账号登录日记备忘录');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(70:9)", "entry");
            Text.fontSize(13);
            Text.fontColor('#757575');
            Text.margin({ top: 6 });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/LoginPage.ets(77:7)", "entry");
            Column.width('90%');
            Column.backgroundColor(Color.White);
            Column.borderRadius(12);
            Column.padding({ top: 20, bottom: 20 });
            Column.shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/LoginPage.ets(78:9)", "entry");
            Row.width('100%');
            Row.padding({ left: 16, right: 16, top: 4, bottom: 4 });
            Row.border({ width: { bottom: 1 }, color: '#E0E0E0' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('账号');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(79:11)", "entry");
            Text.fontSize(14);
            Text.fontColor('#555555');
            Text.width(72);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '请输入账号或手机号', text: this.account });
            TextInput.debugLine("entry/src/main/ets/pages/LoginPage.ets(84:11)", "entry");
            TextInput.layoutWeight(1);
            TextInput.fontSize(15);
            TextInput.backgroundColor(Color.Transparent);
            TextInput.border({ width: 0 });
            TextInput.onChange((value: string) => {
                this.account = value;
            });
        }, TextInput);
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/LoginPage.ets(97:9)", "entry");
            Row.width('100%');
            Row.padding({ left: 16, right: 16, top: 4, bottom: 4 });
            Row.margin({ top: 8 });
            Row.border({ width: { bottom: 1 }, color: '#E0E0E0' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('密码');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(98:11)", "entry");
            Text.fontSize(14);
            Text.fontColor('#555555');
            Text.width(72);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({
                placeholder: '请输入密码',
                text: this.password
            });
            TextInput.debugLine("entry/src/main/ets/pages/LoginPage.ets(103:11)", "entry");
            TextInput.type(this.showPassword ? InputType.Normal : InputType.Password);
            TextInput.layoutWeight(1);
            TextInput.fontSize(15);
            TextInput.backgroundColor(Color.Transparent);
            TextInput.border({ width: 0 });
            TextInput.onChange((value: string) => {
                this.password = value;
            });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.showPassword ? '隐藏' : '显示');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(116:11)", "entry");
            Text.fontSize(13);
            Text.fontColor('#CF0A2C');
            Text.onClick(() => {
                this.showPassword = !this.showPassword;
            });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/LoginPage.ets(128:9)", "entry");
            Row.width('100%');
            Row.padding({ top: 8, right: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/LoginPage.ets(129:11)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('忘记密码？');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(131:11)", "entry");
            Text.fontSize(13);
            Text.fontColor('#CF0A2C');
            Text.onClick(() => {
                this.showToast('找回密码请前往华为账号官网。', 2000);
            });
        }, Text);
        Text.pop();
        Row.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.isLoading ? '登录中...' : '登录');
            Button.debugLine("entry/src/main/ets/pages/LoginPage.ets(147:7)", "entry");
            Button.width('90%');
            Button.height(50);
            Button.margin({ top: 28 });
            Button.fontSize(17);
            Button.fontWeight(FontWeight.Medium);
            Button.backgroundColor(this.isLoading ? '#E0E0E0' : '#CF0A2C');
            Button.fontColor(Color.White);
            Button.borderRadius(25);
            Button.enabled(!this.isLoading);
            Button.onClick(() => {
                this.handleLogin();
            });
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/LoginPage.ets(161:7)", "entry");
            Row.width('90%');
            Row.margin({ top: 24 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/LoginPage.ets(162:9)", "entry");
            Divider.layoutWeight(1);
            Divider.color('#E0E0E0');
        }, Divider);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('  或  ');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(163:9)", "entry");
            Text.fontSize(13);
            Text.fontColor('#9E9E9E');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Divider.create();
            Divider.debugLine("entry/src/main/ets/pages/LoginPage.ets(166:9)", "entry");
            Divider.layoutWeight(1);
            Divider.color('#E0E0E0');
        }, Divider);
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild();
            Button.debugLine("entry/src/main/ets/pages/LoginPage.ets(171:7)", "entry");
            Button.width('90%');
            Button.height(50);
            Button.margin({ top: 16 });
            Button.backgroundColor(Color.White);
            Button.borderRadius(25);
            Button.border({ width: 1, color: '#E0E0E0' });
            Button.onClick(() => {
                this.showToast('正在使用演示账号登录...', 1200);
                setTimeout((): void => {
                    this.doLogin('demo@huawei.com');
                }, 1200);
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.debugLine("entry/src/main/ets/pages/LoginPage.ets(172:9)", "entry");
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.debugLine("entry/src/main/ets/pages/LoginPage.ets(173:11)", "entry");
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create();
            Circle.debugLine("entry/src/main/ets/pages/LoginPage.ets(174:13)", "entry");
            Circle.width(24);
            Circle.height(24);
            Circle.fill('#CF0A2C');
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('H');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(179:13)", "entry");
            Text.fontSize(14);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(Color.White);
        }, Text);
        Text.pop();
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('华为账号一键登录');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(185:11)", "entry");
            Text.fontSize(15);
            Text.fontColor('#1A1A1A');
        }, Text);
        Text.pop();
        Row.pop();
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
            Blank.debugLine("entry/src/main/ets/pages/LoginPage.ets(203:7)", "entry");
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('登录即表示你同意《用户协议》和《隐私声明》。');
            Text.debugLine("entry/src/main/ets/pages/LoginPage.ets(205:7)", "entry");
            Text.fontSize(11);
            Text.fontColor('#9E9E9E');
            Text.textAlign(TextAlign.Center);
            Text.padding({ bottom: 24, left: 24, right: 24 });
        }, Text);
        Text.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "LoginPage";
    }
}
registerNamedRoute(() => new LoginPage(undefined, {}), "", { bundleName: "com.example.diarynotes", moduleName: "entry", pagePath: "pages/LoginPage", pageFullPath: "entry/src/main/ets/pages/LoginPage", integratedHsp: "false", moduleType: "followWithHap" });
