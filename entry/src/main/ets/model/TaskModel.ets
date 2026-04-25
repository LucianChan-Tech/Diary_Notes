export enum TaskLevel {
  S = 'S',
  A = 'A',
  B = 'B',
  C = 'C'
}

export function getLevelDesc(level: TaskLevel): string {
  switch (level) {
    case TaskLevel.S:
      return 'S级 - 今天完成';
    case TaskLevel.A:
      return 'A级 - 2天内完成';
    case TaskLevel.B:
      return 'B级 - 4天内完成';
    case TaskLevel.C:
      return 'C级 - 1周内完成';
    default:
      return '';
  }
}

export function getLevelColor(level: TaskLevel): string {
  switch (level) {
    case TaskLevel.S:
      return '#E53935';
    case TaskLevel.A:
      return '#FB8C00';
    case TaskLevel.B:
      return '#FDD835';
    case TaskLevel.C:
      return '#1E88E5';
    default:
      return '#757575';
  }
}

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
  id: string;
  title: string;
  level: TaskLevel;
  date: string;
  completed: boolean;
  insertionIndex: number;

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
    this.completed = false;
    this.insertionIndex = insertionIndex;
  }
}
