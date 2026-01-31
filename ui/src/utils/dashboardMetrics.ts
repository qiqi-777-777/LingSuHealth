export type ComparisonType = 'week' | 'day';
export type TrendDirection = 'up' | 'down' | 'flat';

export interface ComparisonResult {
  type: ComparisonType;
  percent: number;
  diff: number;
  direction: TrendDirection;
}

export interface MetricAnomalyRule {
  min?: number;
  max?: number;
  percentChangeThreshold?: number;
  diffThreshold?: number;
}

export interface MetricAnomaly {
  reason: string;
  time: string;
}

export function calculateComparison(
  current: number,
  previous: number,
  type: ComparisonType
): ComparisonResult {
  const diff = current - previous;
  const direction: TrendDirection = diff === 0 ? 'flat' : diff > 0 ? 'up' : 'down';
  const percent =
    previous === 0
      ? current === 0
        ? 0
        : 100
      : Number(((diff / Math.abs(previous)) * 100).toFixed(1));

  return { type, percent, diff, direction };
}

export function buildComparisons(current: number, lastWeek: number, yesterday: number): ComparisonResult[] {
  return [
    calculateComparison(current, lastWeek, 'week'),
    calculateComparison(current, yesterday, 'day')
  ];
}

export function evaluateAnomaly(
  current: number,
  comparisons: ComparisonResult[],
  rule: MetricAnomalyRule,
  timeLabel: string
): MetricAnomaly | null {
  if (typeof rule.min === 'number' && current < rule.min) {
    return { reason: `低于阈值 ${rule.min}`, time: timeLabel };
  }

  if (typeof rule.max === 'number' && current > rule.max) {
    return { reason: `高于阈值 ${rule.max}`, time: timeLabel };
  }

  const pct = rule.percentChangeThreshold;
  if (typeof pct === 'number') {
    const hit = comparisons.find((c) => Math.abs(c.percent) >= pct);
    if (hit) {
      return { reason: `波动超过 ${pct}%（较${hit.type === 'week' ? '上周' : '昨日'}）`, time: timeLabel };
    }
  }

  const diffTh = rule.diffThreshold;
  if (typeof diffTh === 'number') {
    const hit = comparisons.find((c) => Math.abs(c.diff) >= diffTh);
    if (hit) {
      return { reason: `变化超过 ${diffTh}（较${hit.type === 'week' ? '上周' : '昨日'}）`, time: timeLabel };
    }
  }

  return null;
}

export function formatSigned(value: number, digits = 0): string {
  const sign = value > 0 ? '+' : value < 0 ? '-' : '';
  const abs = Math.abs(value);
  const fixed = digits > 0 ? abs.toFixed(digits) : Math.round(abs).toString();
  return `${sign}${fixed}`;
}
