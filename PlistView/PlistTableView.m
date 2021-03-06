//
//  PlistTableView.m
//  ExtremeVPN
//
//  Created by 刘鹏 on 2017/11/3.
//  Copyright © 2017年 Musjoy. All rights reserved.
//

#import "PlistTableView.h"
#import HEADER_LOCALIZE     //国际化
#import <FileSource.h>      //文件管理

#import "Utils.h"
#import "UITableViewCell+PlistUtils.h"  //cell配置
#import "NSObject+MutableCopy.h"        //可变版本的拷贝

#ifdef MODULE_CONTROLLER_MANAGER
#import "MJNavigationController.h"
#import "MJControllerManager.h"
#endif

#define PlistTableViewKey @"PlistTableView"

@interface PlistTableView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *arrDataSource;///< 配置信息数据源
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *arrGroupDict;///< 配置信息（显示用）
@property (nonatomic, copy) NSString *observeId;///< 文件监听id
@end

@implementation PlistTableView
#pragma mark - Life Cycle
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // 默认配置
    [self defaultConfig];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 默认配置
        [self defaultConfig];
    }
    return self;
}

- (void)dealloc
{
    //移除文件更新的监听
    [FileSource removeObserve:_observeId withFiles:@[_fileName]];
}

#pragma mark - Subjoin
/// 默认配置
- (void)defaultConfig
{
    self.delegate = self;
    self.dataSource = self;
    self.tableFooterView = [[UIView alloc] init];
}

/// 取数据
- (void)fetchData
{
    id object =  getFileData(_fileName);
    
    if (object == nil && _defaultData) {
        object = _defaultData;
    }

    //将数据全部转为可变版本
    NSMutableDictionary *data = [object loopMutableCopy];
    if (data[PlistTableViewKey]) {
        data = data[PlistTableViewKey];
    }
#ifdef MODULE_LOCALIZE
    //添加国际化信息（先添加，下面的步骤中可能会用到）
    NSString *tableId = nil;
    NSDictionary *dicLocalize = [data objectForKey:kLocalizable];
    if (dicLocalize) {
        tableId = [[MJLocalize sharedInstance] addLocalizedStringWith:dicLocalize];
    }
#endif

    // 初始化视图
    [self viewConfigWithDict:data];
    // 初始化数据
    [self dataConfigWithDict:data];
    
    _arrGroupDict = [_arrDataSource loopMutableCopy];
    
    // 刷新
    [self reloadData];
    
//#ifdef MODULE_LOCALIZE
//    //使用完后，从缓存中移除新增的国际化
//    if (tableId.length) {
//        [[MJLocalize sharedInstance] removeLocalizedWith:tableId];
//    }
//#endif
}

/// 初始化视图
- (void)viewConfigWithDict:(NSDictionary *)dict
{
    if (dict) {
        //配置UITableView
        // 背景色
        NSString *backgroundColor = dict[@"backgroundColor"];
        if (backgroundColor.length) {
            self.backgroundColor = [UIColor colorFromHexRGB:backgroundColor];
        }
        
        // 是否显示分割线
        if ([dict[@"hideSeparator"] boolValue]) {
            self.separatorStyle = UITableViewCellSeparatorStyleNone;
        } else {
            self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        
        // 分割线颜色
        NSString *separatorColor = dict[@"separatorColor"];
        if (separatorColor.length) {
            self.separatorColor = [UIColor colorFromHexRGB:separatorColor];
        }
        
        // 分割线左边距
        NSString *separatorLeftSpace = dict[@"separatorLeftSpace"];
        if (separatorLeftSpace.length) {
            self.separatorInset = UIEdgeInsetsMake(0, [separatorLeftSpace doubleValue], 0, 0);
        }
    }
}

/// 初始化数据
- (void)dataConfigWithDict:(NSDictionary *)dict
{
    if (dict) {
        //存每组及cell的ui配置信息
        _arrDataSource = dict[@"groupList"];
        
        //将cell中所有的国际化key，替换为最终显示文案
        for (NSMutableDictionary *groupDict in _arrDataSource) {
            NSMutableArray *arrCellDataDict = groupDict[@"cellList"];
            
            for (NSMutableDictionary *cellDict in arrCellDataDict) {
                //标题国际化
                NSString *titleKey = cellDict[@"titleKey"];
                if (titleKey.length) {
                    [cellDict setObject:locString(titleKey) forKey:@"titleKey"];
                }
                //副标题国际化
                NSString *detailTextKey = cellDict[@"detailTextKey"];
                if (detailTextKey.length) {
                    [cellDict setObject:locString(detailTextKey) forKey:@"detailTextKey"];
                }
            }
        }
    }
}

#pragma mark - set & get
/// 配置文件
- (void)setFileName:(NSString *)fileName
{
    _fileName = fileName;
    
    //监听配置文件变化
    __weak typeof(self) weakSelf = self;
    _observeId = [FileSource observeFiles:@[_fileName] whileUpdate:^{
        // 取数据
        [weakSelf fetchData];
    }];
    
    // 取数据
    [self fetchData];
}

#pragma mark - Private
/// 删除不需要的组和行（每次都是重新从数据源中删除）
- (void)deleteNeedlessGroups:(NSArray *)groups rows:(NSArray *)rows
{
    _arrGroupDict = [_arrDataSource loopMutableCopy];
    
    if (groups.count) {
        [self deleteNeedlessGroups:groups];
    }
    if (rows.count) {
        [self deleteNeedlessRows:rows];
    }
}

/// 删除不需要的组
- (void)deleteNeedlessGroups:(NSArray *)groups
{
    NSMutableArray *newArrGroups = [[NSMutableArray alloc] init];
    //遍历所有组
    for (NSMutableDictionary *group in _arrGroupDict) {
        if (![groups containsObject:group[@"groupKey"]]) {
            [newArrGroups addObject:group];
        }
    }
    _arrGroupDict = newArrGroups;
}

/// 删除不需要的行
- (void)deleteNeedlessRows:(NSArray *)cells
{
    //遍历所有组
    for (NSMutableDictionary *group in _arrGroupDict) {
        
        NSMutableArray *newArrCells = [[NSMutableArray alloc] init];
        
        //遍历所有行
        NSMutableArray *arrCells = group[@"cellList"];
        for (NSMutableDictionary *cell in arrCells) {
            if (![cells containsObject:cell[@"keyForCell"]]) {
                [newArrCells addObject:cell];
            }
        }
        [group setObject:newArrCells forKey:@"cellList"];
    }
}

/// 取对应cell的数据
- (NSDictionary *)cellDataForAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _arrGroupDict[indexPath.section];
    NSArray *cellList = dict[@"cellList"];
    return cellList[indexPath.row];
}

#pragma mark - Public
/// 取对应groupKey序号，未取到时返回NSNotFound
- (NSInteger)sectionIndexForGroupKey:(NSString *)groupKey
{
    NSInteger index = NSNotFound;
    
    if (groupKey.length == 0) {
        return index;
    }
    
    //遍历所有组
    for (NSMutableDictionary *group in _arrGroupDict) {
        if ([groupKey isEqualToString:group[@"groupKey"]]) {
            index = [_arrGroupDict indexOfObject:group];
            break;
        }
    }
    return index;
}

/// 取对应itemKey序号，未取到时返回nil
- (NSIndexPath *)indexPathForItemKey:(NSString *)itemKey
{
    NSIndexPath *indexPath = nil;
    
    if (itemKey.length == 0) {
        return indexPath;
    }
    
    //遍历所有组
    for (NSMutableDictionary *group in _arrGroupDict) {
        //遍历所有行
        NSMutableArray *arrCells = group[@"cellList"];
        for (NSMutableDictionary *cell in arrCells) {
            if ([itemKey isEqualToString:cell[@"keyForCell"]]) {
                NSInteger section = [_arrGroupDict indexOfObject:group];
                NSInteger row = [arrCells indexOfObject:cell];
                indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                break;
            }
        }
    }
    return indexPath;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *data = [self cellDataForAtIndexPath:indexPath];
    CGFloat cellHeight = [data[@"cellHeight"] doubleValue];
    if (cellHeight <= 0) {
        cellHeight = 44;
    }
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //cell对应数据
    NSDictionary *cellData = [self cellDataForAtIndexPath:indexPath];
    NSDictionary *eventData = cellData[@"cellEvent"];
    
    // 执行指定方法
    // 要执行的方法名
    NSString *actionString = eventData[@"action"];
    if (actionString.length) {
        // 事件执行者，默认是所属控制器
        id executor = _eventExecutor;
        // 方法
        SEL action = NSSelectorFromString(actionString);
        
        // 如果配置其他类执行，则更改执行者
        Class executeClass = NSClassFromString(eventData[@"executeClass"]);
        if (executeClass) {
            // 判断是类方法还是实例方法
            if ([executeClass respondsToSelector:action]) {
                executor = executeClass;
            } else if ([executeClass instancesRespondToSelector:action]) {
                SEL singletonAction = NSSelectorFromString(@"sharedInstance");
                if ([executeClass respondsToSelector:singletonAction]) {
                    // 这里兼容一下，单例中只写了sharedInstance方法，没有写allocWithZone方法的情况
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    executor = [executeClass performSelector:singletonAction];
#pragma clang diagnostic pop
                } else {
                    // 正常情况，只写这一句就够了，不管是不是单例（单例中重写了allocWithZone方法）
                    executor = [executeClass new];
                }
            } else {
                executor = nil;
            }
        }
        
        // 执行此方法
        if (executor && [executor respondsToSelector:action]) {
            IMP imp = [executor methodForSelector:action];
            if ([actionString hasSuffix:@":"]) {
                void (*func)(id, SEL, id) = (void *)imp;
                id data = eventData[@"attachData"]? eventData[@"attachData"]:nil;
                func(executor, action, data);
            } else {
                void (*func)(id, SEL) = (void *)imp;
                func(executor, action);
            }
        }
    }
    
    
    // 跳转页面
    NSString *targetController = eventData[@"targetController"];
    if (targetController.length && NSClassFromString(targetController)) {
#ifdef MODULE_CONTROLLER_MANAGER
        UIViewController *targetVC = [MJControllerManager getViewControllerWithName:targetController];
#else
        UIViewController *targetVC = [self getViewControllerWithName:targetController];
#endif
        //目标控制器
        if (targetVC) {
            id data = eventData[@"targetData"]? eventData[@"targetData"]:nil;
            if (data) {
                [targetVC configWithData:data];
            }
            
            //当前控制器
            UIViewController *selfVC = _eventExecutor;
            BOOL useTabBar = [eventData[@"useTabBar"] boolValue];
            if (useTabBar) {
                selfVC = selfVC.tabBarController;
            }
            
            //跳转方式
            BOOL usePresent = [eventData[@"usePresent"] boolValue];
            
#ifdef MODULE_CONTROLLER_MANAGER
            MJNavigationController *aNavVC = [[MJNavigationController alloc] initWithRootViewController:targetVC];
#else
            UINavigationController *aNavVC = [[UINavigationController alloc] initWithRootViewController:targetVC];
#endif
            if (usePresent) {
                [selfVC presentViewController:aNavVC animated:YES completion:nil];
            } else {
                [selfVC.navigationController pushViewController:targetVC animated:YES];
            }
        }
    }
}

#pragma mark Delegate Subjoin
#ifndef MODULE_CONTROLLER_MANAGER
- (UIViewController *)getViewControllerWithName:(NSString *)aVCName
{
    if (aVCName.length == 0) {
        return nil;
    }
    Class classVC = NSClassFromString(aVCName);
    if (classVC) {
        // 存在该类
        NSString *filePath = [[NSBundle mainBundle] pathForResource:aVCName ofType:@"nib"];
        UIViewController *aVC = nil;
        if (filePath.length > 0) {
            aVC = [[classVC alloc] initWithNibName:aVCName bundle:nil];
        } else {
            aVC = [[classVC alloc] init];
        }
    }
    
    return nil;
}
#endif

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrGroupDict.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = _arrGroupDict[section];
    NSArray *cellList = dict[@"cellList"];
    return cellList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //cell对应数据
    NSDictionary *cellData = [self cellDataForAtIndexPath:indexPath];
    
    NSString *identifier = [cellData objectForKey:@"cellIdentifier"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        NSString *cellClass = [cellData objectForKey:@"cellClass"];
        //cell样式
        UITableViewCellStyle style = 0;
        NSInteger styleEnum = [cellData[@"cellStyle"] integerValue];
        if (styleEnum >= 0 && styleEnum <= 3) {
            style = styleEnum;
        }
        cell = [NSClassFromString(cellClass) cellWithStyle:style reuseIdentifier:identifier];
    }

    cell.backgroundColor = [UIColor clearColor];
    
    //配置
    [cell configCellWithData:cellData];
    
    //额外的配置cell
    if ([_customDlegate respondsToSelector:@selector(plistTableView:configCell:withKey:)]) {
        [_customDlegate plistTableView:self configCell:cell withKey:cellData[@"keyForCell"]];
    }
    
    return cell;
}

@end
