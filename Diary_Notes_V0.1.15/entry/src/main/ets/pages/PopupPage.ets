import {
  AddTaskPopupConfig,
  AuthPopupConfig,
  DeleteTaskPopupConfig,
  EditTaskLevelPopupConfig,
  PopupType,
  RegisterAccountPopupConfig,
  TaskPopupConfig
} from '../model/PopupTypes';
import { TaskLevel, getLevelColor, getLevelDesc } from '../model/TaskModel';

@Component
export struct TaskPopupHost {
  @Prop popupConfig: TaskPopupConfig = null;
  @Link taskTitle: string;
  @Link selectedLevel: TaskLevel;

  onClose: () => void = () => {};
  onConfirm: () => void = () => {};

  private addTaskPopup(): AddTaskPopupConfig {
    return this.popupConfig as AddTaskPopupConfig;
  }

  private editTaskPopup(): EditTaskLevelPopupConfig {
    return this.popupConfig as EditTaskLevelPopupConfig;
  }

  private deleteTaskPopup(): DeleteTaskPopupConfig {
    return this.popupConfig as DeleteTaskPopupConfig;
  }

  @Builder
  private LevelSelector(levelOptions: TaskLevel[]) {
    Row({ space: 10 }) {
      ForEach(levelOptions, (level: TaskLevel) => {
        Text(level)
          .width(48)
          .height(36)
          .textAlign(TextAlign.Center)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.selectedLevel === level ? Color.White : getLevelColor(level))
          .backgroundColor(this.selectedLevel === level ? getLevelColor(level) : '#F5F5F5')
          .borderRadius(18)
          .border({ width: 1.5, color: getLevelColor(level) })
          .onClick(() => {
            this.selectedLevel = level;
          });
      });
    }
  }

  @Builder
  private AddTaskPopupView() {
    Column() {
      Text(this.addTaskPopup().title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      Text(this.addTaskPopup().date)
        .width('100%')
        .fontSize(12)
        .fontColor('#9E9E9E')
        .margin({ bottom: 16 })

      TextInput({
        placeholder: this.addTaskPopup().placeholder,
        text: this.taskTitle
      })
        .width('100%')
        .fontSize(15)
        .onChange((value: string) => {
          this.taskTitle = value;
        })
        .margin({ bottom: 16 })

      Text('优先级（可手动调整）')
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 8 })

      this.LevelSelector(this.addTaskPopup().levelOptions);

      Text(getLevelDesc(this.selectedLevel))
        .fontSize(12)
        .fontColor(getLevelColor(this.selectedLevel))
        .width('100%')
        .margin({ top: 8, bottom: 20 })

      Row({ space: 12 }) {
        Button(this.addTaskPopup().cancelText)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#555555')
          .onClick(() => this.onClose())

        Button(this.addTaskPopup().confirmText)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#CF0A2C')
          .fontColor(Color.White)
          .onClick(() => this.onConfirm())
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  private EditTaskLevelPopupView() {
    Column() {
      Text(this.editTaskPopup().title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Text(`"${this.editTaskPopup().taskTitle}"`)
        .fontSize(14)
        .fontColor('#555555')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 16 })

      this.LevelSelector(this.editTaskPopup().levelOptions);

      Text(getLevelDesc(this.selectedLevel))
        .fontSize(12)
        .fontColor(getLevelColor(this.selectedLevel))
        .width('100%')
        .margin({ top: 8, bottom: 24 })

      Row({ space: 12 }) {
        Button(this.editTaskPopup().cancelText)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#555555')
          .onClick(() => this.onClose())

        Button(this.editTaskPopup().confirmText)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#1E88E5')
          .fontColor(Color.White)
          .onClick(() => this.onConfirm())
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  @Builder
  private DeleteTaskPopupView() {
    Column() {
      Text(this.deleteTaskPopup().title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .margin({ bottom: 12 })

      Text(`"${this.deleteTaskPopup().taskTitle}"`)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ bottom: 10 })

      Text(this.deleteTaskPopup().message)
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 24 })

      Row({ space: 12 }) {
        Button(this.deleteTaskPopup().cancelText)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#555555')
          .onClick(() => this.onClose())

        Button(this.deleteTaskPopup().confirmText)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#E53935')
          .fontColor(Color.White)
          .onClick(() => this.onConfirm())
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  build() {
    Stack() {
      if (this.popupConfig !== null) {
        Column() {}
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')
          .onClick(() => this.onClose())

        Column() {
          if (this.popupConfig.type === PopupType.AddTask) {
            this.AddTaskPopupView();
          }

          if (this.popupConfig.type === PopupType.EditTaskLevel) {
            this.EditTaskLevelPopupView();
          }

          if (this.popupConfig.type === PopupType.DeleteTask) {
            this.DeleteTaskPopupView();
          }
        }
        .width('92%')
        .position({
          x: '4%',
          y: this.popupConfig.type === PopupType.DeleteTask ? '34%' : this.popupConfig.type === PopupType.AddTask ? '20%' : '30%'
        })
        .shadow({ radius: 24, color: '#40000000', offsetX: 0, offsetY: 8 })
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct AuthPopupHost {
  @Prop popupConfig: AuthPopupConfig = null;
  @Link account: string;
  @Link password: string;
  @Link confirmPassword: string;

  onClose: () => void = () => {};
  onConfirm: () => void = () => {};

  private registerPopup(): RegisterAccountPopupConfig {
    return this.popupConfig as RegisterAccountPopupConfig;
  }

  @Builder
  private RegisterAccountPopupView() {
    Column() {
      Text(this.registerPopup().title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 18 })

      Text(this.registerPopup().accountLabel)
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({
        placeholder: this.registerPopup().accountPlaceholder,
        text: this.account
      })
        .width('100%')
        .fontSize(15)
        .onChange((value: string) => {
          this.account = value;
        })
        .margin({ bottom: 14 })

      Text(this.registerPopup().passwordLabel)
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({
        placeholder: this.registerPopup().passwordPlaceholder,
        text: this.password
      })
        .width('100%')
        .type(InputType.Password)
        .fontSize(15)
        .onChange((value: string) => {
          this.password = value;
        })
        .margin({ bottom: 14 })

      Text(this.registerPopup().confirmPasswordLabel)
        .fontSize(13)
        .fontColor('#757575')
        .width('100%')
        .margin({ bottom: 6 })

      TextInput({
        placeholder: this.registerPopup().confirmPasswordPlaceholder,
        text: this.confirmPassword
      })
        .width('100%')
        .type(InputType.Password)
        .fontSize(15)
        .onChange((value: string) => {
          this.confirmPassword = value;
        })
        .margin({ bottom: 24 })

      Row({ space: 12 }) {
        Button(this.registerPopup().cancelText)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#555555')
          .onClick(() => this.onClose())

        Button(this.registerPopup().confirmText)
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#CF0A2C')
          .fontColor(Color.White)
          .onClick(() => this.onConfirm())
      }
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .borderRadius(16)
  }

  build() {
    Stack() {
      if (this.popupConfig !== null && this.popupConfig.type === PopupType.RegisterAccount) {
        Column() {}
          .width('100%')
          .height('100%')
          .backgroundColor('#66000000')
          .onClick(() => this.onClose())

        Column() {
          this.RegisterAccountPopupView();
        }
        .width('92%')
        .position({ x: '4%', y: '20%' })
        .shadow({ radius: 24, color: '#40000000', offsetX: 0, offsetY: 8 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
