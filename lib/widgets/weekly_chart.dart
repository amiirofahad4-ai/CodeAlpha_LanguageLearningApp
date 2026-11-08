import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/utils/context_ext.dart';
import '../core/utils/date_utils.dart';

/// Bar chart of XP earned on each of the last 7 days.
class WeeklyActivityChart extends StatelessWidget {
  const WeeklyActivityChart({super.key, required this.days});

  /// (day, xp), oldest first.
  final List<(DateTime, int)> days;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final maxXp = days.fold<int>(0, (m, d) => math.max(m, d.$2));
    // Round the axis up to a friendly number.
    final maxY = math.max(20, ((maxXp / 10).ceil() * 10) + 10).toDouble();
    final interval = maxY / 4;
    final labelStyle = context.text.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outline,
            strokeWidth: 1,
            dashArray: const [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: interval,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(value.toInt().toString(), style: labelStyle),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    DateUtilsX.shortWeekday(days[i].$1),
                    style: labelStyle,
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${rod.toY.toInt()} XP',
              TextStyle(
                color: scheme.onInverseSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < days.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: days[i].$2.toDouble(),
                  width: 18,
                  // Highlight today
                  color: i == days.length - 1
                      ? scheme.primary
                      : scheme.primary.withValues(alpha: 0.45),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: scheme.primary.withValues(alpha: 0.06),
                  ),
                ),
              ],
            ),
        ],
      ),
      duration: const Duration(milliseconds: 500),
    );
  }
}
