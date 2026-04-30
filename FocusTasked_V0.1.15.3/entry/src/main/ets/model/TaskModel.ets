export enum TaskLevel {
  S = 'S',
  A = 'A',
  B = 'B',
  C = 'C'
}

export function getLevelDesc(level: TaskLevel): string {
  switch (level) {
    case TaskLevel.S:
      return 'S级紧急任务，请优先完成。';
    case TaskLevel.A:
      return 'A级任务，请尽快安排完成。';
    case TaskLevel.B:
      return 'B级任务，建议近期安排完成。';
    case TaskLevel.C:
      return 'C级普通任务，可择日安排完成。';
    default:
      return '';
  }
}

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

export function autoGrade(insertionIndex: number): TaskLevel {
  if (insertionIndex === 0) {
    return TaskLevel.S;
  }
  if (insertionIndex === 1) {
    return TaskLevel.A;
  }
  if (insertionIndex === 2) {
    return TaskLevel.B;
  }
  return TaskLevel.C;
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

export interface CreateTaskInput {
  title: string;
  date: string;
  level?: TaskLevel;
  idSeed: string;
}

function cloneTask(task: Task): Task {
  const copy = new Task(task.id, task.title, task.level, task.date, task.insertionIndex);
  copy.completed = task.completed;
  return copy;
}

function buildTaskId(idSeed: string): string {
  return `task-${Date.now()}-${idSeed}`;
}

export function getTasksForDate(allTasks: Task[], date: string): Task[] {
  return allTasks
    .filter((task) => task.date === date)
    .sort((a, b) => {
      const levelDiff = levelSortWeight(a.level) - levelSortWeight(b.level);
      if (levelDiff !== 0) {
        return levelDiff;
      }

      return a.insertionIndex - b.insertionIndex;
    });
}

export function countTasksForDate(allTasks: Task[], date: string): number {
  return allTasks.filter((task) => task.date === date).length;
}

export function countPendingTasksByLevel(allTasks: Task[], level: TaskLevel): number {
  return allTasks.filter((task) => task.level === level && !task.completed).length;
}

export function hasTasksOnDate(allTasks: Task[], date: string): boolean {
  return allTasks.some((task) => task.date === date);
}

export function createTask(allTasks: Task[], input: CreateTaskInput): Task {
  const normalizedTitle = input.title.trim();
  if (normalizedTitle.length === 0) {
    throw new Error('TASK_TITLE_REQUIRED');
  }

  const insertionIndex = countTasksForDate(allTasks, input.date);
  const level = input.level ?? autoGrade(insertionIndex);
  return new Task(
    buildTaskId(input.idSeed),
    normalizedTitle,
    level,
    input.date,
    insertionIndex
  );
}

export function addTask(allTasks: Task[], input: CreateTaskInput): Task[] {
  const task = createTask(allTasks, input);
  return [...allTasks, task];
}

export function deleteTaskById(allTasks: Task[], id: string): Task[] {
  return allTasks.filter((task) => task.id !== id);
}

export function toggleTaskComplete(allTasks: Task[], id: string): Task[] {
  return allTasks.map((task) => {
    if (task.id !== id) {
      return task;
    }

    const copy = cloneTask(task);
    copy.completed = !task.completed;
    return copy;
  });
}

export function updateTaskLevel(allTasks: Task[], id: string, level: TaskLevel): Task[] {
  return allTasks.map((task) => {
    if (task.id !== id) {
      return task;
    }

    const copy = cloneTask(task);
    copy.level = level;
    return copy;
  });
}
