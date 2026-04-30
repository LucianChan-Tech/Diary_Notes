import { Task, getLevelColor, getLevelDesc } from '../model/TaskModel';

@Component
export struct TaskItemView {
  @Prop task: Task;

  onToggleComplete: (taskId: string) => void = () => {};
  onEdit: (task: Task) => void = () => {};
  onDelete: (task: Task) => void = () => {};

  build() {
    Row() {
      Text(this.task.level)
        .width(32)
        .height(32)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .borderRadius(16)
        .backgroundColor(getLevelColor(this.task.level))
        .margin({ right: 12 })

      Column() {
        Text(this.task.title)
          .fontSize(15)
          .fontColor(this.task.completed ? '#AAAAAA' : '#1A1A1A')
          .decoration(this.task.completed
            ? { type: TextDecorationType.LineThrough, color: '#AAAAAA' }
            : { type: TextDecorationType.None })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(getLevelDesc(this.task.level))
          .fontSize(12)
          .fontColor(getLevelColor(this.task.level))
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Row({ space: 8 }) {
        Text(this.task.completed ? '取消完成' : '完成')
          .fontSize(14)
          .fontColor(this.task.completed ? '#9E9E9E' : '#4CAF50')
          .onClick(() => this.onToggleComplete(this.task.id))

        Text('编辑')
          .fontSize(14)
          .fontColor('#1565C0')
          .onClick(() => this.onEdit(this.task))

        Text('删除')
          .fontSize(14)
          .fontColor('#E53935')
          .onClick(() => this.onDelete(this.task))
      }
      .margin({ left: 8 })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
    .margin({ bottom: 10 })
  }
}
