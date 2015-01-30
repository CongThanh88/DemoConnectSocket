//
//  ViewController.m
//  DemoSocket
//
//  Created by Cong Thanh on 1/29/15.
//  Copyright (c) 2015 com.softfront. All rights reserved.
//

#import "ViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "GCDAsyncSocket.h"

@interface ViewController ()

@end

@implementation ViewController
{
    GCDAsyncSocket *socket;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _lblMyIP.text = [self getIPAddress];
    socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSend:(id)sender {
    if (_txtComposeMessage.text) {
   
        NSString *sentString = [NSString stringWithFormat:@":Sent: %@",_txtComposeMessage.text];
        if (!_txtConversationView.text) {
            _txtConversationView.text = sentString;
        }else{
            _txtConversationView.text = [_txtConversationView.text stringByAppendingString:@"\n"];
            _txtConversationView.text = [_txtConversationView.text stringByAppendingString:sentString];
        }
    }
}

- (IBAction)btnConnect:(id)sender {
    if (_txtIpConnect.text) {
        NSError *error;
        if (![socket connectToHost:[NSString stringWithFormat:@"http://%@",_txtIpConnect.text] onPort:5000 error:&error]) {
            NSLog(@"connect error");
        }
    }
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [sock performBlock:^{
        if ([sock enableBackgroundingOnSocket])
            NSLog(@"Enabled backgrounding on socket");
        else
            NSLog(@"Enabling backgrounding failed!");
    }];
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"HTTP Response:\n%@", httpResponse);
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
}

@end
