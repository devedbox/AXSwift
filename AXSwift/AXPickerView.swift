//
//  AXPickerView.swift
//  20150718
//
//  Created by ai on 15/7/19.
//  Copyright © 2015年 ai. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

/// Default tint color
public let AXDefaultTintColor = UIColor(red: 0.059, green: 0.059, blue: 0.059, alpha: 1.00)
/// Default selected color
public let AXDefaultSelectedColor = UIColor(red: 0.294, green: 0.808, blue: 0.478, alpha: 1.00)
/// Default seperator color
public let AXDefaultSeperatorColor = UIColor(red: 0.824, green: 0.824, blue: 0.824, alpha: 1.00)
/// Default background color
public let AXDefaultBackgroundColor = UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 0.70)
/// Default height of tool bar
public let AXPickerToolBarHeight: CGFloat = 44.0
/// Default height of date picker and common picker
public let AXPickerHeight: CGFloat = 216.0
/// Type of (index, height, insets, backgroundColor) of seperators
public typealias AXPickerViewSeperatorConfiguration = (Int, CGFloat?, UIEdgeInsets?, UIColor?)
/// Type of (index, tintColor, textFont) of items
public typealias AXPickerViewItemConfiguration = (Int, UIColor?, UIFont?)
@available(iOS 7.0, *)
/// Completion closure
///
/// :param: pickerView a instance picker view
public typealias AXCompletion = (pickerView:AXPickerView) -> ()
@available(iOS 7.0, *)
/// Revoking closure
///
/// :param: pickerView a instance picker view
public typealias AXRevoking = (pickerView: AXPickerView) -> ()
@available(iOS 7.0, *)
/// Executing closure
///
/// :param: selectedTitle a selected title of picker view
/// :param: atIndex a index of selected item
/// :param: inPickerView a instance picker view
public typealias AXExecuting = (selectedTitle: String, atIndex: Int, inPickerView: AXPickerView) -> ()
@available(iOS 7.0, *)
/// Configuration closure
///
/// :param: pickerView a instance picker view
public typealias AXConfiguration = (pickerView: AXPickerView) -> ()

@available(iOS 7.0, *)
// Style of AXPickerView
// .Normal is a normal style with a list of title string like UIActionSheet style
// .DatePicker is a date picker
// .CommonPicker is a UIPickerView with the custom data
public enum AXPickerViewStyle: Int {
    /// A style using String items
    case Normal = 0
    /// A style of date picker
    case DatePicker
    /// A style of custom data picker
    case CommonPicker
}

@available(iOS 7.0, *)
// Protocol a protocol when picker view showing and hiding and confirming i.e.
// When showing, call method "pickerViewWillShow:" and "pickerViewDidShow:"
// When hiding, call methid "pickerViewWillHide:" and "pickerViewDidHide:"
// When canceled, call method "pickerViewDidCancel:"
// When confirmed, call method "pickerViewDidConfirm:"
// When selected a item, call method "pickerView:didSelectedItem:atIndex:"
@objc public protocol AXPickerViewDelegate: UIPickerViewDelegate {
    /// Called when a picker view will show
    ///
    /// param: pickerView  a intance picker view
    optional func pickerViewWillShow(pickerView: AXPickerView) -> ()
    /// Called when a picker view did show
    optional func pickerViewDidShow(pickerView: AXPickerView) -> ()
    /// Called when a picker view will hide
    optional func pickerViewWillHide(pickerView: AXPickerView) -> ()
    /// Called when a picker view did hide
    optional func pickerViewDidHide(pickerView: AXPickerView) -> ()
    /// Called when a picker view did cancel
    optional func pickerViewDidCancle(pickerView: AXPickerView) -> ()
    /// Called when a picker view did confirm
    optional func pickerViewDidConfirm(pickerView: AXPickerView) -> ()
    /// Called when a picker view did selected a item at a index
    optional func pickerView(pickerView: AXPickerView, didSelectedItem item: String, atIndex index: Int) -> ()
}
// A protocol of CALayer to mark a layer object
public protocol AXLayerTag {
    /// Type of tag value
    typealias TagType
    /// Tag value
    var tag: TagType!{get set}
}
// Datasource of picker view when the style of picker view eaqul to .CommonPicker
@objc public protocol AXPickerViewDataSource: UIPickerViewDataSource {
    
}
/// An extension managed common picker view
extension AXPickerView {
    public func numberOfComponents() -> Int {
        return _commonPicker.numberOfComponents
    }
    public func selectedRowInComponent(componet: Int) -> Int {
        return _commonPicker.selectedRowInComponent(componet)
    }
    
    public func reloadData () -> Void {
        if style == .CommonPicker {
            _commonPicker.reloadAllComponents()
        }
    }
}
/// An extension managed Objective-C
extension AXPickerView {
    public func configureItem(withTintColor tintColor: UIColor?, font: UIFont?, atIndex index: Int) -> Void {
        var configs: [AXPickerViewItemConfiguration] = []
        if let con = itemConfigs {
            configs += con
        }
        let aConfig: AXPickerViewItemConfiguration = (index, tintColor, font)
        configs += [aConfig]
        self.itemConfigs = configs
    }
    
    public func configureSeparator(withColor color: UIColor?, insets: UIEdgeInsets?, height: CGFloat, atIndex index: Int) -> Void
    {
        var configs: [AXPickerViewSeperatorConfiguration] = []
        if let con = seperatorConfigs {
            configs += con
        }
        let aConfig: AXPickerViewSeperatorConfiguration = (index, height, insets, color)
        configs += [aConfig]
        self.seperatorConfigs = configs
    }
}
@available(iOS 7.0, *)
// AXPicerView, a custom view that user can choose a style deciding the look of picker view, and a convenient way to use image picker controller.
// If choosed a Normal style, it would be a look like a sort of buttons arranged in vertical direction
// If choosed a DatePicker or CommonPicker style, it would be a look like UIPickerView
// Please set the value of items when use Normal style
// Please set a value of view because view property is the key view to show pciker view
public class AXPickerView: UIView {
    //MARK: - Internal Properties
    
    /// The items of picker view when style is Normal
    public var items = [String]?() {
        didSet {
            setNeedsDisplay()
        }
    }
    /// The style of pciker view, there would be a diffrent look when set diffrent value
    /// .Normal is a normal style using buttons arranged in vertical direction
    /// .DatePicker is a date picker view
    /// .CommonPicker is a picker view using data source to full fill the data and decide the show of picker view
    public var style: AXPickerViewStyle! {
        didSet {
            switch style! {
            case .Normal:
                seperatorInsets = UIEdgeInsetsMake(0, 20, 0, 20)
            default :
                seperatorInsets = UIEdgeInsetsZero
            }
        }
    }
    /// A view to be super view of picker view and to decide width of picker view's frame
    public weak var view: UIView?
    /// A custom view to be added to the top of picker view
    public var customView: UIView? {
        didSet {
            if customView == nil {
                if let oldView = oldValue {
                    oldView.removeFromSuperview()
                }
            }
            
            setNeedsDisplay()
        }
    }
    /// Title content of picker view
    public var title: String? {
        get {
            return _titleLabel.text
        }
        set {
            _titleLabel.text = newValue
            setNeedsDisplay()
        }
    }
    /// Font of title label
    public var titleFont: UIFont? = UIFont.systemFontOfSize(14) {
        didSet {
            guard let _ = _titleLabel else {
                return
            }
            _titleLabel.font = titleFont!
        }
    }
    /// Text color of title label
    public var titleTextColor: UIColor? = AXDefaultTintColor.colorWithAlphaComponent(CGFloat(0.5)) {
        didSet {
            guard let _ = _titleLabel else {
                return
            }
            _titleLabel.textColor = titleTextColor!
        }
    }
    /// Font of cancel button
    public var cancleFont: UIFont? = UIFont.systemFontOfSize(16) {
        didSet {
            _cancleBtn.titleLabel?.font = cancleFont
        }
    }
    /// Text color of cancel button
    public var cancleTextColor: UIColor? = UIColor(red: 0.973, green: 0.271, blue: 0.231, alpha: 1.00) {
        didSet {
            _cancleBtn.tintColor = cancleTextColor
        }
    }
    /// Font of complete button
    var completeFont: UIFont? = UIFont.systemFontOfSize(16) {
        didSet {
            _completeBtn.titleLabel?.font = completeFont
        }
    }
    /// Text color of complete button
    public var completeTextColor: UIColor? = AXDefaultSelectedColor {
        didSet {
            _completeBtn.tintColor = completeTextColor
        }
    }
    /// The font of button items default : system_18
    public var itemFont: UIFont? = UIFont.systemFontOfSize(18) {
        didSet {
            configureViews()
        }
    }
    /// The tintColor of button items
    public var itemTintColor: UIColor? = nil {
        didSet {
            configureViews()
        }
    }
    /// The custom configurations of items
    public var itemConfigs: [AXPickerViewItemConfiguration]? = [AXPickerViewItemConfiguration]() {
        didSet {
            configureViews()
        }
    }
    
    /// The color of seperators
    public var seperatorColor: UIColor? = AXDefaultSeperatorColor {
        didSet {
            configureViews()
        }
    }
    /// The default insets of seperators
    public var seperatorInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) {
        didSet {
            configureViews()
        }
    }
    /// A list of custom configuration of seperator
    /// Use a type of (Int, UIEdgetInsets)
    public var seperatorConfigs: [AXPickerViewSeperatorConfiguration]? = [(0, CGFloat(0.7), UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), nil)] {
        didSet {
            configureViews()
        }
    }
    /// The content insets of custom view
    public var customViewInsets: UIEdgeInsets? = UIEdgeInsetsMake(5, 5, 5, 5) {
        didSet {
            setNeedsDisplay()
        }
    }
    /// Delegate of picker view
    public weak var delegate: AXPickerViewDelegate? {
        didSet{
            if style == .CommonPicker {
                _commonPicker?.delegate = self.delegate
            }
        }
    }
    /// Data source of picker view
    public weak var dataSource: AXPickerViewDataSource? {
        didSet{
            if style == .CommonPicker {
                _commonPicker?.dataSource = self.dataSource
            }
        }
    }
    /// Get the date if style is .DatePicker
    public var selectedDate: NSDate? {
        return get({ () -> AnyObject? in
            if self.style == .DatePicker {
                let date = self._datePicker.date
                return date
            } else {
                return nil
            }
        }) as? NSDate
    }
    // MARK: - Private And Lazy Properties
    
    /// AllowsMultipleSelection
    private var _allowsMultipleSelection: Bool = false
    /// The paddin value
    private let padding:CGFloat = 5.0
    /// Get the assets of image picker view
    private var assets: AnyObject? {
        get {
            if #available(iOS 8.0, *) {// If > 8.0, use PHFetchResult
                return self._photoAssetsResult
            } else {
                return self._photoAssets
            }
        }
        set {
            if #available(iOS 8.0, *) {
                if let value = newValue as? PHFetchResult {
                    self._photoAssetsResult = value
                }
            } else {
                if let value = newValue as? [ALAsset] {
                    self._photoAssets = value
                }
            }
        }
    }
    /// The completion block when the handler finished
    private var _completion: AXCompletion? = nil
    /// The image picker block when finished the image picking
    private var _imagePickerBlock: AXImagePickerCompletion? = nil
    /// The revoking block when clicked the cancel button or background
    private var _revoking: AXRevoking? = nil
    /// The executing block when selected the item of a index
    private var _executing: AXExecuting? = nil
    /// Decide to remove from super view when picker view hide
    /// True to remove
    /// False not to remove
    /// Default: true
    private var _removeFromSuperViewOnHide: Bool = true
    /// Title label
    private lazy var _titleLabel: UILabel! = {
       [unowned self]() -> UILabel in
        let label = UILabel(frame: CGRectMake(0, 0, AXPickerToolBarHeight * 2.0, AXPickerToolBarHeight))
        label.font = self.titleFont
        label.textColor = self.titleTextColor
        label.backgroundColor = AXDefaultBackgroundColor
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        label.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin).union(UIViewAutoresizing.FlexibleRightMargin)
        return label
    }()
    /// Complete button
    private lazy var _completeBtn: UIButton! = {
        [unowned self]() -> UIButton in
        let button = UIButton(type: .System)
        button.backgroundColor = AXDefaultBackgroundColor
        button.setTitle("完成", forState: .Normal)
        button.tintColor = self.completeTextColor
        button.titleLabel?.font = self.completeFont
        button.addTarget(self, action: "didConfirm:", forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = 1001
        return button
    }()
    /// Cancel button
    private lazy var _cancleBtn: UIButton! = {
       [unowned self]() -> UIButton in
        let button = UIButton(type: .System)
        button.backgroundColor = AXDefaultBackgroundColor
        button.setTitle("取消", forState: .Normal)
        button.tintColor = self.cancleTextColor
        button.titleLabel?.font = self.cancleFont
        button.addTarget(self, action: "didCancle:", forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = 1002
        return button
    }()
    /// Data picker view
    private lazy var _datePicker: UIDatePicker! = {
        [unowned self]() -> UIDatePicker in
        ///Custom initialize date picker
        let picker = UIDatePicker(frame: CGRectMake(0.0, AXPickerToolBarHeight, self.bounds.size.width, AXPickerHeight))
        picker.backgroundColor = AXDefaultBackgroundColor
        picker.timeZone = NSTimeZone(name: "GMT+8")
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let minDate = dateFormat.dateFromString("1900-01-01 00:00:00")
        picker.minimumDate = minDate
        picker.maximumDate = NSDate()
        picker.setDate(NSDate(), animated: true)
        picker.datePickerMode = .Date
        picker.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        return picker
    }()
    /// Common picker view of UIPickerView
    private lazy var _commonPicker: UIPickerView! = {
       [unowned self]() -> UIPickerView in
        ///custom initialize picker view
        let picker = UIPickerView(frame: CGRectMake(0.0, AXPickerToolBarHeight, self.bounds.size.width, AXPickerHeight))
        picker.backgroundColor = AXDefaultBackgroundColor
        picker.delegate = self
        picker.dataSource = self
        picker.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleBottomMargin).union(.FlexibleLeftMargin).union(.FlexibleRightMargin)
        return picker
    }()
    /// Background view to dim the background and Touching-hide picker view
    private lazy var _backgroundView: UIControl! = {
      [unowned self]() -> UIControl in
        let backgroundView = UIControl(frame: CGRectZero)
        backgroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        backgroundView.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        backgroundView.addTarget(self, action: "didTouchBackground:", forControlEvents: UIControlEvents.TouchDown)
        return backgroundView
    }()
    /// The blur effet bar of UIToolBar
    private lazy var _effectBar: UIToolbar! = {
        () -> UIToolbar in
        let effectBar = UIToolbar(frame: CGRectZero)
        effectBar.translucent = true
        effectBar.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
        for view in effectBar.subviews {
            if view is UIImageView {
                view.hidden = true
            }
        }
        return effectBar
        }()
    @available(iOS 8.0, *)
    /// The effect view of UIVisualEffectView with a UIBlurEffect style
    private lazy var _effectView: UIVisualEffectView! = {
      () -> UIVisualEffectView in
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        effectView.tintColor = UIColor.clearColor()
        effectView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
        return effectView
    }()
    @available(iOS 8.0, *)
    /// The effect views of items
    private var _effectViewOfViews: UIVisualEffectView {
        get {
            let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            effectView.frame = CGRectMake(0, 0, self.bounds.width, AXPickerToolBarHeight)
            effectView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(UIViewAutoresizing.FlexibleWidth)
            return effectView
        }
    }
    @available(iOS 8.0, *)
    /// Tht assets result of image picker view
    private lazy var _photoAssetsResult: PHFetchResult? = get() {
        () -> AnyObject? in
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil)
            if let aFetchResult = fetchResult.firstObject {
                let result = PHAsset.fetchAssetsInAssetCollection(aFetchResult as! PHAssetCollection, options: fetchOptions)
                return result
            } else {
                return nil
            }
        } as? PHFetchResult
    /// The photo library of image picker view
    private let _photoLibrary: ALAssetsLibrary = ALAssetsLibrary()
    /// The photo assets of image picker view
    private var _photoAssets: [ALAsset] = [ALAsset]()
    /// Contain camera
    private var _containsCamera: Bool = true
    @available(iOS, introduced=7.0, deprecated=8.0)
    /// Async get the image and reload collection view
    lazy var validPhotoGroup: (() -> Void)? = {
        [unowned self]() -> Void in
        self._photoLibrary.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: {
            (aGroup: ALAssetsGroup!, stopGroup: UnsafeMutablePointer<ObjCBool>) -> Void in
            stopGroup.initialize(ObjCBool(true))
            if aGroup != nil {
                aGroup.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse) {
                    (assets: ALAsset!, index: Int, stopAssets: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if let aAssets = assets {
                        self._photoAssets += [aAssets]
                        if self._photoAssets.count == aGroup.numberOfAssets() - 1 {
                            stopAssets.initialize(ObjCBool(true))
                            if let collectionView = self.customView as? UICollectionView {
                                collectionView.reloadData()
                            }
                        }
                    }
                }
            }
            }, failureBlock: {
                (error: NSError!) -> Void in
                #if DEBUG
                    print(error)
                #endif
        })
    }
    
    //MARK: - Life Cycle
    
    /// Get instance object with a frame.
    ///
    /// :param: frame  a frame of picker view
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initializer()
    }
    /// Get instance of a picker view with a style and items
    convenience init(style: AXPickerViewStyle = .Normal, items: [String]? = nil) {
        self.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 0))
        self.style = style
        self.items = items
        
        switch self.style! {
            
        case .Normal:
            seperatorInsets = UIEdgeInsetsMake(0, 20, 0, 20)
        default :
            seperatorInsets = UIEdgeInsetsZero
        }
    }
    /// A common initializer
    private func initializer() -> () {
        self.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(UIViewAutoresizing.FlexibleWidth)
        backgroundColor = UIColor.clearColor()
        tintColor = AXDefaultTintColor
        if #available(iOS 8.0, *) {
            addSubview(_effectView)
        } else {
            addSubview(_effectBar)
        }
        addObserver(self, forKeyPath: "frame", options: .New, context: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resizingCustomView", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    deinit {
        items?.removeAll()
        removeObserver(self, forKeyPath: "frame")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: - Override
    
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        guard let aStyle = style else {return}
        
        func configureCustomView(inout customView: UIView) -> () {
            
            let originY = {
                () -> CGFloat in
                switch style! {
                case .Normal:
                    if let _ = title?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
                        return AXPickerToolBarHeight
                    } else {
                        return 0.0
                    }
                default:
                    return AXPickerToolBarHeight
                }
                }()
            
            var rect = customView.bounds
            rect.origin.y = originY + (customViewInsets?.top ?? 0)
            rect.origin.x = (customViewInsets?.left ?? 0)
            rect.size.width = self.bounds.width - ((customViewInsets?.left ?? 0) + (customViewInsets?.right ?? 0))
            customView.frame = rect
            
            customView.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin).union(UIViewAutoresizing.FlexibleWidth)
        }
        
        if customView != nil {
            configureCustomView(&(customView!))
            addSubview(customView!)
        }
        
        switch aStyle {
            
        case .Normal:
            if (title != nil && title!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                addSubview(_titleLabel)
            } else {
                _titleLabel.removeFromSuperview()
            }
            
            let buttons = {
                () -> [UIButton] in
                return subviews.filter({
                    (view: UIView) -> Bool in
                    if view is UIButton && view.tag != 1001 && view.tag != 1002 {
                        return true
                    } else {
                        return false
                    }
                }) as! [UIButton]
            }()
            for button in buttons {
                button.removeFromSuperview()
            }
            
            if let titles = items {
                for (index, item) in titles.enumerate() {
                    addSubview(button(atIndex: index, withTitle: item))
                }
            }
        case .DatePicker:
            execute {
                [unowned self]() -> () in
                var seperatorLayer: CALayer_ax!
                let _ = self.layer.sublayers?.contains() {
                    (layer: CALayer) -> Bool in
                    if let aLayer = layer as? CALayer_ax {
                        seperatorLayer = aLayer
                        return true
                    } else {
                        return false
                    }
                }
                if seperatorLayer != nil {
                    seperatorLayer!.removeFromSuperlayer()
                }
                
                if let _ = self.customView {
                    var rect = self._datePicker!.frame
                    rect.origin.y = AXPickerToolBarHeight + self.customView!.bounds.height + (self.customViewInsets!.top ?? 0) + (self.customViewInsets!.bottom ?? 0)
                    self._datePicker!.frame = rect
                } else {
                    var rect = self._datePicker!.frame
                    rect.origin.y = AXPickerToolBarHeight
                    self._datePicker!.frame = rect
                    self.layer.addSublayer(self.seperator(atIndex: 1, height: 1, color: self.seperatorColor ?? AXDefaultSeperatorColor))
                }
            }
            addSubview(_datePicker!)
            addSubview(_titleLabel)
        case .CommonPicker:
            execute {
                [unowned self]() -> () in
                var seperatorLayer: CALayer_ax!
                let _ = self.layer.sublayers?.contains() {
                    (layer: CALayer) -> Bool in
                    if let aLayer = layer as? CALayer_ax {
                        seperatorLayer = aLayer
                        return true
                    } else {
                        return false
                    }
                }
                if seperatorLayer != nil {
                    seperatorLayer!.removeFromSuperlayer()
                }
                
                if let _ = self.customView {
                    var rect = self._commonPicker!.frame
                    rect.origin.y = AXPickerToolBarHeight + self.customView!.bounds.height + (self.customViewInsets!.top ?? 0) + (self.customViewInsets!.bottom ?? 0)
                    self._commonPicker!.frame = rect
                } else {
                    var rect = self._commonPicker!.frame
                    rect.origin.y = AXPickerToolBarHeight
                    self._commonPicker!.frame = rect
                    self.layer.addSublayer(self.seperator(atIndex: 1, height: 1, color: self.seperatorColor ?? AXDefaultSeperatorColor))
                }
            }
            addSubview(_commonPicker!)
            addSubview(_titleLabel)
        }
        
        resizingSelf()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        sizeToFit()
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        var rightSize = super.sizeThatFits(size)
        rightSize.width = UIScreen.mainScreen().bounds.width
        
        guard let aStyle = style else {
            return rightSize
        }
        if aStyle == .DatePicker || aStyle == .CommonPicker {
            rightSize.height = AXPickerHeight + AXPickerToolBarHeight
        } else {
            var height: CGFloat = AXPickerToolBarHeight
            
            if title != nil && title!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
                height += AXPickerToolBarHeight
            }
            
            if let itemCount = items?.count {
                height += AXPickerToolBarHeight * CGFloat(itemCount)
            }
            
            height += padding
            rightSize.height = height
        }
        
        rightSize.height += {
            () -> CGFloat in
                if let _ = customView {
                    return customView!.bounds.height + (customViewInsets!.top ?? 0) + (customViewInsets!.bottom ?? 0)
                } else {
                    return 0
                }
            }()
        
        return rightSize
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if let mySuperView = newSuperview {
            _backgroundView.frame = mySuperView.bounds
        }
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if let _ = self.superview {
            resizingSelf()
            
            guard let aStyle = style else {
                return
            }
            
            configureTools()
            
            switch aStyle {
                
            case .Normal:
                if let count = items?.count {
                    if count > 0 {
                        addSubview(_cancleBtn)
                    }
                }
            case .DatePicker, .CommonPicker:
                addSubview(_completeBtn)
                addSubview(_cancleBtn)
            }
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            if let frame = change?[NSKeyValueChangeNewKey]?.CGRectValue {
                if #available(iOS 8.0, *) {
                    _effectView.frame = CGRectMake(0, 0, frame.width, frame.height)
                } else {
                    _effectBar.frame = CGRectMake(0, 0, frame.width, frame.height)
                }
            }
        }
    }
    
    //MARK: - Public Instance Methods
    
    /// Show in the view with animation.
    /// 
    /// :param: animated  show animated or not
    func show(animated animated: Bool, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        if let aView = view {
            alpha = 0.0
            _backgroundView.alpha = 0.0
            
            _completion = completion
            _revoking = revoking
            _executing = executing
            
            delegate?.pickerViewWillShow?(self)
            aView.addSubview(_backgroundView)
            aView.addSubview(self)
            
            if animated {
                transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(0, self.bounds.height), CGAffineTransformMakeScale(1, 1))
                alpha = 1.0
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(rawValue: 7), animations: { [weak self]() -> Void in
                        self?._backgroundView.alpha = 1.0
                        self?.transform = CGAffineTransformIdentity
                    }, completion: { [weak self](finished) -> Void in
                        self?.delegate?.pickerViewDidShow?(self!)
                    })
            } else {
                alpha = 1.0
                _backgroundView.alpha = 1.0
            }
        }
    }
    /// Hide animated
    func hide(animated animated: Bool, completion: (() -> Void)? = nil) -> () {
        if let _ = superview {
            delegate?.pickerViewWillHide?(self)
            
            UIView.animateWithDuration(
                0.25,
                delay: 0.0,
                options: UIViewAnimationOptions(rawValue: 7),
                animations: { [weak self]() -> Void in
                    self?.transform = CGAffineTransformMakeTranslation(0.0, (self?.bounds.height)!)
                    self?._backgroundView.alpha = 0.0
                },
                completion: { [weak self](finished) -> Void in
                    if finished {
                        if let _self = self {
                            if _self._removeFromSuperViewOnHide  {
                                _self.removeFromSuperview()
                            } else {
                                _self.alpha = 0.0
                            }
                            _self._backgroundView.removeFromSuperview()
                            _self.transform = CGAffineTransformIdentity
                            
                            _self.delegate?.pickerViewDidHide?(_self)
                            
                            if #available(iOS 8.0, *) {
                                PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(_self)
                            } else {
                                NSNotificationCenter.defaultCenter().removeObserver(_self)
                            }
                            completion?()
                        }
                    }
                })
        }
    }
    
    //MARK: - Private Instance Methods
    
    /// Get a button with title and a right height
    private func button(atIndex index: Int, withTitle title: String?, rightHeight height: CGFloat = AXPickerToolBarHeight) -> UIButton {
        let button = UIButton(type: .System)
        button.setTitle(title, forState: .Normal)
        button.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(.FlexibleWidth).union(.FlexibleRightMargin).union(.FlexibleLeftMargin)
        button.backgroundColor = AXDefaultBackgroundColor
        var aItemColor: UIColor!
        var aItemFont: UIFont!
        
        let _ = itemConfigs?.contains() {
            (configs: AXPickerViewItemConfiguration) -> Bool in
            let (aIndex, color, font) = configs
            if aIndex == index {
                aItemColor = color
                aItemFont = font
                return true
            } else {
                return false
            }
        }
        
        button.tintColor = aItemColor ?? (itemTintColor ?? self.tintColor)
        button.titleLabel?.font = aItemFont ?? itemFont
        button.frame = CGRectMake(0, {
            () -> CGFloat in
            var originY = AXPickerToolBarHeight * CGFloat(self.title?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 ? index + 1 : index)
            if let _ = customView {
                originY += customView!.bounds.height + (customViewInsets!.top ?? 0) + (customViewInsets!.bottom ?? 0)
            }
            return originY
            }(), self.bounds.width, height)
        button.tag = index + Int(1)
        button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        var insets: UIEdgeInsets?
        
        let _ = seperatorConfigs?.contains(){
            (config: AXPickerViewSeperatorConfiguration) -> Bool in
            let (aIndex, _, aInsets, _) = config
            if aIndex == index {
                insets = aInsets
                return true
            } else {
                return false
            }
        }
        if index == 0 {
            if customView == nil {
                button.layer.addSublayer(seperator(atIndex: 0, height: 0.5, color: seperatorColor ?? AXDefaultSeperatorColor, insets: insets))
            }
        } else {
            button.layer.addSublayer(seperator(atIndex: 0, height: 0.5, color: seperatorColor ?? AXDefaultSeperatorColor, insets: insets))
        }
        return button
    }
    /// Get a separator layer with a height, color, insets at a index
    private func seperator(atIndex index: Int, height: CGFloat, color: UIColor, insets:UIEdgeInsets? = nil) -> CALayer_ax {
        let layer = CALayer_ax()
        layer.frame = CGRectMake((insets ?? seperatorInsets).left, AXPickerToolBarHeight * CGFloat(index), self.bounds.size.width - ((insets ?? seperatorInsets).left + (insets ?? seperatorInsets).right), height)
        layer.backgroundColor = color.CGColor
        layer.tag = index + 1
        return layer
    }
    /// Configure views
    private func configureViews() -> () {
        _titleLabel.font = titleFont
        _titleLabel.textColor = titleTextColor
        
        switch style! {
            
        case .Normal:
            let buttons = self.subviews.filter() {
                (aView: UIView) -> Bool in
                return aView is UIButton
            }
            
            for (index, button) in (buttons as! [UIButton]).enumerate(){
                let seperatorBlock = {
                    (config: (Int, CGFloat?, UIEdgeInsets?, UIColor?)) -> Bool in
                    let (aIndex, _, _, _) = config
                    return aIndex == index - 1
                }
                
                let itemBlock = {
                    (config:(Int, UIColor?, UIFont?)) -> Bool in
                    let (aIndex, _, _) = config
                    return aIndex == index - 1
                }
                
                let seperatorLayerBlock = {
                    (aLayer: CALayer) -> Bool in
                    return aLayer is CALayer_ax
                }
                
                if seperatorConfigs != nil {
                    if seperatorConfigs!.contains(seperatorBlock) {
                        if let seperatorLayer = button.layer.sublayers?.filter(seperatorLayerBlock).first {
                            let (_, height, insets, backgroundColor) = (seperatorConfigs!.filter(seperatorBlock).first)!
                            var rect = seperatorLayer.frame
                            rect.origin.x = insets?.left ?? 0
                            rect.size.width = self.bounds.width - ((insets?.left)! + (insets?.right)!) ?? 0
                            rect.size.height = CGFloat(height ?? 0.5)
                            seperatorLayer.frame = rect
                            seperatorLayer.backgroundColor = backgroundColor?.CGColor ?? AXDefaultSeperatorColor.CGColor
                        }
                    }
                } else {
                    if let seperatorLayer = button.layer.sublayers?.filter(seperatorLayerBlock).first {
                        seperatorLayer.backgroundColor = (seperatorColor ?? AXDefaultSeperatorColor).CGColor
                        var rect = seperatorLayer.frame
                        rect.origin.x = seperatorInsets.left ?? 0
                        rect.size.width = self.bounds.width - (seperatorInsets.left + seperatorInsets.right) ?? 0
                        seperatorLayer.frame = rect
                    }
                }
                
                if itemConfigs != nil {
                    if itemConfigs!.contains(itemBlock) {
                        let (_, tintColor, textFont) = (itemConfigs!.filter(itemBlock).first)!
                        button.tintColor = tintColor
                        button.titleLabel?.font = textFont
                    }
                } else {
                    button.tintColor = itemTintColor ?? tintColor
                    button.titleLabel?.font = itemFont
                }
            }
            _cancleBtn.titleLabel?.font = cancleFont
            _cancleBtn.tintColor = cancleTextColor
        case .DatePicker, .CommonPicker:
            _completeBtn.titleLabel?.font = completeFont
            _completeBtn.tintColor = completeTextColor
            _cancleBtn.titleLabel?.font = cancleFont
            _cancleBtn.tintColor = cancleTextColor
        }
    }
    /// Configure tools
    private func configureTools() -> () {
        _titleLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(.FlexibleBottomMargin)
        var rect = _titleLabel.frame
        rect.size.height = AXPickerToolBarHeight
        
        switch style! {
            
        case .Normal:
            let size = CGSizeMake(self.bounds.width, AXPickerToolBarHeight)
            _cancleBtn.frame = CGRectMake(0.0, {
                () -> CGFloat in
                var originY = AXPickerToolBarHeight * CGFloat((items?.count ?? 0) + ((title?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) > 0 ? 1 : 0)) + padding
                if let _ = customView {
                    originY += customView!.bounds.height + (customViewInsets!.top ?? 0) + (customViewInsets!.bottom ?? 0)
                }
                return originY
                }(), size.width, size.height)
            _cancleBtn.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin.union(UIViewAutoresizing.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleLeftMargin).union(.FlexibleWidth)
            rect.origin.x = 0
            rect.size.width = bounds.size.width
        case .DatePicker, .CommonPicker:
            let size = CGSizeMake(AXPickerToolBarHeight, AXPickerToolBarHeight)
            _cancleBtn.frame = CGRectMake(0, 0, size.width, size.height)
            _cancleBtn.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleRightMargin)
            _completeBtn.frame = CGRectMake(self.bounds.width - size.width, 0, size.width, size.height)
            _completeBtn.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin)
            rect.size.width = bounds.size.width - AXPickerToolBarHeight * 2.0
            rect.origin.x = (bounds.width - rect.width) / 2
        }
        
        _titleLabel.frame = rect
    }
    /// Animated to set self to a right size
    private func resizingSelf(animated animated: Bool = false) -> () {
        if let aSuperView = superview {
            let size = sizeThatFits(self.bounds.size)
            let originY = aSuperView.bounds.size.height - size.height
            
            var rect = frame
            rect.origin.y = originY
            
            if animated {
                UIView.animateWithDuration(0.25, animations: { [unowned self]() -> Void in
                    self.frame = rect
                    }, completion: nil)
            } else {
                frame = CGRectMake(0, originY, size.width, size.height)
            }
        }
    }
    /// Set size of custom view to a right size
    @objc private func resizingCustomView() {
        if let label = customView as? UILabel {
            let usedSize = label.text!.boundingRectWithSize(CGSizeMake(bounds.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : label.font], context: nil)
            var rect = label.frame
            rect.size.width = ceil(usedSize.width)
            rect.size.height = ceil(usedSize.height)
            label.frame = rect
            
            setNeedsDisplay()
        }
    }
    
    //MARK: - Actions
    
    /// Called when button has been clicked
    @objc private func buttonClicked(sender: UIButton) -> () {
        hide(animated: true) { () -> Void in
            self.delegate?.pickerView?(self, didSelectedItem:sender.titleForState(.Normal) ?? "", atIndex: sender.tag - Int(1))
        }
        if let aExecuting = self._executing {
            aExecuting(selectedTitle: sender.titleForState(.Normal) ?? "", atIndex: sender.tag - Int(1), inPickerView: self)
        }
    }
    /// Called when completed
    @objc private func didConfirm(sender: UIButton) -> () {
        hide(animated: true) { () -> Void in
            self.delegate?.pickerViewDidConfirm?(self)
        }
        if let aCompletion = self._completion {
            aCompletion(pickerView: self)
        }
    }
    /// Called when canceled
    @objc private func didCancle(sender: UIButton) -> () {
        hide(animated: true) { () -> Void in
            self.delegate?.pickerViewDidCancle?(self)
        }
        if let aRevoking = self._revoking {
            aRevoking(pickerView: self)
        }
    }
    /// Called when touched background view
    @objc private func didTouchBackground(sender: UIControl) -> () {
        hide(animated: true) { () -> Void in
            self.delegate?.pickerViewDidCancle?(self)
        }
        if let aRevoking = self._revoking {
            aRevoking(pickerView: self)
        }
    }
    
    //MARK: - UIPickerViewDataSource
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return (dataSource?.numberOfComponentsInPickerView(pickerView))!
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (dataSource?.pickerView(pickerView, numberOfRowsInComponent: component))!
    }
}
/// Reused identifier of image picker collection cell
private let reusedIdentifier = "AXImagePickerCell"
/// Right height of image picker collection cell
private let rightHeight: CGFloat = 220
/// Min width of image picker collection cell
private let minWidth:CGFloat = 110
/// Completion block executed when finished image picking
typealias AXImagePickerCompletion = (picker: AXPickerView, images: [UIImage]) -> Void
/// Image picker executing block
let imagePickerExecuting: AXExecuting = { (title: String, index: Int, pickerView: AXPickerView) -> Void in
    var indexInfo: Int = 0
    if pickerView._containsCamera {
        indexInfo = index
    } else {
        indexInfo = index + 1
    }
    switch indexInfo {
    case 0:
        UIImagePickerController.requestAuthorizationOfCamera(completion: { () -> Void in
                let cameraPickerController = UIImagePickerController()
                cameraPickerController.delegate = pickerView
                if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                    cameraPickerController.sourceType = .Camera
                    if let rootViewController = pickerView.window?.rootViewController {
                        pickerView._removeFromSuperViewOnHide = false
                        rootViewController.presentViewController(cameraPickerController, animated: true) { () -> Void in
                            
                        }
                    }
                } else {
                    if let window = __window() {
                        AXPracticalHUD.sharedHUD.showError(inView: window, text: "相机不可用", detail: "请检查并重试", configuration: { (HUD) -> Void in
                            HUD.translucent = true
                            HUD.lockBackground = true
                            HUD.dimBackground = true
                            HUD.position  = .Center
                            HUD.animation = .Fade
                            HUD.restoreEnabled = true
                            HUD.hide(animated: true, afterDelay: 2.0)
                        })
                    }
                }
            }) { () -> Void in
                if let window = __window() {
                    AXPracticalHUD.sharedHUD.showError(inView: window, text: "访问相机失败", detail: "请前往 设置->隐私->相机 允许应用访问相机", configuration: { (HUD) -> Void in
                        HUD.translucent = true
                        HUD.lockBackground = true
                        HUD.dimBackground = true
                        HUD.position  = .Center
                        HUD.animation = .Fade
                        HUD.restoreEnabled = true
                        HUD.hide(animated: true, afterDelay: 4.0)
                    })
                }
        }
    case 1:
        AXImagePickerController.requestAuthorization(completion: { () -> Void in
                if let rootViewController = __rootViewController() {
                    let imagePickerController = AXImagePickerController()
                    imagePickerController.axDelegate = pickerView
                    imagePickerController.allowsMultipleSelection = pickerView._allowsMultipleSelection
                    pickerView._removeFromSuperViewOnHide = false
                    rootViewController.presentViewController(imagePickerController, animated: true) { () -> Void in
                        
                    }
                }
            }) { () -> Void in
                if let window = __window() {
                    AXPracticalHUD.sharedHUD.showError(inView: window, text: "访问相册失败", detail: "请前往 设置->隐私->照片 允许应用访问相册", configuration: { (HUD) -> Void in
                        HUD.translucent = true
                        HUD.lockBackground = true
                        HUD.dimBackground = true
                        HUD.position  = .Center
                        HUD.animation = .Fade
                        HUD.restoreEnabled = true
                        HUD.hide(animated: true, afterDelay: 4.0)
                    })
                }
            }
    case 2:
        if let collectionView = pickerView.customView as? UICollectionView {
            var images: [UIImage] = []
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems() {
                if #available(iOS 8.0, *) {
                    for (index, indexPath) in selectedIndexPath.enumerate() {
                        let assets = pickerView._photoAssetsResult?.objectAtIndex(indexPath.row) as! PHAsset
                        if let image = assets.image {
                            images.append(image)
                        }
                    }
                } else {
                    for (index, indexPath) in selectedIndexPath.enumerate() {
                        images.append(pickerView._photoAssets[indexPath.row].image)
                    }
                }
            }
            pickerView._imagePickerBlock?(picker: pickerView, images:images)
        }
    default:
        break
    }
}

@available(iOS 7.0, *)
/// Convenient way to show a picker view with custom configurations
extension AXPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    class public func showInWindow(window: UIWindow, animated:Bool, style:AXPickerViewStyle = .Normal, items:[String]? = nil, title: String? = nil, tips: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        showInView(window, animated: animated, style: style, items: items, title: title, tips: tips, configuration: configuration, completion: completion, revoking: revoking, executing: executing)
    }
    
    class public func showInWindow(window: UIWindow, animated:Bool, style:AXPickerViewStyle = .Normal, items:[String]? = nil, title: String? = nil, customView: UIView? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        showInView(window, animated: animated, style: style, items: items, title: title, customView: customView, configuration: configuration, completion: completion, revoking: revoking, executing: executing)
    }
    
    @available(iOS 7.0, *)
    class public func showInView(view: UIView, animated: Bool, style:AXPickerViewStyle = .Normal, items:[String]? = nil, title: String? = nil, tips: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        let picker = AXPickerView(style: style, items: items)
        configuration?(pickerView: picker)
        picker.view = view
        picker.title = title
        
        picker.sizeToFit()
        
        if let tip = tips {
            let string = NSString(string: tip)
            let font = UIFont.systemFontOfSize(12)
            let usedSize = string.boundingRectWithSize(CGSizeMake(picker.bounds.width, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil)
            
            let label = UILabel(frame: CGRectMake(0, 0, ceil(usedSize.width), ceil(usedSize.height)))
            label.textAlignment = NSTextAlignment.Left
            label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            label.numberOfLines = 0
            label.backgroundColor = UIColor.clearColor()
            label.font = font
            label.textColor = AXDefaultTintColor.colorWithAlphaComponent(0.5)
            label.text = tip
            
            picker.customView = label
        }
        
        picker.show(animated: animated, completion: completion, revoking: revoking, executing: executing)
    }
    
    class public func showInView(view: UIView, animated: Bool, style:AXPickerViewStyle = .Normal, items:[String]? = nil, title: String? = nil, customView: UIView? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> () {
        let picker = AXPickerView(style: style, items: items)
        configuration?(pickerView: picker)
        picker.view = view
        picker.title = title
        picker.customView = customView
        picker.show(animated: animated, completion: completion, revoking: revoking, executing: executing)
    }
}
@available(iOS 7.0, *)
extension AXPickerView {
    class public func showTipsInWindow(window: UIWindow, animated:Bool, items:[String]? = nil, title: String? = nil, tips: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> ()
    {
        self.showTipsInView(window, animated: animated, items: items, title: title, tips: tips, configuration: configuration, completion: completion, revoking: revoking, executing: executing)
    }
    
    class public func showNormalInWindow(window: UIWindow, animated:Bool, items:[String]? = nil, title: String? = nil, customView: UIView? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> ()
    {
        self.showNormalInView(window, animated: animated, items: items, title: title, customView: customView, configuration: configuration, completion: completion, revoking: revoking, executing: executing)
    }
    
    class public func showDatePickerInWindow(window: UIWindow, animated: Bool, title: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil)
    {
        self.showDatePickerInView(window, animated: animated, title: title, configuration: configuration, completion: completion, revoking: revoking)
    }
    
    class public func showPickerInWindow(window: UIWindow, animated: Bool, title: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil)
    {
        self.showPickerInView(window, animated: animated, title: title, configuration: configuration, completion: completion, revoking: revoking)
    }
    
    class public func showTipsInView(view: UIView, animated: Bool, items:[String]? = nil, title: String? = nil, tips: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> ()
    {
        self.showInView(view, animated: animated, style: .Normal, items: items, title: title, tips: tips, configuration: configuration, completion: completion, revoking: revoking, executing: executing)
    }
    
    class public func showNormalInView(view: UIView, animated: Bool, items:[String]? = nil, title: String? = nil, customView: UIView? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, executing: AXExecuting? = nil) -> ()
    {
        self.showInView(view, animated: animated, style: .Normal, items: items, title: title, customView: customView, configuration: configuration, completion: completion, revoking: revoking, executing: executing)
    }
    
    class public func showDatePickerInView(view: UIView, animated: Bool, title: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil)
    {
        let picker = AXPickerView(style: .DatePicker, items: nil)
        configuration?(pickerView: picker)
        picker.view = view
        picker.title = title
        picker.show(animated: animated, completion: completion, revoking: revoking)
    }
    
    class public func showPickerInView(view: UIView, animated: Bool, title: String? = nil, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil)
    {
        let picker = AXPickerView(style: .CommonPicker, items: nil)
        configuration?(pickerView: picker)
        picker.view = view
        picker.title = title
        picker.show(animated: animated, completion: completion, revoking: revoking)
    }
}

@available(iOS 7.0, *)
extension AXPickerView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AXImagePickerControllerDelegate {
    
    class func showImagePickerInWindow(window: UIWindow, animated: Bool, allowsMultipleSelection: Bool = false, containsCamera: Bool = true, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, imagePickerBlock: AXImagePickerCompletion? = nil) -> Void {
        self.showImagePickerInView(window, animated: animated, allowsMultipleSelection: allowsMultipleSelection, containsCamera: containsCamera, configuration: configuration, completion: completion, revoking: revoking, imagePickerBlock: imagePickerBlock)
    }
    
    class func showImagePickerInView(view: UIView, animated: Bool, allowsMultipleSelection: Bool = false, containsCamera: Bool = true, configuration: AXConfiguration? = nil, completion: AXCompletion? = nil, revoking: AXRevoking? = nil, imagePickerBlock: AXImagePickerCompletion? = nil) -> Void {
        AXImagePickerController.requestAuthorization(completion: { () -> Void in
                var items: [String] = []
                if containsCamera {
                    items = ["拍摄", "从相册选取"]
                } else {
                    items = ["从相册选取"]
                }
                let picker = AXPickerView(style: .Normal, items: items)
                picker._containsCamera = containsCamera
                picker.seperatorInsets = UIEdgeInsetsZero
                picker.view = view
                configuration?(pickerView: picker)
                picker._imagePickerBlock = imagePickerBlock
                let collectionView = UICollectionView(frame: CGRectMake(0, 0, 0, rightHeight), collectionViewLayout: {
                    () -> UICollectionViewFlowLayout in
                    let layout = UICollectionViewFlowLayout()
                    layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
                    return layout
                    }())
                picker._allowsMultipleSelection = allowsMultipleSelection
                collectionView.allowsMultipleSelection = allowsMultipleSelection
                collectionView.showsHorizontalScrollIndicator = false
                collectionView.backgroundColor = UIColor.clearColor()
                collectionView.registerClass(AXImagePickerCell.self, forCellWithReuseIdentifier: reusedIdentifier)
                collectionView.delegate = picker
                collectionView.dataSource = picker
                picker.customView = collectionView
                picker.validPhotoGroup?()
                if #available(iOS 8.0, *) {
                    PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(picker)
                } else {
                    NSNotificationCenter.defaultCenter().addObserver(picker, selector: "handleALLibraryChangedNotification:", name: ALAssetsLibraryChangedNotification, object: nil)
                }
                picker.show(animated: true, completion: completion, revoking: revoking, executing: imagePickerExecuting)
            }) { () -> Void in
                if let window = __window() {
                    AXPracticalHUD.sharedHUD.showError(inView: window, text: "访问相册失败", detail: "请前往 设置->隐私->照片 允许应用访问相册", configuration: { (HUD) -> Void in
                        HUD.translucent = true
                        HUD.lockBackground = true
                        HUD.dimBackground = true
                        HUD.position  = .Center
                        HUD.animation = .Fade
                        HUD.restoreEnabled = true
                        HUD.hide(animated: true, afterDelay: 4.0)
                    })
                }
            }
    }
    
    private func rightSize(originalSize size: CGSize, rightHeight: CGFloat) -> CGSize {
        return CGSizeMake(max(minWidth, size.width * (rightHeight / size.height)), rightHeight)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if #available(iOS 8.0, *) {
            let assets = _photoAssetsResult?.objectAtIndex(indexPath.row) as! PHAsset
            let size = CGSizeMake(CGFloat(assets.pixelWidth), CGFloat(assets.pixelHeight))
            return rightSize(originalSize: size, rightHeight: rightHeight)
        } else {
            let defaultRepresentation = _photoAssets[indexPath.row].defaultRepresentation()
            let size = defaultRepresentation.dimensions()
            return rightSize(originalSize: size, rightHeight: rightHeight)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5.0
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if #available(iOS 8.0, *) {
            return _photoAssetsResult?.count ?? 0
        } else {
            return _photoAssets.count
        }
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusedIdentifier, forIndexPath: indexPath) as! AXImagePickerCell
        if #available(iOS 8.0, *) {
            let assets = _photoAssetsResult?.objectAtIndex(indexPath.row) as! PHAsset
            PHImageManager.defaultManager().requestImageForAsset(assets, targetSize: rightSize(originalSize: CGSizeMake(CGFloat(assets.pixelWidth), CGFloat(assets.pixelHeight)), rightHeight: rightHeight), contentMode: .AspectFill, options: nil) { (image, userInfo) -> Void in
                cell.imageView.image = image!
            }
        } else {
            let aspectRatioThumbnail = _photoAssets[indexPath.row].aspectRatioThumbnail()
            cell.imageView.image = UIImage(CGImage: aspectRatioThumbnail.takeUnretainedValue())
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let count = collectionView.indexPathsForSelectedItems()?.count {
            if count >= 9 {
                return false
            }
        }
        return true
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.allowsMultipleSelection {
            if let count = collectionView.indexPathsForSelectedItems()?.count {
                if count > 0 {
                    if self._containsCamera {
                        self.items = ["拍摄", "从相册选取", "已选择\(count)张"]
                        self.itemConfigs = [(2, AXDefaultSelectedColor, nil)]
                    } else {
                        self.items = ["从相册选取", "已选择\(count)张"]
                        self.itemConfigs = [(1, AXDefaultSelectedColor, nil)]
                    }
                    return
                }
            }
            if self._containsCamera {
                self.items = ["拍摄", "从相册选取"]
            } else {
                self.items = ["从相册选取"]
            }
            self.itemConfigs?.removeAll()
        } else {
            if let count = collectionView.indexPathsForSelectedItems()?.count {
                if count > 0 {
                    if self._containsCamera {
                        self.items = ["拍摄", "从相册选取", "选择"]
                        self.itemConfigs = [(2, AXDefaultSelectedColor, nil)]
                    } else {
                        self.items = ["从相册选取", "选择"]
                        self.itemConfigs = [(1, AXDefaultSelectedColor, nil)]
                    }
                    return
                }
            }
            if self._containsCamera {
                self.items = ["拍摄", "从相册选取"]
            } else {
                self.items = ["从相册选取"]
            }
            self.itemConfigs?.removeAll()
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let count = collectionView.indexPathsForSelectedItems()?.count {
            if count > 0 {
                if self._containsCamera {
                    self.items = ["拍摄", "从相册选取", "已选择\(count)张"]
                    self.itemConfigs = [(2, AXDefaultSelectedColor, nil)]
                } else {
                    self.items = ["从相册选取", "已选择\(count)张"]
                    self.itemConfigs = [(1, AXDefaultSelectedColor, nil)]
                }
                return
            }
        }
        if self._containsCamera {
            self.items = ["拍摄", "从相册选取"]
        } else {
            self.items = ["从相册选取"]
        }
        self.itemConfigs?.removeAll()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            _imagePickerBlock?(picker: self, images:[image])
        }
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if self._removeFromSuperViewOnHide == false {
                self.removeFromSuperview()
            }
        }
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        _revoking?(pickerView: self)
        picker.dismissViewControllerAnimated(true) { () -> Void in
            if self._removeFromSuperViewOnHide == false {
                self.removeFromSuperview()
            }
        }
    }
    
    // MARK: - AXImagePickerControllerDelegate
    
    public func imagePickerController(picker: AXImagePickerController, selectedImages images: [UIImage]) -> Void {
        _imagePickerBlock?(picker: self, images:images)
        if self._removeFromSuperViewOnHide == false {
            self.removeFromSuperview()
        }
    }
    
    public func imagePickerControllerCanceled(picker: AXImagePickerController) -> Void {
        _revoking?(pickerView: self)
        if self._removeFromSuperViewOnHide == false {
            self.removeFromSuperview()
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        viewController.navigationController?.navigationBar.tintColor = AXDefaultSelectedColor
    }
    
    public func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
    }
    
    public func navigationControllerSupportedInterfaceOrientations(navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    public func navigationControllerPreferredInterfaceOrientationForPresentation(navigationController: UINavigationController) -> UIInterfaceOrientation
    {
        return UIInterfaceOrientation.Portrait
    }
}
@available(iOS 8.0, *)
extension AXPickerView: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(changeInstance: PHChange) -> Void {
        if let asset = self.assets as? PHFetchResult {
            if let change = changeInstance.changeDetailsForFetchResult(asset) {
                if change.hasIncrementalChanges {
                    self.assets = change.fetchResultAfterChanges
                    if let collectionView = customView as? UICollectionView {
                        collectionView.reloadData()
                        if collectionView.numberOfSections() > 0 && collectionView.numberOfItemsInSection(0) > 0 {
                            collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Top, animated: true)
                        }
                    }
                }
            }
        }
    }
}
@available(iOS, introduced=7.0, deprecated=8.0)
extension AXPickerView {
    @objc private func handleALLibraryChangedNotification(aNotification: NSNotification) -> Void {
        self.validPhotoGroup?()
    }
}
//MARK: - Private Classes
private class CALayer_ax: CALayer, AXLayerTag {
    
    typealias TagType = Int
    
    var tag: TagType!
}
private class AXImagePickerCell: UICollectionViewCell {
    let label = {
        () -> UILabel in
        let lab = UILabel(frame: CGRectZero)
        lab.backgroundColor = UIColor.clearColor()
        lab.font = UIFont.systemFontOfSize(12)
        lab.textColor = AXDefaultSelectedColor
        lab.text = "已选择"
        lab.sizeToFit()
        lab.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin.union(UIViewAutoresizing.FlexibleLeftMargin).union(UIViewAutoresizing.FlexibleRightMargin).union(UIViewAutoresizing.FlexibleTopMargin)
        lab.hidden = true
        return lab
        }()
    
    lazy var imageView: UIImageView! = {
        return get() {
            [unowned self]() -> AnyObject in
            let imgView = UIImageView(frame: CGRectZero)
            imgView.backgroundColor = UIColor.clearColor()
            imgView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.union(.FlexibleWidth).union(.FlexibleBottomMargin).union(.FlexibleRightMargin)
            imgView.contentMode = UIViewContentMode.ScaleAspectFill
            imgView.clipsToBounds = true
            return imgView
            } as! UIImageView
        }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.contentView.bounds
        var rect = label.frame
        rect.origin.x = (imageView.bounds.width - rect.width) / 2
        rect.origin.y = (imageView.bounds.height - rect.height) / 2
        label.frame = rect
    }
    
    override var selected: Bool {
        get {
            return super.selected
        }
        set {
            super.selected = newValue
            
            label.hidden = !selected
            if selected {
                imageView.alpha = 0.1
            } else {
                imageView.alpha = 1.0
            }
        }
    }
    
    private func initializer() -> Void {
        addSubview(imageView)
        addSubview(label)
    }
}