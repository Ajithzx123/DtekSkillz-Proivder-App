import 'package:flutter/material.dart';

import '../../../app/generalImports.dart';

class FilterByBottomSheet extends StatefulWidget {

  const FilterByBottomSheet(
      {super.key,
      required this.minRange,
      required this.maxRange,
      required this.selectedMaxRange,
      required this.selectedMinRange,
      this.selectedRating,});
  final double minRange;
  final double maxRange;
  final double selectedMinRange;
  final double selectedMaxRange;
  final String? selectedRating;

  @override
  State<FilterByBottomSheet> createState() => _FilterByBottomSheetState();
}

class _FilterByBottomSheetState extends State<FilterByBottomSheet> {
  late String selectedRating = widget.selectedRating ?? 'All';
  late double startRange = widget.minRange;
  late double endRange = widget.maxRange;
  List<CategoryModel>? selectedCategories;
  late RangeValues filterPriceRange = RangeValues(
      widget.minRange > widget.selectedMinRange ? widget.minRange : widget.selectedMinRange,
      widget.maxRange < widget.selectedMaxRange ? widget.selectedMaxRange : widget.maxRange,);
  List ratingFilterValues = ['All', '5', '4', '3', '2', '1'];

  String? _getCategoryNames() {
    final List<String?>? categoriesName = selectedCategories?.map((CategoryModel category) => category.name).toList();

    return categoriesName?.join(',');
  }

  Widget _getBottomSheetTitle() {
    return Center(
      child: Text(
        'filter'.translate(context: context),
        style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 24.0,),
      ),
    );
  }

  Widget _getTitle(String title) {
    // Category
    return Text(title,
        style: TextStyle(
            color: Theme.of(context).colorScheme.blackColor,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.normal,
            fontSize: 18.0,),
        textAlign: TextAlign.left,);
  }

  Widget _showSelectedCategory() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // All categories
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.80,
          child: Text(
              selectedCategories == null
                  ? 'allCategories'.translate(context: context)
                  : _getCategoryNames() ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.lightGreyColor,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 12.0,),
              textAlign: TextAlign.left,),
        ),
        // Edit
        Expanded(
          child: InkWell(
            onTap: () async {
              selectedCategories = await showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                builder: (BuildContext context) {
                  return CategoryBottomSheet(
                    initialySelected: selectedCategories,
                  );
                },
              );
              setState(() {});
            },
            child: Text('edit'.translate(context: context),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.accentColor,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 14.0,
                    decoration: TextDecoration.underline,),
                textAlign: TextAlign.right,),
          ),
        )
      ],
    );
  }

  Widget _getBudgetFilterLableAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _getTitle('budget'.translate(context: context)),
        Text(
            '${UiUtils.getPriceFormat(context, double.parse(filterPriceRange.start.toStringAsFixed(2)))}-${UiUtils.getPriceFormat(context, double.parse(filterPriceRange.end.toStringAsFixed(2)))}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.blackColor,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
              fontSize: 14.0,
            ),
            textAlign: TextAlign.right,)
      ],
    );
  }

  Widget _getBudgetFilterRangeSlider() {
    return RangeSlider(
        activeColor: Theme.of(context).colorScheme.accentColor,
        inactiveColor: Theme.of(context).colorScheme.lightGreyColor,
        values: filterPriceRange,
        max: widget.maxRange,
        min: widget.minRange,
        onChanged: (RangeValues newValue) {
          filterPriceRange = newValue;
          setState(() {});
        },);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryColor,
          borderRadius: const BorderRadiusDirectional.only(
              topEnd: Radius.circular(20), topStart: Radius.circular(20),),),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                child: _getBottomSheetTitle(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.4)),
                    Row(
                      children: [
                        _getTitle('category'.translate(context: context)),
                        const Spacer(),
                        if (selectedCategories != null) ...[
                          GestureDetector(
                            onTap: () {
                              //reset
                              selectedCategories = null;
                              setState(() {});
                            },
                            child: Text(
                              'clear'.translate(context: context),
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Theme.of(context).colorScheme.blackColor,
                                  fontSize: 12,),
                            ),
                          )
                        ]
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _showSelectedCategory(),
                    const SizedBox(
                      height: 5,
                    ),

                    if (widget.maxRange > 1) ...{
                      Divider(color: Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.4)),
                      const SizedBox(
                        height: 5,
                      ),
                      _getBudgetFilterLableAndPrice(),
                      _getBudgetFilterRangeSlider(),
                    },
                    const SizedBox(
                      height: 5,
                    ),
                    Divider(color: Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.4)),

                    // _showCurrentLocationContainer(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: _getTitle('rating'.translate(context: context)),
          ),
          _getRatingFilterValues(),
          const Spacer(),
          _showCloseAndApplyButton(),
        ],
      ),
    );
  }

  Widget _getRatingFilterValues() {
    return Container(
      padding: const EdgeInsetsDirectional.only(top: 15.0),
      height: 55,
      width: double.infinity,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        children: List.generate(
            ratingFilterValues.length,
            (int index) => GestureDetector(
                  onTap: () {
                    selectedRating = ratingFilterValues[index];
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(
                      end: 15.0,
                    ),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(7)),
                        color: ratingFilterValues[index] == selectedRating
                            ? Theme.of(context).colorScheme.accentColor
                            : null,
                        border: Border.all(
                            color: ratingFilterValues[index] == selectedRating
                                ? Theme.of(context).colorScheme.accentColor
                                : Theme.of(context).colorScheme.lightGreyColor,),),
                    child: Center(
                      child: Text('★ ${ratingFilterValues[index]}',
                          style: TextStyle(
                              color: ratingFilterValues[index] == selectedRating
                                  ? AppColors.whiteColors
                                  : null,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 18.0,),
                          textAlign: TextAlign.center,),
                    ),
                  ),
                ),),
      ),
    );
  }

  Widget _showCloseAndApplyButton() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryColor,
                ),
                child: Center(
                  child: Text(
                    'close'.translate(context: context),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0,),
                  ),
                ),),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              ServiceFilterDataModel? filterModel;
              if (selectedCategories?.length == 1) {
                filterModel = ServiceFilterDataModel(
                    rating: selectedRating,
                    categoryId: selectedCategories?[0].id.toString(),
                    maxBudget: (filterPriceRange.end).toString(),
                    minBudget: filterPriceRange.start.toString(),);
              } else if (selectedCategories?.isNotEmpty ?? false) {
                if (selectedCategories!.length > 1) {
                  final String categoryIDs = selectedCategories!.map((CategoryModel e) => e.id).toList().join(',');
                  filterModel = ServiceFilterDataModel(
                      rating: selectedRating,
                      caetgoryIds: categoryIDs,
                      maxBudget: (filterPriceRange.end).toString(),
                      minBudget: filterPriceRange.start.toString(),);
                }
              } else {
                filterModel = ServiceFilterDataModel(
                    rating: selectedRating.toLowerCase() == 'all' ? null : selectedRating,
                    maxBudget: (filterPriceRange.end).toString(),
                    minBudget: filterPriceRange.start.toString(),);
              }

              Navigator.pop(context, filterModel);
            },
            child: Container(
                height: 44,
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      color: Color(0x1c343f53),
                      offset: Offset(0, -3),
                      blurRadius: 10,)
                ], color: Theme.of(context).colorScheme.accentColor,),
                child: // Apply Filter
                    Center(
                  child: Text(
                    'applyfilter'.translate(context: context),
                    style: TextStyle(
                        color: AppColors.whiteColors,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0,),
                  ),
                ),),
          ),
        )
      ],
    );
  }
}

class CategoryBottomSheet extends StatefulWidget {

  const CategoryBottomSheet({super.key, this.initialySelected});
  final List<CategoryModel>? initialySelected;

  @override
  State<CategoryBottomSheet> createState() => _CategoryBottomSheetState();
}

class _CategoryBottomSheetState extends State<CategoryBottomSheet> {
  late List<CategoryModel> selectedCategory = widget.initialySelected ?? [];
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_pageScrollListen);

  void _pageScrollListen() {
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchServiceCategoryCubit>().hasMoreData()) {
        context.read<FetchServiceCategoryCubit>().fetchMoreCategories();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * .77,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryColor,
          borderRadius: const BorderRadiusDirectional.only(
              topEnd: Radius.circular(20), topStart: Radius.circular(20),),),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text('category'.translate(context: context),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.blackColor,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontSize: 24.0,),
                  textAlign: TextAlign.center,),
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.lightGreyColor.withOpacity(0.4)),
          Expanded(
            child: SingleChildScrollView(
              //clipBehavior: Clip.none,
              child: BlocBuilder<FetchServiceCategoryCubit, FetchServiceCategoryState>(
                builder: (BuildContext context, FetchServiceCategoryState state) {
                  if (state is FetchServiceCategoryInProgress) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.whiteColors,
                      ),
                    );
                  }

                  if (state is FetchServiceCategorySuccess) {
                    if (state.serviceCategories.isEmpty) {
                      return NoDataContainer(titleKey: 'noDataFound'.translate(context: context));
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.serviceCategories.length,
                            itemBuilder: (BuildContext context, int i) {
                              return recursiveExpansionList(
                                state.serviceCategories[i].toJson(),
                              );
                            },),
                        if (state.isLoadingMoreServicesCategory)
                          CircularProgressIndicator(
                            color: AppColors.whiteColors,
                          )
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ),
          ),
          _showCloseAndApplyButton(),
        ],
      ),
    );
  }

  Widget _showCloseAndApplyButton() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
                height: 44,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryColor),
                child: Center(
                  child: Text(
                    'close'.translate(context: context),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.blackColor,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0,),
                  ),
                ),),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.pop(context, selectedCategory);
            },
            child: Container(
                height: 44,
                decoration: BoxDecoration(boxShadow: const [
                  BoxShadow(
                      color: Color(0x1c343f53),
                      offset: Offset(0, -3),
                      blurRadius: 10,)
                ], color: Theme.of(context).colorScheme.accentColor,),
                child: // Apply Filter
                    Center(
                  child: Text(
                    'apply'.translate(context: context),
                    style: TextStyle(
                        color: AppColors.whiteColors,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0,),
                  ),
                ),),
          ),
        )
      ],
    );
  }

  Widget recursiveExpansionList(Map map) {
    List subList = [];
    subList = map['subCategory'] ?? [];
    final bool contains = selectedCategory
        .where((CategoryModel element) {
          return element.id == map['id'];
        })
        .toSet()
        .isNotEmpty;
    if (subList.isNotEmpty) {
      if (map['level'] == 0) {
        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            map['name'],
          ),
          children: subList.map((e) => recursiveExpansionList(e)).toList(),
        );
      } else {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 15.0),
          child: ExpansionTile(
            title: Text(map['name']),
            children: subList.map((e) => recursiveExpansionList(e)).toList(),
          ),
        );
      }
    } else {
      if (map['level'] == 0) {
        return ListTile(
          title: Text(map['name']),
          leading: Checkbox(
              value: contains,
              fillColor: MaterialStateProperty.all(Theme.of(context).colorScheme.blackColor),
              onChanged: (bool? val) {
                final CategoryModel categoryModel = CategoryModel(
                  id: map['id'],
                  name: map['name'],
                );
                if (contains) {
                  selectedCategory.removeWhere((CategoryModel e) => e.id == map['id']);
                } else {
                  selectedCategory.add(categoryModel);
                }

                setState(() {});
              },),
        );
      } else {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 15.0),
          child: ListTile(
            onTap: () {
              final CategoryModel categoryModel = CategoryModel(
                id: map['id'],
                name: map['name'],
              );
              if (contains) {
                selectedCategory.removeWhere((CategoryModel e) => e.id == map['id']);
              } else {
                selectedCategory.add(categoryModel);
              }

              setState(() {});
            },
            title: Text(map['name']),
            leading: Checkbox(
                fillColor: MaterialStateProperty.all(Theme.of(context).colorScheme.blackColor),
                value: contains,
                onChanged: (bool? val) {
                  final CategoryModel categoryModel = CategoryModel(
                    id: map['id'],
                    name: map['name'],
                  );
                  if (contains) {
                    selectedCategory.removeWhere((CategoryModel e) => e.id == map['id']);
                  } else {
                    selectedCategory.add(categoryModel);
                  }

                  setState(() {});
                },),
          ),
        );
      }
    }
  }
}
