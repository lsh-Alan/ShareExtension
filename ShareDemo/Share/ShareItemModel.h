//
//  ShareItemModel.h
//  Share
//
//  Created by Alan on 2020/11/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareItemModel : NSObject

@property (nonatomic,copy) NSString *name;

///照片/视频首帧
@property (nonatomic,strong) UIImage *image;

///文件路径
@property (nonatomic,copy) NSString *filePath;

///文件类型标示
@property (nonatomic,copy) NSString *TypeIdentifier;


@end

NS_ASSUME_NONNULL_END
