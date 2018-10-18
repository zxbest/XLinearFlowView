# XLinearFlowView

[![CI Status](https://img.shields.io/travis/吴新庭/XLinearFlowView.svg?style=flat)](https://travis-ci.org/吴新庭/XLinearFlowView)
[![Version](https://img.shields.io/cocoapods/v/XLinearFlowView.svg?style=flat)](https://cocoapods.org/pods/XLinearFlowView)
[![License](https://img.shields.io/cocoapods/l/XLinearFlowView.svg?style=flat)](https://cocoapods.org/pods/XLinearFlowView)
[![Platform](https://img.shields.io/cocoapods/p/XLinearFlowView.svg?style=flat)](https://cocoapods.org/pods/XLinearFlowView)

## Doc
> 为减小学习、使用成本，控件接口、协议均参照`UICollectionView.h`，以下不单独说明，详细请见`XLinearFlowView.h`  

1. 初始布局  

	1. 设置默认整体内边距为`UIEdgeInsetsZero`，设置默认标签间距为10，标记渲染位置`layoutPoint`为`(insets.left, insets.top)`
	2. 将标签渲染在`layoutPoint`位置，并更新`layoutPoint.x`为该标签尾部+标签间距  
	3. 判断`layoutPoint`是否超出布局边界，如果超出，换行并更新`layoutPoint = (insets.left, 第二行起始y)`  
	4. 重复2、3

2. 交互时的布局  

	1. 交互开始时，标记被交互的Cell，初始索引、目标索引（初始索引），初始位置（point），目标位置（frame）  
	2. 交互进行时，更新Cell位置、更新初始位置为当前点  
	3. 检测碰撞（是否与已有标签重叠），如果是，更新目标索引为被碰撞标签索引，触发重排，更新目标位置，更新初始索引为目标索引  
	4. 重复2、3
	5. 交互结束或取消时，将被交互Cell移动到目标位置，重置各记录变量。  
  
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

XLinearFlowView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XLinearFlowView'
```

## Author

吴新庭, wu.xinting@hotmail.com

## License

XLinearFlowView is available under the MIT license. See the LICENSE file for more info.
