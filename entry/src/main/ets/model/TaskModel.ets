/**
 * Task priority levels:
 *   S – Must be completed today
 *   A – Must be completed within 2 days
 *   B – Must be completed within 4 days
 *   C – Must be completed within 1 week
 */
export enum TaskLevel {
  S = 'S',
  A = 'A',
  B = 'B',
  C = 'C'
}

/** Returns a human-readable description for each priority level. */
export function getLevelDesc(level: TaskLevel): string {
  switch (level) {
    case TaskLevel.S:
      return 'S级 — 今天必须完成';
    case TaskLevel.A:
      return 'A级 — 2天内必须完成';
    case TaskLevel.B:
      return 'B级 — 4天内必须完成';
    case TaskLevel.C:
      return 'C级 — 一周内必须完成';
    default:
      return '';
  }
}

/** Returns the accent color associated with each priority level. */
export function getLevelColor(level: TaskLevel): string {
  switch (level) {
    case TaskLevel.S:
      return '#E53935'; // red
    case TaskLevel.A:
      return '#FB8C00'; // orange
    case TaskLevel.B:
      return '#FDD835'; // yellow
    case TaskLevel.C:
      return '#1E88E5'; // blue
    default:
      return '#757575';
  }
}

/**
 * Auto-grades a task based on its insertion order within a given day.
 *
 * Current rule (placeholder – easy to extend):
 *   1st task  → S
 *   2nd task  → A
 *   3rd task  → B
 *   4th+ task → C
 *
 * To customise the grading logic, update only this function.
 */
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

/** Returns the sort weight for a level (lower = higher priority). */
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

/** Represents a single work item (diary note / task). */
export class Task {
  id: string;
  title: string;
  level: TaskLevel;
  /** Date key in "YYYY-MM-DD" format. */
  date: string;
  completed: boolean;
  /** Insertion order within the day; drives auto-grading. */
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
