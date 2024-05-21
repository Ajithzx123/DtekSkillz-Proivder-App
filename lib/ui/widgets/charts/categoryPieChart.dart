import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class CategoryPieChart extends StatefulWidget {

  const CategoryPieChart({super.key, required this.categoryProductCounts});
  final List<CaregoriesStatesModel> categoryProductCounts;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  List<Color> colors = [];

  @override
  void initState() {
    Future.delayed(
        Duration.zero,
        () => colors = List.generate(
            widget.categoryProductCounts.length,
            (int index) => Color.fromRGBO(
                  Random().nextInt(255),
                  Random().nextInt(255),
                  Random().nextInt(255),
                  1,
                ),),).then((List<Color> value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (colors.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'categryCount'.translate(context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.blackColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 10,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      startDegreeOffset: 180,
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: List.generate(widget.categoryProductCounts.length, (int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Indicator(
                            color: colors[index],
                            text:
                                ' ${widget.categoryProductCounts[index].name} (${widget.categoryProductCounts[index].totalServices})',
                            textColor: touchedIndex == index
                                ? Theme.of(context).colorScheme.blackColor
                                : Theme.of(context).colorScheme.blackColor,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.categoryProductCounts.length, (int i) {
      final bool isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25.0 : 16.0;
      final double radius = isTouched ? 55.0 : 50.0;

      return PieChartSectionData(
        color: colors[i],
        value: int.parse(widget.categoryProductCounts[i].totalServices!).toDouble(),
        title: '',
        radius: radius,
        borderSide:
            isTouched ? BorderSide(color: Theme.of(context).colorScheme.primaryColor) : null,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isTouched
              ? Theme.of(context).colorScheme.blackColor
              : Theme.of(context).colorScheme.lightGreyColor,
        ),
      );
    });
  }
}
