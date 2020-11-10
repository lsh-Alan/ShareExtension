//
//  ShareViewController.m
//  Share
//
//  Created by Alan on 2020/10/29.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ShareItemModel.h"
#define GropuID @"group.alan.ShareDemo"
@interface ShareViewController ()
{
    int inputItemsCount;
    int counter;
    dispatch_queue_t queue;
    UIActivityIndicatorView *testActivityIndicator;
    NSMutableArray *array;
    UITableView *tableView;
    UIScrollView *headView;
    NSString *currentTimeString;//文件每次进来都在不同的文件夹 app内根据需求去清理
}

@end

@implementation ShareViewController

- (instancetype)init
{
    if (self = [super init]) {
        queue = dispatch_queue_create("group.alan.ShareDemo", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.title = @"标题";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:(UIBarButtonItemStyleDone) target:self action:@selector(cancel)];
    
    array = [NSMutableArray array];
    
    
    CGFloat height = self.navigationController.navigationBar.frame.size.height;
    headView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,height + 20, CGRectGetWidth(self.view.bounds), 300)];
    headView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:headView];
    

    CGFloat y = headView.frame.origin.y + CGRectGetHeight(headView.bounds);
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [UIColor whiteColor];
    cell.frame = CGRectMake(15, y + 30, CGRectGetWidth(self.view.bounds) - 30, 44);
    cell.textLabel.text = @"操纵1";
    cell.imageView.image = [UIImage imageNamed:@"1"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.layer.cornerRadius = 3;
    cell.layer.masksToBounds = YES;
    [self.view addSubview:cell];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(topSafeStar)];
    [cell addGestureRecognizer:tap];
    
    [self didSelectPostWith:self.extensionContext];
}

- (void)cancel
{
    [self cleanCaches];
    NSError *error;
    [self.extensionContext cancelRequestWithError:error];
    
}

- (void)topSafeStar
{
    [self openApp];
}


- (void)didSelectPostWith:(NSExtensionContext *)extensionContext {
    inputItemsCount = 0;
    counter = 0;
    
    
    for(NSExtensionItem *item in extensionContext.inputItems){
        inputItemsCount += item.attachments.count;
    }


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (@available(iOS 13.0, *)) {
        testActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        testActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
#pragma clang diagnostic pop
        
    testActivityIndicator.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0, CGRectGetHeight(self.view.bounds)/2.0);//只能设置中心，不能设置大小
    [self.view addSubview:testActivityIndicator];
    [testActivityIndicator startAnimating]; // 开始旋转
    

    for (NSExtensionItem *item in extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                [self loadFileBy:itemProvider item:item type:(NSString *)kUTTypeImage];
            }else if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudiovisualContent]){
                [self loadFileBy:itemProvider item:item type:(NSString *)kUTTypeAudiovisualContent];
            }else if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePDF]){
                [self loadFileBy:itemProvider item:item type:(NSString *)kUTTypePDF];
            }else if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePresentation]){
                [self loadFileBy:itemProvider item:item type:(NSString *)kUTTypePresentation];
            }else if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]){
                [self loadFileBy:itemProvider item:item type:(NSString *)kUTTypeFileURL];
            }else if([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]){
                [self loadFileBy:itemProvider item:item type:(NSString *)kUTTypeURL];
            }else {
                counter++;
                if(counter >= inputItemsCount){
                    //[self.extensionContext completeRequestReturningItems:extensionContext.inputItems completionHandler:nil];
                    [self FinishGetAllFile];
                }
            }
        }
    }
}

//处理单个资源
- (void)loadFileBy:(NSItemProvider*)itemProvider item:(NSExtensionItem*)item type:(NSString*)type{
    [itemProvider loadItemForTypeIdentifier:type options:nil completionHandler:^(id file, NSError *error) {
        if(file) {
            
            NSString* fileName;
            
            if([[file class] isSubclassOfClass:[NSURL class]]){
                fileName = [((NSURL *)file).absoluteString lastPathComponent];
                
                [self saveFileByNSFileManager:file fileName:fileName Type:type];
            }else if([[file class] isSubclassOfClass:[NSData class]]){
                NSString *MIMETypeStr = nil;
                for(NSString *registeredType in itemProvider.registeredTypeIdentifiers){
                    CFStringRef registeredUTI = (__bridge CFStringRef)registeredType;
                    BOOL isRegisteredIsKindOfType = UTTypeConformsTo(registeredUTI, (__bridge CFStringRef)type);
                    
                    if(isRegisteredIsKindOfType){
                        CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(registeredUTI, kUTTagClassMIMEType);
                        if(MIMEType){
                            MIMETypeStr = [(__bridge_transfer NSString *)MIMEType lastPathComponent];
                            break;
                        }
                    }
                }
                
                if(item.attributedTitle && item.attributedTitle.string)
                    fileName = item.attributedTitle.string;
                else
                    fileName = [self formatDate_yyyyMMddHHmmss:[NSDate date]];
                
                if([[fileName pathExtension] isEqualToString:@""] && MIMETypeStr)
                    fileName = [fileName stringByAppendingPathExtension:MIMETypeStr];
                
                [self saveFileByNSFileManager:file fileName:fileName Type:type];
                self->counter++;
                
                
                if(self->counter >= self->inputItemsCount){
                    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
                    //[self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                    [self FinishGetAllFile];
                }
            }else{
                self->counter++;
                
                if(self->counter >= self->inputItemsCount){
                    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
                    //[self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                    [self FinishGetAllFile];
                }
            }
        }else{
            self->counter++;
            
            if(self->counter >= self->inputItemsCount){
                // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
                //[self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                [self FinishGetAllFile];
            }
        }
    }];
}


- (BOOL)saveFileByNSFileManager:(id)image fileName:(NSString*)fileName Type:(NSString *)type {
    
    if(fileName.length > 0  && ![fileName.capitalizedString isEqualToString:@"/"]){}else{
            fileName = [self formatDate_yyyyMMddHHmmss:[NSDate date]];
        }
    
    NSError *err = nil;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GropuID];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches"];
    containerURL = [containerURL URLByAppendingPathComponent:fileName];
    
    containerURL = [NSURL fileURLWithPath:[self getNewFilePathIfExistsByFilePath:[containerURL path]]];
    
    //保留文件相关信息 处理UI
    ShareItemModel *itemModel = [[ShareItemModel alloc] init];
    itemModel.name = fileName;
    itemModel.filePath = containerURL.absoluteString;
    itemModel.TypeIdentifier = type;
    [array addObject:itemModel];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:[containerURL URLByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *value = @"";
    NSData * binaryImageData = nil;
    
    if([[image class] isSubclassOfClass:[NSURL class]]){
//        binaryImageData = [NSData dataWithContentsOfURL:image];
        
        __block NSError *error = nil;
        
        dispatch_async(queue, ^{
            NSURL * url = image;
            NSInputStream *stream = [NSInputStream inputStreamWithURL:url];
            
//            [stream setDelegate:self];
            [stream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [stream open];
            
            NSOutputStream *oStream = [NSOutputStream outputStreamWithURL:containerURL append:NO];
//            [oStream setDelegate:self];
            [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                               forMode:NSDefaultRunLoopMode];
            [oStream open];
            
            while ([stream hasBytesAvailable] && [oStream hasSpaceAvailable]) {
                uint8_t buffer[1024];
                
                NSInteger bytesRead = [stream read:buffer maxLength:1024];
                if (stream.streamError || bytesRead < 0) {
                    error = stream.streamError;
                    break;
                }
                
                NSInteger bytesWritten = [oStream write:buffer maxLength:(NSUInteger)bytesRead];
                if (oStream.streamError || bytesWritten < 0) {
                    error = oStream.streamError;
                    break;
                }
                
                if (bytesRead == 0 && bytesWritten == 0) {
                    break;
                }
            }
            
            [oStream close];
            [stream close];
            
            self->counter++;
            
            if(self->counter >= self->inputItemsCount){
                // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
                //[self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
                [self FinishGetAllFile];
            }
            
        });
        
        return YES;
    }else if([[image class] isSubclassOfClass:[NSData class]]){
        binaryImageData = image;
        
        BOOL result = [binaryImageData writeToURL:containerURL options:NSDataWritingAtomic error:&err];
        if (!result) {
            NSLog(@"%@",err);
        } else {
            NSLog(@"save value:%@ success.",value);
        }
        
        return result;
    }else{
        return NO;
    }
}

-(NSString*)getNewFilePathIfExistsByFilePath:(NSString*)filePath{
    if (![self checkExistWithFilePath:filePath]) {
        return filePath;
    }else{
        
        NSString *filenameWithOutExtension = [filePath stringByDeletingPathExtension];
        NSString *ext = [filePath pathExtension];
        
        int limit = 999;
        NSString* newFilePath;
        for(int i = 0; i < limit; i++){
            newFilePath = [NSString stringWithFormat:@"%@(%d).%@", filenameWithOutExtension, i+1, ext];
            if(![self checkExistWithFilePath:newFilePath]){
                NSLog(@"%@", newFilePath);
                break;
            }
        }
        return newFilePath;
    }
}

-(BOOL)checkExistWithFilePath:(NSString*)filePath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return YES;
    return NO;
}

-(NSString*)formatDate_yyyyMMddHHmmss:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
    NSString *datestring = [formatter stringFromDate:date];
    return datestring;
}

- (void)FinishGetAllFile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->testActivityIndicator stopAnimating];
    });
    
    //处理资源为照片或视频时 拿不到图片显示的情况
    if (array.count > 0) {
        ShareItemModel *itemModel = array[0];
        if ([itemModel.TypeIdentifier isEqualToString:(NSString *)kUTTypeImage] || [itemModel.TypeIdentifier isEqualToString:(NSString *)kUTTypeAudiovisualContent]) {
            NSMutableArray *deleteArray = [NSMutableArray array];
            for (NSInteger i = 0; i < array.count; i ++) {
                ShareItemModel *itemModel = array[i];
                if ([itemModel.TypeIdentifier isEqualToString:(NSString *)kUTTypeImage]) {
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:itemModel.filePath]];
                    UIImage *image = [UIImage imageWithData:data];
                    itemModel.image = image;
                    
                }else if([itemModel.TypeIdentifier isEqualToString:(NSString *)kUTTypeAudiovisualContent]){
                    itemModel.image = [self getScreenShotImageFromVideoPath:[NSURL URLWithString:itemModel.filePath]];
                }
                if (!itemModel.image) {
                    [deleteArray addObject:itemModel];
                }
            }
            [array removeObjectsInArray:deleteArray];
        }
    }
    
    if (array.count > 0) {
        ShareItemModel *itemModel = array[0];
        if ([itemModel.TypeIdentifier isEqualToString:(NSString *)kUTTypeImage] || [itemModel.TypeIdentifier isEqualToString:(NSString *)kUTTypeAudiovisualContent]) {
            //图片集合
            CGFloat height = 300.f;
            CGFloat lastRight = 0;
            for (NSInteger i = 0; i < array.count; i ++) {
                ShareItemModel *itemModel = array[i];
                CGFloat rate = itemModel.image.size.width/itemModel.image.size.height;
                CGFloat width = height * rate;
                if (width > height) {
                    width = height;
                }
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(lastRight + 15, 0, width, 300)];
                imageView.layer.cornerRadius = 4;
                imageView.layer.masksToBounds = YES;
                imageView.image = itemModel.image;
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->headView addSubview:imageView];
                    
                    if (i >= self->array.count - 1) {
                        if (i == 0) {//只有一个的时候放中间
                            imageView.center = CGPointMake(CGRectGetWidth(self->headView.bounds)/2.0, CGRectGetHeight(self->headView.bounds)/2.0);
                        }else{
                            [self->headView setContentSize:CGSizeMake(CGRectGetWidth(imageView.frame) + imageView.frame.origin.x + 15, 300)];
                        }
                    }
                });
                
                lastRight = CGRectGetWidth(imageView.frame) + imageView.frame.origin.x;
            }
        }else{
            //文件
            [self openApp];
        }

    }else{
        NSError *error;
        [self.extensionContext cancelRequestWithError:error];
    }
}

- (void)openApp
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *customURL = [NSString stringWithFormat:@"ShareDemo://shareExtension"] ;
        UIResponder* responder = self;
        while ((responder = [responder nextResponder]) != nil){
            if([responder respondsToSelector:@selector(openURL:)] == YES){
                //跳转后 防止操作此次文件夹 修改获取路径时间戳值
                self->currentTimeString = [NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970]];
                //
                [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:customURL]];
                //多次跳转会卡死 eg：微信的文档
                //[self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];

                break;
            }
        }
    });
    
}

//获取视频一桢截图
- (UIImage*)getScreenShotImageFromVideoPath:(NSURL*)fileURL
{
    UIImage *shotImage;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
}

- (void)cleanCaches
{
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GropuID];
    containerURL = [containerURL URLByAppendingPathComponent:@"Library/Caches"];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:containerURL.path]) {
        NSString *path = containerURL.path;
        [fileManger removeItemAtPath:path error:nil];
    }
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
