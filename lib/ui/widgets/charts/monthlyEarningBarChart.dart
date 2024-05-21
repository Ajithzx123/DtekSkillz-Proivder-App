import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class MonthlyEarningBarChart extends StatefulWidget {

  const MonthlyEarningBarChart({super.key, required this.monthlySales});
  final List<MonthlySales> monthlySales;

  @override
  State<MonthlyEarningBarChart> createState() => _MonthlyEarningBarChartState();
}

class _MonthlyEarningBarChartState extends State<MonthlyEarningBarChart> {
  int maxAmount = 0;

  @override
  void initState() {
    if (widget.monthlySales.isNotEmpty) {
      final List<int> list = widget.monthlySales.map((MonthlySales e) => int.parse(e.totalAmount!)).toList();

      maxAmount = list.reduce(max);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'monthlySales'.translate(context: context),
          style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 25,
        ),
        Expanded(
          child: BarChart(
            mainBarData(),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  BarChartGroupData makeGroupData(int x, double y,
      {bool isTouched = false,
      double width = 22,
      List<int>? showTooltips,
      LinearGradient? barChartRodGradient,}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          gradient: barChartRodGradient ??
              LinearGradient(
                  colors: [Colors.green.shade300, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,),
          toY: isTouched ? y + 1 : y,
          width: width,
          /* color: isTouched
              ? Theme.of(context).colorScheme.blackColor.withOpacity(0.5)
              : Theme.of(context).colorScheme.blackColor,*/
          borderRadius:
              const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          borderSide: isTouched
              ? BorderSide(color: Theme.of(context).colorScheme.blackColor)
              : BorderSide(
                  color: Theme.of(context).colorScheme.blackColor.withOpacity(0.7), width: 0,),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() {
    return List.generate(widget.monthlySales.length, (int index) {
      int? colorIndex;
      colorIndex = index >= gradientColorForBarChart.length ? findColorIndex(index: index) : index;
      return makeGroupData(index, double.parse(widget.monthlySales[index].totalAmount!),
          width: (MediaQuery.sizeOf(context).width * 0.7) /
              (widget.monthlySales.length > 3 ? widget.monthlySales.length : 3),
          barChartRodGradient: gradientColorForBarChart[colorIndex!],);
    });
  }

  BarChartData mainBarData() {
    return BarChartData(
      maxY: maxAmount + 500,
      alignment: BarChartAlignment.spaceEvenly,
      backgroundColor: Theme.of(context).colorScheme.primaryColor,
      barTouchData: BarTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent e, BarTouchResponse? f) {},
        touchTooltipData: BarTouchTooltipData(
          // tooltipBgColor: ColorsRes.appColor,
          tooltipBgColor: Theme.of(context).colorScheme.blackColor,

          getTooltipItem: (BarChartGroupData group, int groupIndex, BarChartRodData rod, int rodIndex) {
            final String selectedDate = widget.monthlySales[group.x].month ?? '';
            final String salesCount = widget.monthlySales[group.x].totalAmount ?? '';
            return BarTooltipItem(
                '',
                TextStyle(
                  color: Theme.of(context).colorScheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: '$selectedDate\n',
                  ),
                  TextSpan(
                      text: UiUtils.getPriceFormat(context, double.parse(salesCount)),
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),)
                ],);
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getMonthTitle,
            reservedSize: 38,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              interval: maxAmount / 4,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Container(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    '${double.parse(
                      value.toString(),
                    )} ',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.end,
                  ),
                );
              },),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Theme.of(context).colorScheme.blackColor),
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: true,
      ),
    );
  }

  Widget getMonthTitle(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${widget.monthlySales[value.toInt()].month?.toLowerCase().translate(context: context)}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), softWrap: true,),
    );
  }

  dynamic findColorIndex({required int index}) {
    final int difference = index - gradientColorForBarChart.length;
    if (difference < gradientColorForBarChart.length) {
      return difference;
    }
    return findColorIndex(index: difference);
  }
}
