//
//  PlistTableView.h
//  ExtremeVPN
//
//  Created by 刘鹏 on 2017/11/3.
//  Copyright © 2017年 Musjoy. All rights reserved.
//  由plist生成的表格

#import <UIKit/UIKit.h>
@class PlistTableView;

@protocol PlistTableViewDelegate <NSObject>
@optional
/**
 额外配置cell
 少数情况下会用到，一般需要做附加设置，只需在对应cell里面重写configCellWithData方法，并且在方法中调用[super configCellWithData]
 */
- (void)plistTableView:(PlistTableView *)plistTableView configCell:(UITableViewCell *)aCell withKey:(NSString *)key;
@end

@interface PlistTableView : UITableView
@property (nonatomic, copy) IBInspectable NSString *fileName;   ///< 配置文件名称
@property (nonatomic, strong) id defaultData;///< 默认数据
/**
  事件执行者
  默认是此View所属控制器(可在xib面板中连线到File Owner)，当配置文件中指定了执行者的类名时，将使用指定的类来执行
 */
@property (nonatomic, weak) IBOutlet id eventExecutor;

@property (nonatomic, weak) IBOutlet id<PlistTableViewDelegate> customDlegate;///< 自定义方法代理 (可在xib面板中连线到File Owner)

/// 删除不需要的组和行（每次都是重新从数据源中删除）
- (void)deleteNeedlessGroups:(NSArray *)groups rows:(NSArray *)rows;

/// 取对应groupKey序号，未取到时返回NSNotFound
- (NSInteger)sectionIndexForGroupKey:(NSString *)groupKey;
/// 取对应itemKey序号，未取到时返回nil
- (NSIndexPath *)indexPathForItemKey:(NSString *)itemKey;
@end

