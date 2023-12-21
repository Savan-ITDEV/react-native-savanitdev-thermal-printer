
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class POSWIFIManager;
typedef void(^POSWIFIBlock)(BOOL isConnect);
typedef void(^POSWIFICallBackBlock)(NSData *data);
enum {
    SocketOfflineByServer,// 服务器掉线，默认为0
    SocketOfflineByUser,  // 用户主动cut
};


@protocol POSWIFIManagerDelegate <NSObject>

/// Successfully connected to the host
/// @param managerWiFi connection object management
/// @param host ip address
/// @param port The port number
- (void)POSWIFIManager:(POSWIFIManager *)manager didConnectedToHost:(NSString *)host port:(UInt16)port;
/// Disconnect
/// @param manager WiFi connection object management
/// @param error error
- (void)POSWIFIManager:(POSWIFIManager *)manager willDisconnectWithError:(NSError *)error;
// Data written successfully
- (void)POSWIFIManager:(POSWIFIManager *)manager didWriteDataWithTag:(long)tag;
/// Receive the data returned by the printer
/// @param manager Management object
/// @param data Returned data
/// @param tag tag
- (void)POSWIFIManager:(POSWIFIManager *)manager didReadData:(NSData *)data tag:(long)tag;
// 断开连接
- (void)POSWIFIManagerDidDisconnected:(POSWIFIManager *)manager;
@end

@interface POSWIFIManager : NSObject
{
    int commandSendMode; //命令发送模式 0:立即发送 1：批量发送
}
#pragma mark - 基本属性
// 主机地址
@property (nonatomic,copy) NSString *hostStr;
// 端口
@property (nonatomic,assign) UInt16 port;
// 是否连接成功
@property (nonatomic,assign) BOOL connectOK;
// 是自动断开连接 还是 手动断开
@property (nonatomic,assign) BOOL isAutoDisconnect;

@property (nonatomic,weak) id<POSWIFIManagerDelegate> delegate;
// 连接回调
@property (nonatomic,copy) POSWIFIBlock callBack;
// 接收服务端返回的数据
@property (nonatomic,copy) POSWIFICallBackBlock callBackBlock;
@property (nonatomic,strong) NSMutableArray *commandBuffer;
//发送队列数组
#pragma mark - 基本方法
+ (instancetype)shareWifiManager;
//连接主机
-(void)POSConnectWithHost:(NSString *)hostStr port:(UInt16)port completion:(POSWIFIBlock)block;
// 断开主机
- (void)POSDisConnect;

//修改版本的推荐使用发送数据的两个方法
-(void)POSWriteCommandWithData:(NSData *)data;

-(void)POSWriteCommandWithData:(NSData *)data withResponse:(POSWIFICallBackBlock)block;

// 发送TSC完整指令
- (void)POSSendMSGWith:(NSString *)str;


- (void)POSSetCommandMode:(BOOL)Mode;


-(NSArray*)POSGetBuffer;
/*
 * 75.返回等待发送指令队列
 */

-(void)POSClearBuffer;
/*
 * 76.清空等待发送指令队列
 */

-(void)POSSendCommandBuffer;
/*
 * 77.发送指令队列
 */


@end
