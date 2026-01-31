import { describe, it, expect } from 'vitest';
import { buildComparisons, calculateComparison, evaluateAnomaly, formatSigned } from '../utils/dashboardMetrics';

describe('dashboardMetrics utils', () => {
  it('calculates comparison direction and percent', () => {
    const result = calculateComparison(120, 100, 'week');
    expect(result.direction).toBe('up');
    expect(result.percent).toBe(20);
    expect(result.diff).toBe(20);
  });

  it('handles zero baseline comparison', () => {
    const result = calculateComparison(10, 0, 'day');
    expect(result.percent).toBe(100);
    expect(result.direction).toBe('up');
  });

  it('builds week and day comparisons', () => {
    const results = buildComparisons(7, 5, 6);
    expect(results).toHaveLength(2);
    expect(results.at(0)?.type).toBe('week');
    expect(results.at(1)?.type).toBe('day');
  });

  it('evaluates anomaly by threshold rules', () => {
    const comparisons = buildComparisons(12, 6, 8);
    const anomaly = evaluateAnomaly(12, comparisons, { percentChangeThreshold: 50 }, 'now');
    expect(anomaly?.reason).toContain('波动超过');
  });

  it('formats signed values', () => {
    expect(formatSigned(3)).toBe('+3');
    expect(formatSigned(-2)).toBe('-2');
    expect(formatSigned(0)).toBe('0');
  });
});
