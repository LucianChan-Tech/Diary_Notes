export enum TaskLevel {
  S = 'S',
  A = 'A',
  B = 'B',
  C = 'C'
}
// 1. 获取任务等级描述文本
export function getLevelDesc(level: TaskLevel): string {
  switch (level) {
    case TaskLevel.S:
      return 'S级紧急任务请优先完成';
    case TaskLevel.A:
      return 'A级任务请安排完成';
    case TaskLevel.B:
      return 'B级任务请尽快安排完成';
    case TaskLevel.C:
      return 'C级非紧急任务可择日安排完成';
    default:
      return '';
  }
}
// 2. 获取任务等级对应颜色值
export function getLevelColor(level: TaskLevel): string {
  switch (level) {
    case TaskLevel.S:
      return '#D32F2F';
    case TaskLevel.A:
      return '#FF7043';
    case TaskLevel.B:
      return '#FFB300';
    case TaskLevel.C:
      return '#BDBDBD';
    default:
      return '#757575';
  }
}
// 3. 根据插入位置自动分级
export function autoGrade(insertionIndex: number): TaskLevel {
  if (insertionIndex === 0) {
    return TaskLevel.S;
  } else if (insertionIndex === 1) {
    return TaskLevel.A;
  } else if (insertionIndex === 2) {
    return TaskLevel.B;
  } else {
    return TaskLevel.C;
  }
}
// 4. 获取等级排序权重
export function levelSortWeight(level: TaskLevel): number {
  switch (level) {
    case TaskLevel.S:
      return 0;
    case TaskLevel.A:
      return 1;
    case TaskLevel.B:
      return 2;
    case TaskLevel.C:
      return 3;
    default:
      return 4;
  }
}

export class Task {
  id: string;                // 任务唯一标识
  title: string;             // 任务标题
  level: TaskLevel;          // 任务等级(S/A/B/C)
  date: string;              // 任务日期
  completed: boolean;        // 完成状态(默认false)
  insertionIndex: number;    // 插入位置索引

  // 构造函数初始化任务对象
  constructor(
    id: string,
    title: string,
    level: TaskLevel,
    date: string,
    insertionIndex: number
  ) {
    this.id = id;
    this.title = title;
    this.level = level;
    this.date = date;
    this.completed = false;   // 让新建任务默认使用未完成状态
    this.insertionIndex = insertionIndex;
  }
}
